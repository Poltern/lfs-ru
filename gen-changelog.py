#!/usr/bin/env python3

# LFS ChangeLog generator for trivial package addition, removal, and update

from subprocess import Popen, PIPE
from urllib.request import urlopen
from os import getenv

def get_entity(line):
    line = line[1:]
    if not line.startswith("<!ENTITY "):
        return None
    quote_pos = line.find(' "')
    key = line[len("<!ENTITY "):quote_pos]
    value = line[quote_pos + 2:]
    value = value[:value.find('"')]
    return (key, value)

def expand_entity(ent, key):
    value = ent[key]
    out = ""
    sub_ent = ""
    for c in value:
        if c == '&':
            sub_ent = c
        elif sub_ent:
            sub_ent += c
            if c == ';':
                out += expand_entity(ent, sub_ent[1:-1])
                sub_ent = ""
        else:
            out += c
    return out

git_diff = Popen(["git", "diff", "-U999999", "packages.ent"],
                 stdout = PIPE,
                 text = True)
stdout, _ = git_diff.communicate()

lines = stdout.rstrip().split("\n")
ent = [get_entity(i) for i in lines if i[0] != '-']
ent = dict(i for i in ent if i)

add = set()
rem = set()

for l in lines:
    if l[0] in '+-':
        pair = get_entity(l)
        if pair:
            key, _ = pair
            if key.endswith('-md5'):
                pkg = key[:-len('-md5')]
                if l[0] == '+':
                    add.add(pkg)
                else:
                    rem.add(pkg)

upd = add.intersection(rem)
add = add.symmetric_difference(upd)
rem = rem.symmetric_difference(upd)

ticket = {}
security = set()
url = 'https://wiki.linuxfromscratch.org/lfs/report/1?format=tab'
tsv = urlopen(url)
for i in tsv:
    fields = i.decode().split('\t')
    if len(fields) >= 2:
        pkg = fields[1].lower()
        pos = pkg.find(' ')
        if pos > 0:
            pkg = pkg[:pos]
        tic = fields[0]
        if len(fields) >= 3 and fields[2].startswith("high"):
            security.add(pkg)
        ticket[pkg] = tic

print("Plain Text:")
for (s, act) in [(upd, "Update to "), (add, "Add ")]:
    for i in s:
        pkgver = i + "-" + expand_entity(ent, i + "-version")
        out = act + pkgver
        if pkgver in ticket:
            out += ' (#' + ticket[pkgver] + ')'
        print("-", out)
for i in rem:
    print("-", "Remove", i)

print("---------------------")

print("XML")
name = getenv("USER")
for (s, act) in [(upd, "Update to "), (add, "Add ")]:
    for i in s:
        print('        <listitem>')
        pkgver = i + "-" + expand_entity(ent, i + "-version")
        out = '          <para>[' + name + '] - ' + act + pkgver
        if pkgver in security:
            out += " (security fix)"
        out += "."
        if pkgver in ticket:
            out += "  Fixes\n          "
            out += "<ulink url='&lfs-ticket-root;" + ticket[pkgver] + "'>#"
            out += ticket[pkgver] + "</ulink>."
        out += "</para>"
        print(out)
        print('        </listitem>')

#!/usr/bin/env python3

# SPDX-License-Identifier: MIT
# Copyright 2023 The LFS Editors

# Stupid script to render "mconf"-style kernel configuration
# Usage: kernel-config.py [path to kernel tree] [needed config].toml
# The toml file should be like:
#   for bool and tristate:
#     EXT4="*"
#     DRM="*M"
#     EXPERT=" "
#     DRM_I915="*M"
#   for choice:
#     HIGHMEM64G="X"
#   an entry with comment:
#     DRM_I915 = { value = " *M", comment = "for i915, crocus, or iris" }

choice_bit = 1 << 30
ind0 = 0
ind1 = 0
menu_id = 1
stack = []
if_stack = []

expand_var_mp = { 'SRCARCH': 'x86' }
main_dep = {}

def expand_var(s):
    for k in expand_var_mp:
        s = s.replace('$(' + k + ')', expand_var_mp[k])
    return s

def pop_stack(cond):
    global ind0, ind1, stack
    assert(cond(stack[-1][0]))
    s, i0, i1, _ = stack[-1]
    stack = stack[:-1]
    ind0 -= i0
    ind1 -= i1

def pop_stack_while(cond):
    while stack and cond(stack[-1][0]):
        pop_stack(cond)

def cur_menu():
    global stack
    return stack[-1][3] if stack else 0

def cur_if():
    global if_stack
    return if_stack[-1][:] if if_stack else []

def clean_dep(d):
    d = d.strip()
    if d.endswith('=y') or d.endswith('=M'):
        d = d[:-2]
    elif d.endswith(' != ""'):
        d = d[:-6]
    return d

def parse_config(buf):
    global ind0, ind1, stack, menu_id
    is_choice = buf[0].strip() == 'choice'
    is_menu = buf[0].startswith('menu') or is_choice
    is_nonconfig_menu = buf[0].startswith('menu ') or is_choice
    key = None if is_nonconfig_menu else buf[0].split()[1].strip()
    title = buf[0][len('menu '):] if is_nonconfig_menu else None
    deps = ['menu'] + cur_if()
    klass = None

    for line in buf[1:]:
        line = line.strip()
        if line.startswith('depends on '):
            new_deps = line[len('depends on '):].split('&&')
            deps += [clean_dep(x) for x in new_deps]
        elif line.startswith('prompt'):
            title = line[len('prompt '):]
        else:
            for prefix in ['tristate', 'bool', 'string']:
                if line.startswith(prefix + ' '):
                    title = line[len(prefix) + 1:]
                    klass = prefix
                elif line == prefix:
                    klass = prefix
                elif line.startswith('def_' + prefix + ' '):
                    klass = prefix
                else:
                    continue

                if '"' in line:
                    tail = line[line.rfind('"') + 1:].strip()
                    if tail[:3] == 'if ':
                        deps += [clean_dep(x) for x in tail[3:].split('&&')]

    pop_stack_while(lambda x: x not in deps)

    menu_id += is_menu
    internal_key = key or menu_id
    if stack:
        fa = stack[-1][0]
        if fa == 'menu':
            fa = cur_menu() & ~choice_bit
        main_dep[internal_key] = fa

    val = known_config.get(key)
    comment = None
    forced = None

    if type(val) == dict:
        comment = val.get('comment')
        forced = val.get('forced')
        val = val['value']

    klass = klass or 'string'
    if title:
        title = title.strip().lstrip('"')
        title = title[:title.find('"')]

    if not val:
        pass
    elif klass == 'string':
        val = '(' + val + ')'
    else:
        assert((val == 'X') == bool(cur_menu() & choice_bit))
        if (val == 'X'):
            val = '(X)'
        else:
            val = list(val)
            val.sort()
            for c in val:
                if c not in 'M* ' or (c == 'M' and klass != 'tristate'):
                    raise Exception('unknown setting %s for %s' % (c, key))
            bracket = None
            if klass == 'tristate' and forced != '*' :
                bracket = '{}' if forced else '<>'
            else:
                bracket = '--' if forced else '[]'

            val = bracket[0] + '/'.join(val) + bracket[1]

    arrow = ' --->' if is_menu else ''
    r = [ind0, val, ind1, title, arrow, internal_key, cur_menu(), comment]

    # Don't indent for untitled (internal) entries
    x = 2 if title else 0

    key = key or 'menu'
    menu = (menu_id if is_menu else cur_menu())
    menu |= choice_bit if is_choice else 0
    stack_ent = (key, 2, 0, menu) if is_menu else (key, 0, x, menu)
    ind0 += stack_ent[1]
    ind1 += stack_ent[2]
    stack += [stack_ent]

    return r

def load_kconfig(file):
    global ind0, ind1, stack, path, menu_id, if_stack
    r = []
    config_buf = []
    with open(path + file) as f:
        for line in f:
            if config_buf:
                if not (line.startswith('\t') or line.startswith('    ')):
                    r += [parse_config(config_buf)]
                    config_buf = []
                else:
                    config_buf += [line]
                    continue
            if line.startswith('source') or line.startswith('\tsource'):
                sub = expand_var(line.strip().split()[1].strip('"'))
                r += load_kconfig(sub)
            elif line.startswith('config') or line.startswith('menu'):
                config_buf = [line]
            elif line.startswith('choice'):
                config_buf = [line]
            elif line.startswith('endmenu') or line.startswith('endchoice'):
                pop_stack_while(lambda x: x != 'menu')
                pop_stack(lambda x: x == 'menu')
            elif line.startswith('if '):
                line = line[3:]
                top = cur_if()
                top += [x.strip() for x in line.split("&&")]
                if_stack += [top]
            elif line.startswith('endif'):
                if_stack = if_stack[:-1]

    if config_buf:
        r += [parse_config(config_buf)]

    return r

known_config = {}

def escape(x):
    return x.replace('<', '&lt;').replace('>', '&gt;')

from sys import argv
import tomllib

path = argv[1]
if path[-1] != '/':
    path += '/'
with open(argv[2], 'rb') as f:
    known_config = tomllib.load(f)

r = load_kconfig('Kconfig')

# Refcount all menus

index_ikey = {}
for i in reversed(range(len(r))):
    index_ikey[r[i][5]] = i

for i in reversed(range(len(r))):
    if r[i][1] != None:
        key = r[i][5]
        fa = main_dep.get(key)
        if not fa:
            continue
        j = index_ikey[fa]
        if type(fa) == int or not r[j][3]:
            # The main dependency is a menu or untitled magic entry,
            # just mark it used
            r[j][1] = ''
        if r[j][1] is None:
            raise Exception('[%s] needs unselected [%s]' % (key, fa))

r = [i for i in r if i[1] != None and i[3]]

# Now we are going to pretty-print r

## Calculate the maximum value length for each menu
max_val_len = {}
for _, val, _, _, _, _, menu, _ in r:
    x = max_val_len.get(menu) or 0
    max_val_len[menu] = max(x, len(val))

## Output

max_line = 80
buf = []

done = [x[5] for x in r] + ['revision']
for i in known_config:
    if i not in done:
        raise Exception("%s seems not exist" % i)

sep = known_config.get('separate_toplevel_menu')

for i0, val, i1, title, arrow, key, menu, comment in r:
    rem = max_line
    is_choice = (val == '(X)')

    if val:
        val += (max_val_len[menu] - len(val)) * ' '

    rem -= i0 + i1 + bool(val) + len(val)
    line = i0 * ' ' + escape(val) + (i1 + bool(val)) * ' '

    rem -= len(arrow)

    if len(title) > rem:
        title = title[:rem - 3] + '...'

    b = title
    if not is_choice:
        b = b.lstrip('YyMmNnHh.' + "".join(map(str, range(10))))
    a = title[:len(title) - len(b)]
    b0 = "<emphasis role='blue'>" + escape(b[0]) + "</emphasis>"
    line += escape(a) + b0 + escape(b[1:]) + escape(arrow)

    rem -= len(title)

    key = ' [' + key + ']' if type(key) == str else ''

    if len(key) <= rem:
        line += (rem - len(key)) * ' ' + key
    else:
        key = '... ' + key
        line += '\n' + ' ' * (max_line - len(key)) + key
    if type(comment) == str:
        comment = [comment]
    if comment:
        comment = '\n'.join([' ' * i0 + '# ' + line for line in comment])
        buf += [escape(comment) + ':']

    if not menu and buf:
        buf += ['']

    buf += [line.rstrip()]

from jinja2 import Template

t = Template('''<?xml version="1.0" encoding="ISO-8859-1"?>
<!DOCTYPE note PUBLIC "-//OASIS//DTD DocBook XML V4.5//EN"
  "http://www.oasis-open.org/docbook/xml/4.5/docbookx.dtd">
<!-- Automatically generated by kernel-config.py
     DO NOT EDIT! -->
<screen role="nodump"{{ rev }}>{{ '\n'.join(buf) }}</screen>''')

rev = known_config.get('revision')
rev = ' revision="%s"' % rev if rev else ''
print(t.render(rev = rev, buf = buf))

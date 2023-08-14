#!/usr/bin/env python3

def kernel_version(path):
    version = None
    patchlevel = None
    sublevel = None

    with open(path + 'Makefile') as f:
        for line in f:
            if line.startswith('VERSION ='):
                version = line[len('VERSION ='):].strip()
            elif line.startswith('PATCHLEVEL ='):
                patchlevel = line[len('PATCHLEVEL ='):].strip()
            elif line.startswith('SUBLEVEL ='):
                sublevel = line[len('SUBLEVEL ='):].strip()

    assert(version and patchlevel and sublevel)
    return '.'.join([version, patchlevel, sublevel])

if __name__ == '__main__':
    from sys import argv

    path = argv[1]
    if path[:-1] != '/':
        path += '/'

    print(kernel_version(path))

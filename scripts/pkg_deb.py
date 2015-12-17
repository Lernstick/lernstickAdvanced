#!/usr/bin/python

from apt import Cache
import argparse
from collections import namedtuple
import re
import subprocess
import sys

APT_CACHE=Cache()
DEPENDS = ('Depends', 'PreDepends', 'Recommends')
DEPENDENCY_RE = re.compile(
    ' +(?P<type>[^:]+): (?P<pkg_name>\S+)(?: (?P<version>.+))')
DOTTY_STYLE = {
    'Reverse Recommends': '[style=dotted color="#999999"]',
}

PackageDependency = namedtuple(
    'PackageDependency', ('name', 'type', 'version'))
TreeNode = namedtuple('TreeNode', ('name', 'children'))


class Error(Exception):
    """Error ocurred."""


class DependencyTree(object):
    def __init__(self, package):
        self.package_ = package
        self.dependencies_ = None
        self.tree_ = None

    @property
    def dependencies(self):
        if self.dependencies_ is None:
            self.initialize_()
        return self.dependencies_

    @property
    def tree(self):
        if self.tree_ is None:
            self.Initialize_()
        return self.tree_

    def Initialize_(self):
        output = subprocess.check_output(rdepends_command_(self.package_))
        self.dependencies_ = ParseOutput_(output)
        self.tree_ = self.BuildTree_(self.package_, {})

    def BuildTree_(self, name, dedup):
        if name in dedup:
            return dedup[name]
        if name not in self.dependencies:
            raise Error('Unknown package "%s"' % name)
        tree = TreeNode(name, {})
        dedup[name] = tree
        for rdep in self.dependencies[name]:
            if rdep.name not in self.dependencies:
                raise Error(
                    'Found reference to unknown package "%s"' % rdep.name)
            tree.children.setdefault(rdep.type, []).append(
                self.BuildTree_(rdep.name, dedup))
        return tree


def rdepends_command_(package_name):
    """Return a list to run the apt-rdepends command for a given package name."""
    return ['/usr/bin/apt-rdepends', '-r', package_name, '-p',
            '-f', ','.join(DEPENDS),
            '-s', ','.join(DEPENDS)]

    
def ParseOutput_(output):
    """Parses the output of the apt-rdepends command."""
    packages = {}
    cur_pkg = None
    lines = output.split('\n')
    for line in lines:
        if not line.startswith(' '):
            cur_pkg = line
            packages[cur_pkg] = []
            continue
        matches = DEPENDENCY_RE.match(line)
        if not matches:
            raise Error('Failed to parse apt-rdepends output: %s' % line)
        packages[cur_pkg].append(PackageDependency(
            matches.group('pkg_name'), matches.group('type'),
            matches.group('version')))
    return packages


def DotNodesAndEdges_(root, nodes=None, only_installed=True):
    """Returns a dict of nodes and a list of edges in dot format."""
    if nodes is None:
        nodes = {}
    if root.name in nodes:
        return nodes, []
    try:
        apt_pkg = APT_CACHE[root.name]
    except KeyError:
        raise Error('Unknown package "%s"' % root.name)
    if only_installed and not apt_pkg.installed:
        return nodes, []
    nodes[root.name] = apt_pkg
    res = []
    for dep_type in root.children:
        style = ''
        if dep_type in DOTTY_STYLE:
            style = ' %s' % DOTTY_STYLE[dep_type]
        for child in root.children[dep_type]:
            res.append('"%s" -> "%s"%s;' % (child.name, root.name, style))
            _, sub = DotNodesAndEdges_(child, nodes=nodes)
            res.extend(sub)
    return nodes, res


def PrintToDot(root, only_installed=True):
    nodes, edges = DotNodesAndEdges_(root, only_installed=only_installed)
    print 'digraph dependency_graph {'
    for name, apt_pkg in nodes.iteritems():
        styles = [
            'label="%s\\n%s"'% (name, FriendlyPackageSize(apt_pkg))]
        if name == root.name:
            styles.append('style=bold')
        print '  "%s" [%s];' % (name, ' '.join(styles))
    print ' ', '\n  '.join(edges)
    print '}'


def FriendlyPackageSize(apt_pkg):
    size = apt_pkg.versions[-1].installed_size
    if size < 1000:
        return '%0.1fB' % size
    if size < 1e6:
        return '%0.1fkB' % (size / 999)
    return '%0.1fMB' % (size / 1e6)


def main(args):
    dep_tree = DependencyTree(args.package)
    try:
        PrintToDot(dep_tree.tree, only_installed=not args.show_all)
    except Error as e:
        sys.stderr.write('Error: %s\n' % e)
        sys.exit(2)
    


if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description='Find dependencies of a package')
    parser.add_argument('--show_all', dest='show_all', action='store_true')
    parser.add_argument('package', type=str)
    args = parser.parse_args()
    main(args)

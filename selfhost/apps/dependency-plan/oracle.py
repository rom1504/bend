#!/usr/bin/env python3
"""Independent dependency planner oracle, deterministic generator, runner cases."""
from __future__ import annotations
import argparse
import json
from pathlib import Path
import random
import re
import sys

HERE = Path(__file__).resolve().parent
NAME = re.compile(r'[A-Za-z0-9_./-]{1,128}\Z')
MAX_BYTES, MAX_NODES, MAX_EDGES, MAX_ROOTS = 1048576, 4096, 32768, 128

class Problem(Exception):
    pass

def solve(text: str, roots: list[str]) -> str:
    """Use dictionary adjacency and recursive tri-color DFS, not Bend's work stack."""
    if len(roots) > MAX_ROOTS:
        return 'error root-limit\n'
    for name in roots:
        if not NAME.fullmatch(name):
            return f'error invalid-root {name}\n'
    graph: dict[str, list[str]] = {}
    total_edges = 0
    for line_no, line in enumerate(text.split('\n'), 1):
        content = line.partition('#')[0].strip(' \t\r')
        words = re.split(r'[ \t\r]+', content) if content else []
        if not words:
            continue
        for word in words:
            if not NAME.fullmatch(word):
                return f'error invalid-name {line_no} {word}\n'
        name, deps = words[0], words[1:]
        if name in graph:
            return f'error duplicate {line_no} {name}\n'
        if len(graph) >= MAX_NODES or total_edges + len(deps) > MAX_EDGES:
            return 'error graph-limit\n'
        graph[name] = deps
        total_edges += len(deps)
    color: dict[str, int] = {}
    active: list[str] = []
    order: list[str] = []
    reached_edges = 0
    sys.setrecursionlimit(max(sys.getrecursionlimit(), 2 * MAX_NODES + 100))
    def visit(name: str) -> None:
        nonlocal reached_edges
        if color.get(name) == 2:
            return
        if color.get(name) == 1:
            raise Problem(f'error cycle {name}\npath {" ".join(active + [name])}\n')
        if name not in graph:
            raise Problem(f'error missing {name}\npath {" ".join(active + [name])}\n')
        color[name] = 1
        active.append(name)
        reached_edges += len(graph[name])
        for dep in graph[name]:
            visit(dep)
        active.pop()
        color[name] = 2
        order.append(name)
    try:
        for root in roots:
            visit(root)
    except Problem as error:
        return str(error)
    return (f'plan-v1\nroots {" ".join(roots)}\norder {" ".join(order)}\n'
            f'reachable {len(order)}\nedges {reached_edges}\ndeclared {len(graph)}\n')

def solve_file(path: Path, roots: list[str]) -> str:
    try:
        data = path.read_bytes()
    except OSError:
        return 'error file-open\n'
    if len(data) > MAX_BYTES:
        return 'error input-limit\n'
    try:
        text = data.decode('utf-8')
    except UnicodeDecodeError:
        return 'error file-read\n'
    return solve(text, roots)

def generate(nodes: int, seed: int = 17, fanout: int = 5, shape: str = 'dag') -> tuple[str, list[str]]:
    """Return a reproducible graph and useful roots; no compiler is invoked."""
    if not 1 <= nodes <= MAX_NODES or not 1 <= fanout <= 16:
        raise ValueError('nodes must be 1..4096 and fanout 1..16')
    rng = random.Random(seed)
    names = [f'n{i:04d}' for i in range(nodes)]
    rows: list[str] = [f'# dependency-plan generated shape={shape} nodes={nodes} seed={seed}']
    for i, name in enumerate(names):
        if shape == 'tree':
            deps = [names[j] for j in (2 * i + 1, 2 * i + 2) if j < nodes]
        elif shape == 'chain':
            deps = [names[i - 1]] if i else []
        elif shape == 'dag':
            # A backbone makes every node reachable; extra older prerequisites
            # introduce irregular fanout and heavily shared subgraphs.
            earlier = list(range(max(0, i - 1)))
            rng.shuffle(earlier)
            deps = ([names[i - 1]] if i else []) + [names[j] for j in earlier[:min(fanout - 1, len(earlier))]]
        else:
            raise ValueError('shape must be dag, tree or chain')
        rows.append(' '.join([name, *deps]))
    return '\n'.join(rows) + '\n', [names[0] if shape == 'tree' else names[-1]]

def cases(out_dir: Path, depth: str = 'smoke', selected=None) -> list[dict]:
    """Shared runner interface. Each result includes complete newline-exact output."""
    if depth not in ('smoke', 'survey'):
        raise ValueError('depth must be smoke or survey')
    out_dir = Path(out_dir).resolve()
    out_dir.mkdir(parents=True, exist_ok=True)
    result: list[dict] = []
    def add(case_id: str, text: str, roots: list[str], category: str) -> None:
        path = out_dir / (case_id + '.graph')
        path.write_bytes(text.encode('utf-8'))
        result.append(dict(id=case_id, argv=['--graph', str(path), *roots],
            expected=solve_file(path, roots), input_files=[str(path)],
            category=category, declared_rows=sum(bool(x.partition('#')[0].strip()) for x in text.split('\n'))))
    shared = (HERE / 'fixtures/shared.graph').read_text()
    add('shared-app', shared, ['app'], 'valid-shared')
    add('shared-multiple-roots', shared, ['app', 'tests', 'app'], 'valid-shared')
    add('cycle', (HERE / 'fixtures/cycle.graph').read_text(), ['app'], 'invalid-cycle')
    add('missing', (HERE / 'fixtures/missing.graph').read_text(), ['app'], 'invalid-missing')
    add('duplicate', 'app lib\nlib\napp\n', ['app'], 'invalid-declaration')
    add('invalid-name', 'app bad:name\n', ['app'], 'invalid-name')
    add('empty-root', 'app\n', [''], 'invalid-root')
    add('unreachable-cycle', 'app core\ncore\nx y\ny x\n', ['app'], 'valid-unreachable')
    add('crlf-duplicates', '# comment\r\napp\tcore core # repeated edge\r\ncore\r\n', ['app', 'core'], 'valid-format')
    if depth == 'survey':
        add('missing-root', 'app\n', ['unknown'], 'invalid-missing')
        add('self-cycle', 'app app\n', ['app'], 'invalid-cycle')
        add('empty-graph', '# no declarations\n', ['app'], 'invalid-missing')
        add('name-limit', 'x' * 129 + '\n', ['app'], 'invalid-name')
        add('root-limit', 'app\n', ['app'] * 129, 'invalid-limit')
        add('input-limit', '#' * (MAX_BYTES + 1), ['app'], 'invalid-limit')
        for size, shape, fanout in [(100, 'dag', 4), (350, 'dag', 6), (800, 'dag', 5), (511, 'tree', 2), (1000, 'chain', 1)]:
            text, roots = generate(size, 31 + size, fanout, shape)
            add(f'{shape}-{size}', text, roots, 'generated')
    result.append(dict(id='usage', argv=[], expected='error usage: --graph FILE ROOT...\n', input_files=[], category='invalid-usage'))
    return [row for row in result if selected is None or row['id'] in selected]

def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    sub = parser.add_subparsers(dest='command', required=True)
    plan = sub.add_parser('plan')
    plan.add_argument('--graph', type=Path, required=True)
    plan.add_argument('roots', nargs='+')
    gen = sub.add_parser('generate')
    gen.add_argument('--output', type=Path, required=True)
    gen.add_argument('--nodes', type=int, default=350)
    gen.add_argument('--seed', type=int, default=17)
    gen.add_argument('--fanout', type=int, default=5)
    gen.add_argument('--shape', choices=['dag', 'tree', 'chain'], default='dag')
    batch = sub.add_parser('cases')
    batch.add_argument('--out', type=Path, required=True)
    batch.add_argument('--depth', choices=['smoke', 'survey'], default='smoke')
    args = parser.parse_args()
    if args.command == 'plan':
        sys.stdout.write(solve_file(args.graph, args.roots))
    elif args.command == 'generate':
        text, roots = generate(args.nodes, args.seed, args.fanout, args.shape)
        args.output.parent.mkdir(parents=True, exist_ok=True)
        args.output.write_text(text)
        print('roots ' + ' '.join(roots))
    else:
        print(json.dumps(cases(args.out, args.depth), indent=2))

if __name__ == '__main__':
    main()

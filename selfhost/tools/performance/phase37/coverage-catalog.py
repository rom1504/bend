#!/usr/bin/env python3
"""Freeze additive coverage selection before compiler optimization.

The initial catalog has two explicitly pending ray oracles. Acquire only those
two checked pinned-TypeScript points, run reference-oracles.mjs, then publish a
new catalog with their exact differential results. Never use the draft for timing.
"""
import argparse
import copy
import hashlib
import importlib.util
import json
from pathlib import Path

HERE = Path(__file__).resolve().parent
PROGRAMS = HERE.parent / 'programs'
PIN = '018751270e800bc222a93dad7f257083ee53a5f7'

GRID = '''
# Phase37: original source above unchanged; centers across the complete viewport.
def coverage.grid.loop(n: Nat, +i: U32, +mask: U32, +step: U32, +d: Nat,
                       +tn: Nat, acc: U32) -> U32:
  match n:
    case 0n:
      acc
    case 1n+p:
      x = U32.add(U32.mul(U32.and(i, mask), step), U32.div(step, 2))
      y = U32.add(U32.mul(U32.shrn(i, d), step), U32.div(step, 2))
      +at = U32.add(U32.mul(y, 4096), x)
      v = pix(at, tn)
      coverage.grid.loop(p, U32.inc(i), mask, step, d, tn,
        U32.add(acc, U32.mul(v, U32.inc(U32.mul(at, 2654435761)))))

def coverage.grid(+depth: U32, iterations: U32) -> U32:
  +d = U32.to_nat(depth)
  +side = U32.shln(1, d)
  coverage.grid.loop(U32.to_nat(U32.mul(side, side)), 0, U32.sub(side, 1),
    U32.div(4096, side), d, U32.to_nat(iterations), 0)
'''

RAY = '''
# Phase37: original source above unchanged; every sampled position traces rays.
def coverage.active.loop(n: Nat, +at: U32, acc: U32) -> U32:
  match n:
    case 0n:
      acc
    case 1n+p:
      v = pixel(U32.mod(at, 80), U32.div(at, 80), U32.to_f32(40), U32.to_f32(32))
      coverage.active.loop(p, U32.inc(at), U32.add(U32.mul(acc, 16777619), v))

def coverage.active(count: U32, first: U32) -> U32:
  coverage.active.loop(U32.to_nat(count), first, 0)
'''


def identity(file):
    data = Path(file).read_bytes()
    return dict(sha256=hashlib.sha256(data).hexdigest(), bytes=len(data))


def put(file, data):
    file.parent.mkdir(parents=True, exist_ok=True)
    if file.exists():
        if file.read_bytes() != data:
            raise ValueError('Refusing to replace changed frozen source: ' + str(file))
    else:
        file.write_bytes(data)


def fold(n, seed):
    words, accumulator = [seed] * 128, 0
    for i in range(n):
        accumulator = (accumulator + words[i % 128]) & 0xffffffff
        words[i % 128] = accumulator ^ i
    return accumulator


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--applications', type=Path, default=HERE / 'fixtures-new/points-v1.json')
    parser.add_argument('--ray-oracles', type=Path)
    parser.add_argument('--out', type=Path, required=True)
    args = parser.parse_args()
    output = args.out.resolve()
    if output.parent != HERE or output.exists():
        parser.error('--out must be a new file directly inside phase37/')
    spec = importlib.util.spec_from_file_location('phase37_integer_oracles', HERE / 'algorithm-oracles.py')
    oracle = importlib.util.module_from_spec(spec); spec.loader.exec_module(oracle)
    historical_checks = oracle.verify_historical()
    assert fold(4096, 17) == 2339999928
    previous = json.loads((PROGRAMS / 'catalog.json').read_text())
    assert previous['upstreamCommit'] == PIN and len(previous['cases']) == 15
    cases = copy.deepcopy(previous['cases'])
    originals = {case['id']: copy.deepcopy(case) for case in cases}
    for case in cases:
        source = PROGRAMS / case['source']['path']
        assert identity(source) == {k:case['source'][k] for k in ['sha256', 'bytes']}
        destination = HERE / 'fixtures-historical' / source.name
        put(destination, source.read_bytes())
        case['source']['path'] = str(destination.relative_to(HERE))
        case['partition'] = 'historical'
        case['family'] = case['id']
    originals = {case['id']: copy.deepcopy(case) for case in cases}
    variants = []
    def add(parent, identifier, args_, expected, coverage, scope, export='bench', source=None,
            oracle_text='Independent Python reference, cross-checked against the historical pinned upstream golden.'):
        case = copy.deepcopy(originals[parent])
        case.update(id=identifier, category='coverage', partition='variation', family=parent,
                    description=case['description'] + '; additional fixed input', scope=scope,
                    coverage=coverage, oracle=oracle_text, sets=['coverage-variation'])
        if source is not None:
            case['source'] = source
        case['point'] = dict(exportName=export, args=args_, expected=expected)
        variants.append(case)
        return case
    for parent, function, points, coverage, scope in [
        ('editdist', oracle.editdist, [(0, 17), (3, 123)],
         ['Array', 'dynamic-programming', 'changed-seed', 'batch-scaling'],
         '2^depth complete 256×256 pairs, starting at the selected index; input generation and checksum included'),
        ('lexer', oracle.lexer, [(6, 17), (10, 123)],
         ['String', 'sum-types', 'state-machine', 'changed-seed', 'batch-scaling'],
         '2^depth generated lines with changed first index; original short ASCII template remains'),
        ('tree-bitonic', oracle.bitonic, [(6, 17), (9, 123)],
         ['balanced-tree', 'tree-to-tree', 'sorting', 'changed-seed', 'depth-scaling'],
         '2^depth leaves over a seed-dependent key interval; full sort and order-sensitive verification'),
        ('symreg', oracle.symreg, [(4, 17), (7, 123)],
         ['AST', 'producer-consumer', 'shared-tree', 'changed-seed', 'population-scaling'],
         '2^depth population with changed initial seed; AST depth5,32 mutation rounds and16 data points remain fixed'),
    ]:
        for depth, seed in points:
            add(parent, f'variation-{parent}-{depth}-{seed}', [depth, seed], function(depth, seed), coverage, scope)
    for count, seed in [(128, 0), (8192, 123)]:
        add('local-fold', f'variation-local-fold-{count}-{seed}', [count, seed], fold(count, seed),
            ['Array', 'mutable-state', 'wrapping-index', 'changed-seed', 'loop-scaling'],
            '128-slot array; size read/accumulate/write steps, cyclic indexing and final scalar checksum',
            oracle_text='Independent Python128-slot cyclic-array reference; historical4096/17 golden cross-check.')
    for parent, name, wrapper in [('mandelbrot', 'mandelbrot-grid', GRID), ('raytrace', 'raytrace-active', RAY)]:
        original = originals[parent]['source']
        source = HERE / original['path']
        target = HERE / 'fixtures-variants' / (name + '.bend')
        put(target, source.read_bytes() + wrapper.encode())
        derived = dict(path=str(target.relative_to(HERE)), **identity(target), provenance=dict(
            kind='unchanged-historical-fixture-with-coverage-wrapper', parent=original,
            wrapper=wrapper, record='design/phase37/coverage.md'))
        if parent == 'mandelbrot':
            for depth, iterations in [(4, 7), (5, 31)]:
                add(parent, f'variation-mandelbrot-grid-{depth}-{iterations}', [depth, iterations],
                    oracle.mandelbrot_grid(depth, iterations),
                    ['U32', 'fixed-point', 'viewport-distribution', 'iteration-scaling'],
                    f'{1 << depth}×{1 << depth} center samples spread across the complete4096×4096 viewport; '
                    'original pix function and wrapping position-weighted sum; no histogram/recolor passes',
                    export='coverage.grid', source=derived,
                    oracle_text='Independent Python two’s-complement fixed-point pixel calculation and viewport grid; exact wrapping checksum.')
        else:
            for count, first in [(64, 2440), (256, 2240)]:
                case = add(parent, f'variation-ray-active-{count}-{first}', [count, first], None,
                    ['F32', 'geometry', 'tagged-result', 'active-rays', 'position-distribution'],
                    f'{count} consecutive active pixels in the original80×64 small viewport, starting at linear index{first}; '
                    'four subrays each, original geometry/shadow/bounce code, ordered output digest, no inactive probes',
                    export='coverage.active', source=derived,
                    oracle_text='Frozen checked pinned-TypeScript differential output; not an independent F32 reference.')
                case['oracleStatus'] = 'pending-pinned-reference'
    ray_receipt = None
    if args.ray_oracles:
        ray = json.loads(args.ray_oracles.read_text())
        assert ray['kind'] == 'phase37-pinned-reference-oracles' and ray['complete'] and ray['upstreamCommit'] == PIN
        assert ray['compiler']['kind'] == 'checked-pinned-typescript' and ray['compiler']['upstreamCommit'] == PIN
        ray_receipt = dict(path=str(args.ray_oracles.resolve()), **identity(args.ray_oracles))
        observed = {row['id']:row for row in ray['observations']}
        for case in variants:
            if case.get('oracleStatus') != 'pending-pinned-reference': continue
            row = observed.pop(case['id'])
            assert row['sourceSha256'] == case['source']['sha256']
            assert row['exportName'] == case['point']['exportName'] and row['args'] == case['point']['args']
            case['point']['expected'] = row['expected']
            case['oracleStatus'] = 'frozen-pinned-reference'
            case['oracleReceipt'] = ray_receipt
        assert not observed
    application_file = args.applications.resolve()
    applications = json.loads(application_file.read_text())
    assert applications['upstreamCommit'] == PIN and len(applications['cases']) == 16
    for case in applications['cases']:
        source = HERE / case['source']['path']
        assert source.resolve().is_relative_to(HERE) and not source.is_symlink()
        assert identity(source) == {k:case['source'][k] for k in ['sha256', 'bytes']}
    cases.extend(variants); cases.extend(applications['cases'])
    sets = copy.deepcopy(previous['sets'])
    sets['historical'] = sets['full'][:]
    sets['coverage-variation'] = [c['id'] for c in variants]
    sets['coverage-development'] = [c['id'] for c in applications['cases'] if c['partition'] == 'development']
    sets['coverage-holdout'] = [c['id'] for c in applications['cases'] if c['partition'] == 'holdout']
    sets['coverage'] = sets['coverage-variation'] + sets['coverage-development'] + sets['coverage-holdout']
    sets['full'] = sets['historical'] + sets['coverage']
    # Broad is a practical10point application development group. Select other
    # named groups through --cases until CLI named-set support is generalized.
    sets['broad'] = sets['coverage-development']
    result = dict(kind='bend-program-catalog', schemaVersion=1, upstreamCommit=PIN,
        scope='Sequential generated JavaScript; additive coverage45points, not full language/application coverage. '
              'Historical15plus14algorithm/input variants plus16points over8new families. '
              'Three new families/six points held out from optimization tuning.',
        status='frozen' if ray_receipt else 'draft-awaiting-two-pinned-ray-oracles',
        selection=dict(historicalCatalog=dict(path=str(PROGRAMS / 'catalog.json'), **identity(PROGRAMS / 'catalog.json')),
            producer=identity(Path(__file__)), integerOracle=identity(HERE / 'algorithm-oracles.py'),
            historicalOracleChecks=historical_checks, applicationProposal=dict(path=str(application_file), **identity(application_file)),
            rayOracleReceipt=ray_receipt,
            heldoutPolicy='BST,expression,record-aggregation families withheld from profiles/tuning until final candidate freeze.'),
        sets=sets, cases=cases)
    assert len(cases) == 45 and len({c['id'] for c in cases}) == 45
    output.write_text(json.dumps(result, indent=2, ensure_ascii=False) + '\n')
    print(json.dumps(dict(complete=True, status=result['status'], cases=len(cases),
        sourceFiles=len({c['source']['path'] for c in cases}), catalog=str(output),
        rayCases=[c['id'] for c in variants if c.get('oracleStatus') == 'pending-pinned-reference'])))


if __name__ == '__main__':
    main()

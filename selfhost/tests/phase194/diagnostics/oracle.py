#!/usr/bin/env python3
"""Independent finite mathematical results; no Bend/compiler execution or model.

--write freezes literal outputs and catalog for already-authored Bend fixtures.
Default checks all pins and literal oracle outputs without modifying anything.
"""
import argparse
import functools
import hashlib
import json
import operator
from pathlib import Path

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[3]
MASK = (1 << 32) - 1
SIZES = (32, 1024)
SEED = 17
VARIANTS = {
    'value-identity': ('rebind', 'helpers'),
    'register-pressure': ('few', 'many'),
    'f32-region': ('closed', 'mixed'),
    'predicate-flow': ('branch', 'mask'),
    'product-ownership': ('unique', 'shared'),
    'memory-dependence': ('sequential', 'dependent'),
}
LINEAGE = {
    'value-identity': 'coverage-expression-32.bend',
    'register-pressure': 'scalar-region-8192.bend',
    'f32-region': 'coverage-numeric-recurrence-256.bend',
    'predicate-flow': 'scalar-region-8192.bend',
    'product-ownership': 'coverage-record-aggregation-64.bend',
    'memory-dependence': 'local-fold.bend',
}
NOTES = {
    'value-identity': 'Same operations/results; lexical rebindings versus helper arguments. Observe saved old value after subsequent writes. Helpers may inline.',
    'register-pressure': 'Same twelve multiply/add terms and XOR reduction order; calculate-and-reduce versus all terms live before reduction. Final machine schedules may converge.',
    'f32-region': 'Same exact binary-fraction recurrence/result in declared range. Mixed adds per-step F32/U32 roundtrip and scaling work; this is not equal instruction work.',
    'predicate-flow': 'Same selected result. Mask computes both alternatives plus mask operations; branch computes only selected arm. Extra work is intentional.',
    'product-ownership': 'Same one product construction and scalar result. Shared uses two observations of one borrowed product; unique destructures once. Physical allocation/sharing may disappear.',
    'memory-dependence': 'Same 256-word initialization, loaded values, read count and checksum. Sequential advances an independent index; dependent uses loaded successor as next index. Cache-resident, not a DRAM claim.',
}


def answer(family, count, seed):
    if family == 'f32-region':
        # x0=seed/4; (x+1/4)*2-x = x+1/2. All values at these
        # points are exactly representable binary fractions; result=4*xn.
        return seed + 2 * count
    if family == 'memory-dependence':
        # Array[i]=(i+1) mod256. Both traverse the same shifted cycle.
        cycles, rest = divmod(count, 256)
        return (cycles * (255 * 256 // 2) +
                sum((seed + j + 1) % 256 for j in range(rest))) & MASK
    value = seed
    for index in range(count):
        if family == 'value-identity':
            value = ((((value + index) & MASK) ^ 2654435769) * 1664525 + value) & MASK
        elif family == 'register-pressure':
            terms = [((value + k) * (2 * k + 1)) & MASK for k in range(1, 13)]
            value = functools.reduce(operator.xor, terms)
        elif family == 'predicate-flow':
            value = ((value * 3 + 1) if (value & 7) < 3 else (value ^ index)) & MASK
        elif family == 'product-ownership':
            value = ((value * 3) + ((value + index) & MASK ^ 7)) & MASK
        else:
            raise ValueError(family)
    return value


def pin(path, relative=False):
    data = path.read_bytes()
    return dict(file=str(path.relative_to(HERE) if relative else path.resolve()),
                bytes=len(data), sha256=hashlib.sha256(data).hexdigest())


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--write', action='store_true')
    args = parser.parse_args()
    if args.write:
        assert not (HERE / 'catalog.json').exists(), 'Fresh catalog required'
        cases = []
        for family, variants in VARIANTS.items():
            expected = {}
            for size in SIZES:
                path = HERE / 'expected' / f'{family}-{size}.stdout'
                assert not path.exists(), 'Fresh expected file required'
                path.write_text(str(answer(family, size, SEED)) + '\n')
                expected[size] = pin(path, relative=True)
            lineage = ROOT / 'selfhost/tools/bench/catalogs/native45/fixtures' / LINEAGE[family]
            for variant in variants:
                name = family + '-' + variant
                source = HERE / (name + '.bend')
                cases.append(dict(id=name, family=family, variant=variant,
                    source=pin(source, relative=True), expectedFile=expected[1024],
                    point=dict(expectedStdout=str(answer(family, 1024, SEED))+'\n',
                        runtimeArgs=[1024, SEED], repetitions=256, warmups=4,
                        ratioEligible=True),
                    correctness=dict(expectedFile=expected[32],
                        expectedStdout=str(answer(family, 32, SEED))+'\n',
                        runtimeArgs=[32, SEED], repetitions=1, warmups=0),
                    lineage=pin(lineage), workComparison=NOTES[family],
                    oracleProvenance='Independent fixed-point/wrapping-integer mathematics in oracle.py; not obtained from compiler output.',
                    diagnosticOnly=True))
        catalog = dict(schema='bend-benchmark-native-catalog-v1', assetRoot='.',
            kind='phase194-independent-paired-diagnostics', version=1,
            diagnosticOnly=True, native45Membership=False, targetExecuted=False,
            checked=False, oracle=pin(Path(__file__)),
            sets=dict(first3=[r['id'] for r in cases[:6]], full=[r['id'] for r in cases]),
            scope='Twelve diagnostic programs only. No native45 score inclusion or universal compiler correctness claim. Source check and compiled executions remain required.',
            cases=cases)
        (HERE / 'catalog.json').write_text(json.dumps(catalog, indent=2)+'\n')
    catalog = json.loads((HERE / 'catalog.json').read_text())
    assert catalog['oracle'] == pin(Path(__file__))
    for row in catalog['cases']:
        assert pin(HERE / row['source']['file'], relative=True) == row['source']
        for point, expected in [(row['point'], row['expectedFile']),
                                (row['correctness'], row['correctness']['expectedFile'])]:
            n, seed = point['runtimeArgs']
            text = str(answer(row['family'], n, seed))+'\n'
            assert point['expectedStdout'] == text
            assert (HERE / expected['file']).read_text() == text
            assert pin(HERE / expected['file'], relative=True) == expected
        assert pin(Path(row['lineage']['file'])) == row['lineage']
    print(json.dumps(dict(complete=True, programs=len(catalog['cases']),
        finitePoints=2*len(catalog['cases']), targetExecuted=False)))


if __name__ == '__main__':
    main()

#!/usr/bin/env python3
"""Freeze eight single-result transfers; never execute a Bend/compiler target.

Only the original final IO main is replaced. All other source bytes survive.
These inputs are admission/complete-result tests, not native45 runtime ratios.
"""
import argparse
import hashlib
import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
sys.dont_write_bytecode = True
sys.path.insert(0, str(ROOT / 'selfhost/tools/build'))
from common import fresh_output, pin, require, write_json
from source import blocks

CATALOG = ROOT / 'selfhost/tools/bench/catalogs/native45/catalog.json'
CATALOG_SHA = '746fe610bfe1a5704f390b71cd5ee702e6bd874bd89a5a9363d5f69f69c0e475'
RUNTIME = ROOT / 'selfhost/src/runtime/native/runtime.c'
RUNTIME_SHA = '9e1c59078878be94052cb4d2d63a713e19e29b41ed3f94b034f2175a50efd0a9'
LOWER = ROOT / 'selfhost/src/back/qbe/lower.bend'
LOWER_SHA = '6ec5e7eccfa53a907b9cb47ea97c0186e7e3b3ea245091587171190da154aa09'
SELECTED = (
    ('local-fold', 'U32'),
    ('editdist', 'U32'),
    ('lexer', 'U32'),
    ('tree-bitonic', 'U32'),
    ('mandelbrot', 'U32'),
    ('coverage-closures-64', 'U32'),
    ('coverage-unicode-text-16', 'String'),
    ('coverage-record-aggregation-64', 'String'),
)
OLD_MAIN = b'''def main() -> IO(Unit):
  do IO<Unit>:
    args : List<String> <- IO.args()
    p93.run(p93.arguments(args))'''


def sha(data):
    return hashlib.sha256(data).hexdigest()


def checked_asset(row, asset_root):
    relative = Path(row['file'])
    require(not relative.is_absolute() and '..' not in relative.parts,
            'Unexpected catalogue asset path')
    path = (asset_root / relative).resolve(strict=True)
    require(path.is_relative_to(asset_root), 'Catalogue asset escapes root')
    actual = pin(path)
    require(all(actual[k] == row[k] for k in ('sha256', 'bytes')),
            'Frozen catalogue asset changed: ' + str(path))
    return path


def single(rows, kind, name):
    matches = [d for d in rows if d['kind'] == kind and d['name'] == name]
    require(len(matches) == 1, 'Expected one ' + kind + ' ' + name)
    return matches[0]


def pure_oracle(raw, result_type):
    require(raw.endswith(b'\n') and not raw.endswith(b'\n\n'),
            'Expected exactly one final IO.print newline')
    payload = raw[:-1]
    if result_type == 'U32':
        require(re.fullmatch(rb'(0|[1-9][0-9]*)', payload) is not None
                and int(payload) <= 4294967295, 'Unexpected U32 result spelling')
        return raw, 'exact-frozen-U32-stdout'
    require(result_type == 'String', 'Unfamiliar result type')
    text = payload.decode('utf-8', errors='strict')
    # show_val case4 adds quotes. show_chr emits these admitted scalar values
    # verbatim as UTF-8; refuse every escaping/control case, rather than invent
    # a new general-purpose Bend printer in this source-preparation script.
    require(all(ord(c) >= 32 and ord(c) != 127 and c not in '\\"'
                and not 0xD800 <= ord(c) <= 0xDFFF for c in text),
            'String oracle needs an unaudited readback escape')
    return b'"' + payload + b'"\n', 'quoted-complete-frozen-String-payload'


def prepare_case(row, result_type, asset_root):
    source = checked_asset(row['source'], asset_root)
    expected = checked_asset(row['expectedFile'], asset_root)
    raw = source.read_bytes()
    expected_raw = expected.read_bytes()
    require(expected_raw == row['point']['expectedStdout'].encode('utf-8'),
            'Expected file and catalogue point disagree')
    args = row['point']['runtimeArgs']
    require(len(args) == 2 and all(type(n) is int and 0 <= n <= 4294967295 for n in args),
            'Expected exactly two U32 runtime arguments')
    prefix, declarations = blocks(raw)
    require([line for line in prefix.splitlines() if line.startswith(b'import ')] == [b'import Base'],
            'Unfamiliar source imports')
    keys = [(d['kind'], d['name']) for d in declarations]
    require(len(keys) == len(set(keys)), 'Duplicate declaration identity')
    require(not any(d['name'] == 'main' and d['kind'] != 'def' for d in declarations),
            'Unexpected main law/type')
    main = single(declarations, 'def', 'main')
    require(declarations[-1] is main and main['data'].strip() == OLD_MAIN,
            'Unfamiliar original main; refuse transformation')
    value = single(declarations, 'def', 'p93.value')
    wanted = ('def p93.value(a: U32, b: U32) -> ' + result_type + ':\n  bench(a, b)').encode()
    require(value['data'].strip() == wanted, 'Unfamiliar p93.value signature/body')
    new_main = ('def main() -> ' + result_type + ':\n  p93.value(' +
                ', '.join(map(str, args)) + ')\n').encode()
    # Keep all bytes preceding the old declaration header, including its
    # attached blank lines. The admitted main is final and has no annotation.
    unchanged = raw[:main['headerOffset']]
    changed = unchanged + new_main
    new_prefix, new_declarations = blocks(changed)
    require(new_prefix == prefix and len(new_declarations) == len(declarations),
            'Transformation changed source structure')
    preserved = []
    for old, new in zip(declarations, new_declarations):
        require((old['kind'], old['name']) == (new['kind'], new['name']),
                'Transformation changed declaration order')
        if old['name'] != 'main':
            require(old['data'] == new['data'], 'Non-main declaration changed')
            preserved.append(dict(kind=old['kind'], name=old['name'],
                                  bytes=len(old['data']), sha256=sha(old['data'])))
    output, policy = pure_oracle(expected_raw, result_type)
    return dict(row=row, original=source, expected=expected, raw=raw,
                changed=changed, output=output, oraclePolicy=policy,
                resultType=result_type, arguments=args, preserved=preserved,
                transform=dict(kind='replace-exact-final-IO-main-with-pure-value-call',
                    unchangedPrefixBytes=len(unchanged), unchangedPrefixSha256=sha(unchanged),
                    removedMainBytes=len(raw)-len(unchanged), removedMainSha256=sha(raw[len(unchanged):]),
                    addedMain=new_main.decode(), addedMainSha256=sha(new_main),
                    originalValueDeclarationSha256=sha(value['data'])))


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--out', type=Path, required=True)
    args = parser.parse_args()
    require(pin(CATALOG)['sha256'] == CATALOG_SHA, 'Frozen native45 catalogue changed')
    require(pin(RUNTIME)['sha256'] == RUNTIME_SHA and pin(LOWER)['sha256'] == LOWER_SHA,
            'Audited pure-result readback source changed')
    catalog = json.loads(CATALOG.read_text())
    require(catalog['schema'] == 'bend-benchmark-native-catalog-v1'
            and catalog['assetRoot'] == '../..', 'Unfamiliar catalogue schema/root')
    asset_root = (CATALOG.parent / catalog['assetRoot']).resolve(strict=True)
    cases = {row['id']: row for row in catalog['cases']}
    require(len(cases) == len(catalog['cases']), 'Duplicate catalogue ID')
    prepared = [prepare_case(cases[name], result_type, asset_root)
                for name, result_type in SELECTED]
    require(len({item['row']['family'] for item in prepared}) == len(SELECTED),
            'Selected transfer cases do not cover eight distinct families')
    # All validation happens before allocating an output directory.
    out = fresh_output(args.out, ROOT)
    report = dict(kind='phase163-frozen-native45-single-result-transfer', version=1,
        complete=True, targetsRun=False, sourceChecked=False,
        inputs=[pin(__file__), pin(CATALOG), pin(RUNTIME), pin(LOWER),
                pin(ROOT/'selfhost/tools/build/source.py'), pin(ROOT/'selfhost/tools/build/common.py')],
        scope='Eight-family admission and complete single-result transfer. Only main changes. '
              'No frozen timing wrapper/repetition protocol is run; no native45 runtime ratio claim.',
        resultTypes={'U32': 6, 'String': 2}, cases=[])
    for item in prepared:
        row = item['row']
        dest = out / row['id']
        dest.mkdir()
        (dest/'original.bend').write_bytes(item['raw'])
        (dest/'program.bend').write_bytes(item['changed'])
        (dest/'catalog.stdout').write_bytes(item['expected'].read_bytes())
        (dest/'expected.stdout').write_bytes(item['output'])
        receipt = dict(id=row['id'], family=row['family'], resultType=item['resultType'],
            runtimeArgs=item['arguments'], originalSource=pin(item['original']),
            originalCopy=pin(dest/'original.bend'), source=pin(dest/'program.bend'),
            catalogExpected=pin(item['expected']), catalogExpectedCopy=pin(dest/'catalog.stdout'),
            expected=pin(dest/'expected.stdout'), oraclePolicy=item['oraclePolicy'],
            oracleProvenance=row['oracleProvenance'], frozenPoint=row['point'],
            sourceGroup=row['sourceGroup'], transformation=item['transform'],
            preservedDeclarations=item['preserved'], targetsRun=False,
            benchmarkRatioEligible=False)
        write_json(dest/'transformation.json', receipt)
        report['cases'].append(dict(id=row['id'], family=row['family'],
            resultType=item['resultType'], source=receipt['source'], expected=receipt['expected'],
            runtimeArgs=item['arguments'], transformation=pin(dest/'transformation.json'),
            benchmarkRatioEligible=False))
    write_json(out/'manifest.json', report)
    print(json.dumps(dict(complete=True, targetsRun=False, cases=len(report['cases']),
                         manifest=pin(out/'manifest.json'))))


if __name__ == '__main__':
    main()

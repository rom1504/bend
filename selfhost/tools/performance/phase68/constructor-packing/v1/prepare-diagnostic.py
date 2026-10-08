#!/usr/bin/env python3
"""Data-only, exact saved-C one-field packing discriminator. Never executes targets."""
import argparse
import collections
import importlib.util
import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[6]
METHOD = ROOT / 'selfhost/tools/performance/phase68/benchmark/saved-native-v2.py'
METHOD_SHA = '83c586f20c37965a536c32d8c129a6cf481e66e634ab437a6b4a944016510cd2'
RAW = ROOT / 'selfhost/build/phase68'


def main():
    import hashlib
    assert hashlib.sha256(METHOD.read_bytes()).hexdigest() == METHOD_SHA
    spec = importlib.util.spec_from_file_location('p68_packing_saved', METHOD)
    m = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(m)
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--out', type=Path, required=True)
    args = parser.parse_args()
    out = args.out.resolve()
    out.relative_to(RAW)
    recipe, recipe_pin, continuity, inputs, acquisitions, products = m.admit(
        RAW / 'native-flat06-recipe.json', RAW / 'flat-build06/attempt.json',
        [RAW / 'native-flat06/report.json', RAW / 'native-flat06-rest/report.json'])
    plan_pin = m.pin(RAW / 'native-plan02.json')
    plan = m.read(plan_pin['path'])
    # This is exactly the ordinary one-field allocation emitted by ne_constructor.
    # Select encoded user ADT identities, never Base/IO runtime constructors.
    pattern = re.compile(
        r'(?m)^(?P<indent>[ \t]*)u64 (?P<node>nd_\d+) = heap_alloc\(e, cls_fit\(1\)\);\n'
        r'(?P=indent)e\.mem\[(?P=node) \+ 0\] = rfc_seal\(e, (?P<field>v_\d+)\);\n'
        r'(?P=indent)(?P<assign>[^\n;]*?= )term_ctr\((?P<cid>CID__CTOR_[0-9_]+), (?P=node)\);')
    out.mkdir(parents=True, exist_ok=False)
    records = []
    for case, expected_count in [('tree', 21), ('lexer', 12)]:
        parent = products[(case, 'selfhost')]
        source = Path(parent['nativeSource']['path']).read_text()
        assert '#define LOC_MASK ((1ull << 40) - 1)' in source
        changes = []

        def replace(match):
            g = match.groupdict()
            at, field, cid, indent = g['node'], g['field'], g['cid'], g['indent']
            value, word = at + '_packed', at + '_field'
            text = '\n'.join([
                f'Term {word} = {field};', f'Term {value};',
                f'if (({word} & ~LOC_MASK) == 0) {{',
                f'  {value} = term_pak({cid}, {word});', '} else {',
                f'  u64 {at} = heap_alloc(e, cls_fit(1));',
                f'  e.mem[{at} + 0] = rfc_seal(e, {word});',
                f'  {value} = term_ctr({cid}, {at});', '}',
                g['assign'] + value + ';'])
            replacement = '\n'.join(indent + line for line in text.splitlines())
            changes.append(dict(line=source.count('\n', 0, match.start()) + 1,
                constructor=cid, before=match.group(), after=replacement))
            return replacement

        result, count = pattern.subn(replace, source)
        assert count == expected_count, (case, count)
        assert source.count('CID_IO_ARGS') == result.count('CID_IO_ARGS')
        directory = out / case
        directory.mkdir()
        c_file = directory / 'program.c'
        c_file.write_text(result)
        c_pin = m.pin(c_file)
        binary = directory / 'program'
        build = ['taskset', '-c', '3', recipe['clang'], *recipe['clangArgs'],
                 str(c_file), *recipe['linkArgs'], '-o', str(binary)]
        protocol = plan[case]
        values = m.O.points(m.CATALOG[case])
        expected = [m.CATALOG[case]['expected'], m.O.digest(values, protocol['warmups']),
                    m.O.digest(values, protocol['repetitions'])]
        records.append(dict(case=case, parent=parent, diagnosticC=c_pin,
            changes=changes, changeCount=count,
            constructors=dict(collections.Counter(x['constructor'] for x in changes)),
            buildCommand=build,
            runCommand=['taskset', '-c', '3', str(binary), '--threads', '1', '--gpu', 'off',
                        '--', str(protocol['repetitions']), str(protocol['warmups'])],
            expected=expected))
    report = dict(kind='phase68-guarded-packing-c-diagnostic-plan-v1',
        targetsExecuted=False, producer=m.pin(__file__), admissionMethod=m.pin(METHOD),
        recipe=recipe_pin, continuity=continuity, actualInputs=inputs,
        acquisitions=acquisitions, plan=plan_pin, records=records,
        resourcePolicy=dict(cpu=3, treeRssMiB=2048, availableMiB=4096, serial=True),
        scope='Saved-C diagnostic only. No compiler image or foreign/raw ABI qualification. '
              'Every matching encoded ordinary one-field constructor is changed; Base/IO '
              'constructors, runtime, methods, toolchain, and protocol are unchanged.')
    for item in inputs + acquisitions + [recipe_pin, plan_pin]:
        m.verify(item)
    for record in records:
        m.verify(record['diagnosticC'])
        for key in ('source', 'nativeSource', 'executable', 'emissionReceipt'):
            m.verify(record['parent'][key])
    (out / 'plan.json').write_text(json.dumps(report, indent=2) + '\n')
    print(json.dumps(dict(plan=m.pin(out / 'plan.json'), counts={r['case']: r['changeCount'] for r in records}, targetsExecuted=False)))


if __name__ == '__main__':
    main()

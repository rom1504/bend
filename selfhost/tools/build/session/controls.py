#!/usr/bin/env python3
"""Prepare or inspect a small semantic session matrix; never execute a compiler."""
import argparse
import json
from pathlib import Path
import sys
sys.dont_write_bytecode = True
HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE.parent))
from common import fresh_output, pin, require, verify, workspace, write_json


def prepare(a):
    out = fresh_output(a.out, workspace(a.workspace))
    original = ('import Base\ndef work(x: U32) -> U32:\n'
                '  U32.add(x, 1)\ndef main() -> U32:\n  work(2)\n')
    variants = dict(a=original, b=original.replace('U32.add(x, 1)', 'U32.add(x, 3)'),
                    type_error=original.replace('U32.add(x, 1)', 'U32.add(x, True{})'),
                    parse_error=original.replace('U32.add(x, 1)', 'U32.add(x, 1'))
    for name, text in variants.items():
        (out / (name + '.bend')).write_text(text)
    hint = len(original[:original.index('U32.add')].encode('utf-16-le')) // 2
    sequence = [('cold-a', 'a', 'cold'), ('noop-a', 'a', 'warm'),
                ('edit-b', 'b', 'warm'), ('revert-a', 'a', 'warm'),
                ('type-error', 'type_error', 'warm'), ('recover-b', 'b', 'warm'),
                ('parse-error', 'parse_error', 'warm'), ('recover-a', 'a', 'warm')]
    jobs = [dict(name=name, source=str(out / (variant + '.bend')), hint=hint,
                 owner='work', mode=mode, expectError=variant.endswith('_error'))
            for name, variant, mode in sequence]
    base = dict(kind='bend-session-jobs', version=1, logical=str(out / 'a.bend'))
    write_json(out / 'jobs.json', dict(base, jobs=jobs))
    write_json(out / 'native-jobs.json', dict(base, jobs=[x for x in jobs if not x['expectError']]))
    report = dict(kind='bend-session-control-fixtures', version=1, complete=True,
                  targetsRun=False, method=pin(__file__), files=[pin(out / (x + '.bend')) for x in variants],
                  jobs=pin(out / 'jobs.json'), nativeJobs=pin(out / 'native-jobs.json'),
                  expectedProgramOutputs=dict(a='3\n', b='5\n'),
                  scope='One scalar real edit plus mode-matched no-op, recovery and transport controls; not full conformance.')
    write_json(out / 'fixtures.json', report)
    return report


def inspect(a):
    source = pin(a.report)
    report = json.loads(Path(source['file']).read_text())
    require(report.get('complete') is True and report.get('kind') == 'bend-experimental-hosted-session', 'Completed hosted report required')
    expected = ['cold-a', 'noop-a', 'edit-b', 'revert-a', 'type-error', 'recover-b', 'parse-error', 'recover-a']
    rows = report['rows']; require([x['name'] for x in rows] == expected, 'Wrong semantic fixture sequence')
    require(report['coldComparisons'] == len(rows), 'Every request needs its mode-matched cold comparison')
    byname = {x['name']: x for x in rows}
    for row in rows:
        verify(row['source'])
        if row['expectedError']:
            require(row.get('error') and not row.get('product'), 'Refusal published a product')
        else:
            verify(row['product'])
            if row.get('unitFrames'): verify(row['unitFrames'])
    sha = lambda name: byname[name]['product']['sha256']
    require(len({sha(x) for x in ['cold-a', 'noop-a', 'revert-a', 'recover-a']}) == 1, 'No-op/revert/recovery A differs')
    require(sha('edit-b') == sha('recover-b'), 'Recovery B differs')
    require(sha('cold-a') != sha('edit-b'), 'Real source edit did not change the complete QBE product')
    require(byname['noop-a']['renderHits'] > 0, 'No-op failed to exercise renderer reuse')
    verify(source)
    result = dict(kind='bend-session-semantic-controls', version=1, complete=True,
                  report=source, method=pin(__file__), requests=8, positiveProducts=6,
                  modeMatchedColdComparisons=8, semanticRefusals=2,
                  realEditChangesCompleteProduct=True, noOpExercisesReuse=True,
                  scope='Audits producer controls; generated program execution/object-cache controls remain separate.')
    if a.out:
        out = fresh_output(a.out, workspace(a.workspace)); write_json(out / 'report.json', result)
    return result


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('operation', choices=['prepare', 'inspect'])
    p.add_argument('--workspace', type=Path); p.add_argument('--out', type=Path)
    p.add_argument('--report', type=Path); a = p.parse_args()
    require(a.out if a.operation == 'prepare' else a.report, 'Prepare requires --out; inspect requires --report')
    print(json.dumps(prepare(a) if a.operation == 'prepare' else inspect(a)))


if __name__ == '__main__': main()

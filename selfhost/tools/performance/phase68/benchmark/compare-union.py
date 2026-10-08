#!/usr/bin/env python3
"""Compare a disjoint union through unchanged saved-native-v2; no targets."""
import argparse
import hashlib
import json
import math
import os
import statistics
import subprocess
import sys
from pathlib import Path

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[4]
RAW = ROOT/'selfhost/build/phase68'
COMPARATOR = HERE/'saved-native-v2.py'
inputs = {}


def pin(value):
    expected = value if isinstance(value, dict) else None
    p = Path(expected.get('path', expected.get('file')) if expected else value).resolve(strict=True)
    result = dict(path=str(p), sha256=hashlib.sha256(p.read_bytes()).hexdigest(), bytes=p.stat().st_size)
    if expected:
        assert result['sha256'] == expected['sha256']
        if 'bytes' in expected:
            assert result['bytes'] == expected['bytes']
    inputs[str(p)] = result
    return result


def read(value):
    return json.loads(Path(pin(value)['path']).read_text())


def write(path, value):
    with path.open('x') as stream:
        stream.write(json.dumps(value, indent=2)+'\n')


parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument('--baseline-timing', type=Path, required=True)
parser.add_argument('--candidate-timings', type=Path, nargs='+', required=True)
parser.add_argument('--baseline-attempt', type=Path, required=True)
parser.add_argument('--candidate-attempt', type=Path, required=True)
parser.add_argument('--cases', default='numeric,array,closures,tree,map,lexer')
parser.add_argument('--rounds', type=int, default=2)
parser.add_argument('--out', type=Path, required=True)
parser.add_argument('--allow-compiler-input', action='append', choices=['selfhost/src/compiler.json'], default=[])
parser.add_argument('--allow-added-input', action='append', choices=['selfhost/tools/performance/phase67/benchmark/fast-plan.py'], default=[])
args = parser.parse_args()
assert os.sched_getaffinity(0) == {0}, 'Data comparison belongs on CPU0'
output = args.out.resolve()
assert output.is_relative_to(RAW) and not output.exists()
assert args.rounds > 0 and len(args.candidate_timings) > 1
cases = args.cases.split(',')
assert len(set(cases)) == len(cases)
method = pin(COMPARATOR)
assert method['sha256'] == '83c586f20c37965a536c32d8c129a6cf481e66e634ab437a6b4a944016510cd2'
producer = pin(__file__)
baseline_pin = pin(args.baseline_timing)
members, seen, common = [], set(), None
for file in args.candidate_timings:
    identity, report = pin(file), read(file)
    assert report['kind'] == 'phase68-saved-native-measure' and report['complete'] and report['allTimingQualified']
    shared = {k: report[k] for k in ['producer', 'predecessorMethod', 'recipe', 'continuity', 'actualInputs', 'plan']}
    assert common is None or common == shared, 'Members must use identical compiler, method, recipe, inputs and fixed plan'
    common = shared
    keys = [(r['case'], r['role'], r['round']) for r in report['records']]
    member_cases = {k[0] for k in keys}
    assert member_cases and not (seen & member_cases), 'Union members must have disjoint case sets'
    assert len(keys) == len(set(keys))
    assert set(keys) == {(case, 'selfhost', round_) for case in member_cases for round_ in range(args.rounds)}
    seen.update(member_cases)
    acquisitions = [pin(item) for item in report['acquisitions']]
    members.append(dict(timing=identity, cases=sorted(member_cases), acquisitions=acquisitions, recordKeys=keys))
assert seen == set(cases), 'Explicit complete case coverage is required'
output.mkdir(parents=True)
union_file = output/'union.json'
write(union_file, dict(kind='phase68-saved-native-disjoint-union', complete=True, dataOnly=True,
    targetExecuted=False, producer=producer, comparisonMethod=method, members=members,
    shared=common, cases=cases, roles=['selfhost'], rounds=args.rounds,
    scope='Structural union of original immutable measurement receipts; no synthesized timing receipt or relabeled producer. Each original member is independently admitted by unchanged saved-native-v2 before comparison rows are joined.'))
rows, comparisons, commands = [], [], []
shared_comparison = None
for index, member in enumerate(members):
    dest = output/f'comparison-{index+1:02d}.json'
    command = [sys.executable, '-B', str(COMPARATOR), 'compare',
        '--baseline-timing', str(args.baseline_timing.resolve()),
        '--candidate-timing', member['timing']['path'],
        '--baseline-attempt', str(args.baseline_attempt.resolve()),
        '--candidate-attempt', str(args.candidate_attempt.resolve()), '--out', str(dest)]
    for option, values in [('allow-compiler-input', args.allow_compiler_input), ('allow-added-input', args.allow_added_input)]:
        for value in values:
            command += ['--'+option, value]
    process = subprocess.run(command, cwd=ROOT, capture_output=True, text=True)
    write(output/f'comparison-{index+1:02d}-process.json', dict(command=command, returncode=process.returncode,
        stdout=process.stdout, stderr=process.stderr, dataOnly=True, targetExecuted=False))
    assert process.returncode == 0, process.stderr
    comparison = read(dest)
    assert comparison['complete'] and comparison['dataOnly'] and not comparison['targetExecuted']
    assert comparison['producer'] == method
    assert comparison['inputs'] == [baseline_pin, member['timing']]
    shared = {k: comparison[k] for k in ['baselineContinuity', 'candidateContinuity', 'baselineRecipe',
        'candidateRecipe', 'plan', 'registeredCompilerInputs', 'registeredAddedInputs', 'changedSharedInputs']}
    assert shared_comparison is None or shared_comparison == shared
    shared_comparison = shared
    assert {r['case'] for r in comparison['rows']} == set(member['cases'])
    for row in comparison['rows']:
        assert row['role'] == 'selfhost' and row['baselineRounds'] == row['candidateRounds'] == args.rounds
        rows.append(dict(row, candidateTiming=member['timing'], comparison=pin(dest)))
    comparisons.append(pin(dest));commands.append(command)
assert len(rows) == len(cases) and {r['case'] for r in rows} == set(cases)
rows.sort(key=lambda r: cases.index(r['case']))
gm = lambda key: math.exp(statistics.mean(math.log(r[key]) for r in rows))
result = dict(kind='phase68-saved-native-comparison-union', complete=True, dataOnly=True, targetExecuted=False,
    producer=producer, comparisonMethod=method, union=pin(union_file), comparisons=comparisons,
    commands=commands, **shared_comparison, rows=rows,
    geomeanCandidateOverBaselineRuntime=gm('candidateOverBaselineRuntime'),
    geomeanCandidateOverBaselineClang=gm('candidateOverBaselineClang'),
    geomeanCandidateOverBaselineCBytes=gm('candidateOverBaselineCBytes'),
    scope='Explicit disjoint case union, independently validated by unchanged saved-native-v2. Original receipt/producer identities remain intact. Sequential two-round campaigns; saved runtime, original single-build Clang clocks and C sizes remain separate.')
for item in list(inputs.values()):
    pin(item)
result['inputs'] = list(inputs.values())
write(output/'report.json', result)
print(json.dumps(dict(output=pin(output/'report.json'), runtimeRatio=result['geomeanCandidateOverBaselineRuntime'],
    clangRatio=result['geomeanCandidateOverBaselineClang'], cBytesRatio=result['geomeanCandidateOverBaselineCBytes'])))

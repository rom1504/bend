#!/usr/bin/env python3
"""Verify and combine three full-corpus runtime batches; never execute targets."""
import json
import math
import sys
from pathlib import Path
sys.path.insert(0, str(Path(__file__).resolve().parent.parent / 'programs'))
from run import PRESETS, load_bundle, require, summarize, verify
from support import identity
if len(sys.argv) != 8:
    raise SystemExit('usage: summarize-runtime.py CATALOG BASELINE CANDIDATE OUT_JSON REPORT1 REPORT2 REPORT3')
catalog_path, baseline_path, candidate_path, out, *report_paths = map(Path, sys.argv[1:])
require(not out.exists(), 'Output already exists')
inputs = [identity(p) for p in [Path(__file__), sys.modules['run'].__file__, sys.modules['support'].__file__, catalog_path, *report_paths]]
catalog = json.loads(catalog_path.read_text())
catalog_hash = identity(catalog_path)['sha256']
selected = {row['id']: row for row in catalog['cases']}
require(len(selected) == len(catalog['cases']) == 45 and set(selected) == set(catalog['sets']['full']), 'Expected exact full45 catalog')
baseline = load_bundle(baseline_path, catalog, catalog_hash, list(selected.values()), ['baseline', 'typescript'], inputs)
candidate = load_bundle(candidate_path, catalog, catalog_hash, list(selected.values()), ['candidate'], inputs)
variants = {**baseline['roles'], **candidate['roles']}
for row in selected.values():
    inputs.append(verify(catalog_path.parent / row['source']['path'], row['source']))
cases, reports, common, environments, sample_count, intervals = {}, [], None, set(), 0, []
roles = ['typescript', 'baseline', 'candidate']
ratio_names = ['baseline/typescript', 'candidate/typescript', 'baseline/candidate']
for path in report_paths:
    report = json.loads(path.read_text())
    require(report.get('complete') is True and report.get('pass') is True and report.get('status') == 'measured', 'Incomplete batch: ' + str(path))
    plan = report['plan']
    require(plan['budgetSeconds'] == 600 and plan['protocol'] == PRESETS[600] and plan['roles'] == roles, 'Wrong full-run protocol')
    require(plan['variants'] == variants, 'Compiler role identities differ from supplied bundles')
    shared = {key: value for key, value in plan.items() if key not in ['selectedIds', 'selectedSet']}
    require(common is None or common == shared, 'Node, resources, protocol or other plan fields differ')
    common = shared
    require(report['selectedCases'] == report['measuredCases'] == len(report['cases']), 'Batch coverage differs')
    require([row['id'] for row in report['cases']] == plan['selectedIds'], 'Case order differs from plan')
    inputs.extend(report['inputs'])
    reports.append(identity(path))
    for row in report['cases']:
        key = row['id']
        require(key in selected and key not in cases and row['point'] == selected[key]['point'], 'Unknown, repeated or changed point: ' + key)
        rounds = 3 if key == 'raytrace' else 5
        samples = row['samples']
        require(row['rounds'] == rounds and len(samples) == rounds * 3, 'Wrong sample count: ' + key)
        require([(s['role'], s['round']) for s in samples] == [(r, n) for n in range(rounds) for r in roles[n % 3:] + roles[:n % 3]], 'Wrong rotated rounds: ' + key)
        for sample in samples:
            result, process, role = sample['result'], sample['process'], sample['role']
            require(sample.get('complete') is True and result.get('complete') is True and result.get('pass') is True and process.get('complete') is True and process['returncode'] == 0, 'Failed sample: ' + key)
            module = (candidate if role == 'candidate' else baseline)['points'][key][role]
            command = process['command']
            for leaf, expected in [(Path(command[-1]), result), (Path(command[-1]).parent / 'process/process.json', process)]:
                inputs.append(identity(leaf))
                require(json.loads(leaf.read_text()) == expected, 'Raw sample/process receipt differs: ' + str(leaf))
            intervals.append((process['started'], process['finished']))
            require(len(command) == 10 and command[:6] == ['taskset', '-c', str(plan['cpu']), plan['node'], '--stack-size=4096', '--max-old-space-size=' + str(plan['heapMiB'])], 'Sample command differs')
            require(process['rssLimitBytes'] == plan['rssMiB'] * 1024**2 and process['availableFloorBytes'] == plan['availableMiB'] * 1024**2, 'Sample resource policy differs')
            config = {**row['point'], **{k: plan['protocol'][k] for k in ['warmupCalls', 'warmupMs', 'calibrationMs', 'targetMs']}}
            config['warmupCalls'] = 1 if key == 'raytrace' else config['warmupCalls']
            require(result['config'] == config and result['module']['file'] == command[-3], 'Sample point or module path differs')
            for filename, expected in [(command[-3], module), (command[-4], {'sha256': result['toolSha256']}), (command[-2], {'sha256': result['configSha256']})]:
                actual = identity(filename)
                require(all(actual[k] == v for k, v in expected.items() if k in ['sha256', 'bytes']), 'Changed measured input: ' + filename)
                inputs.append(actual)
            require(result['module']['sha256'] == module['sha256'] and json.loads(Path(command[-2]).read_text()) == config, 'Sample input binding differs')
            require(result['affinity'].split(':', 1)[1].strip() == str(plan['cpu']), 'Sample CPU differs')
            require(result['execArgv'] == command[4:6], 'Sample Node flags differ')
            require(math.isfinite(result['msPerCall']) and result['msPerCall'] > 0, 'Invalid timing')
            environments.add((result['node'], tuple(result['execArgv']), result['toolSha256']))
        raw = summarize(samples, roles, rounds)
        require(raw == row['summary'] and raw['complete'], 'Stored summary differs from raw samples: ' + key)
        paired = {name: [next(s['result']['msPerCall'] for s in samples if s['role'] == name.split('/')[0] and s['round'] == n) / next(s['result']['msPerCall'] for s in samples if s['role'] == name.split('/')[1] and s['round'] == n) for n in range(rounds)] for name in ratio_names}
        cases[key] = dict(id=key, sourceSha256=selected[key]['source']['sha256'], family=selected[key].get('family'), rawSummary=raw, ratios=raw['ratios'], pairedRoundRatios=paired, candidateChangePercent=100 * (1 / raw['ratios']['baseline/candidate'] - 1))
        sample_count += len(samples)
require(set(cases) == set(selected) and sample_count == 669 and len(environments) == 1, 'Incomplete corpus or inconsistent sample environment')
intervals.sort()
require(all(math.isfinite(a) and math.isfinite(b) and a <= b for a, b in intervals) and all(b <= c for (a, b), (c, d) in zip(intervals, intervals[1:])), 'Invalid or overlapping sample execution')
def geometric(values):
    return math.exp(sum(math.log(x) for x in values) / len(values))

def grouped(field):
    return {group: {name: geometric([r['ratios'][name] for r in cases.values() if r[field] == group]) for name in ratio_names} for group in sorted({r[field] for r in cases.values()})}

sources = grouped('sourceSha256')
families = grouped('family') if all(r['family'] is not None for r in cases.values()) else {}
means = {name: dict(pointWeighted=geometric([r['ratios'][name] for r in cases.values()]), equalSourceWeighted=geometric([r[name] for r in sources.values()]), **({'equalFamilyWeighted': geometric([r[name] for r in families.values()])} if families else {})) for name in ratio_names}
frozen = {}
for entry in inputs:
    require(entry['path'] not in frozen or frozen[entry['path']] == entry, 'Conflicting recorded input identities')
    frozen[entry['path']] = entry
for filename, entry in frozen.items():
    verify(filename, entry)
counts = {label: sum(test(r['ratios']['baseline/candidate']) for r in cases.values()) for label, test in [('wins', lambda x: x > 1), ('regressions', lambda x: x < 1), ('ties', lambda x: x == 1)]}
result = dict(kind='bend-full-runtime-summary', complete=True, **{'pass': True}, points=len(cases), samples=sample_count, sourceCount=len(sources), familyCount=len(families), reports=reports, inputs=list(frozen.values()), plan=common, sampleEnvironment=list(environments)[0], geometricMeans=means, medianChanges=counts, sources=sources, families=families, cases=list(cases.values()))
out.parent.mkdir(parents=True, exist_ok=True)
with out.open('x') as stream:
    json.dump(result, stream, indent=2, allow_nan=False)
    stream.write('\n')
print(json.dumps({k: result[k] for k in ['points', 'samples', 'sourceCount', 'geometricMeans', 'medianChanges']}))

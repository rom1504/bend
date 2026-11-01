#!/usr/bin/env python3
"""Root-only, guarded complete-render/write comparison over three retained segments."""
import argparse
import json
import math
import os
from pathlib import Path
import statistics
import sys

sys.dont_write_bytecode = True
ROOT = Path(__file__).resolve().parents[3]
sys.path.insert(0, str(ROOT/'selfhost/tools/build'))
from common import clean_environment, fresh_output, pin, require, run, same_bytes, verify, write_json


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--preparation', type=Path, required=True)
    parser.add_argument('--out', type=Path, required=True)
    parser.add_argument('--rounds', type=int, default=6)
    parser.add_argument('--minimum-seconds', type=float, default=0.15)
    args = parser.parse_args()
    require(os.sched_getaffinity(0) == {3}, 'Root CPU3 guard required')
    clean_environment()
    require(args.rounds == 6 and 0.1 <= args.minimum_seconds <= 0.5, 'Bounded six-pair protocol required')
    prep = json.loads(args.preparation.read_text())
    require(prep['complete'] and prep['kind'] == 'phase147-matched-native-render-preparation' and prep['version'] == 3 and not prep['targetsRun'], 'Preparation schema differs')
    controls = json.loads(verify(prep['controls']).read_text())
    require(controls['kind'] == 'phase147-fragment-render-controls' and controls['complete'] and controls['passed'] and len(controls['rows']) == 3, 'Three checked full-text controls required')
    inputs = [pin(__file__), pin(Path(__file__).with_name('render-prepare-fragment-native.py')),
              pin(ROOT/'selfhost/tools/build/common.py'), pin(sys.executable), pin(args.preparation),
              prep['controls'], *prep['inputs'], *controls['inputs']]
    builds = {}
    require([row['role'] for row in prep['rows']] == ['baseline', 'candidate'], 'Matched roles differ')
    for row in prep['rows']:
        build = json.loads(Path(row['build']).read_text())
        require(build['kind'] == 'bend-native-build' and build['complete'] and not build['changedInputs'], 'Native build incomplete')
        require(build['request']['source'] == row['source'], 'Native build source differs')
        require(build['binary']['file'] == row['binary'], 'Native image path differs')
        builds[row['role']] = build
        inputs += [pin(row['build']), row['source'], build['binary'], build['object'], *build['inputs']]
    require(builds['baseline']['runtime'] == builds['candidate']['runtime'] and
            builds['baseline']['toolchain'] == builds['candidate']['toolchain'], 'Runtime or toolchain differs')
    source_a = Path(prep['rows'][0]['source']['file']).read_bytes()
    source_b = Path(prep['rows'][1]['source']['file']).read_bytes()
    selection=prep['entrySelection'];require(selection['reference'] in [0,1] and selection['candidate']==2, 'Unsupported ablation')
    before=('p147qn_main('+str(selection['reference'])+')').encode();after=b'p147qn_main(2)'
    require(source_a.count(before)==1 and source_a.replace(before,after)==source_b,
            'Source difference exceeds selected mode')
    for row in controls['rows']:
        require(row['completeTextExact'] and row['inputUnchanged'], 'Missing exact hosted control')
        inputs += [row['baseline'], row['candidate']]
    unique = {}
    for item in inputs:
        require(item['file'] not in unique or unique[item['file']] == item, 'Conflicting input identities')
        unique[item['file']] = item
    inputs = list(unique.values())
    for item in inputs: verify(item)
    out = fresh_output(args.out, ROOT)
    report = dict(kind='phase147-fragment-native-render-pairs', version=1, complete=False,
        passed=False, entrySelection=selection, inputs=inputs, preparation=pin(args.preparation), controls=prep['controls'],
        nativeBuilds={role: pin(row['build']) for role, row in zip(['baseline', 'candidate'], prep['rows'])},
        protocol=dict(rounds=6, minimumCalibrationSeconds=args.minimum_seconds, maximumCount=100000,
            order='AB/BA alternates by round and fixture; one fresh process per observation.',
            clock='Child wall time including launch/setup/render/write/close; prior calibration warms filesystem caches.',
            consumer='One File.write per complete function String; oracle mode writes full stdout, timed mode writes /dev/null.',
            fixtureScope='Three exact current Map/Lexer/compiler branch-free bodies under original scalar renderer; not full selected emitter or compiler.'),
        observations=[], cases=[], fullTextChecks=[])
    def save(): write_json(out/'report.json', report)
    save()
    def execute(label, role, mode, index, count):
        command = [builds[role]['binary']['file'], '--threads', '1', '--gpu', 'off', '--', mode, str(index), str(count)]
        result = run(command, cwd=ROOT, stdout=out/(label+'.stdout'), stderr=out/(label+'.stderr'), seconds=15)
        row = dict(label=label, role=role, mode=mode, index=index, count=count, **result)
        report['observations'].append(row); save()
        require(result['complete'] and result['exitCode'] == 0 and result['stderr']['bytes'] == 0,
                'Child failed or emitted diagnostics: '+label)
        if mode == 'oracle':
            expected = controls['rows'][index]['baseline']
            require(same_bytes(result['stdout']['file'], expected['file']), 'Complete native text differs: '+label)
            report['fullTextChecks'].append(dict(label=label, expected=expected, actual=result['stdout'], byteExact=True))
        else:
            require(result['stdout']['bytes'] == 0, 'Timed child emitted unexpected stdout')
        return row
    try:
        for index, fixture in enumerate(controls['rows']):
            for role in ['baseline', 'candidate']:
                execute('before-%d-%s'%(index, role), role, 'oracle', index, 1)
            count, calibrated = 1000, False
            calibration = []
            for attempt in range(6):
                pair = [execute('calibrate-%d-%d-%s'%(index, attempt, role), role, 'bench', index, count)
                        for role in ['baseline', 'candidate']]
                calibration += [row['label'] for row in pair]
                duration = min(row['seconds'] for row in pair)
                if duration >= args.minimum_seconds:
                    calibrated = True; break
                require(count < 100000, 'Maximum count remains below calibration floor')
                count = min(100000, count * max(2, min(8, math.ceil(args.minimum_seconds/duration*1.1))))
            require(calibrated, 'Calibration did not close within six attempts')
            paired = []
            for round_index in range(6):
                order = ['baseline', 'candidate'] if (round_index+index)%2 == 0 else ['candidate', 'baseline']
                pair = {role: execute('pair-%d-%d-%s'%(index, round_index, role), role, 'bench', index, count) for role in order}
                paired.append(dict(round=round_index, order=order,
                    baselineSeconds=pair['baseline']['seconds'], candidateSeconds=pair['candidate']['seconds'],
                    candidateOverBaseline=pair['candidate']['seconds']/pair['baseline']['seconds']))
            for role in ['baseline', 'candidate']:
                execute('after-%d-%s'%(index, role), role, 'oracle', index, 1)
            report['cases'].append(dict(index=index, name=fixture['name'], calls=fixture['calls'], count=count,
                calibration=calibration, pairs=paired, completeFunctionBytes=fixture['baseline']['bytes'],
                fullTextSha256=fixture['baseline']['sha256'],
                medianPairedRatio=statistics.median(p['candidateOverBaseline'] for p in paired),
                medianBaselineSeconds=statistics.median(p['baselineSeconds'] for p in paired),
                medianCandidateSeconds=statistics.median(p['candidateSeconds'] for p in paired)))
            save()
        for item in inputs: verify(item)
        report.update(complete=True, passed=True)
    except BaseException as error:
        report['error'] = repr(error)
        raise
    finally:
        save()
    print(json.dumps(dict(complete=True, cases=report['cases'], report=pin(out/'report.json'))))


if __name__ == '__main__': main()

#!/usr/bin/env python3
"""Runtime-only, per-role calibrated comparison of frozen C and Bend products."""
import argparse
import json
import math
import os
from pathlib import Path
import statistics
import sys
import time

sys.dont_write_bytecode = True
HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[3]
sys.path.insert(0, str(HERE.parent))
import bench
from common import changed_inputs, clean_environment, fresh_output, pin, require, verify, write_json

ROLES = ('handwritten-c', 'bend-qbe', 'bend-c')
REFERENCE = ROLES[0]
MAX_REPETITIONS = 2**31-1
MAX_ATTEMPTS = 8
SAMPLE_SECONDS = 30
CATALOG = HERE.parent/'catalogs/native45/catalog.json'


def method_files():
    return [Path(__file__).resolve(), HERE.parent/'bench.py',
            HERE.parents[1]/'build/common.py', HERE.parents[1]/'build/assets.py', CATALOG]


def input_pins(rows):
    require(isinstance(rows,list) and len(rows) <= 10000, 'Bounded input pin list required')
    result = []
    for row in rows:
        require(isinstance(row,dict) and set(('file','bytes','sha256')) <= set(row)
                and isinstance(row['file'],str) and Path(row['file']).is_absolute()
                and type(row['bytes']) is int and row['bytes'] >= 0
                and isinstance(row['sha256'],str) and len(row['sha256']) == 64,
                'Complete absolute input pin required')
        actual = pin(verify(row))
        require(actual['file'] == row['file'], 'Noncanonical frozen input path')
        result.append(actual)
    return bench.unique_inputs(result)


def load_manifest(file):
    identity = pin(file)
    document = json.loads(verify(identity).read_text())
    require(document.get('kind') == 'phase184-direct-c-products' and document.get('complete') is True,
            'Complete phase184-direct-c-products manifest required')
    inputs = input_pins(document.get('inputs'))
    frozen = {row['file']:row for row in inputs}
    for method in method_files():
        actual = pin(method)
        require(frozen.get(actual['file']) == actual, 'Frozen manifest omits or changes consumed method/catalog: '+str(method))
    original = {case['id']:case for case in json.loads(CATALOG.read_text())['cases']}
    cases = document.get('cases')
    require(isinstance(cases,list) and 0 < len(cases) <= 45, 'One to45 frozen cases required')
    seen = set()
    for case in cases:
        name = case.get('id')
        require(isinstance(name,str) and name in original and name not in seen, 'Unknown or duplicate native45 case')
        seen.add(name)
        require(case.get('point') == original[name]['point'], 'Point/oracle differs from original native45: '+name)
        require(case.get('family') == original[name]['family'], 'Case family differs from native45: '+name)
        require(case.get('sourceGroup') == original[name]['sourceGroup'], 'Source group differs from native45: '+name)
        point = case['point']
        require(type(point['repetitions']) is int and 0 < point['repetitions'] <= MAX_REPETITIONS
                and type(point['warmups']) is int and 0 <= point['warmups'] <= MAX_REPETITIONS,
                'Repetition/warmup count exceeds exact success-count range')
        require(set(case.get('roles',{})) == set(ROLES), 'Every case requires handwritten-c, bend-qbe and bend-c')
        for name, role in case['roles'].items():
            declared = input_pins(role.get('inputs'))
            inputs += declared
            allowed = {row['file'] for row in [*frozen.values(),*declared]}
            command = role.get('command')
            require(isinstance(command,list) and 0 < len(command) <= 32 and all(
                isinstance(word,str) and 0 < len(word) <= 32768 and '\x00' not in word for word in command),
                'Bounded explicit command argv required')
            require(command[0] in allowed and os.access(command[0],os.X_OK), 'Command executable is not pinned/executable')
            require(all(word in allowed for word in command if Path(word).is_absolute()), 'Unpinned command file')
            if name == REFERENCE:
                require(len(command) == 2 and command[1] in allowed, 'Handwritten C requires binary and pinned expected-output file')
                require(Path(command[1]).read_bytes() == point['expectedStdout'].encode('utf8'), 'Handwritten C expected file differs from catalog')
    return document, bench.unique_inputs([identity,*inputs]), identity


def next_repetitions(repetitions, elapsed_ms, target_ms):
    if elapsed_ms > 2*target_ms and repetitions > 1:
        return max(1,(repetitions*target_ms+elapsed_ms-1)//elapsed_ms)
    if elapsed_ms == 0:
        proposed = repetitions*10
    else:
        proposed = (repetitions*target_ms + elapsed_ms-1)//elapsed_ms
    return min(MAX_REPETITIONS,max(repetitions+1,proposed))


def case_summary(case, rounds):
    result = bench.summary(case['samples'],list(ROLES),REFERENCE,rounds,case['point']['ratioEligible'])
    result['admitted'] = result['complete'] and (not result['ratioEligible'] or result['ratios'] is not None)
    result['logRatios'] = None
    result['bestBendEnvelope'] = None
    if result['ratios'] is not None:
        result['logRatios'] = {role:math.log(ratio) for role,ratio in result['ratios'].items()}
        winner = min(ROLES[1:],key=lambda role:result['stats'][role]['medianMs'])
        ratio = result['ratios'][winner]
        result['bestBendEnvelope'] = dict(role=winner,msPerInvocation=result['stats'][winner]['medianMs'],
            ratioToHandwrittenC=ratio,logRatio=math.log(ratio),
            scope='Post hoc per-case best median; not a single backend configuration.')
    return result


def weighted_ratios(cases, values):
    families, sources = {}, {}
    for case, ratio in zip(cases,values):
        families.setdefault(case['family'],[]).append(math.log(ratio))
        sources.setdefault(case['sourceGroup'],[]).append(math.log(ratio))
    logs = [math.log(value) for value in values]
    return dict(equalPointGeomean=math.exp(statistics.mean(logs)),meanLogRatio=statistics.mean(logs),
        meanPositiveLogSlowdown=statistics.mean(max(0,value) for value in logs),
        equalFamilyGeomean=math.exp(statistics.mean(statistics.mean(group) for group in families.values())),
        equalSourceGeomean=math.exp(statistics.mean(statistics.mean(group) for group in sources.values())),
        familyCount=len(families),sourceCount=len(sources),
        families={name:math.exp(statistics.mean(group)) for name,group in families.items()},
        sources={name:math.exp(statistics.mean(group)) for name,group in sources.items()})


def aggregate(cases):
    eligible = [case for case in cases if case['point']['ratioEligible']]
    if not eligible or not all(case['summary']['admitted'] for case in cases):
        return dict(complete=False,reason='No timed cases, or a selected case is incomplete, failed or below100ms.')
    roles = {role:weighted_ratios(eligible,[case['summary']['ratios'][role] for case in eligible]) for role in ROLES[1:]}
    envelope = weighted_ratios(eligible,[case['summary']['bestBendEnvelope']['ratioToHandwrittenC'] for case in eligible])
    envelope.update(scope='Post hoc per-case minimum of admitted Bend medians; not one backend.',
                    choices={case['id']:case['summary']['bestBendEnvelope']['role'] for case in eligible})
    return dict(complete=True,timedCases=len(eligible),correctnessOnlyCases=len(cases)-len(eligible),
                roles=roles,bestBendEnvelope=envelope)


def execute(args, root=ROOT):
    started = time.monotonic()
    require(math.isfinite(args.seconds) and 0 < args.seconds <= 900, 'Campaign deadline must be at most900 seconds')
    require(1 <= args.rounds <= 20 and 200 <= args.target_ms <= 300, 'Invalid rounds or calibration target')
    require(args.guarded and sorted(os.sched_getaffinity(0)) == [args.cpu], 'One outer guarded CPU lane required')
    clean_environment()
    require('BENDRTS' not in os.environ, 'Ambient BENDRTS must be unset')
    document, inputs, manifest_pin = load_manifest(args.manifest)
    known = {case['id']:case for case in document['cases']}
    names = args.cases.split(',') if args.cases else list(known)
    require(names and len(names) == len(set(names)) and all(name in known for name in names), 'Unknown, duplicate or empty case selection')
    selected = [known[name] for name in names]
    out = fresh_output(args.out,root)
    deadline = started+args.seconds
    report = dict(kind='phase184-direct-c-runtime-comparison',version=1,complete=False,status='running',
        manifest=manifest_pin,inputs=inputs,methods=[pin(path) for path in method_files()],reference=REFERENCE,roles=list(ROLES),
        selectedCaseIds=names,manifestCaseCount=len(known),allManifestCases=len(names) == len(known),fullCatalog=len(names) == 45,
        secondsLimit=args.seconds,targetMs=args.target_ms,minimumAcceptedMs=100,rounds=args.rounds,cpu=args.cpu,
        maximumRepetitions=MAX_REPETITIONS,maximumCalibrationAttempts=MAX_ATTEMPTS,childSecondsLimit=SAMPLE_SECONDS,
        scope='Runtime only; per-role calibrated normalized milliseconds per invocation. Not the historical equal-count score.',
        clock='Native45 in-program millisecond interval includes result validation and success-count printing.',
        ordering='Each case calibrates its roles then completes rotated serial rounds; starting role also rotates by case.',
        qualification='Exact fixed catalog output and per-invocation success counts; no build timing or compiler promotion.',
        cases=[dict(id=case['id'],family=case['family'],sourceGroup=case['sourceGroup'],point=case['point'],
                    status='pending',calibration={},pilots=[],samples=[]) for case in selected])

    def save(): write_json(out/'report.json',report)

    def sample(case, item, role, repetitions, stage, index):
        row = dict(role=role,repetitions=repetitions,warmups=case['point']['warmups'],correct=False,stage=stage)
        row['attempt' if stage == 'pilot' else 'round'] = index
        item['pilots' if stage == 'pilot' else 'samples'].append(row); save()
        directory = out/stage/case['id']/(str(index)+'-'+role)
        try:
            require(time.monotonic() < deadline,'Campaign deadline exhausted before child')
            command = [*case['roles'][role]['command'],str(repetitions),str(case['point']['warmups']),
                       *map(str,case['point']['runtimeArgs'])]
            child = bench.child(command,directory,min(deadline,time.monotonic()+SAMPLE_SECONDS),root)
            row['process'] = child
            require(not child['timedOut'],'Child deadline exceeded')
            require(child['stdout']['bytes'] <= len(case['point']['expectedStdout'].encode('utf8'))+128,
                    'Output exceeds exact native45 contract bound')
            point = dict(case['point'],repetitions=repetitions)
            elapsed = bench.observation(verify(child['stdout']).read_bytes(),verify(child['stderr']).read_bytes(),
                                        child['exitCode'],point,child['seconds'])
            row.update(correct=True,elapsedMs=elapsed,metricMs=elapsed/repetitions,
                       lowResolution=point['ratioEligible'] and elapsed < 100)
        except (OSError,ValueError,TimeoutError) as error:
            row['error'] = str(error)
            row['retainedStreams'] = [pin(directory/name) for name in ('stdout','stderr') if (directory/name).is_file()]
        save()
        return row

    save()
    try:
        for case_index, (case,item) in enumerate(zip(selected,report['cases'])):
            if time.monotonic() >= deadline: break
            item['status'] = 'calibrating'; save()
            order = ROLES[case_index%3:]+ROLES[:case_index%3]
            for role in order:
                repetitions = case['point']['repetitions']
                calibration = dict(startingRepetitions=repetitions,complete=False)
                item['calibration'][role] = calibration
                if not case['point']['ratioEligible']:
                    calibration.update(complete=True,repetitions=repetitions,reason='Correctness-only zero-work control')
                    continue
                for attempt in range(MAX_ATTEMPTS):
                    if time.monotonic() >= deadline: break
                    row = sample(case,item,role,repetitions,'pilot',attempt)
                    if not row['correct']: break
                    if row['elapsedMs'] >= args.target_ms and (row['elapsedMs'] <= 2*args.target_ms or repetitions == 1):
                        calibration.update(complete=True,repetitions=repetitions,pilotElapsedMs=row['elapsedMs'])
                        break
                    next_count = next_repetitions(repetitions,row['elapsedMs'],args.target_ms)
                    if next_count == repetitions:
                        calibration['error'] = 'Repetition ceiling reached below calibration target'; break
                    row.update(nextRepetitions=next_count,adjustment='down' if next_count < repetitions else 'up')
                    repetitions = next_count
                if not calibration['complete']:
                    calibration.setdefault('error','Calibration failed, exhausted its attempts, or reached the campaign deadline')
                save()
            if not all(item['calibration'].get(role,{}).get('complete') for role in ROLES):
                item['status'] = 'calibration-incomplete'; save(); continue
            item['status'] = 'timing'; save()
            for index in range(args.rounds):
                order = ROLES[(index+case_index)%3:]+ROLES[:(index+case_index)%3]
                for role in order:
                    if time.monotonic() >= deadline: break
                    sample(case,item,role,item['calibration'][role]['repetitions'],'timed',index)
                if time.monotonic() >= deadline: break
            item['summary'] = case_summary(item,args.rounds)
            item['status'] = 'complete' if item['summary']['admitted'] else 'timing-incomplete'
            save()
    except (OSError,ValueError,TimeoutError,KeyboardInterrupt) as error:
        report['error'] = str(error) or type(error).__name__
    finally:
        for item in report['cases']: item['summary'] = case_summary(item,args.rounds)
        report['executionComplete'] = all(item['summary']['complete'] for item in report['cases'])
        report['changedInputs'] = changed_inputs(inputs)
        report['deadlineReached'] = time.monotonic() >= deadline
        report['aggregate'] = aggregate(report['cases'])
        report['complete'] = not report['changedInputs'] and not report.get('error') and all(item['summary']['admitted'] for item in report['cases'])
        if report['changedInputs']:
            for item in report['cases']:
                item['summary'].update(admitted=False,ratios=None,logRatios=None,bestBendEnvelope=None)
            report['aggregate'] = dict(complete=False,reason='Frozen inputs changed; recorded observations are invalidated.')
        report['wallSeconds'] = time.monotonic()-started
        report['deadlineOverrunSeconds'] = max(0,report['wallSeconds']-args.seconds)
        report['deadlineReached'] = report['wallSeconds'] >= args.seconds
        if report['deadlineReached']:
            report['complete'] = False
            report['aggregate'] = dict(complete=False,reason='Campaign deadline reached; retain individual admitted case summaries only.')
        report['status'] = 'complete' if report['complete'] else 'partial'
        save()
    return report


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--manifest',type=Path,required=True)
    parser.add_argument('--cases',help='Comma-separated explicit IDs; default all manifest cases')
    parser.add_argument('--rounds',type=int,default=3)
    parser.add_argument('--seconds',type=float,default=900)
    parser.add_argument('--target-ms',type=int,default=250)
    parser.add_argument('--guarded',action='store_true')
    parser.add_argument('--cpu',type=int,default=3)
    parser.add_argument('--out',type=Path,required=True)
    report = execute(parser.parse_args())
    print(json.dumps({key:report[key] for key in ('complete','status','wallSeconds','aggregate')},indent=2))
    return 0 if report['complete'] else 1


if __name__ == '__main__':
    try: raise SystemExit(main())
    except (OSError,ValueError,KeyError,TypeError) as error:
        print('runtime comparison: '+str(error),file=sys.stderr); raise SystemExit(1)

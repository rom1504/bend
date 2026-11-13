#!/usr/bin/env python3
"""Pool existing captures within each exact variant; never edit source receipts.

Calls the maintained comparator's pool_captures after independently checking
the raw run, frozen command, binary, outputs, and capture-analysis identities.
Role-specific repetition counts prohibit the ordinary cross-variant comparison.
"""
import argparse
import json
from pathlib import Path
import statistics
import sys

sys.dont_write_bytecode = True
ROOT = Path(__file__).resolve().parents[3]
sys.path.insert(0, str(ROOT/'selfhost/tools/profiler'))
import compare as C
import run as R


def require(condition, message):
    if not condition:
        raise ValueError(message)


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--report', type=Path, required=True)
    p.add_argument('--out', type=Path, required=True)
    a = p.parse_args()
    require(not a.out.exists(), 'Fresh analysis output required')
    reader = C.Reader()
    raw_pin = C.pin(a.report)
    raw = reader.read(raw_pin)
    require(raw.get('complete') and raw.get('passed') and not raw.get('changedInputs'), 'Complete unchanged output-checked run required')
    require(raw['schema'] == 'bend-native-profile-run-v1', 'Unexpected run schema')
    manifest_pin = C.pin(a.report.parent/'manifest.json')
    require(any(item['sha256'] == manifest_pin['sha256'] and item['bytes'] == manifest_pin['bytes']
                for item in raw['inputs']), 'Original manifest not bound to run')
    manifest = reader.read(manifest_pin)
    for item in raw['inputs']:
        reader.verify(item)
    for item in R.all_pins(manifest):
        reader.verify(item)
    result = dict(kind='phase190-within-role-physical-pools', complete=False, targetsRun=False,
        originalReport=raw_pin, originalManifest=manifest_pin, method=C.pin(__file__),
        poolingMethod=C.pin(C.__file__), sourceRunUnmodified=True, roles={},
        scope='Derived independent within-role pools; no cross-role workload-identity or qualification claim. Per-repetition CPU is a descriptive normalization of one clean observation.')
    try:
        C.summarize_reports([a.report])
    except ValueError as error:
        require(str(error).startswith('Same workload name has different source/arguments:'),
                'Unexpected maintained comparator rejection: '+str(error))
        result['preservedComparatorRejection'] = dict(error=str(error), method=C.pin(C.__file__),
            reason='Each role has a distinct calibrated repetition argument; retain original manifests/reports and pool only identical role commands.')
    else:
        raise ValueError('Expected different-repetition comparison rejection was not observed')
    for workload in manifest['workloads']:
        for variant in workload['variants']:
            key = workload['name']+':'+variant['name']
            rows = [row for row in raw['rows'] if (row['workload'],row['variant']) == (workload['name'],variant['name'])]
            require(len(rows) == 3 and sorted(row['mode'] for row in rows) == ['clean','sample','sample'],
                    'Exactly one clean and two samples required per role')
            command = variant['command']
            marker = command.index('--RTS')
            count, warmups = int(command[marker+1]), int(command[marker+2])
            require(count > 0 and warmups >= 0, 'Explicit positive repetitions required')
            captures = []
            for row in rows:
                require(row['correct'] and row['command'] == command and not row.get('timedOut')
                        and row['returncode'] == variant['expected'].get('exitCode',0)
                        and row.get('argv0',command[0]) == C._effective_argv0(variant)
                        and not row.get('diagnosticRuntime'), 'Role execution identity/status mismatch')
                for stream in ('stdout','stderr'):
                    require(R.output_matches(reader.verify(row[stream]),variant['expected'][stream]), 'Independent output mismatch')
                if row['mode'] == 'sample':
                    analysis = reader.read(row['analysis'])
                    reader.verify(row['profile'])
                    require(analysis['identities']['capture']['sha256'] == row['profile']['sha256']
                            and analysis['identities']['binary']['sha256'] == variant['binary']['sha256'],
                            'Capture/binary analysis mismatch')
                    captures.append(dict(identity=row['analysis'],analysis=analysis,childCpuSeconds=row['cpuSeconds']))
            require(sorted(c['analysis']['header']['period_us'] for c in captures) == [8000,13000], 'Both8/13ms periods required')
            clean = next(row for row in rows if row['mode']=='clean')
            pooled = C.pool_captures(captures,clean['cpuSeconds'],minimum_samples=500)
            admitted = (pooled['adequate'] and pooled['estimateAvailable'] and not pooled['rejectedCaptures']
                        and pooled['unknownSamples'] == 0)
            result['roles'][key] = dict(binary=variant['binary'], command=command,
                sourceIdentity=C._source_identity(variant,manifest['cwd']),
                repetitions=count,warmups=warmups,cleanObservation=clean,
                cleanCpuSecondsPerRepetition=clean['cpuSeconds']/count,
                sampledOverCleanWallRatio=statistics.median(row['wallSeconds'] for row in rows if row['mode']=='sample')/clean['wallSeconds'],
                quantitativelyAdmitted=admitted, profile=pooled)
    result['complete'] = True
    a.out.mkdir(parents=True)
    R.save(a.out/'report.json',result)
    for key,value in result['roles'].items():
        print(key,json.dumps(dict(admitted=value['quantitativelyAdmitted'],
            cpuMicrosecondsPerRepetition=value['cleanCpuSecondsPerRepetition']*1e6,
            samples=value['profile']['samples'],functions=value['profile']['functions'][:4]),indent=2))


if __name__ == '__main__':
    main()

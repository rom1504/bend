#!/usr/bin/env python3
"""Bounded same-executable screen; retain every failed or neutral hypothesis."""
import argparse
import json
import statistics
import sys
import time
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
sys.dont_write_bytecode = True
sys.path.insert(0, str(ROOT/'selfhost/tools/build'))
from common import fresh_output, pin, require, run, verify, write_json


def main():
    p = argparse.ArgumentParser()
    p.add_argument('--manifest', type=Path, required=True)
    p.add_argument('--controls', type=Path, required=True)
    p.add_argument('--out', type=Path, required=True)
    p.add_argument('--ids', default='')
    p.add_argument('--budget-seconds', type=float, default=240)
    p.add_argument('--pairs', type=int, default=3)
    a = p.parse_args()
    plan = json.loads(a.manifest.read_text())
    controls = json.loads(a.controls.read_text())
    build_path, api_path = Path(plan['buildReport']), Path(plan['apiReport'])
    build, api = json.loads(build_path.read_text()), json.loads(api_path.read_text())
    require(build['complete'] and api['complete'] and api['checked'], 'Checked native image required')
    require(build['request']['source'] == plan['source'] == api['source'] == controls['source'], 'Source mismatch')
    require(controls['complete'], 'Complete hosted controls required')
    require(2 <= a.pairs <= 5, 'Bounded balanced pairs required')
    binary = pin(plan['binary'])
    require(binary == build['binary'], 'Native image changed')
    inputs = [pin(__file__), pin(a.manifest), pin(a.controls), pin(build_path), pin(api_path), binary,
              plan['source'], *plan['inputs'], *build['inputs'], *api['inputs']]
    for row in inputs: verify(row)
    out = fresh_output(a.out, ROOT)
    start = time.monotonic()
    result = dict(kind='phase155-native-screen', complete=False, inputs=inputs, rows=[], extraChecks=[],
                  scope='Whole child times include setup, computation, output and destruction. '
                        'Kernel/region screens, not whole compiler or generated-program scores.')
    def save(): write_json(out/'report.json', result)
    save()
    for index,check in enumerate(plan.get('extraChecks',[])):
        folder=out/('extra-'+str(index));folder.mkdir()
        process=run([binary['file'],'--threads','1','--gpu','off','--','screen',check['argumentId'],'old','0'],
                    cwd=ROOT,stdout=folder/'stdout',stderr=folder/'stderr',seconds=8)
        expected=str(int(check['expected'])) if isinstance(check['expected'],bool) else str(check['expected'])
        passed=process['complete'] and process['exitCode']==0 and (folder/'stderr').stat().st_size==0 and (folder/'stdout').read_bytes()==(expected+'\n').encode()
        result['extraChecks'].append(dict(check,passed=passed,process=process));save()
    selected = set(a.ids.split(',')) if a.ids else None
    for case in plan['cases']:
        if selected and case['id'] not in selected: continue
        gate = next(r for r in controls['rows'] if r['id'] == case['id'])
        extra_ok = all(r['passed'] for r in controls.get('extraChecks', [])+result['extraChecks'] if r['family'] == case['family'])
        row = dict(id=case['id'], title=case['title'], family=case['family'], complete=False,
                   calls=[], pairs=[], status='pending')
        result['rows'].append(row); save()
        if not gate['passed'] or not extra_ok:
            row.update(complete=True, status='rejected-correctness'); save(); continue
        case_start = time.monotonic()
        def invoke(role, n, kind, expected=None):
            require(time.monotonic()-start < a.budget_seconds, 'Whole screen budget reached')
            require(time.monotonic()-case_start < 45, 'Per-idea budget reached')
            folder = out/(case['id']+'-'+str(len(row['calls'])))
            folder.mkdir()
            proc = run([binary['file'], '--threads', '1', '--gpu', 'off', '--', 'screen', case['id'], role, str(n)],
                       cwd=ROOT, stdout=folder/'stdout', stderr=folder/'stderr', seconds=8)
            call = dict(role=role, n=n, kind=kind, process=proc)
            row['calls'].append(call); save()
            require(proc['complete'] and proc['exitCode']==0 and (folder/'stderr').stat().st_size==0, 'Native process failed')
            value = (folder/'stdout').read_bytes()
            require(len(value) <= 8_000_000, 'Bounded complete output required')
            if expected is not None: require(value == expected, 'Complete native output mismatch')
            return call, value
        try:
            for point in gate['controls']:
                expected = (point['old']+'\n').encode()
                for role in ('old','new'): invoke(role,point['n'],'native-control',expected)
            zero = [invoke(role,0,'startup')[0]['process']['seconds'] for role in ('old','new')]
            target = max(.12, 3 * max(zero)); row['targetSeconds'] = target
            n = 1
            while True:
                old, expected = invoke('old', n, 'calibration')
                new, _ = invoke('new', n, 'calibration', expected)
                if min(old['process']['seconds'],new['process']['seconds']) >= target: break
                require(n < 65536, 'Insufficient signal at repetition cap')
                n = min(65536,n*4)
            row['n'] = n
            for pair in range(a.pairs):
                order = ['old','new'] if pair%2==0 else ['new','old']
                measurements = {}
                for role in order:
                    call,_ = invoke(role,n,'timed',expected)
                    measurements[role]=call['process']['seconds']
                row['pairs'].append(dict(order=order,seconds=measurements,ratio=measurements['new']/measurements['old'])); save()
            row['medianSeconds'] = {role:statistics.median(p['seconds'][role] for p in row['pairs']) for role in ('old','new')}
            row['ratio'] = row['medianSeconds']['new']/row['medianSeconds']['old']
            row['status'] = 'win-screen' if row['ratio'] < .95 else 'loss-screen' if row['ratio'] > 1.05 else 'neutral-screen'
            row['complete']=True
        except Exception as error:
            row.update(complete=True,status='screen-refused',error=repr(error))
        row['elapsedSeconds']=time.monotonic()-case_start;save()
        print(json.dumps({k:row[k] for k in ('id','status','ratio','error') if k in row}),flush=True)
    for row in inputs: verify(row)
    result.update(complete=True,elapsedSeconds=time.monotonic()-start);save()


if __name__ == '__main__': main()

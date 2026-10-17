#!/usr/bin/env python3
"""Build and execute representative measured products; not a runtime benchmark."""
import argparse
import importlib.util
import json
import os
from pathlib import Path
import shutil
import subprocess
import sys
import time

sys.dont_write_bytecode = True
HERE = Path(__file__).resolve().parent
spec = importlib.util.spec_from_file_location('comparison', HERE/'compare.py')
C = importlib.util.module_from_spec(spec); spec.loader.exec_module(C)
ROOT, P, pin, verify, read, save = C.ROOT, C.P, C.pin, C.verify, C.read, C.save
SELECTED = ['lexer', 'variation-ray-active-256-2240', 'coverage-closures-256',
            'coverage-unicode-text-64', 'coverage-map-churn-128', 'coverage-numeric-recurrence-1024']


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--comparison', type=Path, required=True)
    p.add_argument('--out', type=Path, required=True)
    a = p.parse_args(); parent_pin = pin(a.comparison); parent = read(a.comparison)
    assert parent['complete'] and parent['passed'] and parent['corpus']=='broad45'
    out = a.out.resolve()
    assert out.is_relative_to(ROOT/'selfhost/build/phase105') and not out.exists()
    out.mkdir(parents=True)
    builds = [read(verify(parent['stages'][s]['build'])['file']) for s in ('b1','b2')]
    assert builds[0]['clang'] == builds[1]['clang']
    clang = verify(builds[0]['clang'])
    methods = [pin(f) for f in [__file__,HERE/'compare.py',P/'phase46/execute.py',P/'phase86/guard.py',P/'programs/support.py']]
    report = dict(complete=False, passed=False, comparison=parent_pin, clang=clang, methods=methods,
        selected=SELECTED, products=[], started=time.time(),
        scope='Six varied closed45 products, native B1/B2 identical C built once plus upstream. '
              'Matched O2 CPU3 builds and one-worker executions verify complete output. '
              'Build clocks are single observations; execution is correctness only, not a program-speed comparison.')
    def checkpoint(): save(out/'report.json',report)
    checkpoint()
    def run(label, argv, seconds):
        assert shutil.disk_usage(ROOT).free > 192*1024**2
        prefix = out/label
        command = [sys.executable,'-B',str(P/'phase86/guard.py'),'--out',str(prefix)+'-guard',
            '--seconds',str(seconds),'--rss-mib','2048','--available-mib','4096','--cpu','3','--',
            sys.executable,'-B',str(P/'phase46/execute.py'),str(prefix)+'.child.json',*map(str,argv)]
        done = subprocess.run(command,cwd=ROOT,capture_output=True,text=True)
        Path(str(prefix)+'.stdout').write_text(done.stdout);Path(str(prefix)+'.stderr').write_text(done.stderr)
        guard = read(str(prefix)+'-guard/process.json')
        assert done.returncode==0 and guard['complete'] and not guard.get('stoppedFor'),('Failed',label)
        child = read(str(prefix)+'.child.json');assert child['returncode']==0
        return dict(command=command, guard=pin(str(prefix)+'-guard/process.json'),
                    child=pin(str(prefix)+'.child.json'), processSeconds=child['processSeconds'],
                    peakRssKiB=child['maxRssKiB']), child
    try:
        for name in SELECTED:
            case = next(c for c in parent['cases'] if c['name']==name)
            for role in ('b2','upstream'):
                sample = next(r for r in parent['rows'] if r['case']==name and r['role']==role and not r['acquisition'])
                product = verify(sample['output'])
                if role=='b2':
                    b1 = next(r for r in parent['rows'] if r['case']==name and r['role']=='b1')
                    assert C.same(verify(b1['output']),product)
                row = dict(case=name,role=role,c=product,passed=False)
                report['products'].append(row);checkpoint()
                binary = out/(name+'-'+role)
                row['build'],_ = run(name+'-'+role+'-build',[
                    clang['file'],'-isystem',str(Path(clang['file']).parents[1]/'include/clang'),
                    '-O2',product['file'],'-o',binary,'-lm','-pthread'],60)
                row['binary']=pin(binary)
                row['execution'],child = run(name+'-'+role+'-execute',[binary,*case['runtimeArgs']],20)
                assert child['stdout']==case['expectedStdout'] and child['stderr']==case['expectedStderr'],('Behavior differs',name,role)
                row.update(passed=True,exactStdout=True,exactStderr=True);checkpoint()
                print(json.dumps(dict(case=name,role=role,passed=True,buildSeconds=row['build']['processSeconds'])),flush=True)
        verify(parent_pin);verify(clang)
        for method in methods:verify(method)
        report.update(complete=True,passed=True)
    except BaseException as error:
        report['error']=repr(error);raise
    finally:
        report['finished']=time.time();checkpoint()


if __name__=='__main__':main()

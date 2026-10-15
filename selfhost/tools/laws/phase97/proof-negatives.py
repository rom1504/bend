#!/usr/bin/env python3
"""Require semantic proof failures, with standalone acceptance of wrong helpers."""
import argparse
import hashlib
import json
from pathlib import Path
import re
import subprocess
import sys

ROOT=Path(__file__).resolve().parents[4]
CHECK=Path(__file__).with_name('check.py')


def pin(path):
    path=Path(path).resolve();data=path.read_bytes()
    return dict(file=str(path),bytes=len(data),sha256=hashlib.sha256(data).hexdigest())


def main():
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument('--plan',type=Path,required=True);p.add_argument('--out',type=Path,required=True)
    a=p.parse_args();out=a.out.resolve();out.mkdir(parents=True,exist_ok=False)
    plan=json.loads(a.plan.read_text());jobs=[]
    if 'jobs' in plan:
        assert pin(CHECK)==plan['checker']
        jobs=plan['jobs']
    else:
        for row in plan['rows']:
            assert row['lawSource']['sha256']==row['positiveLaw']['sha256']
            jobs.extend([
                dict(name=row['id']+'-helper',source=row['helperSource'],expectedExit=0,requires=[],classification='well-formed safe semantic mutant'),
                dict(name=row['id']+'-law',source=row['lawSource'],expectedExit=1,requires=[row['id']+'-helper'],classification='frozen production law rejects wrong helper')])
    report=dict(complete=False,plan=pin(a.plan),checker=pin(CHECK),method=pin(__file__),rows=[])
    def save():(out/'report.json').write_text(json.dumps(report,indent=2)+'\n')
    passed=set()
    try:
        for job in jobs:
            assert set(job['requires'])<=passed
            assert pin(job['source']['file'])==job['source']
            folder=out/job['name']
            command=[sys.executable,'-B',str(CHECK),'--source',job['source']['file'],'--out',str(folder),'--source-only']
            proc=subprocess.run(command,cwd=ROOT,capture_output=True,text=True)
            (out/(job['name']+'.stdout')).write_text(proc.stdout)
            (out/(job['name']+'.stderr')).write_text(proc.stderr)
            result=json.loads((folder/'report.json').read_text())
            check=result['rows']['check'];execution=check['process']
            row=dict(name=job['name'],classification=job['classification'],expectedExit=job['expectedExit'],
                     report=pin(folder/'report.json'),passed=False,requires=job['requires'])
            report['rows'].append(row);save()
            assert execution['returncode']==job['expectedExit'] and not execution.get('stoppedFor')
            assert proc.returncode==job['expectedExit']
            if job['expectedExit']==0:
                assert result['complete'] and check['stdout']=='ALL PROOFS CHECK\nUse --verdict for mathematical validity.\n' and not check['stderr']
            else:
                diagnostic=check['stderr']
                assert diagnostic.startswith('SOME PROOFS FAIL\nError:\n- expected :') and '- observed :' in diagnostic,diagnostic
                assert not any(x in diagnostic for x in ['consumed more than once','unfilled law','expected an expression','SyntaxError']),diagnostic
                location=re.search(r'^Location: (.+)$',diagnostic,re.M);assert location,diagnostic
                assert any(name in location[1] for name in result['lawNames']), ('Not rejected in a law body',diagnostic)
                row['rejectedLaw']=location[1];row['diagnostic']=diagnostic
            row['passed']=True;passed.add(job['name']);save()
            print(json.dumps(dict(name=job['name'],passed=True,expectedExit=job['expectedExit'])),flush=True)
        assert pin(CHECK)==report['checker'] and pin(a.plan)==report['plan'] and pin(__file__)==report['method']
        report.update(complete=True,rejectedCases=sum(j['expectedExit']==1 for j in jobs),helperAdmissions=sum(j['expectedExit']==0 for j in jobs))
    except BaseException as error:
        report['error']=repr(error);raise
    finally:save()


if __name__=='__main__':main()

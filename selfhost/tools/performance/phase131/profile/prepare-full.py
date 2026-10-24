#!/usr/bin/env python3
"""Prepare one bounded full-source final-N2 sample; no target execution."""
import argparse
import copy
import json
from pathlib import Path
import sys

ROOT=Path(__file__).resolve().parents[5]
PROF=ROOT/'selfhost/tools/profiler'
sys.dont_write_bytecode=True
sys.path.insert(0,str(PROF))
from run import pin,verify,save,all_pins


def read(path):return json.loads(Path(path).read_text())


def main():
    p=argparse.ArgumentParser(description=__doc__);p.add_argument('--out',type=Path,required=True);a=p.parse_args()
    out=a.out.resolve();assert not out.exists() and out.is_relative_to(ROOT/'selfhost/build/phase131')
    short=ROOT/'selfhost/build/phase131/final-profile01/manifest.json';m=copy.deepcopy(read(short))
    qualification=ROOT/'selfhost/build/phase131/final-native-qualification01.json';q=read(qualification)
    native=ROOT/'selfhost/build/phase130/p131-final-reproduce01/report.json';r=read(native)
    assert q['complete'] and q['nativeQualified'] and q['byteExact']
    assert r['complete'] and r['byteExact'] and r['exitCode']==0 and not r['changedInputs']
    assert r['source']==q['source'] and r['image']==q['n2'] and r['product']==q['reproducedQbe']['right']
    expected=q['reproducedQbe']['left']
    assert expected['sha256']==r['product']['sha256'] and expected['bytes']==r['product']['bytes']
    original=m['workloads'][0]['variants'][0]
    assert original['binary']==q['n2'] and original['command'][8:]==r['command'][8:]
    variant=copy.deepcopy(original);variant['command']=r['command'];variant['inputs']=[pin(x) for x in r['command'] if Path(x).is_file()]
    variant['expected']=dict(exitCode=0,stdout=dict(kind='exact',**expected),stderr=dict(kind='exact',**r['stderr']))
    m['workloads']=[dict(name='compiler-self-source',timeoutSeconds=540,variants=[variant])]
    m['inputs'] += [pin(__file__),pin(short),pin(qualification),pin(native),q['source'],q['n2'],expected,pin(PROF/'run.py')]
    m['scope']='One sample-only full compiler-source request by actual final N2,32ms sampled-thread CPU period. Exact107MB pre-existing Q2 oracle. No paired clean baseline or newly measured speed ratio; generic absolute CPU scaling stays unavailable.'
    m['adjacentHistoricalClean']=dict(receipt=pin(native),nativeSeconds=r['nativeSeconds'],cpuSeconds=r['cpuSeconds'],
        role='Earlier same-image/source emission; not an interleaved clean baseline. Retained as context only, never inserted as a profiler row.')
    m['resourcePlan']=dict(outerGuardSeconds=600,innerTargetTimeoutSeconds=540,treeRssLimitMiB=4096,
        availableFloorMiB=16384,fileSizeLimitMiB=256,coreLimitBytes=0,cpu=3,
        outputHandling='Target stdout streams directly to an exclusive file; exact-output authentication hashes1MiB blocks. No full-output Python read_bytes path applies.',
        expectedStdoutBytes=expected['bytes'],oneNewQbeOutput=True)
    for item in all_pins(m):verify(item)
    out.mkdir(parents=True);save(out/'manifest.json',m)
    command=[sys.executable,'-B',str(PROF/'run.py'),'--manifest',str(out/'manifest.json'),
        '--out',str(out/'capture'),'--names','compiler-self-source','--modes','sample','--rounds','1','--periods-us','32000']
    save(out/'jobs.json',dict(complete=True,targetsRun=False,inputs=[pin(__file__),pin(out/'manifest.json'),pin(PROF/'run.py')],
        jobs=[dict(name='final-n2-full-source-sample',seconds=600,command=command)],resourcePlan=m['resourcePlan']))
    print(json.dumps(dict(complete=True,targetsRun=False,manifest=pin(out/'manifest.json'),jobs=pin(out/'jobs.json'),command=command)))


if __name__=='__main__':main()

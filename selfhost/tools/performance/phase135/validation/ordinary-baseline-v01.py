#!/usr/bin/env python3
"""Pin/run the existing uncached ordinary entry of the SAME session executable."""
import argparse
import importlib.util
import json
from pathlib import Path
import subprocess
import sys
import time

sys.dont_write_bytecode=True
ROOT=Path(__file__).resolve().parents[5]
FULL=ROOT/'selfhost/tools/performance/phase135/validation/full-session-v01.py'
spec=importlib.util.spec_from_file_location('full_session',FULL);F=importlib.util.module_from_spec(spec);spec.loader.exec_module(F)
pin,verify,require=F.pin,F.verify,F.require
COMPOSER=ROOT/'selfhost/tools/performance/phase131/prepare.py'
spec=importlib.util.spec_from_file_location('source_compose',COMPOSER);P=importlib.util.module_from_spec(spec);spec.loader.exec_module(P)
METHOD=ROOT/'selfhost/tools/performance/phase130/native-request.py'


def main():
    ap=argparse.ArgumentParser(description=__doc__);g=ap.add_mutually_exclusive_group(required=True)
    g.add_argument('--prepare',action='store_true');g.add_argument('--run',action='store_true')
    ap.add_argument('--plan',type=Path,required=True);ap.add_argument('--full-plan',type=Path);ap.add_argument('--out',type=Path)
    a=ap.parse_args()
    if a.prepare:
        require(a.full_plan is not None and a.out is not None,'Full plan and result path required')
        full=F.read(a.full_plan);core_path=ROOT/'implementation/phase134/final/candidate.json';core=F.read(core_path)
        require(full['complete'] and core['complete'] and core['nativeQualified'],'Frozen session and qualified core required')
        old=P.blocks(verify(core['source']).read_text());new=P.blocks(verify(full['experimentalCompilerSource']).read_text())
        require(set(old)<=set(new),'Original declaration missing')
        changed=[n for n in old if P.norm(old[n])!=P.norm(new[n])]
        require(changed==['p111_native_args'],'Ordinary compiler declarations changed')
        arm='    case Con{program,Con{+path,Con{+base,Con{+mode,Con{+cache,Con{+stamp,Nil{}}}}}}}:'
        require(arm in old['p111_native_args'] and arm in new['p111_native_args'],'Ordinary CLI arm missing')
        require(P.norm(old['p111_native_args'][old['p111_native_args'].index(arm):])==P.norm(new['p111_native_args'][new['p111_native_args'].index(arm):]),'Ordinary CLI arm/failure changed')
        prior=F.read(ROOT/'selfhost/build/phase134/session-native-plan04/plan.json')
        carrier_receipt=F.read(core_path)['preferredCarrierReceipt']
        command=[sys.executable,str(METHOD),'--image',full['image']['file'],'--source',full['revisions'][1]['source']['file'],
            '--carrier-receipt',carrier_receipt['file'],'--expected-qbe',full['revisions'][1]['expectedQbe']['file'],
            '--seconds','650','--out',str(a.out.absolute())]
        inputs=[pin(__file__),pin(FULL),pin(METHOD),pin(COMPOSER),pin(a.full_plan),pin(core_path),core['source'],
            full['experimentalCompilerSource'],*full['inputs'],carrier_receipt]
        inputs=list({(x['file'],x['sha256']):x for x in inputs}.values())
        for x in inputs:verify(x)
        folder=a.plan.absolute().parent;require(folder==folder.resolve() and folder.is_relative_to(ROOT/'selfhost/build/phase135') and not folder.exists(),'Fresh Phase135 plan required')
        require(a.out.absolute().is_relative_to(ROOT/'selfhost/build/phase130') and not a.out.exists(),'Existing request driver requires fresh Phase130 output')
        folder.mkdir(parents=True)
        plan=dict(kind='phase135-equal-image-ordinary-baseline',complete=True,inputs=inputs,command=command,
            image=full['image'],source=full['revisions'][1]['source'],expectedQbe=full['revisions'][1]['expectedQbe'],
            unchangedSharedDeclarationCount=len(old)-1,changedSharedDeclarations=changed,ordinaryCliArmExact=True,
            sourceComparison='Exact declaration text after removing whitespace-only/comment-only lines, using existing source composer; native ordinary CLI arm and original failure are identical.',
            guards=dict(cpu=3,seconds=700,rssMiB=4096,availableMiB=16384,fileMiB=256),
            scope='Uncached ordinary B on the SAME experimental executable, actual historical B path and independent fullQBE. Entire child process includes Base preparation,startup,render,close; warm B interval excludes session preparation. No fulltwo-revision no-cache or upstream ratio from this single observation.')
        F.save(a.plan,plan);print(json.dumps(dict(complete=True,plan=pin(a.plan),targetsRun=False)));return 0
    plan=F.read(a.plan);require(plan['complete'] and pin(__file__)in plan['inputs'],'Frozen baseline plan required')
    for x in plan['inputs']:verify(x)
    started=time.monotonic();result=subprocess.run(plan['command'],cwd=ROOT,check=False)
    report=dict(complete=result.returncode==0,exitCode=result.returncode,wallSeconds=time.monotonic()-started,plan=pin(a.plan),scope=plan['scope'],changedInputs=[])
    for x in plan['inputs']:
        try:verify(x)
        except(OSError,ValueError):report['changedInputs'].append(x['file']);report['complete']=False
    F.save(a.plan.parent/'execution.json',report)
    return 0if report['complete']else 1


if __name__=='__main__':sys.exit(main())

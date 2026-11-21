#!/usr/bin/env python3
"""Freeze a Phase200 runtime screen and exact guarded argv; execute nothing."""
import argparse,importlib.util,json,re,sys
from pathlib import Path
sys.dont_write_bytecode=True
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[2]
spec=importlib.util.spec_from_file_location('screen',HERE/'screen.py');M=importlib.util.module_from_spec(spec);spec.loader.exec_module(M);B=M.B
FOCUS=['mandelbrot','lexer','symreg','test-map-set-ops','coverage-bst-64','coverage-record-aggregation-256']
p=argparse.ArgumentParser();p.add_argument('--name',required=True);p.add_argument('--runtime',required=True,type=Path);p.add_argument('--receipt',required=True,type=Path);p.add_argument('--cases',default=','.join(FOCUS));p.add_argument('--native-manifest',type=Path,default=ROOT/'selfhost/build/phase198/p199-integrated-native45-01/programs.manifest.json');p.add_argument('--native-role',default='candidate');a=p.parse_args()
assert re.fullmatch(r'[a-z0-9][a-z0-9-]{0,70}',a.name)
base=B.read(M.BASE/'manifest.json');names=[c['id'] for c in base['cases']] if a.cases=='all' else a.cases.split(',');assert len(names)==len(set(names)) and all(n in {c['id'] for c in base['cases']} for n in names)
source=B.read(a.native_manifest);assert a.native_role in source['roles'] and all(n in {c['id'] for c in source['cases']} for n in names)
runtime=B.pin(a.runtime);receipt=B.read(a.receipt);assert receipt['complete'] and any(M.verify(pin)==runtime for pin in M.nested_pins(receipt))
paths=[a.runtime,a.receipt,a.native_manifest,M.BASE/'manifest.json',M.BASE/'report.json',HERE/'screen.py',HERE/'make-plan.py',HERE/'job.py',M.R.__file__,M.S.__file__,M.S.S.__file__,M.S.S.A.__file__,M.S.S.PARTITION,M.R.CATALOG]
inputs=B.unique_inputs([B.pin(path) for path in paths]);full=len(names)==45;timing=225 if full else max(30,len(names)*5+15);seconds=timing+(35 if full else 20);disk=32 if full else (6 if len(names)<=3 else 10)
plan=dict(kind='phase200-frozen-runtime-screen',name=a.name,inputs=inputs,baseline=B.pin(M.BASE/'manifest.json'),baselinePreparation=B.pin(M.BASE/'report.json'),runtime=runtime,runtimeReceipt=B.pin(a.receipt),nativeManifest=B.pin(a.native_manifest),nativeRole=a.native_role,sourceChanged=source['roles'][a.native_role]['compilerSource']!=base['roles']['candidate']['compilerSource'],cases=names,rounds=3,targetMs=140,minimumAcceptedMs=100,timingSeconds=timing,guardSeconds=seconds,diskMiB=disk,scope='Frozen selected cases; actual guarded target work is separate. Runtime receipt pins an explicit ABI11102 provider; independent full output checks required before timing.')
folder=HERE/'plans';folder.mkdir(exist_ok=True);path=folder/(a.name+'.json');argvpath=folder/(a.name+'-argv.json');assert not path.exists() and not argvpath.exists()
B.save(path,plan,fresh=True);argv=[sys.executable,'-B',str(HERE/'job.py'),a.name,str(seconds),str(disk),sys.executable,'-B',str(HERE/'screen.py'),'--plan',str(path),'--out',str(ROOT/'selfhost/build/phase200'/a.name)];B.save(argvpath,argv,fresh=True)
print(json.dumps(dict(targetsRun=False,plan=str(path),argv=str(argvpath),cases=names,seconds=seconds,diskMiB=disk)))

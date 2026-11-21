#!/usr/bin/env python3
"""Freeze gzip image provenance, real native45 inputs, independent C/oracles and argv."""
import argparse,json,re,sys
from pathlib import Path
sys.dont_write_bytecode=True
from support import B,ROOT,HERE,P,R,S,L,NATIVE,CATALOG,SUMMARY,REFERENCE,SMOKE,image_binding,c_reference
p=argparse.ArgumentParser();p.add_argument('--name',required=True);p.add_argument('--baseline',required=True,type=Path);p.add_argument('--baseline-receipt',required=True,type=Path);p.add_argument('--baseline-source',type=Path);p.add_argument('--candidate',required=True,type=Path);p.add_argument('--candidate-receipt',required=True,type=Path);p.add_argument('--candidate-source',type=Path);p.add_argument('--cases',default='smoke');p.add_argument('--expect-unchanged',default='');p.add_argument('--controls',type=Path);p.add_argument('--target-ms',type=int,default=140);p.add_argument('--seconds',type=int);p.add_argument('--disk-mib',type=int);a=p.parse_args();assert re.fullmatch('[a-z0-9][a-z0-9-]{0,70}',a.name) and 100<=a.target_ms<=140
images={role:image_binding(getattr(a,role),getattr(a,role+'_receipt'),getattr(a,role+'_source')) for role in ['baseline','candidate']}
cat=B.catalog(CATALOG);known={c['id']:c for c in cat['cases']};names=list(known) if a.cases=='all' else SMOKE if a.cases=='smoke' else a.cases.split(',');assert names and len(names)==len(set(names)) and set(names)<=known.keys()
unchanged=a.expect_unchanged.split(',') if a.expect_unchanged else [];assert set(unchanged)<=set(names)
ref=B.read(REFERENCE);command=ref['compilerCommand'].copy();assert command[8]=='x86-object' and command[11]=='cache';command[0]='{image}';command[9]='{source}'
links=[j['command'] for j in ref['jobs'] if j['label']=='link'];assert len(links)==1;link=links[0].copy();link[2]='{object}';link[3]='{runtime}';link[-1]='{output}'
old=B.read(ROOT/'research/phase199/broad/integrated-pins.json');runtime=old['live'];B.verify(runtime)
summary,cmanifest,cases=c_reference();selected=[known[n] for n in names]
controls=[]
if a.controls:
 for row in B.read(a.controls)['fixtures']:
  source=B.pin(a.controls.parent/row['source']);expected=B.pin(a.controls.parent/row['expected']);assert source['sha256']==row['sourceSha256'] and expected['sha256']==row['expectedSha256'];controls.append(dict(id=row['id'],source=source,expected=expected,kind=row['kind']))
paths=[__file__,HERE/'support.py',HERE/'screen.py',HERE/'job.py',P.__file__,P.M.__file__,R.__file__,S.__file__,S.S.__file__,S.S.A.__file__,S.S.PARTITION,L.__file__,NATIVE.__file__,CATALOG,SUMMARY,REFERENCE,command[10],command[12],link[0]]
inputs=[B.pin(path) for path in paths]+[runtime,old['bundle'],summary['references']]
for binding in images.values():inputs.extend(binding[k] for k in ['gzip','receipt','source'])
for case in selected:
 assert all(case[k]==cases[case['id']][k] for k in ['point','source','expectedFile'])
 product=cases[case['id']]['products']['c'];inputs.extend([case['source'],case['expectedFile'],product['artifact'],*product['inputs']])
inputs.extend(cmanifest['roles']['c']['inputs'])
if a.controls:inputs.append(B.pin(a.controls))
for row in controls:inputs.extend([row['source'],row['expected']])
assert len({row['id'] for row in controls})==len(controls) and all(B.NAME.fullmatch(row['id']) and row['id'] not in ('.','..') for row in controls)
inputs=B.unique_inputs(inputs)
for pin in inputs:B.verify(pin)
full=len(names)==45;seconds=a.seconds or (600 if full else max(90,len(names)*20+len(controls)*5));disk=a.disk_mib or (96 if full else max(24,len(names)*3))
folder=HERE/'plans';folder.mkdir(exist_ok=True);path=folder/(a.name+'.json');argvpath=folder/(a.name+'-argv.json');assert not path.exists() and not argvpath.exists()
plan=dict(kind='phase205-frozen-dual-native-screen',inputs=inputs,name=a.name,images=images,runtime=runtime,runtimeReceipt=old['bundle'],compilerCommand=command,linkCommand=link,cReference=summary['references'],cSummary=B.pin(SUMMARY),cases=names,controls=controls,expectUnchanged=unchanged,rounds=3,targetMs=a.target_ms,minimumAcceptedMs=100,guardSeconds=seconds,diskMiB=disk,timingSeconds=225 if full else max(35,len(names)*6+15),scope='Both gzip-native images compile every real selected source; actual products and independent outputs precede timing. All roles timed, even identical objects/layouts. Native45 source variants supply transfer observations; optional authored controls are correctness-only.')
B.save(path,plan,fresh=True);argv=[sys.executable,'-B',str(HERE/'job.py'),a.name,str(seconds),str(disk),sys.executable,'-B',str(HERE/'screen.py'),'--plan',str(path),'--out',str(ROOT/'selfhost/build/phase205'/a.name)];B.save(argvpath,argv,fresh=True);print(json.dumps(dict(targetsRun=False,plan=str(path),argv=str(argvpath),cases=names,seconds=seconds,diskMiB=disk)))

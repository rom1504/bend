#!/usr/bin/env python3
"""Prepare an unchanged-object final04 diagnostic relink; no target execution."""
import argparse,gzip,importlib.util,json,shutil,sys
from pathlib import Path
sys.dont_write_bytecode=True
ROOT=Path(__file__).resolve().parents[5];PROF=ROOT/'selfhost/tools/profiler'
def load(name,path):
 spec=importlib.util.spec_from_file_location(name,path);m=importlib.util.module_from_spec(spec);spec.loader.exec_module(m);return m
R=load('runtime',PROF/'runtime.py');O=load('owners',PROF/'owners.py');pin,verify=R.pin,R.verify
p=argparse.ArgumentParser(description=__doc__);p.add_argument('--out',type=Path,required=True);a=p.parse_args();out=a.out.resolve()
assert not out.exists() and out.is_relative_to(ROOT/'selfhost/build/phase145')
cp=ROOT/'implementation/phase144/final04/candidate.json';c=json.loads(cp.read_text());assert c['complete'] and c['nativeQualified']
for k in ['source','nativeObject','n2','nativeBuild','runtime','preferredCarrierReceipt','preferredCarrier','base']:verify(c[k])
b=json.loads(Path(c['nativeBuild']['file']).read_text());assert b['complete'] and b['binary']==c['n2'] and b['object']==c['nativeObject'] and b['runtime']==c['runtime'] and b['source']==c['source'];verify(b['retainedIR'])
runtime=ROOT/'selfhost/build/phase144/serial-rfc01/runtime.c'
assert pin(runtime)['sha256']=='aa95d2c0426c05bcc4d34244dd8b22b79ebcaf6d30634569201961f60b57f333'
assert c['runtime']['sha256']=='2d07832382a11d7e993124ecc70452e4e1a3b7f753cf429343e1183cd8e493a3'
diag,edits=R.materialize(runtime.read_bytes());out.mkdir(parents=True)
(out/'runtime.c').write_bytes(diag);(out/'edits.json').write_text(json.dumps(edits,indent=2)+'\n')
for name in ['runtime.h','primitives.h']:shutil.copyfile(runtime.parent/name,out/name)
shutil.copyfile(PROF/'runtime-support.inc.c',out/'runtime-support.inc.c');shutil.copyfile(__file__,out/'method.py')
# Stream the retained QBE once; publish only the dispatch table, not all function text.
parsed=O.parse_qbe_owners(b['retainedIR']['file']);assert parsed['descriptor']['segment_count']<65532
owner=dict(schema='phase145-exact-native-owner-map-v1',qbe=b['retainedIR'],compilerSource=c['source'],build=c['nativeBuild'],parser=pin(PROF/'owners.py'),descriptor=parsed['descriptor'],coverage=parsed['coverage'],fids=parsed['fids'],rules=parsed['rules'],limitations=parsed['limitations'])
with gzip.GzipFile(filename=str(out/'owners.json.gz'),mode='wb',mtime=0) as f:f.write((json.dumps(owner,separators=(',',':'))+'\n').encode())
ref=ROOT/'selfhost/build/phase144/final04-small-products01/report.json';e=json.loads(ref.read_text());assert e['complete'] and c['source'] in e['inputs'] and c['api'] in e['inputs']
cases=[]
for name in ['lexer','coverage-map-churn-128']:
 x=next(x for x in e['cases'] if x['name']==name);assert x['verified'];verify(x['source']);verify(x['qbe']);assert x['qbe']['bytes']<8*1024*1024
 cases.append(dict(name=name,source=x['source'],expected=x['qbe'],oracleReceipt=pin(ref)))
gcc=Path(shutil.which('gcc')).resolve();flags=['-O2','-std=gnu11','-ffp-contract=off','-DP144_SINGLE_MUTATOR_RFC=1']
inputs=[pin(__file__),pin(PROF/'runtime.py'),pin(PROF/'runtime-support.inc.c'),pin(PROF/'owners.py'),pin(cp),c['source'],c['nativeObject'],c['n2'],c['nativeBuild'],c['runtime'],pin(runtime),pin(runtime.parent/'runtime.h'),pin(runtime.parent/'primitives.h'),pin(gcc),b['retainedIR'],pin(ref),c['api'],c['checkedApi'],c['preferredCarrierReceipt'],c['preferredCarrier'],c['base']]
for x in cases:inputs.extend([x['source'],x['expected']])
for x in inputs:verify(x)
jobs=[dict(label='compile-runtime',command=[str(gcc),*flags,'-c',str(out/'runtime.c'),'-o',str(out/'runtime.o')]),dict(label='link-diagnostic',command=[str(gcc),'-no-pie',c['nativeObject']['file'],str(out/'runtime.o'),'-pthread','-lm','-Wl,--export-dynamic-symbol=bend_profile_dispatch_get','-Wl,--export-dynamic-symbol=bend_profile_dispatch_id','-o',str(out/'program')])]
plan=dict(schema='bend-native-profile-runtime-plan-v1',complete=True,compiled=False,executed=False,reverseExact=True,inputs=inputs,outputs=[pin(out/n) for n in ['runtime.c','runtime.h','primitives.h','runtime-support.inc.c','method.py','edits.json','owners.json.gz']],jobs=jobs,cases=cases,baseline=c['n2'],compilerSource=c['source'],programObject=c['nativeObject'],runtimeSource=pin(runtime),linkedRuntime=c['runtime'],ownerMap=pin(out/'owners.json.gz'),base=c['base'],carrier=c['preferredCarrier'],stamp=c['preferredStamp'],addedCounters=[],scope='Unchanged16-channel profiler with final04 N2 object and exact selected serial runtime policy. Active dispatch ownership is lexical lowering context, not logical ancestry, phase membership, source calls or allocation origin. No character/query-probe completeness claim; generated inline operations can bypass runtime hooks. Counter time is diagnostic.')
(out/'plan.json').write_text(json.dumps(plan,indent=2)+'\n');print(json.dumps(dict(complete=True,plan=pin(out/'plan.json'),owners=pin(out/'owners.json.gz'),cases=[x['name'] for x in cases],targetExecution=False)))

#!/usr/bin/env python3
"""Single-policy collection-cadence falsifier; same binary and exact QBE gate."""
import argparse,importlib.util,json,os,sys
from pathlib import Path
ROOT=Path(__file__).resolve().parents[3]
sys.path.insert(0,str(ROOT/'selfhost/tools/build'))
from common import pin,verify,write_json,fresh_output,require,same_bytes
spec=importlib.util.spec_from_file_location('profile_run',ROOT/'selfhost/tools/profiler/run.py')
P=importlib.util.module_from_spec(spec);spec.loader.exec_module(P)
p=argparse.ArgumentParser();p.add_argument('--out',type=Path,required=True)
p.add_argument('--case',choices=['map','compiler-checker','full-compiler'],required=True)
p.add_argument('--roles',default='c,qbe');p.add_argument('--seconds',type=float,default=300)
p.add_argument('--gc-factor',choices=['1'],required=True)
a=p.parse_args();out=fresh_output(a.out,ROOT);roles=a.roles.split(',')
require(roles==['c'],'Collection policy ablation only applies to the C role')
require(len(set(roles))==len(roles) and set(roles)<={'c','qbe'} and roles,'Invalid roles')
if a.case=='full-compiler':
    case=json.loads((ROOT/'selfhost/build/phase156/full-inputs01/manifest.json').read_text())['cases'][0]
    receipt=Path(case['oracleReceipt']['file']);oracle=json.loads(receipt.read_text())['retainedIR']
else:
    old=json.loads((ROOT/'selfhost/build/phase156/pilot01/report.json').read_text())
    case=next(c for c in old['cases'] if c['name']==a.case)
    oracle=case['oracle'];receipt=Path(oracle['file']).parent/'report.json'
original=json.loads(receipt.read_text());require(original['complete'],'Incomplete independent oracle')
require(original['request']['source']==case['source'],'Oracle input mismatch')
base=original['request']['base'];image=ROOT/'selfhost/build/phase156/request-prepare01/native/program'
cbuild=ROOT/'selfhost/build/phase160/request-c02/report.json';c=json.loads(cbuild.read_text());require(c['complete'],'Incomplete C acquisition')
inputs=[pin(__file__),pin(P.__file__),pin(receipt),oracle,case['source'],base,pin(image),pin(cbuild),c['binary'],
    pin(ROOT/'selfhost/build/phase160/parser-equivalence02/report.json'),pin(ROOT/'selfhost/build/phase156/request-prepare01/native/report.json')]
for x in inputs:verify(x)
env={k:v for k,v in os.environ.items() if not k.startswith('BEND_') and k not in ['LD_PRELOAD','LD_AUDIT']}
env['BEND_GC_FACTOR']=a.gc_factor
r=dict(environment={'BEND_GC_FACTOR':a.gc_factor},kind='phase160-collection-budget-ablation',complete=False,inputs=inputs,case=a.case,rows=[],
    scope='Whole fresh process, identical original request algorithms, live Base, complete source check/lower/verify/render/write/teardown. No machine construction. Source normalization has exact independent spanless-parser equality.',
    acquisitionScope='C image emitted with bendc checking disabled after independent original checking + parser equivalence; runtime is private bounded-search GC; BEND_UNBOX=0 during emission. Not general conformance or production selection.')
write_json(out/'report.json',r)
for role in roles:
    directory=out/role;product=directory/'program.ssa'
    binary=c['binary']['file'] if role=='c' else str(image)
    cmd=[binary,'--threads','1','--gpu','off','--']+([] if role=='c' else ['transfer'])+[base['file'],case['source']['file'],'old',str(product)]
    process=P.execute(cmd,directory,ROOT,a.seconds,env,argv0='transfer')
    row=dict(role=role,process=process,passed=False);r['rows'].append(row);write_json(out/'report.json',r)
    require(process['returncode']==0 and not process['timedOut'],'Compiler execution failed')
    require(process['stdout']['bytes']==0 and process['stderr']['bytes']==0,'Unexpected diagnostic output')
    got=pin(product);row['product']=got
    row['byteExact']=same_bytes(product,verify(oracle));write_json(out/'report.json',r)
    require(row['byteExact'],'Complete QBE differs')
    # Only this newly produced, unfrozen output is replaced after complete equality.
    # The canonical oracle is never overwritten. Retain exact bytes without another
    #118MB disk copy; commit intent and final identity outside the measured child.
    intent=dict(product=got,canonical=oracle,byteExact=True,complete=False)
    write_json(directory/'dedup-intent.json',intent)
    temporary=directory/'program.shared';os.link(oracle['file'],temporary);os.replace(temporary,product)
    require(pin(product)==got,'Dedup changed output bytes')
    write_json(directory/'dedup-result.json',dict(intent,complete=True,links=product.stat().st_nlink))
    row['deduplicatedAgainst']=oracle;row['passed']=True;write_json(out/'report.json',r)
    print(json.dumps(dict(role=role,seconds=process['wallSeconds'],rssKiB=process['peakRssKiB'],byteExact=True)),flush=True)
for x in inputs:verify(x)
r['complete']=True;write_json(out/'report.json',r)

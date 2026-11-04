#!/usr/bin/env python3
"""Fixed compiler executable, full versus exact native-root input source."""
import argparse,importlib.util,json,os,sys
from pathlib import Path
ROOT=Path(__file__).resolve().parents[3]
sys.path.insert(0,str(ROOT/'selfhost/tools/build'))
from common import pin,verify,require,write_json,fresh_output,same_bytes
spec=importlib.util.spec_from_file_location('profile_run',ROOT/'selfhost/tools/profiler/run.py')
P=importlib.util.module_from_spec(spec);spec.loader.exec_module(P)
p=argparse.ArgumentParser();p.add_argument('--out',type=Path,required=True)
p.add_argument('--case',choices=['full','closure'],required=True);p.add_argument('--seconds',type=float,default=320)
a=p.parse_args();out=fresh_output(a.out,ROOT)
prior=ROOT/'selfhost/build/phase160/full-qbe01/report.json';d=json.loads(prior.read_text())
require(d['complete'] and d['rows'][0]['passed'],'Original common request not admitted')
old=d['rows'][0];cmd=list(old['process']['command']);oracle=old['deduplicatedAgainst']
full=pin(cmd[-3]);base=pin(cmd[-4]);image=pin(cmd[0])
require(full['sha256']=='027e15041035522ed7e40ef971eff75f24a09ef6a00e3f8fe335839f94bcb8a8','Wrong full source')
check=ROOT/'selfhost/build/phase160/closure-check01/report.json';c=json.loads(check.read_text())
require(c['complete'] and c['checked'],'Closure source check missing')
source=c['source'] if a.case=='closure' else full
require(c['source']['sha256']=='15d41d9bf2cec2b11f4dab6dbce8c2cfea5eb59b5ce0b879d5281a5084012bc2','Wrong closure')
inputs=[pin(__file__),pin(P.__file__),pin(prior),pin(check),source,full,base,image,oracle,
 pin(ROOT/'selfhost/build/phase160/closure-prepare01/manifest.json'),
 pin(ROOT/'selfhost/build/phase156/request-prepare01/native/report.json')]
for item in inputs:verify(item)
product=out/'child/program.ssa';cmd[-3]=source['file'];cmd[-1]=str(product)
require(cmd[-2]=='old','Not original compiler route')
env={k:v for k,v in os.environ.items() if not k.startswith('BEND_') and k not in ['LD_PRELOAD','LD_AUDIT']}
r=dict(kind='phase161-fixed-compiler-source-request',complete=False,case=a.case,inputs=inputs,source=source,
 image=image,base=base,fullSource=full,originalOracle=oracle,
 scope='Fresh whole original compiler request: live Base, parse/check, optimize/verify, QBE rendering/writing and teardown. Input source differs; executable/policy fixed. Machine construction excluded.')
write_json(out/'report.json',r)
r['process']=P.execute(cmd,out/'child',ROOT,a.seconds,env,argv0='transfer');write_json(out/'report.json',r)
process=r['process'];require(process['returncode']==0 and not process['timedOut'],'Request failed')
require(process['stdout']['bytes']==process['stderr']['bytes']==0,'Unexpected diagnostic output')
r['product']=pin(product);require(r['product']['bytes']>0,'No QBE output')
r['equalToFullCompiler']=same_bytes(product,verify(oracle));write_json(out/'report.json',r)
if a.case=='full':require(r['equalToFullCompiler'],'Full-source oracle failed')
if r['equalToFullCompiler']:
 write_json(out/'dedup-intent.json',dict(product=r['product'],canonical=oracle,byteExact=True))
 temporary=out/'child/program.shared';os.link(oracle['file'],temporary);os.replace(temporary,product)
 require(pin(product)==r['product'],'Dedup changed bytes')
 write_json(out/'dedup-result.json',dict(complete=True,product=r['product'],canonical=oracle))
for item in inputs:verify(item)
r['complete']=True;r['equivalence']='Complete QBE identical' if r['equalToFullCompiler'] else 'Output difference requires reconciliation; not compiler qualification'
write_json(out/'report.json',r)
print(json.dumps(dict(case=a.case,seconds=process['wallSeconds'],rssKiB=process['peakRssKiB'],bytes=r['product']['bytes'],equal=r['equalToFullCompiler'])))

#!/usr/bin/env python3
"""Bounded same-source acquisition. Run inside exactly one resource guard."""
import argparse,json,os,sys
from pathlib import Path
ROOT=Path(__file__).resolve().parents[3]
sys.path.insert(0,str(ROOT/'selfhost/tools/bench'))
import acquire
from common import pin,run,write_json,require
p=argparse.ArgumentParser();p.add_argument('--role',choices=['upstream','gc','rc'],required=True)
p.add_argument('--source',type=Path,default=ROOT/'selfhost/tests/phase157/workload.bend')
p.add_argument('--reuse-c',type=Path)
p.add_argument('--reuse-emission',type=Path)
p.add_argument('--out',type=Path,required=True);p.add_argument('--seconds',type=int,default=180)
a=p.parse_args();out=a.out.resolve();out.mkdir(parents=True,exist_ok=False)
source=pin(a.source.resolve())
assets=json.loads((ROOT/'selfhost/manifests/assets-native.json').read_text())
env=dict(os.environ)
for k in list(env):
 if k.startswith('BEND_'):del env[k]
r=dict(kind='phase157-acquisition',complete=False,role=a.role,source=source)
try:
 if a.role=='upstream':
  role,doc,inputs=acquire.prepare_role(dict(provider='upstream',target='c',host='js',stage='upstream',policy='pinned-O3',status='independent-reference',assets=str(ROOT/'selfhost/manifests/assets-native.json')),ROOT,ROOT)
  spec=acquire.reference_plan(role,source);write_json(out/'spec.json',spec)
  cmd=[role['engine']['file'],ROOT/'selfhost/tools/bench/upstream.mjs',out/'spec.json',out/'emission.json']
  r['inputs']=inputs
 else:
  env.update(BEND_RC='0' if a.role=='gc' else '1',BEND_AUTO_PAR='0')
  if a.role=='gc':env['BEND_NO_FREE']='1'
  r['policyEnvironment']={k:v for k,v in env.items()if k.startswith('BEND_')}
  seed=ROOT/'selfhost/build/phase157/seed01/bendc'
  cmd=[seed,'--threads','1','--gpu','off','--',assets['assets']['base']['file'],source['file']]
  r['inputs']=[pin(seed),pin(ROOT/'selfhost/build/phase157/vendor/manifest.json'),assets['assets']['base']]
 if a.reuse_emission:
  import shutil
  old=a.reuse_emission.resolve();prior=json.loads((old/'report.json').read_text())
  require(prior['source']==source and prior['role']==a.role and prior['policyEnvironment']==r['policyEnvironment'],'Emission reuse identity differs')
  from common import verify
  verify(prior['emission']['stdout']);require(prior['emission']['complete'],'Prior checked emission failed')
  shutil.copy2(old/'program.c',out/'program.c');r['emission']=prior['emission'];r['emissionReuse']=pin(old/'report.json')
 else:r['emission']=run(cmd,cwd=ROOT,stdout=out/'program.c',stderr=out/'emission.stderr',seconds=a.seconds,env=env)
 require(r['emission']['complete'],'Checked emission failed')
 if a.reuse_c:
  import shutil
  old=a.reuse_c.resolve();require((old/'program.c').read_bytes()==(out/'program.c').read_bytes(),'Reuse requires byte-identical emitted C')
  r['exactCReuse']=[pin(old/'report.json'),pin(old/'program.c'),pin(old/'program')]
  shutil.copy2(old/'program',out/'program')
  r.update(complete=True,product=pin(out/'program'),cSource=pin(out/'program.c'))
  write_json(out/'report.json',r);print(json.dumps(r));sys.exit(0)
 flags=assets['toolchains']['c'];compiler=assets['assets']['clang'];r['compiler']=compiler;r['toolchain']=flags
 cfile=out/'program.c'
 if a.role!='upstream':
  # Old pinned Base effects already schedule blocking IO through io_work.
  # The new runtime's third argument requests pre-waiting; zero preserves
  # immediate legacy callback dispatch. Only these exact nine registrations.
  import re
  pairs=[('FILE_CLOSE','file_close_run'),('FILE_WRITE','file_write_run'),('FILE_WRITE_BYTES','file_write_bytes_run'),('FILE_OPEN','file_open_run'),('FILE_READ','file_read_run'),('FILE_READ_BYTES','file_read_bytes_run'),('FILE_READ_AT','file_read_at_run'),('FILE_SIZE','file_size_run'),('IO_ARGS','io_args_run')]
  text=cfile.read_text();original=text
  require(len(re.findall(r'\bio_eff\(',text))==len(pairs),'Unexpected IO registration set')
  for cid,fn in pairs:
   before=f'io_eff(CID_{cid}, {fn});';after=f'io_eff(CID_{cid}, {fn}, 0);'
   require(text.count(before)==1,'Missing exact legacy registration');text=text.replace(before,after)
  cfile=out/'program-adapted.c';cfile.write_text(text)
  r['effectAdapter']=dict(original=pin(out/'program.c'),adapted=pin(cfile),registrations=pairs,meaning='Zero pre-wait policy preserves legacy callback-managed io_work scheduling; experiment-only ABI bridge.')
 cmd=[compiler['file'],*flags['flags'],*flags.get('includeFlags',[]),'-I',ROOT/'selfhost/build/phase157/vendor/rt',cfile,'-o',out/'program',*flags['libraries']]
 r['machine']=run(cmd,cwd=ROOT,stdout=out/'machine.stdout',stderr=out/'machine.stderr',seconds=a.seconds,env=env)
 require(r['machine']['complete'],'Machine construction failed')
 r.update(complete=True,product=pin(out/'program'),cSource=pin(cfile))
except Exception as e:r['error']=repr(e)
write_json(out/'report.json',r);print(json.dumps(r));sys.exit(0 if r['complete']else 1)

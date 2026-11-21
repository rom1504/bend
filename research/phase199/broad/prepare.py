#!/usr/bin/env python3
"""Authenticate all45 N1 objects, verify original relinks, link live, check 3 roles."""
import argparse,hashlib,importlib.util,json,os,subprocess,sys,time
from pathlib import Path
sys.dont_write_bytecode=True
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[2]
sys.path.insert(0,str(ROOT/'selfhost/tools/bench'));import bench as B
spec=importlib.util.spec_from_file_location('layouts',ROOT/'research/phase198/qualification/compare-source-products.py');L=importlib.util.module_from_spec(spec);spec.loader.exec_module(L)
BASE=ROOT/'selfhost/build/phase198/progress-live-plan01'
SOURCE_SHA='3b1c136a2822f3f0824edca400f40b62490be9757af233a4e9694c527961fcf4'
def keyed(doc):
 rows={x['id']:x for x in doc['cases']};assert len(rows)==len(doc['cases'])==45;return rows
def read_manifest(path):
 j=B.read(path);assert j['schema']=='bend-benchmark-manifest-v1' and j['kind']=='programs'
 for x in j['inputs']:B.verify(x)
 return j

def prepare(native,source,out):
 assert os.sched_getaffinity(0)=={3} and 'BENDRTS' not in os.environ
 out=out.resolve();out.mkdir(parents=True,exist_ok=False)
 held=B.read(ROOT/'research/phase198/runtime-broad/portfolio-pins.json')
 for item in held.values():B.verify(item)
 source=B.pin(source);assert source['sha256']==SOURCE_SHA
 candidate=read_manifest(native);role=candidate['roles']['candidate']
 assert role['compilerSource']==source and role['stage']=='N1' and role['target']=='x86' and role['emit']=='object' and role['runtime']==held['original']
 incumbent=read_manifest(BASE/'manifest.json');baseproof=B.read(BASE/'report.json')
 assert baseproof['complete'] and baseproof['manifest']==B.pin(BASE/'manifest.json') and baseproof['inputs']==held
 original=read_manifest(baseproof['native']['file']);assert baseproof['native']==B.pin(baseproof['native']['file'])
 assert incumbent['roles']['live']['compilerSource']['sha256']=='72061fa57c75993b59eaf42e18c6b923eebea640c352d0f7b9cd1d27ce7be91d'
 assert incumbent['roles']['live']['runtime']==held['live']
 mature=read_manifest(held['matureC']['file'])
 refs,old,new,ordinary=map(keyed,[mature,incumbent,candidate,original]);assert refs.keys()==old.keys()==new.keys()==ordinary.keys()
 input_pins=[B.pin(__file__),B.pin(L.__file__),B.pin(native),B.pin(BASE/'manifest.json'),B.pin(BASE/'report.json'),*held.values()]
 inputs=B.unique_inputs(input_pins)
 live_role=dict(role,runtime=held['live'],policy='ordinary-serial-split-live-descriptor',status='phase199-native-N1-same-object-live-runtime',inputs=[*role['inputs'],*inputs])
 recipe=dict(kind='programs',cwd=str(ROOT),catalog=str(ROOT/'selfhost/tools/bench/catalogs/native45/catalog.json'),reference='c',roles=dict(c=mature['roles']['c'],baseline=incumbent['roles']['live'],candidate=live_role),cases=[])
 report=dict(kind='phase199-three-role-preparation',complete=False,source=source,native=B.pin(native),baseline=B.pin(BASE/'manifest.json'),baselinePreparation=B.pin(BASE/'report.json'),inputs=inputs,originalRuntime=held['original'],liveRuntime=held['live'],cases={},scope='Same catalog and independent outputs; new original-runtime default relinks must match production bytes. Existing baseline original relinks are authenticated. Only C/progress-live/new-live are timed; no installed/reproduction claim.')
 save=lambda:B.save(out/'report.json',report)
 save()
 for name,case in new.items():
  base,ref=old[name],refs[name];assert all(case[k]==base[k]==ref[k] for k in ('point','source','expectedFile'))
  oldproduct=ordinary[name]['products']['candidate'];oldproof=baseproof['cases'][name]
  assert oldproof['object']==oldproduct['generatedSource'] and oldproof['base']==oldproduct['artifact']
  assert oldproof['originalRelink']['sha256']==oldproduct['artifact']['sha256'] and oldproof['originalRelink']['bytes']==oldproduct['artifact']['bytes']
  assert dict(oldproduct,artifact=oldproof['live'])==base['products']['live']
  for pin in (oldproof['originalRelink'],oldproof['object'],oldproof['live']):B.verify(pin)
  archive=case['products']['candidate'];production=B.pin(Path(archive['artifact']['file']).with_name('report.json'));assert production in archive['inputs']
  built=B.read(production['file']);obj=built['object']
  assert built['complete'] and not built['changedInputs'] and built['assemblerSkipped'] and built['emit']=='object'
  assert built['binary']==archive['artifact'] and obj==archive['generatedSource'] and built['runtime']==held['original']
  assert built['request']['image']==role['compiler'] and built['request']['imageMetadata']['sourceIdentity']==source
  assert built['request']['source']==case['source'] and built['host']=='native' and built['stage']=='N1' and built['target']=='x86'
  for pin in (obj,archive['artifact'],case['source'],case['expectedFile']):B.verify(pin)
  jobs=[j for j in built['jobs'] if j['label']=='link'];assert len(jobs)==1
  cmd=jobs[0]['command'];assert jobs[0]['exitCode']==0 and not jobs[0].get('timedOut',False)
  assert all(cmd.count(p)==1 for p in [held['original']['file'],obj['file'],archive['artifact']['file']])
  folder=out/'cases'/name;folder.mkdir(parents=True)
  original_path=folder/'default-relink';live_path=folder/'live'
  for target,runtime in [(original_path,held['original']),(live_path,held['live'])]:
   link=cmd.copy();link[link.index(held['original']['file'])]=runtime['file'];link[link.index(archive['artifact']['file'])]=str(target)
   subprocess.run(link,check=True,timeout=20,capture_output=True)
  relink=B.pin(original_path);assert all(relink[k]==archive['artifact'][k] for k in ('bytes','sha256'))
  # The production ELF retains these exact bytes; avoid a redundant 45-ELF copy.
  original_path.unlink()
  live=dict(archive,artifact=B.pin(live_path));arms=dict(c=ref['products']['c'],baseline=base['products']['live'],candidate=live)
  checks={};point=case['point']
  for alias,product in arms.items():
   B.verify(product['artifact']);obs=dict(point,repetitions=int(point['repetitions']>0),warmups=0)
   command=[product['artifact']['file'],*B.native_runtime_arguments(product),str(obs['repetitions']),'0',*map(str,point['runtimeArgs'])]
   child=B.child(command,folder/('oracle-'+alias),time.monotonic()+20,str(ROOT))
   assert not child['timedOut'] and child['stdout']['bytes']<=len(point['expectedStdout'].encode())+128
   elapsed=B.observation(Path(child['stdout']['file']).read_bytes(),Path(child['stderr']['file']).read_bytes(),child['exitCode'],obs,child['seconds'])
   checks[alias]=dict(repetitions=obs['repetitions'],elapsedMs=elapsed,process=child)
  same_obj=all(obj[k]==oldproof['object'][k] for k in ('bytes','sha256'))
  same_layout=L.loaded_layout(live_path)==L.loaded_layout(oldproof['live']['file'])
  report['cases'][name]=dict(object=obj,production=production,default=archive['artifact'],verifiedDefaultRelink={k:relink[k] for k in ('bytes','sha256')},defaultRelinkRetained=False,live=live['artifact'],oracles=checks,objectIdenticalToProgress=same_obj,allocatedLayoutIdenticalToProgress=same_layout)
  recipe['cases'].append(dict(id=name,products=arms));save()
 B.save(out/'recipe.json',recipe);B.freeze(out/'recipe.json',out/'manifest.json')
 report.update(complete=True,manifest=B.pin(out/'manifest.json'),unchangedCases=[name for name,row in report['cases'].items() if row['objectIdenticalToProgress'] and row['allocatedLayoutIdenticalToProgress']],independentObservations=135)
 for pin in inputs:B.verify(pin)
 save();print(json.dumps(dict(complete=True,manifest=report['manifest'],unchangedCases=report['unchangedCases'])))
if __name__=='__main__':
 p=argparse.ArgumentParser();p.add_argument('--native',type=Path,required=True);p.add_argument('--source',type=Path,required=True);p.add_argument('--out',type=Path,required=True);a=p.parse_args();prepare(a.native.resolve(),a.source.resolve(),a.out)

#!/usr/bin/env python3
"""Close a frozen actual-source owner contract; never convert failed raw evidence to PASS."""
import argparse,hashlib,json,importlib.util
from pathlib import Path
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[4]
SUPERVISOR_SHA='860b59bce0b8c38e2e548368b14c51825bd62d8da1da200e2049737f1e0e383d'
def ident(p):
 p=Path(p).resolve();data=p.read_bytes();return dict(file=str(p),sha256=hashlib.sha256(data).hexdigest(),bytes=len(data))
def read(p):return json.loads(Path(p).read_text())
def verify(row):
 p=row.get('file',row.get('path'));assert ident(p)['sha256']==row['sha256'],p
 return ident(p)
def pointer(data,key):
 for part in key.lstrip('/').split('/'):
  part=part.replace('~1','/').replace('~0','~');data=data[int(part)] if isinstance(data,list) else data[part]
 return data
def embedded(data,rows):
 if isinstance(data,dict):
  if 'sha256' in data and ('file' in data or 'path' in data) and 'commit' not in data:
   rows.append(verify(data))
  for v in data.values():embedded(v,rows)
 elif isinstance(data,list):
  for v in data:embedded(v,rows)
def assert_value(actual,wanted,label):
 if isinstance(wanted,dict) and set(wanted)=={'length'}:assert len(actual)==wanted['length'],label
 else:assert type(actual)==type(wanted) and actual==wanted,label
def main():
 p=argparse.ArgumentParser(description=__doc__);p.add_argument('contract',type=Path);p.add_argument('out',type=Path);a=p.parse_args();assert not a.out.exists();a.out.mkdir(parents=True)
 c=read(a.contract);r=dict(kind='phase43-selected-image-owner-controls',complete=False,**{'pass':False},owner=c['owner'],producer=ident(__file__),contract=ident(a.contract),inputs=[])
 try:
  assert c['kind']=='phase43-actual-owner-frozen-contract' and c['complete']
  assert c['catalogueSha256']==ident(HERE/'owner-catalogue-v2.json')['sha256'];catalogue=read(HERE/'owner-catalogue-v2.json');policy=catalogue[c['owner']]
  assert c['policy']==policy
  if 'controllerSha256' in policy:assert c['controller']['sha256']==policy['controllerSha256']
  assert c['controller']['sha256']==verify(c['controllerSnapshot'])['sha256'];verify(c['controller'])
  attempt=verify(c['attempt']);m=read(attempt['file']);assert m['checked'];node=verify(m['node']);assert m['node']['version']=='v24.18.0';r.update(attempt=attempt,api=m['api'],runtime=m['runtime'],base=m['base'],controller=c['controller'],rawReport=ident(c['rawReport']))
  spec=importlib.util.spec_from_file_location('runtime_agreement',HERE/'runtime-agreement-v1.py');mod=importlib.util.module_from_spec(spec);spec.loader.exec_module(mod);r['runtimeAgreement']=mod.verify_attempt(Path(attempt['file']).parent)
  raw=read(c['rawReport']);assert not raw.get('error') and not raw.get('current'), 'failed/unfinished raw controller report'
  for key,wanted in policy['assertions'].items():assert_value(pointer(raw,key),wanted,key)
  for each in policy.get('eachAssertions',[]):
   for row in pointer(raw,each['array']):
    for key,wanted in each['assertions'].items():assert_value(pointer(row,key),wanted,key)
  def encoded(name):return '$R_'+'_'.join(str(ord(x)) for x in name)+'$tree'
  if c['owner'] in ['products-bst','products-fixture']:
   prefix='p37.bst.' if c['owner']=='products-bst' else 'p43.prefix.'
   for row in raw['results']:
    if 'size' in row:assert row['candidate'].get(encoded(prefix+'build'),0)>0,'ordinary BST build activation required even at size zero'
    if row.get('size',0)>0:
     for name in [prefix+'insert','insert.fin','bst.down']:assert row['candidate'].get(encoded(name),0)>0,'ordinary BST positive worker '+name
  if c['owner']=='products-bst-pair-ignored':
   for row in raw['results']:
    assert row['counts'].get(encoded('p43.prefix.build'),0)>0,'ordinary ignored BST build must activate'
    if row['size']>0:
     for name in ['p43.prefix.insert','insert.fin','bst.down']:assert row['counts'].get(encoded(name),0)>0,'ordinary ignored BST positive worker '+name
  if c['owner'] in ['products-pair','products-pair-precedence']:
   precedence=c['owner'].endswith('-precedence')
   for row in raw['results']:
    for name in ['p43.pair.loop','p43.pair.shared']:
     global_count=row['counts'].get(encoded(name),0)
     if precedence:assert global_count==0 and row['counts'].get(encoded(name)[:-5],0)>0,'exact original scalar precedence required'
     else:assert global_count>0,'ordinary target global pair worker required'
  if c['owner'] in ['products-pair-ignored','products-pair-ignored-precedence']:
   precedence=c['owner'].endswith('-precedence')
   for row in raw['results']:
    assert type(row['freshPairEntries']) is int and type(row['scalarEntries']) is int
    if precedence:assert row['freshPairEntries']==0 and row['scalarEntries']>0,'ordinary ignored-field scalar precedence required'
    else:assert row['freshPairEntries']>0,'ordinary ignored-field positive pair activation required'
  if c['owner']=='callbacks-admission':
   for row in raw['checks']['controls']:
    if 'expected' in row:assert row['accepted']==row['expected']
    else:assert row['original'] is True and row['forged'] is False and row['expectedOriginal'] is True and row['expectedForged'] is False
  if c['owner']=='u32-guards':
   names=policy['fixedCases']+['host-hook-'+str(i) for i in range(40)]+['protocol-'+str(i) for i in range(15)]
   assert [x['name'] for x in raw['cases']]==names,'exact original numeric/protocol hook inventory'
  r['inputs'].extend([ident(c['rawReport']),ident(a.contract),verify(c['controller']),verify(c['controllerSnapshot'])]);embedded(raw,r['inputs'])
  execution=read(c['rawExecution']);assert execution['complete'] and execution['returncode']==0 and not execution.get('stoppedFor');supervisor=verify(execution['producer']);assert supervisor==ident(ROOT/'selfhost/tools/performance/phase32/bounded-run.py') and supervisor['sha256']==SUPERVISOR_SHA,'exact maintained bounded-run supervisor required';assert 'kind' not in execution,'retained supervisor schema has no kind field'
  assert execution['rssLimitBytes']==2048*1024**2 and execution['availableFloorBytes']==2048*1024**2 and 0<execution['secondsLimit']<=180
  assert execution['peakTreeRssBytes']<=execution['rssLimitBytes'] and execution['minimumAvailableBytes']>=execution['availableFloorBytes']
  command=[str((Path(x) if Path(x).is_absolute() else Path(execution['cwd'])/x).resolve()) for x in execution['command']]
  assert node['file'] in command,'raw controller did not consume frozen Node executable'
  executable=execution['command'][3] if Path(execution['command'][0]).name=='taskset' and execution['command'][1]=='-c' else execution['command'][0]
  assert str((Path(executable) if Path(executable).is_absolute() else Path(execution['cwd'])/executable).resolve())==node['file'],'frozen Node must execute the controller'
  assert c['controller']['file'] in command,'raw execution did not run exact pinned controller'
  assert str(Path(c['rawCommandInput']).resolve()) in command,'raw controller did not consume canonical module/derivation'
  raw_path=Path(c['rawReport']).resolve()
  if c['owner']=='u32-guards':assert raw_path==Path(c['rawExecution']).resolve().parent/'stdout.log','guard JSON must be exact enclosing stdout'
  else:assert str(raw_path.parent) in command,'raw controller execution did not produce exact canonical report directory'
  r['inputs'].append(ident(c['rawExecution']));r['emissions']=[]
  for file in c['emittedModules']:
   module=ident(file);receipt=ident(str(file)+'.json');e=read(receipt['file'])
   assert e['kind']=='bend-program-checked-emission' and e['complete'] and e['observation']['checked'] and e['observation']['status']=='ok'
   assert e['output']['sha256']==module['sha256'];assert e['attempt']['sha256']==attempt['sha256']
   for key in ['api','runtime','base']:
    assert e['compiler'][key]['sha256']==m[key]['sha256'];verify(e['compiler'][key])
   verify(e['input']);emitter=verify(e['producer']);assert emitter==ident(ROOT/'selfhost/tools/performance/programs/emit-worker.mjs'),'maintained checked emission producer required'
   driver=verify(e['compiler']['driver']);assert driver==ident(Path(attempt['file']).parent/'snapshot/tools/typed-driver.mjs'),'selected checked snapshot driver required'
   r['emissions'].append(dict(module=module,receipt=receipt,source=e['input']))
  assert r['emissions'] or policy.get('compilerOnly') is True,'actual checked source emission required'
  evidence=r['inputs'][:]
  for file in c.get('auxiliaryInputs',[]):embedded(read(file),evidence);r['inputs'].append(ident(file))
  for file in c['derivations']:
   d=read(file);assert d['complete'];before=len(evidence);embedded(d,evidence);r['inputs'].append(ident(file))
   if 'derivationController' in policy:
    tool=verify(c['derivationController']);trusted=any(x['sha256']==tool['sha256'] for x in evidence[before:])
    for name,wanted in d.get('files',{}).items():
     artifact=Path(file).parent/name;assert ident(artifact)['sha256']==wanted
     if wanted==tool['sha256']:trusted=True
    assert trusted,'derivation does not pin exact actual-source instrumentation tool'
  if 'derivationController' in policy:assert c['derivations'],'actual-source derivation required'
  for emission in r['emissions']:
   assert any(x['sha256']==emission['module']['sha256'] for x in evidence),'actual checked module absent from raw controller/derivation chain'
  if policy.get('compilerOnly'):
   assert any(x['sha256']==m['api']['sha256'] for x in evidence),'proof controls do not bind selected compiler API'
  r['semanticAssertions']=policy['assertions'];r['complete']=True;r['pass']=True
 except Exception as e:r['error']=str(e);raise
 finally:(a.out/'report.json').write_text(json.dumps(r,indent=2)+'\n')
 print(json.dumps(dict(complete=True,**{'pass':True},owner=c['owner'],report=ident(a.out/'report.json'))))
if __name__=='__main__':main()

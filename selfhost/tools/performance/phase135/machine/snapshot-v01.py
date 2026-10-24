#!/usr/bin/env python3
"""Expose exactly revision A's authenticated machine entries for an A->B replay.
Metadata, local immutable-entry symlinks and hashes only; no compiler/tool target.
"""
import argparse,fcntl,importlib.util,json,pathlib,re,sys,time
sys.dont_write_bytecode=True
HERE=pathlib.Path(__file__).resolve().parent;ROOT=HERE.parents[4];PHASE=ROOT/'selfhost/build/phase135'
s=importlib.util.spec_from_file_location('objects',HERE/'objects-v01.py');O=importlib.util.module_from_spec(s);s.loader.exec_module(O)
pin,verify=O.pin,O.verify

def read(p):return json.loads(pathlib.Path(p).read_text())
def require(c,m):
 if not c:raise ValueError(m)

def create(a,out):
 began=time.monotonic();joined=read(a.session);join_pin=pin(a.session)
 require(joined['complete']and joined['kind']=='phase135-native-framed-machine-session'and joined['producerExitCode']==0,'Completed exact native producer join required')
 require(len(joined['sources'])==len(joined['machineReports'])==2,'Exactly A and B reports required')
 for p in joined['machineReports']:verify(p)
 first,second=[read(p['file'])for p in joined['machineReports']]
 for i,b in enumerate([first,second]):
  require(b['complete']and b['kind']=='phase135-framed-machine-build'and b['expectedPayloadExact']and b['source']==joined['sources'][i]and b['context']['producer']==joined['producer']and b['context']['runtime']==joined['runtime'],'Wrong machine source/producer/context')
 require(first['context']==second['context'],'A/B contexts differ')
 require(len({u['key']for u in second['units']})==len(second['units']),'Duplicate B keys require an explicit sequential-hit model')
 original=pathlib.Path(first['cache']).resolve()
 require(original.is_relative_to(PHASE)and original.is_dir()and not out.is_relative_to(original)and not original.is_relative_to(out),'Disjoint authentic Phase135 original cache required')
 inputs=[pin(__file__),pin(HERE/'objects-v01.py'),join_pin,*joined['inputs'],*joined['machineReports']]
 entries=[];keys=set()
 # Refuse a concurrent writer. This does not modify its immutable entries.
 with(original/'writer.lock').open('rb')as lock:
  fcntl.flock(lock,fcntl.LOCK_SH|fcntl.LOCK_NB)
  for i,u in enumerate(first['units']):
   key=u['key'];require(u['index']==i and re.fullmatch('[0-9a-f]{64}',key)and key not in keys,'Noncanonical/duplicate A unit key');keys.add(key)
   target=original/key;require(target.is_dir()and target.resolve()==target,'Expected original immutable entry directory')
   require(pin(target/'receipt.json')==u['receipt'],'A receipt moved or changed');r=read(target/'receipt.json')
   require(r['complete']and r['key']==key and r['context']==first['context']and r['payload']==u['payload']and r['object']==u['object'],'A cache receipt admission mismatch')
   require(key==O.hash_json(dict(context=first['context'],kind=u['kind'],payload=u['payload'])),'A key is not the actual admission key')
   verify(r['object']);inputs.extend([u['receipt'],u['object']]);entries.append(dict(key=key,index=i,kind=u['kind'],payload=u['payload'],target=str(target),receipt=u['receipt'],object=u['object']))
  require(bool(entries),'Empty A cache view')
  for p in inputs:verify(p)
  out.mkdir(parents=True)
  with(out/'writer.lock').open('xb'):pass
  for entry in entries:(out/entry['key']).symlink_to(entry['target'],target_is_directory=True)
  require({p.name for p in out.iterdir()}==keys|{'writer.lock'},'View contains extra cache entries')
  for entry in entries:require((out/entry['key']).is_symlink()and(out/entry['key']).resolve()==pathlib.Path(entry['target']),'Cache link mismatch')
  for p in inputs:verify(p)
 expected=[dict(index=u['index'],key=u['key'],reused=u['key']in keys)for u in second['units']]
 result=dict(kind='phase135-revision-a-cache-view',complete=True,targetsRun=False,inputs=inputs,producerJoin=join_pin,producer=joined['producer'],sources=joined['sources'],context=first['context'],aReport=joined['machineReports'][0],bReport=joined['machineReports'][1],originalCache=str(original),cache=str(out),entries=entries,expectedB=expected,expectedBHits=sum(u['reused']for u in expected),expectedBMisses=sum(not u['reused']for u in expected),seconds=time.monotonic()-began,scope='Exactly A membership at creation; local symlinks to pinned immutable A entries. B-only entries from the completed original cache are excluded. Subsequent B misses create fresh entries in this view; never reuse the mutated view for another first-edit measurement.')
 O.save(out/'snapshot.json',result);return dict(complete=True,snapshot=pin(out/'snapshot.json'),aKeys=len(keys),expectedBHits=result['expectedBHits'],expectedBMisses=result['expectedBMisses'])

def check(a,out):
 snapshot=read(a.snapshot);replayed=read(a.replay)
 require(snapshot['complete']and snapshot['kind']=='phase135-revision-a-cache-view','Complete A-only view required')
 require(replayed['complete']and replayed['kind']=='phase135-supervised-cached-replay'and replayed['exitCodes']==[0,0]and replayed['currentBuild']==snapshot['bReport'],'Exact completed current B replay required')
 verify(replayed['machineReport']);built=read(replayed['machineReport']['file'])
 require(built['complete']and not built['cold']and built['cache']==snapshot['cache']and built['context']==snapshot['context']and built['source']==snapshot['sources'][1],'Wrong replay view/current identity')
 actual=[dict(index=u['index'],key=u['key'],reused=u['reused'])for u in built['units']]
 require(actual==snapshot['expectedB'],'Measured hit/miss set is not exactly A membership')
 inputs=[pin(__file__),pin(a.snapshot),pin(a.replay),replayed['machineReport'],*snapshot['inputs']]
 for u in built['units']:inputs.extend([u['receipt'],u['object']])
 for p in inputs:verify(p)
 result=dict(kind='phase135-a-to-b-replay-membership',complete=True,targetsRun=False,inputs=inputs,snapshot=pin(a.snapshot),replay=pin(a.replay),machineReport=replayed['machineReport'],exactAOnlyHitMask=True,hits=built['reusedUnits'],misses=built['builtUnits'],scope='Observed B cache admissions equal exact A membership; independent cold machine comparison and semantic gates remain separate.')
 O.save(out,result);return dict(complete=True,report=pin(out),hits=result['hits'],misses=result['misses'])

def main():
 ap=argparse.ArgumentParser(description=__doc__);ap.add_argument('--session',type=pathlib.Path);ap.add_argument('--snapshot',type=pathlib.Path);ap.add_argument('--replay',type=pathlib.Path);ap.add_argument('--out',type=pathlib.Path,required=True);a=ap.parse_args();out=a.out.resolve()
 require(not out.exists()and out.is_relative_to(PHASE),'Fresh Phase135 destination required')
 require((bool(a.session)and not a.snapshot and not a.replay)or(not a.session and bool(a.snapshot)and bool(a.replay)),'Choose create --session or check --snapshot/--replay')
 result=create(a,out)if a.session else check(a,out);print(json.dumps(result))
if __name__=='__main__':main()

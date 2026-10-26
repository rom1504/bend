#!/usr/bin/env python3
"""Join an exact-output request, ordered milestones and actual linked FID map."""
import argparse,json,sys
from pathlib import Path
sys.dont_write_bytecode=True
ROOT=Path(__file__).resolve().parents[5];PROF=ROOT/'selfhost/tools/profiler';sys.path.insert(0,str(PROF))
from run import pin,verify,save,all_pins
from attribute import bind_owners

def read(p):return json.loads(Path(p).read_text())
def need(value,message):
 if not value:raise ValueError(message)
def main():
 ap=argparse.ArgumentParser(description=__doc__)
 for name in ['plan','build','request','sidecar','guard','out']:ap.add_argument('--'+name,type=Path,required=True)
 a=ap.parse_args();need(not a.out.exists(),'Fresh metadata receipt required')
 result=dict(kind='phase143-milestone-request-verification',complete=False,targetsRun=False,stageAttributionValid=False,inputs=[pin(__file__)])
 try:
  files=[a.plan,a.build,a.request,a.sidecar,a.guard];result['inputs'] += [pin(p) for p in files]
  plan,built,request,sidecar,guard=map(read,files)
  for item in all_pins(plan):verify(item)
  need(plan['kind']=='phase143-optional-native-milestones' and plan['complete'] and not plan['nativeQualified'],'Experimental milestone plan required')
  need(built['complete'] and built['plan']==plan['plan'],'Diagnostic build not bound to plan')
  commands=read(verify(plan['plan']))['jobs']
  need(len(commands)==len(built['jobs'])==2,'Exact runtime compile/relink required')
  for expected,actual in zip(commands,built['jobs']):
   need(expected['command']==actual['command'] and actual['returncode']==0 and not actual['timedOut'],'Diagnostic build command/status mismatch')
   verify(actual['product'])
  image=built['jobs'][-1]['product']
  need(request['complete'] and request['image']==image and request['expectedQbe'],'Successful exact-oracle request required')
  for item in request['inputs']:verify(item)
  verify(request['product'])
  need(all(request['product'][k]==request['expectedQbe'][k] for k in ['bytes','sha256']),'Output oracle mismatch')
  need(guard['complete'] and guard['returncode']==0 and not guard.get('stoppedFor'),'Guarded request failed')
  command=guard['command'];binding='BEND_MILESTONES_OUT='+str(a.sidecar.resolve())
  guard_inputs_path=a.guard.parent/'inputs.json'
  result['inputs'].append(pin(guard_inputs_path));guard_inputs=read(guard_inputs_path)
  for item in guard_inputs:verify(dict(file=item['path'],bytes=item['bytes'],sha256=item['sha256']))
  def bound_option(option,identity):
   need(command.count(option)==1,'Unique explicit guarded option required: '+option)
   actual=command[command.index(option)+1]
   allowed=[identity['file'],str(Path(identity['file']).relative_to(ROOT))]
   recorded=dict(path=identity['file'],bytes=identity['bytes'],sha256=identity['sha256'])
   return actual in allowed and recorded in guard_inputs
  need(command.count(binding)==1 and bound_option('--image',image) and bound_option('--source',request['source']),'Sidecar/image/source not bound to guarded invocation')
  result['guardArgumentBinding']='Explicit absolute or repository-relative options, authenticated against original guard input snapshots; no inferred cwd.'
  result['requestExact']=True;result['observedMarkers']=sidecar.get('rows',[])
  need(sidecar.get('schema')=='bend-dispatch-milestones-v1' and sidecar.get('sequentialOnly') is True,'Unknown milestone schema')
  markers=plan['markers'];rows=sidecar['rows'];need(len(rows)==len(markers)==sidecar['expectedMarkers'],'Marker count mismatch')
  need(sidecar['expectedSegmentCount']==plan['expectedSegments'],'Wrong dispatch table size')
  owner_pin=next(p for p in plan['inputs'] if Path(p['file']).name=='owners.json')
  owner=read(verify(owner_pin));_,linked,binding_info=bind_owners(owner,image['file'])
  need(binding_info['elfType']==2,'Only exact non-PIE image addresses admitted')
  for row,marker in zip(rows,markers):
   need(row['label']==marker['label'] and row['fid']==marker['fid'],'Wrong ordered direct marker')
   need(int(row['segmentAddress'],16)==linked[marker['fid']]['elfAddress'],'Milestone address does not match actual current image')
  need(sidecar['complete'] and sidecar['observedInOrder']==len(markers) and not sidecar['badOrderOrDuplicate'] and not sidecar['clockError'],'Missing/repeated/reordered milestone: no stage timing admitted')
  need(all(row['entries']==1 for row in rows),'Each direct marker must execute exactly once')
  for name in ['wall','cpu']:
   values=[sidecar[name+'StartNs'],*[row[name+'Ns'] for row in rows],sidecar[name+'FinishNs']]
   need(all(isinstance(v,int) and v>=0 for v in values) and all(a<=b for a,b in zip(values,values[1:])),'Invalid monotonic clock sequence')
  labels=['Base preparation','parse/load','checking plus publication','proof dependence report','owned/foreign eligibility','main eligibility','checked context reconstruction','annotation/reach preparation','annotation layout check','erasure/request finalization']
  result['intervals']=[dict(label=label,begin=left['label'],end=right['label'],wallSeconds=(right['wallNs']-left['wallNs'])/1e9,cpuSeconds=(right['cpuNs']-left['cpuNs'])/1e9) for label,left,right in zip(labels,rows,rows[1:])]
  result.update(complete=True,stageAttributionValid=True,ownerBinding=binding_info,image=image,scope='Same current program.o and direct-FID sequence. Entry intervals include continuations/reference management; remaining backend/render/teardown is not split. One-request sequential diagnostic only; compare overhead before inferring clean costs.')
 except BaseException as error:result['error']=repr(error)
 save(a.out,result);print(json.dumps({k:result.get(k) for k in ['complete','requestExact','stageAttributionValid','error']}));return 0 if result['complete'] else 1
if __name__=='__main__':sys.exit(main())

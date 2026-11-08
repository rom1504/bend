#!/usr/bin/env python3
"""One experimental session interface over the maintained compiler and explicit assets."""
import argparse
import hashlib
import json
import os
from pathlib import Path
import sys
import time
sys.dont_write_bytecode = True
HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE.parent))
import assets
import request as requests
from common import changed_inputs, clean_environment, fresh_output, pin, require, run, timeout, workspace, write_json
sys.path.insert(0, str(HERE))
import transport

def plan(a):
    root=workspace(a.workspace);timeout(a.seconds);clean_environment();doc=assets.load_assets(a.assets,root)
    a.target='qbe';image,metadata,image_inputs=requests.image_binding(a,doc)
    base,carrier,stamp,base_inputs=assets.prepared_base(doc,'cache',a.base_key,a.carrier_key)
    runtime=assets.asset(doc,a.runtime_key);jobs_pin=pin(a.jobs);jobs_document=json.loads(Path(jobs_pin['file']).read_text())
    require(jobs_document.get('kind')=='bend-session-jobs' and jobs_document.get('version')==1,'Versioned job manifest required')
    logical=jobs_document['logical'];require(Path(logical).is_absolute() and '\n' not in logical and '\r' not in logical,'Absolute logical source path required')
    jobs=jobs_document['jobs'];require(isinstance(jobs,list) and 0<len(jobs)<=64,'One to64 jobs required')
    inputs=[doc['_manifest'],pin(__file__),pin(sys.executable),pin(HERE/'hosted.mjs'),pin(HERE.parent/'hosted.mjs'),pin(HERE/'transport.py'),pin(requests.__file__),pin(assets.__file__),pin(HERE.parent/'common.py'),jobs_pin,*image_inputs,*base_inputs,runtime]
    prepared=[]
    for i,j in enumerate(jobs):
        source=pin(j['source']);require(0<source['bytes']<=16777216,'Source exceeds bounded reader')
        require(type(j['hint']) is int and 0<=j['hint']<2**32 and j['mode'] in ['cold','warm'],'Invalid offset/mode')
        require(isinstance(j['owner'],str) and j['owner'] and not any(c in j['owner'] for c in '\n\r'),'Invalid owner')
        row=dict(name=j.get('name',str(i)),source=source,hint=j['hint'],owner=j['owner'],mode=j['mode'],expectError=j.get('expectError',False))
        require(type(row['expectError']) is bool,'Expected error must be Boolean');inputs.append(source)
        if j.get('expected'):row['expected']=pin(j['expected']);inputs.append(row['expected'])
        prepared.append(row)
    result=dict(kind='bend-experimental-session-request',version=1,experimental=True,selected=False,host=a.host,stage=a.stage,target='qbe',
      image=image,imageMetadata=metadata,base=base,carrier=carrier,stamp=stamp,runtime=runtime,logical=logical,jobs=prepared,
      policy=dict(kind='cached-session-v1',logicalSourcePath=logical),inputs=inputs,out=str(a.out.resolve()),checkCold=a.check_cold,units=a.units,
      imageRuntime=metadata.get('linkedRuntime'),runtimeRole='Image linked runtime and target build runtime are distinct identities.')
    if a.host=='js':
        require(metadata.get('checked') is True and metadata.get('protocol')=='session-api-v1','Explicit checked session API required');engine=assets.asset(doc,a.engine_key);inputs.append(engine)
        result['engine']=engine
        result['command']=[engine['file'],str(HERE/'hosted.mjs'),str(a.out.resolve()/'request.json')]
    else:
        require('P140/2' in metadata.get('sessionProtocols',[]),'Image binding must explicitly advertise P140/2 session protocol')
        require(not a.units and not a.check_cold and not any(j['expectError'] for j in prepared),'Native batch supports success jobs only; hosted controls establish recovery/units')
        require(os.access(image['file'],os.X_OK),'Executable native image required')
        result['runtimeArgumentConvention']=assets.runtime_argument_convention(metadata)
        require(result['runtimeArgumentConvention']!='bend-rts-v1' or 'BENDRTS' not in os.environ,'Explicit RTS requests require ambient BENDRTS to be unset')
        result['command']=[image['file'],*assets.runtime_arguments(metadata,application=True),'phase140-batch',logical,base['file'],carrier['file'],stamp,str(a.out.resolve()/'jobs.txt'),'v1']
    return result

def execute(a,request):
    root=workspace(a.workspace);out=fresh_output(a.out,root);write_json(out/'request.json',request)
    report=dict(kind='bend-experimental-session',version=1,complete=False,experimental=True,selected=False,request=request,
      scope='Explicit mode-matched session. No native self-hosting qualification, general invalidation theorem or compiler selection.')
    started=time.monotonic()
    try:
        if a.host=='native':
            lines=[]
            for i,j in enumerate(request['jobs']):
                fields=[j['source']['file'],str(out/f'{i:03}.frames'),str(j['hint']),j['owner'],j['mode']]
                require(not any('\n' in x or '\r' in x for x in fields),'Record separator in path');lines.extend(fields)
            (out/'jobs.txt').write_text('\n'.join(lines)+'\n')
        process=run(request['command'],cwd=root,stdout=out/'stdout.log',stderr=out/'stderr.log',seconds=a.seconds);report['process']=process
        require(process['complete'] and process['stderr']['bytes']==0,'Session producer failed or diagnosed error')
        if a.host=='js':
            observed=json.loads((out/'hosted.json').read_text());require(observed.get('complete') is True,'Hosted session incomplete');report['observed']=pin(out/'hosted.json')
        else:
            prior=None;rows=[]
            for i,j in enumerate(request['jobs']):
                context=dict(kind='phase140-transport-context',protocol=2,session=hashlib.sha256(str(out).encode()).hexdigest(),producer=request['image'],runtime=request['runtime'],source=j['source'],policy=request['policy'],inputs=request['inputs'])
                cp=out/f'{i:03}-context.json';write_json(cp,context)
                with (out/f'{i:03}.frames').open('rb') as stream:
                    decoded=transport.decode(stream,out/f'{i:03}-transport',cp,pin(cp)['sha256'],prior,pin(prior)['sha256'] if prior else None,j.get('expected',{}).get('sha256'))
                prior=out/f'{i:03}-transport/report.json';rows.append(dict(name=j['name'],transport=pin(prior),product=decoded['payload'],reusedPieces=decoded['reusedPieces']))
            report['rows']=rows
        report['complete']=True
    except BaseException as error:report['error']=repr(error)
    finally:
        report['changedInputs']=changed_inputs(request['inputs']);report['complete']=report['complete'] and not report['changedInputs']
        report['seconds']=time.monotonic()-started;write_json(out/'report.json',report)
    return report

def main():
    p=argparse.ArgumentParser(description=__doc__);p.add_argument('--workspace',type=Path);p.add_argument('--assets',type=Path,required=True)
    image=p.add_mutually_exclusive_group(required=True);image.add_argument('--image-key');image.add_argument('--image',type=Path)
    p.add_argument('--image-receipt',type=Path);p.add_argument('--host',choices=['native','js'],required=True);p.add_argument('--stage',required=True)
    p.add_argument('--jobs',type=Path,required=True);p.add_argument('--out',type=Path,required=True);p.add_argument('--seconds',type=float,default=120)
    for key,default in [('base-key','base'),('carrier-key','prepared-base'),('runtime-key','qbe-runtime'),('engine-key','bun')]:p.add_argument('--'+key,default=default)
    p.add_argument('--check-cold',action='store_true');p.add_argument('--units',action='store_true');p.add_argument('--plan',action='store_true');a=p.parse_args();request=plan(a)
    if a.plan:print(json.dumps(request,indent=2));return 0
    result=execute(a,request);print(json.dumps({k:result.get(k) for k in ['complete','seconds','error']}));return 0 if result['complete'] else 1
if __name__=='__main__':sys.exit(main())

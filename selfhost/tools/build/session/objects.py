#!/usr/bin/env python3
"""Reuse exact Bend-framed QBE units; preserve the qualified ELF globalization policy.

This machine receipt never attests producer success. Join the source/session
receipt separately. Run under the existing outer disk/process guard.
"""
import argparse
import fcntl
import hashlib
import json
import os
from pathlib import Path
import shutil
import sys
import time
sys.dont_write_bytecode=True
HERE=Path(__file__).resolve().parent
sys.path.insert(0,str(HERE.parent))
import assets
from common import changed_inputs, clean_environment, fresh_output, pin, require, run, timeout, verify, workspace, write_json
sys.path.insert(0,str(HERE))
import protocol
import elf

FLAGS=dict(qbe=['-t','amd64_sysv'],assembler=['-mbranches-within-32B-boundaries'],linker=['-no-pie','-Wl,--build-id=none'],libraries=['-pthread','-lm'])
def key(context,kind,payload):
    return hashlib.sha256(json.dumps(dict(context=context,kind=kind,payload=payload),sort_keys=True,separators=(',',':')).encode()).hexdigest()

def build(a):
    root=workspace(a.workspace);clean_environment();timeout(a.seconds);doc=assets.load_assets(a.assets,root)
    require(0<a.max_unit_bytes<=268435456,'Bounded unit size required')
    tools={name:assets.asset(doc,name) for name in ['qbe','assembler','linker','objcopy']}
    runtime=assets.asset(doc,a.runtime_key);stream_pin=pin(a.stream);source=pin(a.source);producer=pin(a.producer)
    policy=doc.get('toolchains',{}).get('qbe',{})
    require(policy.get('target')=='amd64_sysv' and policy.get('assemblerFlags')==FLAGS['assembler'] and policy.get('linkerFlags')==['-no-pie'] and policy.get('libraries')==FLAGS['libraries'],'Unknown QBE toolchain policy')
    methods=[pin(__file__),pin(HERE/'protocol.py'),pin(HERE/'elf.py'),pin(HERE.parent/'common.py'),pin(assets.__file__)]
    context=dict(policy='closed-framed-generated-symbols-v1',producer=producer,runtime=runtime,tools=tools,flags=FLAGS,methods=methods,
      policySalt=a.policy_salt,abi='amd64 SysV scalar w/l; generated symbols globalized only inside a closed non-PIE executable')
    expected=pin(a.expected) if a.expected else None;inputs=[doc['_manifest'],source,producer,runtime,stream_pin,*tools.values(),*methods,*([expected] if expected else [])]
    cache=a.cache.absolute();out=a.out.absolute()
    require(cache==cache.resolve() and cache.is_relative_to(root/'selfhost/build') and not cache.is_symlink(),'Confined nonsymlink cache required')
    require(not cache.is_relative_to(out) and not out.is_relative_to(cache),'Disjoint output/cache required')
    if a.cold:require(not cache.exists(),'Cold reference needs a fresh cache')
    out=fresh_output(out,root);cache.mkdir(parents=True,exist_ok=True)
    start=time.monotonic();deadline=start+a.seconds;lock=(cache/'writer.lock').open('a')
    report=dict(kind='bend-experimental-object-session',version=1,complete=False,publishable=False,producerStatusVerified=False,experimental=True,
      source=source,stream=stream_pin,context=context,inputs=inputs,cache=str(cache),units=[],jobs=[],
      scope='Exact producer/runtime/tool/policy/payload object reuse. Source identity is recorded per request, not included in a unit key; unchanged units may survive a real edit. No semantic reuse decision occurs in this host.')
    current=None;whole=hashlib.sha256();whole_bytes=0;objects=[];definitions=set()
    def save():report['seconds']=time.monotonic()-start;write_json(out/'report.json',report)
    def left():
        value=deadline-time.monotonic()
        if value<=0:raise TimeoutError('Whole machine stage deadline')
        return value
    def stage(label,command,directory):
        job=run(command,cwd=root,stdout=directory/(label+'.stdout'),stderr=directory/(label+'.stderr'),seconds=left());job['label']=label;report['jobs'].append(job);save()
        require(job['complete'],'Machine stage failed: '+label)
        if label=='qbe':require(job['stderr']['bytes']==0,'Unexpected QBE diagnostics')
    def begin(kind,index):
        nonlocal current
        left();directory=out/f'unit-{index:05d}';directory.mkdir();file=directory/'unit.ssa'
        current=dict(kind=kind,index=index,directory=directory,path=file,file=file.open('xb'),hash=hashlib.sha256(),bytes=0)
        def write(data):
            nonlocal whole_bytes
            require(current['bytes']+len(data)<=a.max_unit_bytes,'Unit byte bound exceeded')
            require(whole_bytes+len(data)<=512*1024*1024,'Whole framed byte bound exceeded')
            current['file'].write(data);current['hash'].update(data);current['bytes']+=len(data);whole.update(data);whole_bytes+=len(data)
        return write
    def end(kind,index,size):
        nonlocal current
        u=current;u['file'].close();require(size==u['bytes'],'Frame size mismatch');digest=dict(bytes=size,sha256=u['hash'].hexdigest())
        identity=key(context,kind,digest);entry=cache/identity;hit=entry.exists();row=dict(index=index,kind=kind,payload=digest,key=identity,reused=hit);report['units'].append(row);save()
        require(not entry.is_symlink(),'Cache entry symlink refused')
        if hit:
            receipt_pin=pin(entry/'receipt.json');receipt=json.loads(Path(receipt_pin['file']).read_text())
            require(receipt.get('complete') is True and receipt.get('key')==identity and receipt.get('context')==context and receipt.get('payload')==digest,'Cache receipt admission mismatch')
            obj=entry/'unit.o';require(receipt['object']['file']==str(obj),'Cache object path escaped its entry');verify(receipt['object']);names=elf.metadata(obj)['definitions']
            require(names==receipt['definitions'],'Cached definition inventory mismatch');verify(receipt_pin)
        else:
            entry.mkdir();asm=entry/'unit.s';raw=entry/'raw.o';obj=entry/'unit.o'
            stage('qbe',[tools['qbe']['file'],*FLAGS['qbe'],'-o',asm,u['path']],entry)
            stage('assemble',[tools['assembler']['file'],*FLAGS['assembler'],'-o',raw,asm],entry)
            before=elf.metadata(raw);symbols=entry/'globalize.txt';symbols.write_text(''.join(x+'\n' for x in before['promoted']))
            if before['promoted']:stage('globalize',[tools['objcopy']['file'],'--globalize-symbols='+str(symbols),raw,obj],entry)
            else:shutil.copyfile(raw,obj)
            after=elf.metadata(obj);elf.compare(before,after);names=after['definitions']
            receipt=dict(complete=True,key=identity,context=context,payload=digest,object=pin(obj),definitions=names,promoted=before['promoted'],allocatedAndRelocationsExact=True,originSource=source)
            write_json(entry/'receipt.json',receipt);asm.unlink();raw.unlink()
        require(not definitions.intersection(names),'Duplicate generated definition');definitions.update(names);objects.append(obj)
        row.update(receipt=pin(entry/'receipt.json'),object=pin(obj));require(pin(u['path'])['sha256']==digest['sha256'],'Current unit changed')
        if a.retain_units:row['text']=pin(u['path'])
        else:u['path'].unlink()
        current=None;save()
    save()
    try:
        while True:
            left()
            try:fcntl.flock(lock,fcntl.LOCK_EX|fcntl.LOCK_NB);break
            except BlockingIOError:time.sleep(.05)
        with a.stream.open('rb') as stream:report['framing']=protocol.units(stream,begin,end)
        report['payloadDigest']=dict(bytes=whole_bytes,sha256=whole.hexdigest())
        if expected:require(report['payloadDigest']=={k:expected[k] for k in ['bytes','sha256']},'Complete payload differs from expected QBE')
        require(objects and {'main','p111_program'}<=definitions,'Incomplete closed-image definitions')
        stage('link',[tools['linker']['file'],*FLAGS['linker'],*objects,runtime['file'],*FLAGS['libraries'],'-o',out/'program'],out)
        for row in report['units']:verify(row['object']);verify(row['receipt'])
        report.update(binary=pin(out/'program'),reusedUnits=sum(x['reused'] for x in report['units']),builtUnits=sum(not x['reused'] for x in report['units']),complete=True)
    except BaseException as error:report['error']=repr(error)
    finally:
        if current and not current['file'].closed:current['file'].close()
        report['changedInputs']=changed_inputs(inputs);report['complete']=report['complete'] and not report['changedInputs'];save();fcntl.flock(lock,fcntl.LOCK_UN);lock.close()
    return report

def main():
    p=argparse.ArgumentParser(description=__doc__)
    for name in ['assets','stream','out','cache','producer','source']:p.add_argument('--'+name,type=Path,required=True)
    p.add_argument('--workspace',type=Path);p.add_argument('--runtime-key',default='qbe-runtime');p.add_argument('--policy-salt',default='')
    p.add_argument('--expected',type=Path);p.add_argument('--seconds',type=float,default=120);p.add_argument('--max-unit-bytes',type=int,default=67108864)
    p.add_argument('--cold',action='store_true');p.add_argument('--retain-units',action='store_true');a=p.parse_args();r=build(a)
    print(json.dumps({k:r.get(k) for k in ['complete','reusedUnits','builtUnits','binary','error']}));return 0 if r['complete'] else 1
if __name__=='__main__':sys.exit(main())

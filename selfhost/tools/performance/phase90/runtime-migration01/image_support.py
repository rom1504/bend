"""One-time native07 lineage/join/build checks; no execution or compiler rewriting."""
import sys
from pathlib import Path
sys.dont_write_bytecode=True
from support import ROOT,P,SOURCE_SHA,RUNTIME_SHA,transition,historical,transport,request_auth,args,read,pin,verify
JS_METHOD=P/'phase90/bootstrap/emit-self-runtime02.mjs'
JS_METHOD_SHA='e201f1387c3866ece7cc966cbe52633912f8b87ea72ae9f0a545968e0ce45511'
NATIVE_METHOD=Path(__file__).with_name('run.py')
NATIVE_METHOD_SHA='3a6a0ba11bafaee9a6a903969aa21f6cb578bfb3ef33c6822ae0b16aa8cc70ae'

def exact(a,b):return all(a[k]==b[k] for k in ['sha256','bytes'])

def join(native_file,js_file,js_guard):
    seal,seal_pin=transition(audit=True)
    native_pin,js_pin=pin(native_file),pin(js_file);native,js=read(native_file),read(js_file)
    assert native['kind']=='phase90-native-new-runtime-emission'
    assert native['complete'] and native['passed'] and native['executionPerformed'] and native['inputsUnchanged'] and not native['checkOnly']
    assert native['calls']==1 and native['sourceUnchanged']
    assert verify(native['method'])==pin(NATIVE_METHOD) and native['method']['sha256']==NATIVE_METHOD_SHA
    for m in native['methods']:verify(m)
    auth,provenance=request_auth(verify(native['transport'])['file'])
    assert native['producer']['authentication']==seal['producer'] and native['transition']==seal_pin
    assert native['cache']==seal['cache'] and native['subject']==auth['source']
    assert native['subject']['sha256']==SOURCE_SHA
    output=verify(native['output']);assert len(native['outputs'])==1 and output==verify(native['outputs'][0])
    assert output['file']==str(Path(native_file).resolve().parent/'output.1.c')
    process=read(verify(pin(Path(native['guard'])/'process.json'))['file'])
    assert process==native['process'] and process['complete'] and process['returncode']==0 and not process.get('stoppedFor')
    argv=args(auth,auth['source']['file'],Path(native_file).resolve().parent/'output',1)
    assert process['command'][-len(argv):]==argv and native['command'][-len(argv):]==argv
    for p in native['guardReceipts']:verify(p)
    assert len(native['requestMs'])==1
    assert js['kind']=='phase90-qualified-js-b2-new-runtime-emission' and js['complete'] and js['stage']=='complete'
    assert js['inputsUnchanged'] and js['verification']['inputsUnchanged'] and js['verification']['copiesUnchanged'] and js['verification']['requestCopiesUnchanged']
    assert js['observation']['status']=='ok' and js['observation']['checked']
    assert len(js['policy'])==4 and all(v==0 for v in js['policy'].values())
    js_inputs=[historical(p,seal) for p in js['inputs']]
    method=pin(JS_METHOD);assert method['sha256']==JS_METHOD_SHA and method in js_inputs
    producer=js['producer'];assert producer['stage']=='self-emitted driver-qualified JS-hosted Bend B2'
    pins=read(verify(producer['imagePins'])['file']);assert pins['kind']=='phase56-direct-image-pins'
    for key in ['attempt','emission','comparison']:assert exact(verify(producer[key]),verify(pins[key]))
    assert exact(verify(producer['api']),verify(pins['b2'])) and exact(verify(producer['generator']),verify(pins['b1']))
    assert read(pins['emission']['file'])['pass'] and read(pins['comparison']['file'])['pass']
    assert verify(js['subject'])==auth['source'] and js['sourceDerivation']['inverseRecoversAncestor'] and js['sourceDerivation']['exactOutsideReplacements']
    assert js['requestRuntime']['producerUnchanged']
    for key in ['plan','ready','templateReceipt','driver']:
        assert verify(js['requestRuntime'][key])==verify(native['requestRuntime'][key])
    for key in ['runtime','template']:
        assert exact(verify(js['requestRuntime'][key]),verify(native['requestRuntime'][key]))
    assert js['requestRuntime']['runtime']['sha256']==RUNTIME_SHA
    twin=verify(js['output']);assert exact(output,twin),'Full native06 and genuine JS B2 C differ'
    guard_pin=pin(Path(js_guard)/'process.json');guard=read(guard_pin['file'])
    assert guard['complete'] and guard['returncode']==0 and not guard.get('stoppedFor')
    tail=guard['command'][-5:]
    tail=[str((ROOT/p).resolve()) for p in tail]
    assert tail[0]==str(JS_METHOD) and tail[1]==producer['imagePins']['file'] and tail[3]==str(Path(js_file).resolve().parent) and tail[4]==js['requestRuntime']['ready']['file']
    method_plan=pin(tail[2]);assert method_plan in js_inputs
    assert read(tail[2])['kind']=='phase90-selfhosting-qualification-plan'
    guard_inputs=[historical(p,seal) for p in read(Path(js_guard)/'inputs.json')]
    assert method in guard_inputs and verify(producer['node']) in guard_inputs
    return dict(kind='phase90-native06-genuine-js-b2-new-runtime-c-equality',complete=True,source=auth['source'],
        nativeEmission=native_pin,jsEmission=js_pin,jsGuard=guard_pin,transport=verify(native['transport']),transition=seal_pin,
        c=output,independentC=twin,exactC=True,runtime=verify(native['requestRuntime']['runtime']),
        producer=seal['producer'],methods=[pin(__file__),pin(Path(__file__).with_name('support.py')),method,pin(NATIVE_METHOD)],
        scope='Unpatched C emitted independently by native06 and genuine JS B2 from exact D04 with identical new runtime bytes. No native07 build or self-execution yet.')

def bind(native_file,js_file,js_guard,build_guard,image):
    comparison=join(native_file,js_file,js_guard)
    process_pin=pin(Path(build_guard)/'process.json');process=read(process_pin['file'])
    inputs_pin=pin(Path(build_guard)/'inputs.json');inputs=[verify(p) for p in read(inputs_pin['file'])]
    binary=pin(image)
    assert process['complete'] and process['returncode']==0 and not process.get('stoppedFor')
    assert comparison['c']['file'] in process['command'] and binary['file'] in process['command']
    assert comparison['c'] in inputs
    return dict(kind='phase90-native-runtime-migrated-image',complete=True,method=pin(__file__),binary=binary,
        source=comparison['source'],c=comparison['c'],comparison=comparison,guard=process_pin,buildInputs=inputs_pin,
        inputs=inputs,command=process['command'],transport=comparison['transport'],transition=comparison['transition'],
        cPatched=False,ownBackend=True,selfQualified=False,publicAdmitted=False,
        scope='Actual native07 build of unpatched native06 C independently equal to genuine JS B2 output. Actual compiler flags are retained; successor equality and semantic controls remain required.')

def authenticate_unqualified(image,receipt_file):
    receipt_pin=pin(receipt_file);receipt=read(receipt_file)
    assert receipt['kind']=='phase90-native-runtime-migrated-image' and receipt['complete'] and not receipt['cPatched']
    assert receipt['ownBackend'] and not receipt['publicAdmitted']
    assert verify(receipt['binary'])==pin(image)
    comparison=receipt['comparison']
    current=bind(comparison['nativeEmission']['file'],comparison['jsEmission']['file'],Path(comparison['jsGuard']['file']).parent,
                 Path(receipt['guard']['file']).parent,image)
    assert current==receipt
    auth,provenance=request_auth(receipt['transport']['file'])
    auth=dict(auth,image=receipt['binary'],source=receipt['source'],c=receipt['c'],provenance='native-emitted-unpatched-C',diagnosticOnly=False)
    return auth,dict(build=receipt_pin,comparison=comparison,transport=receipt['transport'],transition=receipt['transition'],
        producer=receipt,originProducer=provenance['producer'],requestRuntime=provenance['requestRuntime'])

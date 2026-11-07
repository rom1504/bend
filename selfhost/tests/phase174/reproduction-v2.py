#!/usr/bin/env python3
"""Aggregate native reproduction with the exact Phase174 ELF metadata audit."""
import argparse
import hashlib
import importlib.util
import json
from pathlib import Path
import struct
import sys
import time

sys.dont_write_bytecode = True
ROOT = Path(__file__).resolve().parents[3]
sys.path.insert(0,str(ROOT/'selfhost/tools/build'))
import common

CANONICAL = dict(bytes=3161409,sha256='74cd7de3e5076490e20ba0218d4c9254853be72562946b9ef66fed6c10c7a53a')
CHUNK = 1024 * 1024


def same_identity(a,b):
    return all(a.get(k)==b.get(k) for k in ('bytes','sha256'))


def need(value,message):
    common.require(value,message)


def load_segments(path):
    """Bounded ELF64 AMD64 load-image reader, including zero-fill metadata."""
    before=common.pin(path)
    with Path(path).open('rb') as stream:
        header=stream.read(64)
        need(len(header)==64 and header[:7]==b'\x7fELF\x02\x01\x01','ELF64 little endian required')
        values=struct.unpack('<16sHHIQQQIHHHHHH',header)
        _,typ,machine,version,entry,phoff,_,flags,ehsize,phsize,phnum,_,_,_=values
        need(typ in (2,3) and machine==62 and version==1 and ehsize==64 and phsize==56 and phnum<=64,'Unsupported bounded AMD64 executable')
        need(phoff+phsize*phnum<=before['bytes'],'ELF program table outside file')
        loads=[]
        for index in range(phnum):
            stream.seek(phoff+index*phsize)
            record=stream.read(phsize)
            need(len(record)==phsize,'Truncated ELF program header')
            kind,permissions,offset,address,physical,size,memory,alignment=struct.unpack('<IIQQQQQQ',record)
            if kind!=1:continue
            need(size<=memory and offset+size<=before['bytes'],'PT_LOAD range invalid')
            stream.seek(offset);digest=hashlib.sha256();remaining=size
            while remaining:
                chunk=stream.read(min(CHUNK,remaining))
                need(chunk,'Truncated PT_LOAD bytes')
                digest.update(chunk);remaining-=len(chunk)
            loads.append(dict(offset=offset,virtualAddress=address,physicalAddress=physical,
                fileBytes=size,memoryBytes=memory,flags=permissions,alignment=alignment,sha256=digest.hexdigest()))
    need(loads and before==common.pin(path),'ELF changed while reading load segments')
    return dict(type=typ,machine=machine,entry=entry,flags=flags,segments=loads)


def main():
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--out',type=Path,required=True)
    args=parser.parse_args()
    out=common.fresh_output(args.out,ROOT)
    started=time.monotonic()
    pins={}
    report=dict(kind='phase174-native-reproduction-v2',version=1,complete=False,targetsRun=False,
        n1Reused=False,allSameSource=False,qbeFixedPoint=False,loadedSegmentsEqual=False,
        inputs=[],changedInputs=[],scope='Existing native N1 acquisition, fresh N1-to-N2 build and actual N2 Q3 request. Mechanical self-reproduction is not a correctness theorem or independent conformance gate.')

    def track(row):
        need(isinstance(row,dict) and all(k in row for k in ('file','bytes','sha256')),'File identity required')
        path=str(Path(row['file']).resolve(strict=True))
        actual=dict(row,file=path)
        if path in pins:need(same_identity(pins[path],actual),'Conflicting input pins: '+path)
        else:
            common.verify(actual)
            pins[path]={k:actual[k] for k in ('file','bytes','sha256')}
        return pins[path]

    def read_report(path,kind,historical=False):
        bound=track(common.pin(path))
        value=json.loads(Path(bound['file']).read_text())
        need(value.get('kind')==kind and value.get('version')==1 and value.get('complete') is True,'Successful '+kind+' required')
        need(not value.get('error') and value.get('changedInputs')==[],'Unchanged completed report required')
        # Historical acquisition-time source/tool metadata is provenance, not
        # a demand that every old checkout file still occupy its former bytes.
        # Its immutable receipt is authenticated separately against the frozen
        # reference. Actual source/image/runtime/products are checked below.
        if not historical:
            for row in value['inputs']:track(row)
        request=value['request']
        request_file=Path(bound['file']).with_name('request.json')
        request_pin=track(common.pin(request_file))
        need(json.loads(request_file.read_text())==request,'Embedded request differs from frozen request.json')
        need(request.get('kind')=='bend-build-request-plan' and request.get('version')==1,'Known request-plan schema required')
        need(request.get('host')=='native' and request.get('target')=='qbe' and request.get('mode')=='cache','Native cached QBE request required')
        need(request.get('outputContract')=='stdout' and request['imageMetadata'].get('protocol')=='qbe-source-v1','QBE source protocol required')
        if not historical:
            for row in request['inputs']:track(row)
        for key in ('source','image','base','carrier'):track(request[key])
        # Installed-image metadata historically keeps a digest-only runtime
        # identity; its actual object is authenticated through build.runtime.
        runtime_identity=request['imageRuntime']
        need(isinstance(runtime_identity,dict) and isinstance(runtime_identity.get('bytes'),int)
             and isinstance(runtime_identity.get('sha256'),str) and len(runtime_identity['sha256'])==64,
             'Explicit linked-runtime identity required')
        if 'file' in runtime_identity:track(runtime_identity)
        need(request['command'][0]==request['image']['file'],'Request command is not its pinned producer')
        if kind=='bend-native-build':
            need(value.get('compilerExitCode')==value.get('qbeExitCode')==0 and value.get('sourceIR') is None,'Source-producing native build required')
            need(value['compilerCommand']==request['command'],'Producer command differs from request')
            need(value.get('retainIR') is True,'Retained complete QBE required')
            need(value.get('processes') and all(x.get('status')==0 for x in value['processes']),'Incomplete compiler/QBE processes')
            labels=set()
            for job in value['jobs']:
                need(job.get('complete') and job.get('exitCode')==0 and not job.get('timedOut'),'Incomplete machine construction')
                labels.add(job['label']);track(job['stdout']);track(job['stderr'])
            need({'assemble','link'}<=labels,'Assembler/linker stages missing')
            for key in ('compilerStderr','qbeStderr','qbeStdout'):
                need(track(value[key])['bytes']==0,'Unexpected compiler/QBE diagnostic')
            for key in ('runtime','retainedIR','assembly','object','binary'):track(value[key])
            need(same_identity(value['retainedIR'],value['irDigest']),'Retained QBE differs from complete stream digest')
        else:
            child=value['process']
            need(child.get('complete') and child.get('exitCode')==0 and not child.get('timedOut'),'Q3 request did not complete')
            need(child['command']==request['command'],'Q3 command differs from request')
            need(track(child['stderr'])['bytes']==0,'Unexpected Q3 diagnostics')
            track(child['stdout']);track(value['product'])
            need(same_identity(child['stdout'],value['product']),'Q3 stdout/product mismatch')
        return value,bound,request_pin

    try:
        track(common.pin(__file__));track(common.pin(common.__file__));track(common.pin(sys.executable))
        source=track(common.pin(ROOT/'selfhost/build/phase174/source01/compiler.bend'))
        need(same_identity(source,CANONICAL),'Integrated canonical source differs')
        reference_path=ROOT/'selfhost/build/phase174/reference-source01/receipt.json'
        track(common.pin(reference_path));reference=json.loads(reference_path.read_text())
        need(reference.get('kind')=='phase174-frozen-reference' and reference.get('complete'),'Frozen promotion reference required')
        track(reference['source'])
        frozen_n1=next(row for row in reference['pins'] if row['file']=='selfhost/build/phase171/native-candidate01/report.json')
        frozen_binary=next(row for row in reference['pins'] if row['file']=='selfhost/build/phase171/native-candidate01/program')
        historical_path=ROOT/'selfhost/build/phase171/native-candidate01/report.json'
        need(same_identity(common.pin(historical_path),frozen_n1),'Historical receipt differs from frozen reference')
        n1,n1_receipt,n1_request=read_report(historical_path,'bend-native-build',historical=True)
        n2,n2_receipt,n2_request=read_report(ROOT/'selfhost/build/phase174/native-n2/report.json','bend-native-build')
        q3,q3_receipt,q3_request=read_report(ROOT/'selfhost/build/phase174/q3/report.json','bend-build-request')
        need(same_identity(n1_receipt,frozen_n1) and same_identity(n1['binary'],frozen_binary),'Historical N1 reuse differs from frozen reference')
        frozen_parent=next(row for row in reference['pins'] if row['file']=='selfhost/dist/qbe/bend')
        need(same_identity(n1['request']['image'],frozen_parent) and same_identity(n1['request']['imageMetadata']['sourceIdentity'],reference['source']),
             'Historical N1 parent image/source identity differs from frozen Phase170 reference')
        report.update(source=source,n1=n1['binary'],n2=n2['binary'],n1Reused=True,
            receipts=dict(n1=n1_receipt,n2=n2_receipt,q3=q3_receipt),requests=dict(n1=n1_request,n2=n2_request,q3=q3_request))
        report['historicalAcquisition']=dict(receipt=n1_receipt,inputsAtAcquisition=n1['inputs'],
            changedInputsAtAcquisition=n1['changedInputs'],parent=n1['request']['image'],parentSource=reference['source'],
            policy='Frozen receipt/request bytes and actual source/image/parent/runtime/products reauthenticated. Historical acquisition input list is retained provenance, not current checkout dependencies.')
        for built,stage in ((n1,'N1'),(n2,'N2')):
            binding=built['imageBinding']
            need(binding.get('kind')=='bend-build-image-binding' and binding.get('version')==1 and binding.get('complete'),'Complete derived-image binding required')
            need(binding.get('host')=='native' and binding.get('stage')==stage and binding.get('targets')==['qbe'] and binding.get('protocol')=='qbe-source-v1','Incorrect derived compiler stage/protocol')
            need(binding['image']==built['binary'] and binding['producer']==built['request']['image'],'Derived binding/image/producer mismatch')
            need(binding['producerHost']==built['request']['host'] and binding['producerStage']==built['request']['stage'],'Derived producer stage mismatch')
            need(same_identity(binding['sourceIdentity'],source) and same_identity(built['request']['source'],source),'Different self-compilation source')
            need(same_identity(binding['linkedRuntime'],built['runtime']),'Binding runtime differs from linked object')
        need(n2['request']['image']==n1['binary'] and n2['request']['imageMetadata']==n1['imageBinding'] and n2['request']['stage']=='N1','N2 was not built by the authenticated N1')
        need(q3['request']['image']==n2['binary'] and q3['request']['imageMetadata']==n2['imageBinding'] and q3['request']['stage']=='N2','Q3 was not emitted by the authenticated N2')
        need(same_identity(q3['request']['source'],source),'Q3 source differs')
        need(n1['runtime']==n2['runtime'] and n1['toolchain']==n2['toolchain'],'Machine runtime/toolchain policy differs')
        for value in (n1,n2,q3):
            request=value['request']
            need(same_identity(request['imageRuntime'],n1['runtime']),'Executing compiler runtime differs')
            for key in ('base','carrier','stamp','mode','providers','outputContract'):
                need(request[key]==n1['request'][key],'Preparation/provider boundary differs: '+key)
        # Equal flags alone do not authenticate the machine tools.
        tools=[]
        for built in (n1,n2):
            paths=[built['qbeCommand'][0]]+[next(j for j in built['jobs'] if j['label']==label)['command'][0] for label in ('assemble','link')]
            toolpins=[next(row for row in built['inputs'] if row['file']==path) for path in paths]
            tools.append(toolpins)
        need(all(same_identity(a,b) for a,b in zip(*tools)),'Actual QBE/assembler/linker identities differ')
        need(n2.get('comparedToReference') is True and n2['expectedQbe']==n1['retainedIR'],'Fresh N2 did not use the old complete QBE oracle')
        need(q3.get('byteExact') is True and q3['request']['expected']==n2['retainedIR'],'Actual Q3 did not compare the complete N2 QBE product')
        report['allSameSource']=True
        report['bindings']=dict(n1=n1['imageBinding'],n2=n2['imageBinding'],q3Producer=q3['request']['imageMetadata'])
        report['runtime']=n1['runtime'];report['toolchain']=n1['toolchain'];report['tools']=tools[0]
        products={'program.ssa':('retainedIR',),'program.s':('assembly',),'program.o':('object',)}
        machine={}
        for name,(key,) in products.items():
            machine[name]=same_identity(n1[key],n2[key]) and common.same_bytes(n1[key]['file'],n2[key]['file'])
            need(machine[name],'Exact generation product differs: '+name)
        qbe=same_identity(n2['retainedIR'],q3['product']) and common.same_bytes(n2['retainedIR']['file'],q3['product']['file'])
        need(qbe,'Q3 complete QBE fixed point failed')
        report['machineIdentity']=machine;report['qbeFixedPoint']=qbe
        report['products']=dict(n1={name:n1[key[0]] for name,key in products.items()},n2={name:n2[key[0]] for name,key in products.items()},q3=q3['product'])
        loaded1=load_segments(n1['binary']['file']);loaded2=load_segments(n2['binary']['file'])
        report['loadedSegments']=dict(n1=loaded1,n2=loaded2)
        report['loadedSegmentsEqual']=loaded1==loaded2
        report['wholeELFEqual']=same_identity(n1['binary'],n2['binary']) and common.same_bytes(n1['binary']['file'],n2['binary']['file'])
        # This exact pair has a shorter linker STT_FILE path and a changed GNU
        # build-id. Keep raw identity false; do not silently normalize binaries.
        audit_method=ROOT/'selfhost/tests/phase174/elf-audit.py'
        audit_receipt=ROOT/'experiments/phase174/elf-audit.json'
        track(common.pin(audit_method));audit_pin=track(common.pin(audit_receipt))
        retained_audit=json.loads(audit_receipt.read_text())
        track(retained_audit['method'])
        spec=importlib.util.spec_from_file_location('phase174_elf_audit',audit_method)
        audit_module=importlib.util.module_from_spec(spec);spec.loader.exec_module(audit_module)
        actual_audit=audit_module.audit(n1['binary']['file'],n2['binary']['file'],n1['object']['file'],n2['object']['file'])
        actual_audit['method']=common.pin(audit_method)
        need(actual_audit==retained_audit,'Actual exact ELF audit differs from its retained evidence')
        need(actual_audit['complete'] and actual_audit['runtimeImageEquivalent'],'Runtime image equivalence audit failed')
        need(report['loadedSegmentsEqual'] is False and actual_audit['loadedSegmentsEqual'] is False,'Unexpected raw loaded-image identity; this exception is for the audited pair only')
        report['allocatedSectionsEqual']=actual_audit['allocatedSectionsEqual']
        report['compiledCodeDataEqual']=actual_audit['allocatedSectionsExceptGnuBuildIdEqual']
        report['loaderRelevantHeadersEqual']=actual_audit['loaderRelevantHeadersEqual']
        report['runtimeImageEquivalent']=actual_audit['runtimeImageEquivalent']
        report['elfMetadataException']=dict(audit=audit_pin,ranges=actual_audit['admittedMetadataRanges'],
            loadedByteDifferences=actual_audit['loadedByteDifferences'],buildId=actual_audit['buildId'],
            scope=actual_audit['equivalenceScope'])
        report['machineIdentityScope']='N1/N2 actual retained SSA, assembly and object bytes; Q3 actual SSA only. No Q3 machine-build claim. Whole ELF, raw PT_LOAD bytes and all allocatable sections are NOT identical: exact e_shoff and GNU build-id metadata differences are independently parsed and exposed.'
        report['complete']=True
    except Exception as error:
        report['error']=repr(error)
    finally:
        report['inputs']=list(pins.values())
        report['changedInputs']=common.changed_inputs(report['inputs'])
        if report['changedInputs']:report['complete']=False
        report['wallSeconds']=time.monotonic()-started
        common.write_json(out/'report.json',report)
    print(json.dumps({key:report.get(key) for key in ('complete','n1Reused','allSameSource','qbeFixedPoint','machineIdentity','loadedSegmentsEqual','allocatedSectionsEqual','compiledCodeDataEqual','runtimeImageEquivalent','wholeELFEqual','error')}))
    return 0 if report['complete'] else 1


if __name__=='__main__':sys.exit(main())

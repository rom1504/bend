#!/usr/bin/env python3
"""Seal actual native07 self equality and semantic gates for fast request admission; no targets."""
import argparse,json,sys
from pathlib import Path
sys.dont_write_bytecode=True
from support import ROOT,P,read,pin,verify,args as native_args
from image_support_v2 import authenticate_unqualified,exact
HERE=Path(__file__).resolve().parent

def main():
    p=argparse.ArgumentParser(description=__doc__)
    for key in ['image','build','self_report','qualification','out']:p.add_argument(key,type=Path)
    p.add_argument('--pointer',type=Path,default=HERE/'native-admission.json');a=p.parse_args()
    auth,provenance=authenticate_unqualified(a.image,a.build)
    self_pin,qualification_pin=pin(a.self_report),pin(a.qualification)
    self_report,qualification=read(a.self_report),read(a.qualification)
    assert self_report['kind']=='phase90-native-runtime-migrated-emission'
    assert self_report['complete'] and self_report['passed'] and self_report['executionPerformed'] and not self_report['checkOnly']
    assert self_report['inputsUnchanged'] and self_report['exactC'] and self_report['independentlyCompared'] and self_report['calls']==1
    assert self_report['subject']==auth['source'] and self_report['sourceUnchanged']
    assert self_report['producer']['build']==provenance['build'] and self_report['producer']['authentication']==provenance['producer']
    assert exact(verify(self_report['output']),auth['c']) and exact(verify(self_report['oracle']),auth['c'])
    for m in self_report['methods']:verify(m)
    def actual(row,expected_code=0):
        directory=Path(row['guard']);process=read(directory/'process.json')
        assert process==row['process'] and process['complete'] and process['returncode']==expected_code and not process.get('stoppedFor')
        receipts=row.get('receipts',row.get('guardReceipts',[]));assert receipts
        for record in receipts:verify(record)
        if 'stdout' in row:assert (directory/'stdout.log').read_text()==row['stdout']
        if 'stderr' in row:assert (directory/'stderr.log').read_text()==row['stderr']
        return process
    process=actual(self_report)
    argv=native_args(auth,auth['source']['file'],Path(a.self_report).resolve().parent/'output',1)
    assert process['command'][-len(argv):]==argv
    assert qualification['kind']=='phase90-native07-semantic-qualification'
    assert qualification['complete'] and qualification['passed'] and qualification['executionPerformed'] and not qualification['checkOnly']
    assert qualification['inputsUnchanged'] and qualification['liveQualified'] and qualification['cachedQualified']
    assert qualification['authentication']==auth and qualification['build']==provenance['build']
    assert verify(qualification['method'])['sha256']=='ed16c720e646303c7ac0b16feeadc2cdc6517e0239f0fc2b12479e05b91952d1'
    for record in qualification['inputs']:verify(record)
    controls=read(verify(qualification['controls'])['file']);out_dir=Path(a.qualification).resolve().parent
    expected=[(mode,c) for mode in ['live','cached'] for c in controls['cases']]
    assert len(expected)==len(qualification['compilerRows'])==8
    cached_outputs={}
    for row,(mode,case) in zip(qualification['compilerRows'],expected):
        assert row['name']==mode+'-'+case['name'] and row['mode']==mode and row['source']==case['source']
        assert row['passed'] and row['exactC'] and row['guardReturncode']==0
        assert exact(verify(row['output']),verify(case['oracle'])) and row['oracle']==case['oracle']
        producer=dict(auth,cache=None) if mode=='live' else auth
        argv=native_args(producer,case['source']['file'],out_dir/row['name'],1)
        assert actual(row)['command'][-len(argv):]==argv
        if mode=='cached':cached_outputs[case['name']]=row['output']
    assert len(qualification['negativeRows'])==len(controls['negatives'])==2
    for row,case in zip(qualification['negativeRows'],controls['negatives']):
        assert row['passed'] and row['source']==case['source'] and row['expectedError']==case['expectedError']
        assert row['outputAbsent'] and not (out_dir/(row['name']+'.1.c')).exists()
        assert case['expectedError']+':' in row['stderr'];actual(row,1)
    assert len(qualification['programRows'])==len(controls['cases'])==4
    for row,case in zip(qualification['programRows'],controls['cases']):
        assert row['passed'] and row['name']==case['name'] and row['c']==cached_outputs[case['name']]
        assert row['expected']==case['execute'];actual(row['build']);actual(row['run'],case['execute']['exitCode'])
        binary=verify(row['binary']);assert binary['file'] in row['build']['process']['command'] and row['c']['file'] in row['build']['process']['command']
        assert binary['file'] in row['run']['process']['command']
        assert row['run']['stdout']==case['execute']['stdout'] and row['run']['stderr']==case['execute']['stderr']
        if 'outputSha256' in case['execute']:assert verify(row['copiedFile'])['sha256']==case['execute']['outputSha256']
    out=a.out.resolve();assert out.is_relative_to(ROOT/'selfhost/build/native/releases');out.mkdir(parents=True,exist_ok=False)
    # Immutable request assets are already frozen in transport02. Base path stays
    # unchanged because the admitted carrier's source-location ABI binds it.
    result=dict(kind='phase90-native-self-hosted-compiler-admission',version=1,complete=True,
        method=pin(__file__),binary=auth['image'],source=auth['source'],c=auth['c'],build=provenance['build'],
        transition=provenance['transition'],transport=provenance['transport'],selfEquality=self_pin,semanticQualification=qualification_pin,
        comparison=provenance['comparison'],base=auth['base'],runtime=auth['runtime'],template=auth['template'],parts=auth['runtimeParts'],
        effectsDir=auth['effectsDir'],effects=auth['effects'],cache=auth['cache'],cacheBasePath=auth['base']['file'],
        argvSentinel=auth['argvSentinel'],cPatched=False,selfQualified=True,liveQualified=True,cachedQualified=True,
        scope='Bend compiler executing natively, built from unpatched native-emitted C equal to genuine JS B2; exact own-source C successor and scoped semantic/execution gates. Entry supports one source importing Base and the nine admitted effects; not full-language, GPU, parallel-runtime or performance qualification.')
    target=out/'admission.json';target.write_text(json.dumps(result,indent=2)+'\n')
    pointer=dict(kind='phase90-native-compiler-selection',complete=True,admission=pin(target),method=pin(__file__))
    with a.pointer.open('x') as f:json.dump(pointer,f,indent=2);f.write('\n')
    print(json.dumps(dict(admission=pin(target),pointer=pin(a.pointer),targetExecuted=False)))

if __name__=='__main__':main()

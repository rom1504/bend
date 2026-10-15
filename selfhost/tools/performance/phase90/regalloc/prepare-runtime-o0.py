#!/usr/bin/env python3
"""Prepare/review runtime O0 compatibility; never mutate canonical files or run targets.

prepare OUT ATTEMPT freezes the one upstream guard change and emits a root-run
Bend template-generation command. finish OUT verifies that actual result and
writes a three-file canonical patch (runtime, generated template, driver pin).
"""
import argparse
import difflib
import hashlib
import json
import sys
from pathlib import Path
sys.dont_write_bytecode=True
ROOT=Path(__file__).resolve().parents[5]
BEFORE='#if __has_attribute(preserve_none) && __has_attribute(preserve_most)\n'
AFTER='#if __has_attribute(preserve_none) && __has_attribute(preserve_most) \\\n  && defined(__OPTIMIZE__)\n'
RUNTIME_SHA='0e52adc8d206f7c07944567adddaefaedfb7830ad23d2ba6bbca64dd2e4fb245'
TEMPLATE_SHA='f9f5a1c98f17f892d891032ca35489234e43d3b4112a18e592e6da408b09736c'
FILES=['selfhost/src/runtime/native/runtime.c','selfhost/src/runtime/native/runtime-template.json','selfhost/tools/typed-driver.mjs']

def pin(file):
    file=Path(file).resolve();data=file.read_bytes()
    return dict(file=str(file),sha256=hashlib.sha256(data).hexdigest(),bytes=len(data))

def verify(record):
    actual=pin(record['file'])
    assert actual['sha256']==record['sha256'],actual['file']
    if 'bytes' in record:assert actual['bytes']==record['bytes']
    return actual

def write(file,text):
    with file.open('x') as stream:stream.write(text)

def save(file,value):write(file,json.dumps(value,indent=2)+'\n')

def main():
    p=argparse.ArgumentParser(description=__doc__);p.add_argument('mode',choices=['prepare','finish']);p.add_argument('out',type=Path);p.add_argument('attempt',type=Path,nargs='?');args=p.parse_args();out=args.out.resolve()
    if args.mode=='prepare':
        assert args.attempt;out.mkdir(parents=True,exist_ok=False)
        attempt_pin=pin(args.attempt);attempt=json.loads(Path(attempt_pin['file']).read_text())
        assert attempt['checked'] is True;api=verify(attempt['api'])
        old=[pin(ROOT/f) for f in FILES]
        assert old[0]['sha256']==RUNTIME_SHA and old[1]['sha256']==TEMPLATE_SHA
        runtime=Path(old[0]['file']).read_text();assert runtime.count(BEFORE)==1
        upstream=ROOT/'bend2/comp.ts';assert AFTER in upstream.read_text()
        candidate=runtime.replace(BEFORE,AFTER,1);assert candidate.replace(AFTER,BEFORE,1)==runtime
        target=out/'runtime.c';write(target,candidate)
        generator=ROOT/'selfhost/tools/development/native-template.mjs'
        command=['/home/ai/.nvm/versions/node/v24.18.0/bin/node',str(generator),attempt_pin['file'],str(target),str(out/'runtime-template.json'),str(out/'template-receipt.json')]
        plan=dict(kind='phase90-runtime-o0-guard-plan',complete=True,targetExecuted=False,
            method=pin(__file__),canonicalInputs=old,upstream=pin(upstream),attempt=attempt_pin,api=api,generator=pin(generator),
            source=pin(target),replacement=dict(before=BEFORE,after=AFTER),templateCommand=command,
            followup=[sys.executable,'-B',str(Path(__file__).resolve()),'finish',str(out)],
            scope='No canonical mutation. Root must run checked Bend template generation under its guard, then finish to obtain reviewable runtime/template/driver patch.')
        save(out/'plan.json',plan);print(json.dumps(plan));return
    assert args.attempt is None
    plan_pin=pin(out/'plan.json');plan=json.loads(Path(plan_pin['file']).read_text())
    assert plan['kind']=='phase90-runtime-o0-guard-plan'
    for record in plan['canonicalInputs']+[plan[k] for k in ['method','upstream','attempt','api','generator','source']]:verify(record)
    receipt_pin=pin(out/'template-receipt.json');receipt=json.loads(Path(receipt_pin['file']).read_text())
    assert receipt['kind']=='bend-native-template' and receipt['chunks']==5 and receipt['exactRoundTrip']
    for key,parent in [('producer','api'),('attempt','attempt'),('generator','generator'),('runtime','source')]:assert verify(receipt[key])==plan[parent]
    artifact=verify(receipt['artifact']);assert artifact['file']==str(out/'runtime-template.json')
    data=json.loads(Path(artifact['file']).read_text());assert data['version']==1 and data['runtimeSha256']==plan['source']['sha256']
    assert len(data['parts'])==5 and ''.join(data['parts'])==(out/'runtime.c').read_text()
    old_template=json.loads(Path(plan['canonicalInputs'][1]['file']).read_text())
    assert data['parts'][1:]==old_template['parts'][1:]
    assert data['parts'][0].replace(AFTER,BEFORE,1)==old_template['parts'][0]
    driver=Path(plan['canonicalInputs'][2]['file']).read_text()
    marker="const nativeTemplateSha256='"+TEMPLATE_SHA+"';";assert driver.count(marker)==1
    candidate_driver=driver.replace(marker,"const nativeTemplateSha256='"+artifact['sha256']+"';",1)
    write(out/'typed-driver.mjs',candidate_driver)
    outputs=[pin(out/'runtime.c'),artifact,pin(out/'typed-driver.mjs')]
    chunks=[]
    for relative,old,new in zip(FILES,plan['canonicalInputs'],outputs):
        chunks.extend(difflib.unified_diff(Path(old['file']).read_text().splitlines(True),Path(new['file']).read_text().splitlines(True),fromfile='a/'+relative,tofile='b/'+relative))
    patch=out/'canonical.patch';write(patch,''.join(chunks))
    save(out/'ready.json',dict(kind='phase90-runtime-o0-guard-prepared-patch',complete=True,canonicalMutated=False,
        plan=plan_pin,templateReceipt=receipt_pin,inputs=plan['canonicalInputs'],outputs=outputs,patch=pin(patch),
        scope='Reviewable patch only. Upstream-compatible O0 PRESERVE fallback; regenerated Bend template and matching driver fast-path pin. Checked build/release and native execution gates remain separate.'))
    print(json.dumps(dict(complete=True,canonicalMutated=False,patch=pin(patch),outputs=outputs)))

if __name__=='__main__':main()

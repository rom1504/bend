#!/usr/bin/env python3
"""Freeze scanner-produced new runtime transport; never edit canonical files or run targets."""
import argparse,json,sys
from pathlib import Path
sys.dont_write_bytecode=True
from support import ROOT,P,RUNTIME_SHA,transition,historical,read,pin,verify

def main():
    ap=argparse.ArgumentParser(description=__doc__);ap.add_argument('ready',type=Path);ap.add_argument('out',type=Path);a=ap.parse_args()
    seal,seal_pin=transition(audit=True)
    ready_pin=pin(a.ready);ready=read(a.ready)
    assert ready['kind']=='phase90-runtime-large-table-accessor-prepared' and ready['complete'] and not ready['canonicalMutated']
    plan_pin=verify(ready['plan']);plan=read(plan_pin['file'])
    assert plan['kind']=='phase90-runtime-large-table-accessor-plan' and plan['complete'] and plan['threshold']==4096
    assert plan['canonicalInputs']==ready['inputs']
    for record in plan['canonicalInputs']+plan['sourceAudit']+[plan[k] for k in ['method','helper','upstream','attempt','api','generator','source']]:historical(record,seal)
    receipt_pin=verify(ready['templateReceipt']);receipt=read(receipt_pin['file'])
    assert receipt['kind']=='bend-native-template' and receipt['chunks']==5 and receipt['exactRoundTrip']
    for key,other in [('producer','api'),('attempt','attempt'),('generator','generator'),('runtime','source')]:
        expected=verify(plan[other]);assert all(receipt[key][k]==expected[k] for k in ['file','sha256'])
    runtime,template,driver=[verify(p) for p in ready['outputs']]
    assert runtime==plan['source'] and runtime['sha256']==RUNTIME_SHA
    assert all(receipt['artifact'][k]==template[k] for k in ['file','sha256'])
    parts=read(template['file']);assert parts['version']==1 and parts['runtimeSha256']==RUNTIME_SHA and len(parts['parts'])==5
    assert ''.join(parts['parts']).encode()==Path(runtime['file']).read_bytes()
    old_template=read(historical(plan['canonicalInputs'][1],seal)['file'])
    expected=[]
    for part in old_template['parts']:
        for edit in plan['edits']:part=part.replace(edit['before'],edit['after'])
        expected.append(part)
    assert parts['parts']==expected
    old_driver=Path(historical(plan['canonicalInputs'][2],seal)['file']).read_text()
    before="const nativeTemplateSha256='"+plan['canonicalInputs'][1]['sha256']+"';"
    after="const nativeTemplateSha256='"+template['sha256']+"';"
    assert old_driver.count(before)==1 and old_driver.replace(before,after,1)==Path(driver['file']).read_text()
    assets=read(P/'phase89/native-b2/nine-effects.json');effects=[verify(p) for p in assets['admittedEffects']]
    assert len(effects)==9
    out=a.out.resolve();assert out.is_relative_to(ROOT/'selfhost/build/phase90');out.mkdir(parents=True,exist_ok=False)
    target=out/'runtime.c';target.write_bytes(Path(runtime['file']).read_bytes())
    new_parts=[]
    for i,text in enumerate(parts['parts']):
        p=Path(str(target)+f'.part{i}');p.write_text(text);new_parts.append(pin(p))
    template_copy=out/'runtime-template.json';template_copy.write_bytes(Path(template['file']).read_bytes())
    effects_dir=out/'effs';effects_dir.mkdir();copied=[]
    for effect in effects:
        p=effects_dir/Path(effect['file']).name;p.write_bytes(Path(effect['file']).read_bytes());copied.append(pin(p))
    result=dict(kind='phase90-new-runtime-native-transport',complete=True,executionPerformed=False,method=pin(__file__),
        transition=seal_pin,ready=ready_pin,plan=plan_pin,templateReceipt=receipt_pin,driver=driver,
        runtime=pin(target),template=pin(template_copy),parts=new_parts,base=seal['producer']['base'],
        effectsDir=str(effects_dir),effects=copied,sourceEffects=effects,
        scope='Explicit new external runtime transport for unchanged source D04; no image/source rebinding, native07 build or new semantic qualification.')
    p=out/'transport.json';p.write_text(json.dumps(result,indent=2)+'\n');print(json.dumps(dict(transport=pin(p),targetExecuted=False)))

if __name__=='__main__':main()

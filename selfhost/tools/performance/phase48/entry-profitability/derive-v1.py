#!/usr/bin/env python3
"""Data-only array06 entry-guard derivatives; root alone runs targets.
Usage: derive-v1.py ARRAY06_LOCAL_FOLD_MODULE NEW_OUT
"""
import argparse
import hashlib
import json
from pathlib import Path

HERE=Path(__file__).resolve().parent
API='28f9eb983b2ba3603a9af703d832d4a301efe32182b468e090db6b728a47d12f'
RUNTIME='880bce50e3194b9ee9d99bd57c18ef88bcb8925d9d1668dec6765040a4d3219b'
SOURCE='d13b49747fbe6308aa35451ca6f1e1059f0a01bac8fce671dc7a195424b5cc3a'

def identity(p):
    p=Path(p).resolve(strict=True);data=p.read_bytes()
    return dict(path=str(p),sha256=hashlib.sha256(data).hexdigest(),bytes=len(data))

def once(text,before,after):
    assert text.count(before)==1, 'Nonexact generated anchor: '+before
    return text.replace(before,after,1)

def main():
    ap=argparse.ArgumentParser(description=__doc__)
    ap.add_argument('module',type=Path);ap.add_argument('out',type=Path)
    a=ap.parse_args();module=a.module.resolve(strict=True)
    receipt_file=Path(str(module)+'.json');receipt=json.loads(receipt_file.read_text())
    assert receipt['kind']=='bend-program-checked-emission' and receipt['complete']
    assert receipt['observation']['checked'] and receipt['observation']['status']=='ok'
    assert receipt['compiler']['api']['sha256']==API and receipt['compiler']['runtime']['sha256']==RUNTIME
    assert receipt['input']['sha256']==SOURCE, 'The independent scalar oracle belongs only to frozen local-fold'
    inputs=[identity(module),identity(receipt_file),identity(__file__),identity(HERE/'array-local-guard-v1.js.frag'),identity(HERE/'audit-v1.mjs')]
    assert inputs[0]['sha256']==receipt['output']['sha256']
    for record in [receipt['attempt'],receipt['compiler']['api'],receipt['compiler']['runtime'],receipt['compiler']['base'],receipt['input']]:
        item=identity(record.get('file',record.get('canonicalPath')))
        assert item['sha256']==record['sha256'];inputs.append(item)
    text=module.read_text();fragment=(HERE/'array-local-guard-v1.js.frag').read_text()
    marker='/* private raw array root */'
    suffix='&&localGuard($guards)){'+marker
    assert text.count(marker)==1 and text.count(suffix)==1
    marker_at=text.index(marker);guard_at=text.rfind('const $guards=',0,marker_at)
    assert guard_at>=0
    names=json.loads(text[guard_at+len('const $guards='):text.index(';',guard_at)])
    assert names and len(set(names))==len(names) and all(isinstance(x,str) for x in names)
    host_at=text.rfind('arrayViewHostGuard(',0,marker_at)
    assert host_at>guard_at
    host=text[host_at:text.index(')',host_at)+1]
    assert host=='arrayViewHostGuard(true)', 'This version admits the exact no-F32 parent only'
    insertion='// Standard host initialization is the established runtime premise.'
    assert 'function arrayViewLocalGuard(' not in text
    safe=once(once(text,insertion,fragment+'\n'+insertion),suffix,'&&arrayViewLocalGuard($guards)){'+marker)
    assert once(once(safe,fragment+'\n'+insertion,insertion),'&&arrayViewLocalGuard($guards)){'+marker,suffix)==text
    # Deliberately unsafe bound: remove ONLY this entry's host/dependency checks.
    # Canonical input demand/validation, body and old fallback remain unchanged.
    unsafe=text[:host_at]+'true'+text[host_at+len(host):]
    unsafe=once(unsafe,suffix,'&&true){'+marker)
    out=a.out.resolve();out.mkdir(parents=True,exist_ok=False)
    manifest=dict(kind='phase48-array-entry-guard-derivatives',complete=False,executed=False,
                  diagnosticOnly=True,productionSafe=False,checkedDerivative=False,
                  inputs=inputs,entryKind='root',guardNames=names,variants={},audit={})
    variants={'original':text,'allocation-free':safe,'unsafe-admission-bypass':unsafe}
    for name,body in variants.items():
        p=out/name/'program.mjs';p.parent.mkdir();p.write_text(body)
        manifest['variants'][name]={**identity(p),'semanticProposal':name=='allocation-free',
                                    'unsafeUpperBound':name=='unsafe-admission-bypass'}
    for name,body in [('original',once(text,insertion,fragment+'\n'+insertion)),('allocation-free',safe)]:
        counted=once(body,marker,marker+'$p48Entries++;')
        counted+='\nlet $p48Entries=0;\nexport const $P48Audit={G,names:'+json.dumps(names)+',host:()=>arrayViewHostGuard(true),original:()=>localGuard('+json.dumps(names)+'),candidate:()=>arrayViewLocalGuard('+json.dumps(names)+'),entries:()=>$p48Entries,reset:()=>{$p48Entries=0;},proof:()=>regionProof};\n'
        p=out/'audit'/name/'program.mjs';p.parent.mkdir(parents=True);p.write_text(counted)
        manifest['audit'][name]=identity(p)
    (out/'audit-v1.mjs').write_bytes((HERE/'audit-v1.mjs').read_bytes())
    manifest['auditController']=identity(out/'audit-v1.mjs')
    # Independent maintained local-fold oracle points are configs, not policy.
    manifest['points']=[]
    for n,seed in [(0,0),(1,17),(128,0),(128,123),(4096,17),(8192,123)]:
        values=[seed]*128;acc=0
        for i in range(n):
            j=i%128;acc=(acc+values[j])&0xffffffff;values[j]=(acc^i)&0xffffffff
        config=dict(exportName='bench',args=[n,seed],expected=acc,warmupCalls=3,warmupMs=1000,
                    calibrationMs=50,targetMs=200,maxRepetitions=1000000)
        p=out/f'point-{n}-{seed}.json';p.write_text(json.dumps(config,indent=2)+'\n')
        manifest['points'].append(dict(id=f'{n}-{seed}',config=identity(p)))
    for item in inputs:assert identity(item['path'])==item
    manifest['complete']=True
    (out/'manifest.json').write_text(json.dumps(manifest,indent=2)+'\n')
    print(json.dumps(dict(complete=True,executed=False,out=str(out))))

if __name__=='__main__':main()

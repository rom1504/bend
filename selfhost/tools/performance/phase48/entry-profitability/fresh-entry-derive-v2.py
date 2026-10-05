#!/usr/bin/env python3
"""Data-only saved derivative for one explicit fresh-full-host scalar entry.

Usage: fresh-entry-derive-v2.py CHECKED_ARRAY06_MODULE NEW_OUT --root bench
Rejects missing freshness or any unrecognized input predicate; executes nothing.
"""
import argparse
import hashlib
import json
from pathlib import Path
import re

HERE=Path(__file__).resolve().parent
def identity(p):
    p=Path(p).resolve(strict=True);b=p.read_bytes()
    return dict(path=str(p),sha256=hashlib.sha256(b).hexdigest(),bytes=len(b))

def inert_inputs(text):
    if text.startswith('stringHostGuard()&&'):text=text[len('stringHostGuard()&&'):]
    patterns=[
        r'\(typeof (\$s\d+)==="number"&&Number\.isInteger\(\1\)&&\1>=0&&\1<=4294967295\)&&',
        r'\(typeof (\$s\d+)==="bigint"&&\1>=0n&&\1<=281474976710655n\)&&',
        r'\(typeof (\$s\d+)==="boolean"\)&&',
        r'\(typeof (\$s\d+)==="string"\)&&',
        r'\(typeof (\$s\d+)==="number"&&\(Number\.isNaN\(\1\)\|\|Math\.fround\(\1\)===\1\)\)&&',
    ]
    count=0
    while text!='true':
        matches=[re.match(pattern,text) for pattern in patterns]
        hit=next((m for m in matches if m),None)
        assert hit,'Unproved input/host predicate before dependency guard: '+text[:150]
        text=text[hit.end():];count+=1
    return count

def main():
    ap=argparse.ArgumentParser(description=__doc__);ap.add_argument('module',type=Path)
    ap.add_argument('out',type=Path);ap.add_argument('--root',default='bench');a=ap.parse_args()
    module=a.module.resolve(strict=True);receipt_file=Path(str(module)+'.json')
    receipt=json.loads(receipt_file.read_text());assert receipt['complete'] and receipt['observation']['checked']
    assert receipt['compiler']['api']['sha256']=='28f9eb983b2ba3603a9af703d832d4a301efe32182b468e090db6b728a47d12f'
    assert receipt['compiler']['runtime']['sha256']=='880bce50e3194b9ee9d99bd57c18ef88bcb8925d9d1668dec6765040a4d3219b'
    inputs=[identity(module),identity(receipt_file),identity(__file__),identity(HERE/'region-fresh-local-guard-v2.js.frag')]
    assert inputs[0]['sha256']==receipt['output']['sha256']
    for item in [receipt['attempt'],receipt['compiler']['api'],receipt['compiler']['runtime'],receipt['compiler']['base'],receipt['input']]:
        row=identity(item.get('file',item.get('canonicalPath')));assert row['sha256']==item['sha256'];inputs.append(row)
    source=module.read_text();start='G['+json.dumps(a.root)+']='
    assert source.count(start)==1
    at=source.index(start);end=source.find('\nG[',at+len(start));end=len(source) if end<0 else end
    root=source[at:end]
    prefix='if($entered&&regionProof===null&&regionHostGuard()&&'
    suffix='&&localGuard($guards)){'
    assert root.count(prefix)==1 and root.count(suffix)==1,'Exact fresh-full-host root proof missing'
    p=root.index(prefix)+len(prefix);q=root.index(suffix,p)
    argument_count=inert_inputs(root[p:q])
    fragment=(HERE/'region-fresh-local-guard-v2.js.frag').read_text()
    insertion='// Standard host initialization is the established runtime premise.'
    assert source.count(insertion)==1 and 'function regionFreshLocalGuard(' not in source
    changed_root=root.replace(suffix,'&&regionFreshLocalGuard($guards)){',1)
    changed=source[:at]+changed_root+source[end:]
    changed=changed.replace(insertion,fragment+'\n'+insertion,1)
    inverse=changed.replace(fragment+'\n'+insertion,insertion,1)
    inverse=inverse[:at]+inverse[at:].replace('&&regionFreshLocalGuard($guards)){',suffix,1)
    assert inverse==source
    out=a.out.resolve();out.mkdir(parents=True,exist_ok=False)
    variants={}
    for name,text in [('original',source),('fresh-allocation-free',changed)]:
        f=out/name/'program.mjs';f.parent.mkdir();f.write_text(text);variants[name]=identity(f)
    for item in inputs:assert identity(item['path'])==item
    manifest=dict(kind='phase48-fresh-host-entry-derivative',complete=True,executed=False,
      diagnosticOnly=True,sourceQualified=False,root=a.root,inputs=inputs,variants=variants,
      proof=dict(explicitNullRegionProof=True,unchangedFullRegionHostGuard=True,
                 inertCanonicalArgumentCount=argument_count,inputGrammar='syntactically total scalar whitelist',
                 inheritedPath='original localGuard delegation',unsafeBound=False),
      changes='Exactly one dependency guard call after fresh full host proof; original fallback, body, inputs and host guard unchanged.')
    (out/'manifest.json').write_text(json.dumps(manifest,indent=2)+'\n')
    print(json.dumps(dict(complete=True,executed=False,out=str(out))))

if __name__=='__main__':main()

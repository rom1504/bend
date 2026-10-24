#!/usr/bin/env python3
"""Exact session adapter on frozen audited units; no production selection edit."""
import argparse,importlib.util,json,pathlib
ROOT=pathlib.Path(__file__).resolve().parents[5]
def load(name,path):
 s=importlib.util.spec_from_file_location(name,path);m=importlib.util.module_from_spec(s);s.loader.exec_module(m);return m
C=load('compose',ROOT/'selfhost/tools/performance/phase131/prepare.py')
p=argparse.ArgumentParser();p.add_argument('--out',type=pathlib.Path,required=True);a=p.parse_args();out=a.out.resolve();assert not out.exists()and out.is_relative_to(ROOT/'selfhost/build/phase134')
parent=ROOT/'selfhost/build/phase134/units-source01/manifest.json';r=json.loads(parent.read_text());assert C.pin(r['source']['file'])==r['source'];assert r['source']['sha256']=='873921c3fb13e69450d65800e8b13a0cc9803b7a9ad4886cee8446f37a8f0dcc'
for x in r['inputs']:assert C.pin(x['file'])==x
modules=[pathlib.Path(__file__).parent/n for n in ('units-raw-v01.bend','session-v01.bend','entry-v01.bend')]
before=pathlib.Path(r['source']['file']).read_text();old=C.blocks(before);C.ENTRY_GATES-={'p111_native_args'}
text,added,protected=C.compose(before,[x.read_text()for x in modules],{'p111_native_args','p134u_emitted'},set());new=C.blocks(text)
changed=sorted(n for n in old if C.norm(old[n])!=C.norm(new[n]));assert changed==['p111_native_args','p134u_emitted'];assert all(C.norm(old[n])==C.norm(new[n])for n in r['unchangedProofDeclarations'])
# Existing six-argument branch and failure body remain exactly as before.
old_tail=old['p111_native_args'].split('    case Con{program,Con{+path',1)[1];assert new['p111_native_args'].endswith('    case Con{program,Con{+path'+old_tail)
assert 'p134e_collect'not in new['p134u_emitted'];assert new['p111_native_request']==old['p111_native_request']
out.mkdir(parents=True);(out/'compiler.bend').write_text(text);(out/'prepare.py').write_bytes(pathlib.Path(__file__).read_bytes())
for i,m in enumerate(modules):(out/f'module{i}.bend').write_bytes(m.read_bytes())
manifest=dict(complete=True,checked=False,targetsRun=False,source=C.pin(out/'compiler.bend'),parent=r['source'],sourceManifest=C.pin(parent),inputs=[C.pin(__file__),C.pin(ROOT/'selfhost/tools/performance/phase131/prepare.py'),C.pin(parent),*r['inputs'],*[C.pin(m)for m in modules]],overrides=changed,added=added,protectedDeclarations=protected,unchangedProofDeclarations=r['unchangedProofDeclarations'],scope='Experimental process-local two-revision entry only. Raw units adapter removes collecting wrapper; all original verifiers/proofs and ordinary native request unchanged. Cache is never externally serialized or accepted.')
(out/'manifest.json').write_text(json.dumps(manifest,indent=2)+'\n');print(json.dumps(manifest['source']))

#!/usr/bin/env python3
"""Exact experimental emission adapter on frozen Phase134 session source04."""
import argparse,importlib.util,json,pathlib,sys
sys.dont_write_bytecode=True
ROOT=pathlib.Path(__file__).resolve().parents[5];HERE=pathlib.Path(__file__).resolve().parent
s=importlib.util.spec_from_file_location('composer',ROOT/'selfhost/tools/performance/phase131/prepare.py');C=importlib.util.module_from_spec(s);s.loader.exec_module(C)
p=argparse.ArgumentParser();p.add_argument('--out',type=pathlib.Path,required=True);a=p.parse_args();out=a.out.resolve();assert not out.exists()and out.is_relative_to(ROOT/'selfhost/build/phase135')
parent=ROOT/'selfhost/build/phase134/session-source04/manifest.json';r=json.loads(parent.read_text());assert r['source']['sha256']=='1cadf44f486825a6f161ff01b15b582eca13522585deff8415d6c8c2aea7be45'
for x in [r['source'],*r['inputs']]:assert C.pin(x['file'])==x
modules=[HERE/n for n in ['frame-plan-v01.bend','writer-v01.bend','session-v01.bend','controls-v01.bend','entry-v01.bend']]+[HERE.parent/'preparation/stages-v02.bend']
before=pathlib.Path(r['source']['file']).read_text();old=C.blocks(before);C.ENTRY_GATES-={'p111_native_args'};text,added,protected=C.compose(before,[m.read_text()for m in modules],{'p111_native_args'},{'p135ms_prepared'});new=C.blocks(text)
changed=sorted(n for n in old if C.norm(old[n])!=C.norm(new[n]));assert changed==['p111_native_args'];assert all(C.norm(old[n])==C.norm(new[n])for n in r['unchangedProofDeclarations'])
old_tail=old['p111_native_args'].split('    case Con{program,Con{+path',1)[1];assert new['p111_native_args'].endswith('    case Con{program,Con{+path'+old_tail)
out.mkdir(parents=True);(out/'compiler.bend').write_text(text);(out/'prepare.py').write_bytes(pathlib.Path(__file__).read_bytes())
for i,m in enumerate(modules):(out/f'module{i}.bend').write_bytes(m.read_bytes())
report=dict(complete=True,checked=False,targetsRun=False,source=C.pin(out/'compiler.bend'),parent=r['source'],sourceManifest=C.pin(parent),inputs=[C.pin(__file__),C.pin(ROOT/'selfhost/tools/performance/phase131/prepare.py'),C.pin(parent),r['source'],*r['inputs'],*[C.pin(m)for m in modules]],overrides=changed,moduleOverrides=['p135ms_prepared'],added=added,protectedDeclarations=protected,unchangedProofDeclarations=r['unchangedProofDeclarations'],scope='Only new explicit frame-mode entry and new helpers; plain six-argument request and existing phase134 session helpers unchanged. Frames do not change payload instructions or skip any verifier.')
(out/'manifest.json').write_text(json.dumps(report,indent=2)+'\n');print(json.dumps(report['source']))

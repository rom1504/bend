"""Bind a checked Base-decoder-only source to unchanged qualified runtime contracts."""
import argparse
import importlib.util
import json
from pathlib import Path
ROOT=Path(__file__).resolve().parents[4]
spec=importlib.util.spec_from_file_location('compose130',ROOT/'selfhost/tools/performance/phase130/prepare.py')
C=importlib.util.module_from_spec(spec);spec.loader.exec_module(C)
P=C.P

def main():
 ap=argparse.ArgumentParser(description=__doc__)
 for n in ['source-manifest','api-report','equivalence','out']:ap.add_argument('--'+n,type=Path,required=True)
 a=ap.parse_args();assert not a.out.exists() and a.out.resolve().is_relative_to(ROOT/'selfhost/build/phase130')
 sm,api,eq=[json.loads(p.read_text()) for p in [a.source_manifest,a.api_report,a.equivalence]]
 oldfile=ROOT/'selfhost/build/phase128/native-admission03.json';old=json.loads(oldfile.read_text())
 assert P.pin(oldfile)['sha256']=='6a9e250b802760a9369d2b446aaf4cdd4dd71285e917ee215a4f7c6d9fbde768'
 assert sm['complete'] and sm['parent']==old['source'] and P.pin(sm['source']['file'])==sm['source']
 assert api['complete'] and api['checked'] and api['status']==0 and sm['source'] in api['inputs']
 assert [str(Path(x).resolve()) for x in api['command'] if x.endswith('.bend')]==[sm['source']['file']]
 assert {'p88_cache_prepare','p86_prepare','p86_plan','p111_runtime_admission','p111_emit_admitted','p111_compile_source'} <= set(api['exports'])
 assert eq['complete'] and eq['passed'] and eq['candidate']['source']==sm['source'] and eq['candidate']['receipt']['api']==api['api']
 assert eq['runtime']==old['runtime'] and eq['runtimeUnchanged']
 assert len(eq['rows'])==3 and all(x['byteIdentical'] for x in eq['rows'])
 assert all(x['exact'] for x in eq['comparisons']) and len(eq['comparisons'])>=2
 before=P.blocks(Path(old['source']['file']).read_text());after=P.blocks(Path(sm['source']['file']).read_text())
 assert set(before)<=set(after)
 changes=sorted(n for n in before if P.norm(before[n])!=P.norm(after[n]))
 assert set(changes)==set(sm['overrides']) and all(n.startswith('p88_') or n=='P88Cursor' for n in changes)
 assert all(n.startswith(('p130m_', 'p130mc_')) for n in set(after)-set(before))
 # Source-local decoder changes cannot authorize runtime/library or verifier changes.
 for name in sm['protectedDeclarations']:assert P.norm(before[name])==P.norm(after[name])
 for row in old['runtimeContract']['sourceDeclarations']:
  name=row['name'];assert P.norm(before[name])==P.norm(after[name])
 inputs=[P.pin(__file__),P.pin(spec.origin),P.pin(P.__file__),P.pin(oldfile),P.pin(a.source_manifest),P.pin(a.api_report),P.pin(a.equivalence),
         *sm['inputs'],*api['inputs'],*eq['inputs'],old['source'],old['runtime'],api['api'],sm['source']]
 inputs=list({x['file']:x for x in inputs}.values())
 for row in inputs:assert P.pin(row['file'])==row
 r=dict(kind='phase130-base-only-native-acquisition-admission',complete=True,sourceChecked=True,nativeQualified=False,selected=False,installed=False,
        source=sm['source'],api=api['api'],runtime=old['runtime'],sourceBinding=P.pin(a.source_manifest),checkedApi=P.pin(a.api_report),
        equivalence=P.pin(a.equivalence),parentAdmission=P.pin(oldfile),changedDeclarations=changes,addedDeclarations=sorted(set(after)-set(before)),
        originalVerifiersUnchanged=True,runtimeContractsUnchanged=True,inputs=inputs,
        scope='Checked private transport decoder only. Inherited runtime contracts unchanged by normalized complete declaration audit. Acquisition permission, not native qualification or promotion.')
 a.out.write_text(json.dumps(r,indent=2)+'\n');print(json.dumps(dict(complete=True,changes=len(changes),added=len(r['addedDeclarations']))))
if __name__=='__main__':main()

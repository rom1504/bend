#!/usr/bin/env python3
"""Extract the checked Bend prototype; transport and exact source closure only."""
import argparse,hashlib,importlib.util,json,sys
from pathlib import Path
ROOT=Path(__file__).resolve().parents[3]
sys.dont_write_bytecode=True;sys.path.insert(0,str(ROOT/'selfhost/tools/build'))
import source as assembly
from common import fresh_output,pin,require,write_json
spec=importlib.util.spec_from_file_location('p154_extract',ROOT/'experiments/phase147/tools/prepare.py')
E=importlib.util.module_from_spec(spec);spec.loader.exec_module(E)
ROOTS=['p113d_candidate','p113k_function','p113e_function','p113e_private',
 'p113e_originals','ns_ctor_index','p113e_signatures','p111q_function_ids','p111q_constructor_ids','missing',
 'p154d_candidate','p154k_function','p154c_function','p154c_decode_function','p154c_name','p154n_text']
def main():
 p=argparse.ArgumentParser();p.add_argument('--out',type=Path,required=True);a=p.parse_args()
 canonical=assembly.maintained_assemble(ROOT/'selfhost/src/compiler.json',ROOT/'selfhost','qbe')
 qualification=ROOT/'implementation/phase152/qualification.json';q=json.loads(qualification.read_text())
 require(len(canonical)==q['source']['bytes']and hashlib.sha256(canonical).hexdigest()==q['source']['sha256'],'Qualified canonical boundary changed')
 modules=[ROOT/'selfhost/tests/phase154'/f for f in ['model.bend','codec.bend','scalar.bend','lower.bend']]
 parts=[('canonical',canonical)]+[(p.name,p.read_bytes())for p in modules]
 body,declarations=E.extract(parts,ROOTS,1_500_000)
 out=fresh_output(a.out,ROOT);(out/'compiler.bend').write_bytes(body)
 write_json(out/'exports.json',dict(kind='bend-hosted-api-exports',version=1,exports=ROOTS,protocol='hosted-api-v1',targets=['qbe'],preparationModes=['live'],scope='Private direct numeric producer/scalar and independent original verifier/output.'))
 api=out/'api';job=E.guard('phase154-prototype-api',api,[ROOT/'selfhost/.assets/bin/bun',ROOT/'selfhost/tools/build/hosted.mjs','acquire','--source',out/'compiler.bend','--exports',out/'exports.json','--upstream',ROOT/'selfhost/.bootstrap/upstream-phase66','--engine',ROOT/'selfhost/.assets/bin/bun','--out',api],120,2048,256)
 report=dict(kind='phase154-prototype-preparation',version=1,complete=True,targetsRun=False,source=pin(out/'compiler.bend'),inputs=[pin(__file__),pin(E.__file__),pin(assembly.__file__),pin(qualification),pin(ROOT/'selfhost/src/compiler.json'),*[pin(p)for p in modules]],declarations=declarations,apiReport=str(api/'report.json'),jobs=[job])
 write_json(out/'manifest.json',report);write_json(out/'jobs.json',[job]);print(json.dumps(dict(source=report['source'],declarations=len(declarations),jobs=str(out/'jobs.json'))))
if __name__=='__main__':main()

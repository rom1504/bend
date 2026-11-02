#!/usr/bin/env python3
"""Prepare checked actual-publication transfer; print jobs, execute no targets."""
import argparse,hashlib,importlib.util,json,sys
from pathlib import Path
ROOT=Path(__file__).resolve().parents[3]
sys.dont_write_bytecode=True
sys.path.insert(0,str(ROOT/'selfhost/tools/build'))
import source as assembly
from common import fresh_output,pin,require,write_json
s=importlib.util.spec_from_file_location('extract155pt',ROOT/'experiments/phase147/tools/prepare.py')
E=importlib.util.module_from_spec(s);s.loader.exec_module(E)

def main():
 p=argparse.ArgumentParser(description=__doc__);p.add_argument('--out',type=Path,required=True);p.add_argument('--full-source',action='store_true');a=p.parse_args()
 canonical=assembly.maintained_assemble(ROOT/'selfhost/src/compiler.json',ROOT/'selfhost','qbe')
 qualification=ROOT/'implementation/phase152/qualification.json';q=json.loads(qualification.read_text())
 require(hashlib.sha256(canonical).hexdigest()==q['source']['sha256'],'Qualified canonical source changed')
 _,blocks=assembly.blocks(canonical);original=b''.join(b['data']for b in blocks if b['name']!='main')
 config=Path(__file__).with_name('spec.json');spec=json.loads(config.read_text());exports=spec['exports']
 modules=[ROOT/x for x in spec['dependencies']+[spec['module']]]
 body,declarations=E.extract([('canonical',original),*[(str(f),f.read_bytes())for f in modules]],exports,2_000_000)
 out=fresh_output(a.out,ROOT);(out/'compiler.bend').write_bytes(body)
 workload=b'def main() -> U32:\n  Bool.to_u32(String.is_empty(p111_verify_program(p111_empty())))\n'
 verifier,_=E.extract([('canonical',original),('workload',workload)],['main'])
 (out/'verifier.bend').write_bytes(verifier)
 families=[dict(name='compiler-verifier-slice',source=pin(out/'verifier.bend')),
  dict(name='coverage-map-churn-128',source=pin(ROOT/'selfhost/tests/consolidation/native-broad/coverage-map-churn-128.bend'))]
 if a.full_source:
  (out/'actual-compiler.bend').write_bytes(canonical);families.append(dict(name='full-current-compiler',source=pin(out/'actual-compiler.bend')))
 base=pin(ROOT/'selfhost/.bootstrap/upstream-phase66/bend2/base.bend')
 inputs=[pin(__file__),pin(config),pin(Path(__file__).with_name('run.mjs')),pin(E.__file__),pin(assembly.__file__),pin(qualification),
  pin(ROOT/'selfhost/src/compiler.json'),pin(ROOT/'experiments/phase154/tools/graph.mjs'),base,*[pin(f)for f in modules],*[f['source']for f in families]]
 write_json(out/'exports.json',dict(kind='bend-hosted-api-exports',version=1,exports=exports,protocol='hosted-api-v1',targets=['qbe'],preparationModes=['live'],scope='Actual declaration publication replay; no dependent checker or native speed qualification.'))
 checked=out/'checked-api';result=out/'transfer'
 jobs=[E.guard('phase155-publication-transfer-check',checked,[ROOT/'selfhost/.assets/bin/bun',ROOT/'selfhost/tools/build/hosted.mjs','acquire',
  '--source',out/'compiler.bend','--exports',out/'exports.json','--upstream',ROOT/'selfhost/.bootstrap/upstream-phase66',
  '--engine',ROOT/'selfhost/.assets/bin/bun','--out',checked],150,2048,256),
  E.guard('phase155-publication-transfer',result,[ROOT/'selfhost/.assets/bin/bun',Path(__file__).with_name('run.mjs'),
  '--manifest',out/'manifest.json','--out',result],120,2048,256)]
 report=dict(kind='phase155-publication-transfer-preparation',version=1,complete=True,targetsRun=False,inputs=inputs,source=pin(out/'compiler.bend'),
  canonicalIdentity=dict(bytes=len(canonical),sha256=hashlib.sha256(canonical).hexdigest()),declarations=declarations,exports=exports,
  apiReport=str(checked/'report.json'),families=families,base=base,limits=spec['limits'],jobs=jobs,
  scope='Source-order real loaded declarations, full declaration seed/suffix schedule, bounded publication/event-history replay. Hosted diagnostic clocks only.')
 write_json(out/'manifest.json',report);write_json(out/'jobs.json',jobs)
 print(json.dumps(dict(source=report['source'],declarations=len(declarations),jobs=str(out/'jobs.json'))))

if __name__=='__main__':main()

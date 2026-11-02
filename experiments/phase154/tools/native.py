#!/usr/bin/env python3
"""Prepare one checked native binary for both complete producer families."""
import argparse,importlib.util,json,sys
from pathlib import Path
from prepare import ROOT,E,assembly,fresh_output,pin,require,write_json
sys.dont_write_bytecode=True
from common import verify

def main():
 p=argparse.ArgumentParser()
 for n in ['preparation','controls','books','out']:p.add_argument('--'+n,type=Path,required=True)
 a=p.parse_args();prep=json.loads(a.preparation.read_text());controls=json.loads(a.controls.read_text());books=json.loads(a.books.read_text())
 require(prep['complete']and controls['complete']and controls['passed']and books['complete'],'Complete source/controls/books required')
 require(prep['source']==controls['source'],'Controlled source differs')
 for x in prep['inputs']+controls['inputs']+books['inputs']:verify(x)
 source=verify(prep['source']).read_bytes();canonical=assembly.maintained_assemble(ROOT/'selfhost/src/compiler.json',ROOT/'selfhost','qbe')
 _,have=assembly.blocks(source);names={r['name']for r in have};_,original=assembly.blocks(canonical)
 extra=b''.join(r['data']for r in original if r['name']not in names and r['name']!='main')
 chunks=[];families=[];inputs=[pin(__file__),pin(Path(__file__).with_name('prepare.py')),pin(a.preparation),pin(a.controls),pin(a.books),*prep['inputs']]
 out=fresh_output(a.out,ROOT)
 for i,row in enumerate(books['rows']):
  accepted=[r for r in controls['rows']if r.get('family')==row['family']and r.get('outputExact')]
  require(len(accepted)>=3,'At least three complete independently admitted owners per family')
  header=verify(row['headers']).read_text()
  for name in ['headers','constructors','direct_headers']:header=header.replace('p154h_'+name+'(',f'p154h_{name}_{i}(')
  chunks.append(header)
  chunks.append(f'def p154h_names_{i}() -> List<&2,String>:\n  '+json.dumps([r['name']for r in accepted])+'\n')
  chunks.append(f'def p154h_book_path_{i}() -> String:\n  '+json.dumps(str(verify(row['book'])))+'\n')
  oracle=out/f'{i}-expected.stdout';oracle.write_bytes(b''.join(verify(r['oracle']).read_bytes()for r in accepted))
  families.append(dict(name=row['family'],argument=['compiler','map'][i],owners=[r['name']for r in accepted],book=row['book'],inputGraph=row['inputGraph'],oracle=pin(oracle)))
  inputs += [row['headers'],row['book'],row['inputGraph'],*[r['oracle']for r in accepted]]
 for name,typ in [('headers','List<&2,N111Segment>'),('constructors','List<&2,N_Constructor>'),('direct_headers','List<&2,P113DFunction>'),('names','List<&2,String>'),('book_path','String')]:
  chunks.append(f'@unsafe\ndef p154h_{name}(family: U32) -> {typ}:\n  nt_choose({typ},U32.is_eq(family,0),u => p154h_{name}_0(),u => p154h_{name}_1())\n')
 fixture='\n'.join(chunks).encode();loader=ROOT/'selfhost/tests/phase154/input.bend';harness=Path(__file__).with_name('native-harness.bend')
 body,declarations=E.extract([('prototype',source),('canonical-extra',extra),('input',loader.read_bytes()),('fixture',fixture),('harness',harness.read_bytes())],['main','p154h_text','p154r_read'],1_000_000)
 (out/'compiler.bend').write_bytes(body);(out/'fixture.bend').write_bytes(fixture);inputs +=[pin(loader),pin(harness)]
 exports=['p154h_text','p154r_read'];write_json(out/'exports.json',dict(kind='bend-hosted-api-exports',version=1,exports=exports,protocol='hosted-api-v1',targets=['qbe'],preparationModes=['live'],scope='Complete small harness independently checked; source-only private research API.'))
 checked=out/'checked-api';native=out/'native'
 jobs=[E.guard('phase154-harness-check',checked,[ROOT/'selfhost/.assets/bin/bun',ROOT/'selfhost/tools/build/hosted.mjs','acquire','--source',out/'compiler.bend','--exports',out/'exports.json','--upstream',ROOT/'selfhost/.bootstrap/upstream-phase66','--engine',ROOT/'selfhost/.assets/bin/bun','--out',checked],120,2048,256),
 E.guard('phase154-native-harness',native,['python3','-B',ROOT/'selfhost/tools/build/native.py','--assets',ROOT/'selfhost/manifests/assets-native.json','--host','native','--stage','N2','--target','qbe','--mode','cache','--image',ROOT/'selfhost/build/phase152/native-n2/program','--image-receipt',ROOT/'selfhost/build/phase152/native-n2/report.json','--source',out/'compiler.bend','--out',native,'--retain-ir','--seconds','180'],200,2048,512)]
 report=dict(kind='phase154-native-preparation',version=1,complete=True,targetsRun=False,inputs=inputs,source=pin(out/'compiler.bend'),fixture=pin(out/'fixture.bend'),families=families,declarations=declarations,binary=str(native/'program'),buildReport=str(native/'report.json'),harnessCheckReport=str(checked/'report.json'),jobs=jobs,
 region='Exact captured erased request book -> candidate production -> scalar transformation -> original independent verifier -> mature QBE emission -> write and teardown. New numeric path decodes once at final verification/output. Ordinary fixed leaf conversions charged.',
 contextLifetime='Read and decode entire frozen book and build authentic prefix contexts once per process; repeat fresh complete selected-owner pipelines. Startup/final cleanup retained in whole-child time. No lower-result or scalar-result reuse.',
 scope='9 admitted direct-helper owners from20 inspected. Original p113d producer on erased input is narrower than selected canonical p113pl/static pipeline. No full compiler, whole Map or upstream ratio.')
 write_json(out/'manifest.json',report);write_json(out/'jobs.json',jobs)
 print(json.dumps(dict(source=report['source'],declarations=len(declarations),families=[dict(name=x['name'],owners=len(x['owners']))for x in families],jobs=str(out/'jobs.json'))))
if __name__=='__main__':main()

"""Authenticate actual Phase130 self-reproduction, builds and semantic gates."""
import argparse
import hashlib
import json
from pathlib import Path
import sys
ROOT=Path(__file__).resolve().parents[4]
sys.path.insert(0,str(ROOT/'selfhost/tools/performance/phase128/native'))
import qualify as Q

def main():
 ap=argparse.ArgumentParser(description=__doc__)
 for n in ['admission','hosted','n1-build','self-emission','n2-build','n1-focused','n2-focused','n2-full45','out']:
  ap.add_argument('--'+n,type=Path,required=True)
 a=ap.parse_args();assert not a.out.exists() and a.out.resolve().is_relative_to(ROOT/'selfhost/build/phase130')
 paths=[a.admission,a.hosted,a.n1_build,a.self_emission,a.n2_build,a.n1_focused,a.n2_focused,a.n2_full45]
 ad,h,b1,se,b2,f1,f2,full=[json.loads(p.read_text()) for p in paths]
 assert ad['complete'] and ad['sourceChecked'] and ad['kind']=='phase130-base-only-native-acquisition-admission'
 assert h['complete'] and h['entry']=='p111_emit_admitted' and all(h.get(k) for k in ['sourceChecked','runtimeAdmitted','irVerified'])
 assert all(ad[k] in h['inputs'] for k in ['source','api','checkedApi'])
 tools=json.loads(Q.BASE.read_text())['tools'];n1=Q.build(b1,h['product'],ad['runtime'],tools)
 assert se['complete'] and se['kind']=='phase130-native-source-qbe-request' and se['byteExact']
 assert se['image']==n1 and se['source']==ad['source'] and se['runtime']==ad['runtime'] and se['expectedQbe']==h['product']
 assert Path(se['product']['file']).read_bytes()==Path(h['product']['file']).read_bytes()
 n2=Q.build(b2,se['product'],ad['runtime'],tools)
 focused_names=json.loads((ROOT/'selfhost/tools/performance/phase111/coverage/manifest.json').read_text())['fixtures']
 for image,report in [(n1,f1),(n2,f2)]:
  assert report['complete'] and report['passed'] and image in report['inputs'] and ad['runtime'] in report['inputs']
  assert report['names']==[x['name'] for x in focused_names]
  assert report['summary']['semanticPasses']==16 and report['summary']['expectedRefusals']==3 and report['summary']['pending']==0
 assert full['complete'] and full['passed'] and n2 in full['inputs'] and ad['runtime'] in full['inputs']
 assert len(full['names'])==45 and full['summary']['semanticPasses']==45 and full['summary']['expectedRefusals']==0 and full['summary']['pending']==0
 inputs=[Q.pin(__file__),Q.pin(Q.__file__),Q.pin(Q.BASE),*[Q.pin(p) for p in paths]]
 for report in [ad,h,b1,se,b2,f1,f2,full]:inputs.extend(Q.pins(report))
 inputs=list({r['file']:r for r in inputs}.values())
 for row in inputs:Q.verify(row)
 result=dict(kind='phase130-native-qualification',complete=True,nativeQualified=True,byteExact=True,
             source=ad['source'],api=ad['api'],runtime=ad['runtime'],n1=n1,n2=n2,
             admission=Q.pin(a.admission),hostedQbe=h['product'],nativeQbe=se['product'],
             reports={name:Q.pin(p) for name,p in zip(['admission','hosted','n1Build','selfEmission','n2Build','n1Focused','n2Focused','n2Full45'],paths)},
             inputs=inputs,installed=False,selected=False,
             scope='Actual checked hosted→N1→N2 QBE reproduction using compact carrier for N1 self-emission; both focused19 and N2 ordinary45 with original decimal carrier. Full products and three requests in both formats separately established. No ELF fixed-point or N2→N3 claim.')
 a.out.write_text(json.dumps(result,indent=2)+'\n');print(json.dumps(dict(complete=True,nativeQualified=True,n1=n1,n2=n2)))
if __name__=='__main__':main()

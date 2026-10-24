"""Freeze byte-exact native request comparisons before broad qualification."""
import argparse,copy,hashlib,json,pathlib,importlib.util
ROOT=pathlib.Path(__file__).resolve().parents[5]
def pin(p):
 p=pathlib.Path(p).resolve();b=p.read_bytes();return dict(file=str(p),bytes=len(b),sha256=hashlib.sha256(b).hexdigest())
p=argparse.ArgumentParser();p.add_argument('--image',required=True,type=pathlib.Path);p.add_argument('--name',required=True);p.add_argument('--out',required=True,type=pathlib.Path);a=p.parse_args()
assert not a.out.exists();selected=json.loads((ROOT/'implementation/phase134/final/candidate.json').read_text());ref=json.loads((ROOT/'selfhost/build/phase134/reference03.json').read_text())
spec=importlib.util.spec_from_file_location('p137request',ROOT/'selfhost/tools/performance/phase130/native-request.py');R=importlib.util.module_from_spec(spec);spec.loader.exec_module(R)
carrier,base,inputs=R.carrier_inputs(pathlib.Path(selected['preferredCarrierReceipt']['file']))
receipt=a.image.parent/'report.json';b=json.loads(receipt.read_text());assert b['complete'] and b['binary']==pin(a.image)
m=dict(schema='bend-native-profile-workloads-v1',cwd=str(ROOT),scope='Experimental source-to-QBE request screen; exact fixed source/output bytes, prepared Base, fresh process per observation; no upstream or native qualification claim.',inputs=[pin(__file__),pin(receipt),pin(ROOT/'selfhost/build/phase134/reference03.json'),pin(ROOT/'implementation/phase134/final/candidate.json'),*inputs],workloads=[])
for c in ref['cases']:
 assert pin(c['source']['file'])==c['source'] and pin(c['expectedQbe']['file'])==c['expectedQbe'];m['inputs'] += [c['source'],c['expectedQbe']]
 w=dict(name=c['name'],timeoutSeconds=30,variants=[])
 for role,image in [('qualified',selected['n2']), (a.name,b['binary'])]:
  assert pin(image['file'])==image
  w['variants'].append(dict(name=role,binary=image,command=[image['file'],'--threads','1','--gpu','off','--','phase111',c['source']['file'],base['file'],'cache',carrier['carrier']['file'],carrier['stamp']],expected=dict(exitCode=0,stdout=dict(kind='exact',bytes=c['expectedQbe']['bytes'],sha256=c['expectedQbe']['sha256']),stderr=dict(kind='exact',bytes=0,sha256=hashlib.sha256(b'').hexdigest()))))
 m['workloads'].append(w)
a.out.write_text(json.dumps(m,indent=2)+'\n')

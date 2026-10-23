"""Bind Phase130 request comparison to frozen Phase128 case/oracle/tool policies."""
import argparse
import copy
import importlib.util
import json
from pathlib import Path
ROOT=Path(__file__).resolve().parents[4]
spec=importlib.util.spec_from_file_location('p130_native',Path(__file__).with_name('native-request.py'))
N=importlib.util.module_from_spec(spec);spec.loader.exec_module(N)

def main():
 ap=argparse.ArgumentParser(description=__doc__)
 for n in ['admission','n1-build','n1-focused','out']:ap.add_argument('--'+n,type=Path,required=True)
 a=ap.parse_args();assert not a.out.exists()
 oldfile=ROOT/'selfhost/build/phase128/native-qualified-timing01/n1-n2.json'
 # The copied timing manifest is the frozen actual previous qualification block.
 assert oldfile.exists()
 m=json.loads(oldfile.read_text());q=json.loads((ROOT/'implementation/phase128/candidate.json').read_text())
 admission,build,focused=[json.loads(p.read_text()) for p in [a.admission,a.n1_build,a.n1_focused]]
 assert admission['complete'] and admission['sourceChecked'] and build['complete'] and focused['complete'] and focused['passed']
 assert admission['runtime']==q['runtime'] and admission['runtime'] in build['inputs']
 assert build['binary'] in focused['inputs'] and focused['summary']['semanticPasses']==16 and focused['summary']['expectedRefusals']==3 and focused['summary']['pending']==0
 m=copy.deepcopy(m);m['kind']='phase112-frozen-native-transport-comparison';m['runtime']=q['runtime']
 m['roles']['phase111']=dict(binary=q['n1'],source=q['source'],generation='Qualified Phase128 N1 decimal',carrierReceipt=N.pin(N.OLD))
 m['roles']['phase112']=dict(binary=build['binary'],source=admission['source'],generation='Experimental Phase130 N1 compact; focused19 passed',carrierReceipt=N.pin(ROOT/'selfhost/build/phase130/base-carrier01/receipt.json'))
 m['inputs'] += [N.pin(__file__),N.pin(oldfile),N.pin(a.admission),N.pin(a.n1_build),N.pin(a.n1_focused),N.pin(Path(__file__).with_name('timing-run.py')),N.pin(Path(__file__).with_name('native-request.py'))]
 m['lineage']=dict(comparison='Phase128 N1 decimal versus Phase130 N1 compact versus unchanged pinned upstream. Fresh rotated three-round block; same sources, Base semantic products, runtime, tools, output oracles and machine-build flags. Native prepared Base advantage disclosed.',qualificationScope='Candidate focused19; full native self-reproduction separately reported.',installed=False)
 m['nativeQualified']=False;m['researchOnly']=True
 a.out.write_text(json.dumps(m,indent=2)+'\n');print(str(a.out))
if __name__=='__main__':main()

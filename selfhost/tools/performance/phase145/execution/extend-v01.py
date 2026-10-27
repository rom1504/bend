#!/usr/bin/env python3
"""Add the retained compiler-index slice only after an exact native oracle exists."""
import argparse,importlib.util,json,sys
from pathlib import Path
sys.dont_write_bytecode=True
ROOT=Path(__file__).resolve().parents[5]
spec=importlib.util.spec_from_file_location('p145native',ROOT/'selfhost/tools/performance/phase130/native-request.py');N=importlib.util.module_from_spec(spec);spec.loader.exec_module(N)
def main():
 p=argparse.ArgumentParser();p.add_argument('--plan',type=Path,required=True);p.add_argument('--oracle',type=Path,required=True);p.add_argument('--out',type=Path,required=True);a=p.parse_args()
 plan=json.loads(a.plan.read_text());oracle=json.loads(a.oracle.read_text());out=a.out.resolve()
 source=N.pin(ROOT/'selfhost/build/phase144/predicate-proxy-source01/positive.bend')
 N.require(not out.exists() and out.is_relative_to(ROOT/'selfhost/build/phase145'),'Fresh Phase145 output')
 N.require(plan['complete'] and oracle['complete'] and oracle['kind']=='phase130-native-source-qbe-request','Wrong oracle/plan')
 N.require(oracle['image']==plan['native'] and oracle['source']==source and oracle['base']==plan['base'] and oracle['carrier']==plan['carrier'] and oracle['stamp']==plan['stamp'],'Native oracle is not same fixed request')
 N.require(oracle['exitCode']==0 and oracle['stderr']['bytes']==0 and oracle['product']['bytes']>0,'Incomplete ordinary oracle')
 plan['inputs'] += [N.pin(__file__),N.pin(a.plan),N.pin(a.oracle),N.pin(ROOT/'selfhost/build/phase144/predicate-proxy-source01/manifest.json'),source,oracle['product'],*oracle['inputs']]
 for item in plan['inputs']:N.verify(item)
 plan['cases'].append(dict(name='compiler-index-slice',source=source,expectedQbe=oracle['product'],scope='Retained actual dependency-closed compiler index plus finite checks; not full compiler scalability. Native oracle is independently compared with checked hosted execution before timing conclusions.'))
 out.mkdir(parents=True);(out/'plan.json').write_text(json.dumps(plan,indent=2)+'\n');print(out/'plan.json')
if __name__=='__main__':main()

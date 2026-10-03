#!/usr/bin/env python3
"""Run reviewed frozen argv stages serially through the existing campaign ledger."""
import argparse,hashlib,json,subprocess
from pathlib import Path
ROOT=Path(__file__).resolve().parents[5]
def main():
 p=argparse.ArgumentParser(description=__doc__);p.add_argument('recipe',type=Path);p.add_argument('--stage',choices=['semantic','cost-prepare','postinstall'],required=True);p.add_argument('--ledger',type=Path,required=True);p.add_argument('--jobs',type=Path,required=True);p.add_argument('--prefix',required=True);p.add_argument('--admission',type=Path);p.add_argument('--check-only',action='store_true');a=p.parse_args();r=json.loads(a.recipe.read_text())
 assert r['kind']=='phase42-materialized-final-integration-recipe' and r['bound'] and r['complete'] and not r['executed']
 for row in r['toolInputs']:assert hashlib.sha256(Path(row['path']).read_bytes()).hexdigest()==row['sha256'],row['path']
 for key in ['parent','extension','producer','mappingTemplate']:
  row=r['materialization'][key];assert hashlib.sha256(Path(row['file']).read_bytes()).hexdigest()==row['sha256']
 for row in r['materialization']['artifacts']:assert hashlib.sha256(Path(row['file']).read_bytes()).hexdigest()==row['sha256']
 binding=r['candidateBinding'];manifest=json.loads(Path(binding['attempt']['path']).read_text());assert hashlib.sha256(Path(binding['attempt']['path']).read_bytes()).hexdigest()==binding['attempt']['sha256'] and manifest['api']==binding['api']
 for key in ['api','runtime','base','node']:
  row=binding[key];assert manifest[key]==row and hashlib.sha256(Path(row['file']).read_bytes()).hexdigest()==row['sha256']
 if a.stage=='postinstall':
  assert a.admission and a.admission.is_file(),'Explicit frozen performance/cost admission receipt required'
  admission=json.loads(a.admission.read_text());assert admission['complete'] and admission['pass'] and admission['attempt']['sha256']==binding['attempt']['sha256'] and admission['api']['sha256']==binding['api']['sha256']
  semantic=json.loads((Path(r['bindings']['OUT'])/'composite-preinstall/report.json').read_text());assert semantic['complete'] and semantic['pass'] and semantic['attempt']['sha256']==binding['attempt']['sha256']
 names=r['stages'][a.stage];steps={s['name']:s for s in r['steps']};assert all(steps[n].get('argv') for n in names)
 if a.check_only:print(json.dumps(dict(complete=True,executed=False,stage=a.stage,names=names)));return
 subprocess.run(['python3',str(ROOT/'selfhost/tools/performance/phase41/recipe-run.py'),str(a.recipe),','.join(names),'--ledger',str(a.ledger),'--jobs',str(a.jobs),'--prefix',a.prefix],check=True,cwd=ROOT)
if __name__=='__main__':main()

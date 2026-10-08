#!/usr/bin/env python3
"""Data-only recipe: five real sources and eighteen bounded private controls."""
from pathlib import Path
import argparse, hashlib, json, subprocess, sys
ROOT=Path(__file__).resolve().parents[6]
def pin(p):
 p=p.resolve(strict=True);b=p.read_bytes();return {'file':str(p),'sha256':hashlib.sha256(b).hexdigest(),'bytes':len(b)}
def main():
 ap=argparse.ArgumentParser();ap.add_argument('--attempt',type=Path,required=True);ap.add_argument('--out',type=Path,required=True);a=ap.parse_args()
 out=a.out.resolve();attempt_file=a.attempt/'attempt.json' if a.attempt.is_dir() else a.attempt
 attempt=json.loads(attempt_file.read_text());assert attempt['checked'];assert not out.exists()
 here=Path(__file__).parent;producer=here/'prepare-controls.py'
 subprocess.run([sys.executable,str(producer),'--attempt',str(attempt_file),'--out',str(out)],check=True)
 source_recipe=out/'min-wide-recipe.json';r=json.loads(source_recipe.read_text());controller=here/'controls.mjs'
 actual=Path(attempt['api']['file']);assert pin(actual)['sha256']==attempt['api']['sha256'];source=actual.read_text()
 names=['run_loop','$jd_calls_match_fields$','$jd_calls_match_arm$','$jd_calls_fields$','$jd_calls_body$','$jd_calls_bad$','$kt$','$all$','$atom$']
 for name in names:assert source.count('function '+name+'(')==1,name
 private_out=out/'private-controls';guard=ROOT/'selfhost/tools/performance/phase32/bounded-run.py'
 command=['python3','-B',str(guard),'--seconds','30','--rss-mib','2048','--available-mib','4096',str(out/'private-supervisor'),'--','taskset','-c','3','env','NODE_OPTIONS=','NODE_PATH=',attempt['node']['file'],'--stack-size=4096','--max-old-space-size=1024',str(controller),str(attempt_file.parent),str(private_out)]
 r.update({'kind':'phase66-min-wide-final-controls','producer':pin(Path(__file__)),'parentFocusedRecipe':pin(source_recipe),'attempt':pin(attempt_file),'api':pin(actual),'controller':pin(controller),'guard':pin(guard),'privateDeclarationPreflight':names})
 r['commands'].append({'name':'wide-field-eighteen','command':command,'expectedExitCodes':[0],'expectedObservations':18,'report':str(private_out/'report.json')})
 final=out/'final-recipe.json';final.write_text(json.dumps(r,indent=2)+'\n');print(json.dumps({'recipe':pin(final)}))
if __name__=='__main__':main()

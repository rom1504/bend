"""Fresh positive native IO/numeric controls with exact output/status oracles."""
import argparse,json,subprocess,sys,time
from pathlib import Path
ROOT=Path(__file__).resolve().parents[3]
sys.path.insert(0,str(ROOT/'selfhost/tools/build'))
from common import pin,verify,write_json,fresh_output,run
import assets
p=argparse.ArgumentParser();p.add_argument('--assets',type=Path,required=True);p.add_argument('--image-key',default='qbe-api');p.add_argument('--host',default='js');p.add_argument('--stage',default='B1');p.add_argument('--cases',default='numeric,array-unchecked,char-output,argv,files,open-errors,exit,exit-upper-valid,halt-valid');p.add_argument('--out',type=Path,required=True);a=p.parse_args()
out=fresh_output(a.out,ROOT);document=assets.load_assets(a.assets,ROOT);rows=[];inputs=[pin(__file__),document['_manifest']];start=time.monotonic();report=dict(kind='phase182-native-positive-controls',complete=False,inputs=inputs,rows=rows,scope='Ordinary valid source/runtime behavior. Explicit exit status23/255/7 is requested by Bend IO, never a failure-runtime probe. No parallel/GPU claim.')
def save():report['seconds']=time.monotonic()-start;write_json(out/'report.json',report)
try:
 for name in a.cases.split(','):
  if not name or any(c not in 'abcdefghijklmnopqrstuvwxyz-' for c in name):raise ValueError('unknown case name')
  source=ROOT/'selfhost/tests/phase182/native'/f'{name}.bend';inputs.append(pin(source));folder=out/name;folder.mkdir();expected=[];code=0
  for line in source.read_text().splitlines():
   if line.startswith('#|exit '):code=int(line[7:])
   elif line.startswith('#|'):expected.append(line[2:])
  stdout='\n'.join(expected)+('\n' if expected else '');stderr=''
  if name=='halt-valid':stdout='before\n';stderr='reported\n'
  command=[sys.executable,'-B','selfhost/tools/build/native.py','--assets',str(a.assets),'--image-key',a.image_key,'--host',a.host,'--stage',a.stage,'--target','qbe','--mode','cache','--source',str(source),'--out',str(folder/'build'),'--seconds','55','--retain-ir']
  built=run(command,cwd=ROOT,stdout=folder/'build.stdout',stderr=folder/'build.stderr',seconds=65)
  row=dict(name=name,source=pin(source),build=built,expected=dict(stdout=stdout,stderr=stderr,exitCode=code),complete=False);rows.append(row);save()
  receipt=folder/'build/report.json'
  if not built['complete'] or not receipt.exists():continue
  b=json.loads(receipt.read_text());row['receipt']=pin(receipt)
  if not b['complete']:continue
  work=folder/'run';work.mkdir();e=run([str(folder/'build/program'),*assets.runtime_arguments(assets.runtime_provider(document,'qbe-runtime'))],cwd=work,stdout=folder/'stdout',stderr=folder/'stderr',seconds=15)
  row['execution']=e;row['complete']=not e.get('timedOut') and not e.get('error') and e['exitCode']==code and (folder/'stdout').read_text()==stdout and (folder/'stderr').read_text()==stderr;save()
 for item in inputs:verify(item)
 report['complete']=all(row['complete'] for row in rows)
except Exception as e:report['error']=repr(e)
finally:save();print(json.dumps(dict(complete=report['complete'],cases=[(r['name'],r['complete'])for r in rows],error=report.get('error'))))
sys.exit(0 if report['complete'] else 1)

#!/usr/bin/env python3
import json,os,sys
from pathlib import Path
root=Path(__file__).resolve().parents[3];sys.path.insert(0,str(root/'selfhost/tools/build'))
from common import pin,require,run,write_json
import assets
out=root/'selfhost/build/phase174/installed-public-smoke';require(not out.exists(),'Fresh output required');out.mkdir()
selector=root/'selfhost/manifests/current.json';d=json.loads(selector.read_text())
require((root/'selfhost/bend').resolve()==(root/'selfhost/dist/native/bend').resolve(),'Public symlink differs')
source=root/'selfhost/tests/consolidation/cli/base-u32.bend'
inputs=[pin(selector),pin(source),pin(root/'selfhost/cli.mjs'),pin(root/d['components']['js']['image']['file']),pin(root/d['components']['nativeCli']['image']['file'])]
doc=assets.load_assets(root/'selfhost/manifests/assets-native.json',root)
engine=pin('/home/ai/.nvm/versions/node/v24.22.1/bin/node');inputs.append(engine)
env={k:v for k,v in os.environ.items() if not k.startswith('BEND_') and k not in ('NODE_OPTIONS','NODE_PATH','LD_PRELOAD')}
env['BEND_TYPED_BASE_CACHE']='off'
js=run([engine['file'],str(root/'selfhost/cli.mjs'),str(source),'--run'],cwd=out,stdout=out/'js.stdout',stderr=out/'js.stderr',seconds=60,env=env)
require(js['complete'] and Path(js['stdout']['file']).read_text()=='42\n' and Path(js['stderr']['file']).stat().st_size==0,'Installed default JS output differs')
c=run([str(root/'selfhost/bend'),str(source),'-o',str(out/'program.c')],cwd=root,stdout=out/'c.stdout',stderr=out/'c.stderr',seconds=30,env=env)
require(c['complete'] and Path(c['stdout']['file']).stat().st_size==0 and Path(c['stderr']['file']).read_text()=='ALL PROOFS CHECK\nUse --verdict for mathematical validity.\n\n','Installed default native CLI differs from its qualified diagnostic contract')
controls=json.loads((root/'selfhost/build/phase174/public-controls/report.json').read_text())
expected=next(x['candidate'] for x in controls['products'] if x['name']=='numeric');actual=pin(out/'program.c')
require(all(actual[k]==expected[k] for k in ('bytes','sha256')),'Installed default C product differs')
write_json(out/'report.json',dict(kind='phase174-installed-public-smoke',complete=True,passed=True,inputs=inputs,js=js,native=c,cProduct=actual,expectedC=expected,jsExpected='42\n',apiOverride=False,scope='Default installed selectors and public entrypoints; broad qualification is separate.'))
print(json.dumps(dict(complete=True,passed=True)))

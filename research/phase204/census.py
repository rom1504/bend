import json,subprocess,sys
from pathlib import Path
from prepare import ROOT,BASE,HERE
out=Path(sys.argv[1]).resolve()
out.mkdir(parents=True)
names=['p88_cache_prepare','p86_plan','x198pw_plan','x202k_shape']
exports=out/'exports.json'
exports.write_text(json.dumps(dict(kind='bend-hosted-api-exports',version=1,protocol='typed-api-v1',targets=['qbe'],exports=names)))
bun=ROOT/'selfhost/.assets/bin/bun'
for label,cmd in [('api',[bun,'selfhost/tools/build/hosted.mjs','acquire','--source',BASE,'--out',out/'api','--exports',exports,'--engine',bun,'--upstream','selfhost/.bootstrap/upstream-phase182']),('scan',['/home/ai/.nvm/versions/node/v24.12.0/bin/node','--stack_size=6553','--max-old-space-size=1800',HERE/'segments.mjs',out])]:
    with (out/(label+'.log')).open('xb') as f:subprocess.run(cmd,check=True,stdout=f,stderr=subprocess.STDOUT)

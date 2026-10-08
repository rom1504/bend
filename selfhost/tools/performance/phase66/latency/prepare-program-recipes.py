#!/usr/bin/env python3
"""Prepare root-only four/full checked acquisition and later data admission commands."""
import argparse, hashlib, json, shlex, sys
from pathlib import Path
ROOT=Path(__file__).resolve().parents[5];RAW=ROOT/'selfhost/build/phase66'
def pin(p):
    p=Path(p).resolve(strict=True);return dict(file=str(p),sha256=hashlib.sha256(p.read_bytes()).hexdigest())
p=argparse.ArgumentParser(description=__doc__);p.add_argument('--attempt',type=Path,required=True)
p.add_argument('--prefix',required=True);p.add_argument('--method',type=Path,default=RAW/'latency-method05')
a=p.parse_args();assert a.prefix.replace('-','').replace('_','').isalnum()
attempt_file=a.attempt/'attempt.json' if a.attempt.is_dir() else a.attempt;attempt_file=attempt_file.resolve(strict=True)
m=json.loads(attempt_file.read_text());assert m['checked'] and m['config']['strictExact']
assert pin(m['api']['file'])['sha256']==m['api']['sha256']
boot=json.loads(Path(m['bootstrapReport']['file']).read_text());assert pin(m['bootstrapReport']['file'])['sha256']==m['bootstrapReport']['sha256']
assert boot['revision']=='059266225b77c8ca256ac6b25ee5c21449bab151'
out=RAW/(a.prefix+'-program-recipes');assert not out.exists()
method=a.method.resolve(strict=True);assert method.is_relative_to(RAW)
catalog_file=RAW/'head-ts-inputs/catalog.json';catalog=json.loads(catalog_file.read_text())
assert catalog['upstreamCommit']==boot['revision']
compile_catalog=json.loads((ROOT/'selfhost/tools/performance/phase60/catalog.json').read_text())
ids=['numeric-recurrence','lexer','test-map-set-ops','raytrace-active']
points=[point for key in ids for point in next(row for row in compile_catalog['compileInputs'] if row['id']==key)['pointIds']]
common=[sys.executable,'-B',str(ROOT/'selfhost/tools/performance/phase52/prepare-v2.py'),'--attempt',str(attempt_file.parent),
    '--catalog',str(catalog_file),'--role','candidate','--backend','direct','--cpu','3','--rss-mib','2048',
    '--available-mib','4096','--timeout','30','--node',m['node']['file']]
commands={}
for label,args in [('four',['--cases',','.join(points)]),('full',['--set','full'])]:
    acquisition=RAW/(a.prefix+'-'+label+'-acquisition');smoke=RAW/(a.prefix+'-'+label+'-smoke')
    oracle=RAW/(a.prefix+'-'+label+'-oracles.json');latency=RAW/(a.prefix+'-'+label+'-latency')
    commands[label+'-acquire']=common+args+['--out',str(acquisition)]
    commands[label+'-smoke']=[sys.executable,'-B',str(Path(__file__).parent/'runtime/smoke.py'),'--manifest',str(acquisition/'manifest.json'),
        '--catalog',str(catalog_file),'--out',str(smoke),'--node',m['node']['file']]
    commands[label+'-join']=['taskset','-c','0',sys.executable,'-B',str(Path(__file__).parent/'join-bend-oracles-v2.py'),
        '--attempt',str(attempt_file.parent),'--acquisition',str(acquisition),'--smoke',str(smoke),
        '--cases',','.join(ids) if label=='four' else 'all','--out',str(oracle)]
    commands[label+'-bind']=['taskset','-c','0',sys.executable,'-B',str(Path(__file__).parent/'bind-qualified.py'),
        '--attempt',str(attempt_file.parent),'--oracles',str(oracle),'--out',str(latency),'--method',str(method)]
recipe=dict(kind='phase66-b1-program-qualification-recipe',complete=True,dataOnly=True,targetExecuted=False,producer=pin(__file__),
    attempt=pin(attempt_file),api=m['api'],method=pin(method/'derivation.json'),catalog=pin(catalog_file),commands=commands,
    scope='Four-source8point fast acquisition first; full23/45 optional later. Actual checked selected API. Acquire/smoke are root-only targets; join/bind are CPU0 data. Own output qualification precedes caches and clean clocks.')
out.mkdir(parents=True);(out/'recipe.json').write_text(json.dumps(recipe,indent=2)+'\n')
(out/'commands.txt').write_text('\n\n'.join('# '+k+'\n'+shlex.join(v) for k,v in commands.items())+'\n')
print(json.dumps(dict(recipe=pin(out/'recipe.json'))))

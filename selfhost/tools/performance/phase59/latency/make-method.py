#!/usr/bin/env python3
"""Data-only Phase59 successor: clean requests or one complete first-request profile."""
import argparse, ast, hashlib, json
from pathlib import Path

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[4]
TOOLS = HERE.parents[1]
p = argparse.ArgumentParser(description=__doc__)
p.add_argument('out', type=Path)
a = p.parse_args()
out = a.out.resolve()
assert out.is_relative_to(ROOT/'selfhost/build/phase59') and not out.exists()
assert (ROOT/'selfhost/build/phase59').is_dir(), 'Root must initialize Phase59 first'

def identity(file):
 file = Path(file).resolve(strict=True); data = file.read_bytes()
 return dict(file=str(file), sha256=hashlib.sha256(data).hexdigest(), bytes=len(data))

def literal(file): return repr(str(Path(file).resolve()))
parents = {
 'setup.mjs': (TOOLS/'phase58/latency/setup-v2.mjs', '443790f456fa27401c227c6db968bce7293161ec3bbed24c8cad80d612734ee3'),
 'profile.mjs': (ROOT/'selfhost/build/phase58/latency-method04/profile.mjs', '1f744e18c301372389458aaaf714123a6d29fee6a94ffca3913abf33b7a5d9d6'),
 'worker.mjs': (ROOT/'selfhost/build/phase58/latency-method04/worker.mjs', 'd4e5d800894183a3787a3fa10fad5085deb412a8f86d4529035a6e8a488d1143'),
 'run.py': (ROOT/'selfhost/build/phase58/latency-method04/run.py', '0687c393fff5b7f311dd98069dd2ae88a1a6071ae4be7610eb944fdfbdc823b7'),
}
attempt = identity(ROOT/'selfhost/build/phase58/checked-last01/attempt.json')
emission = identity(ROOT/'selfhost/build/phase58/final-last01/bootstrap/full/report.json')
assert attempt['sha256'] == 'e500b277beb16202d1e16aa5f24ebbd6964ca8ba3eaed41e7ff0b988cd266de1'
assert emission['sha256'] == 'd952025b0cacfa72b56f074b53df0e2a5fa3e8bbd3c844108f335f1704c3a99a'
e = json.loads(Path(emission['file']).read_text())
assert e['complete'] and e['pass']
assert e['module']['sha256'] == 'a73daccf86a807092a334d5f3121745e0b91c3054164c25462f1658644b7b081'
assert e['subject']['source']['sha256'] == '85454aab7a6ef25d1e78970b1c24d68ac2a90a23a4b39b64a30de311c2fc5091'
bindings = dict(kind='phase59-compiler-image-bindings',version=1,comparison='fixed-source',
 roles={'direct':dict(kind='direct',attempt=attempt,emission=emission)},
 scope='Selected genuine checked-last01 B2 versus pinned TypeScript. No diagnostic compiler syntax or source changes.')
outputs = {}; derivations = []
for name, (parent, expected) in parents.items():
 before = identity(parent); assert before['sha256'] == expected
 text = parent.read_text(); edits = []
 def edit(old, new, count=1):
  global text
  actual = text.count(old); assert actual == count, (name, old[:100], actual, count)
  text = text.replace(old, new); edits.append(dict(old=old,new=new,count=count))
 if name == 'setup.mjs':
  for old, file in [('../../../development/workflow.mjs', ROOT/'selfhost/tools/development/workflow.mjs'),
    ('../../phase54/bootstrap/adapter.mjs', TOOLS/'phase54/bootstrap/adapter.mjs'),
    ('../../../development/process.mjs', ROOT/'selfhost/tools/development/process.mjs'),
    ('../../../conformance/inventory.mjs', ROOT/'selfhost/tools/conformance/inventory.mjs')]:
   edit(repr(old), json.dumps(file.as_uri()), text.count(repr(old)))
  edit("const root=path.resolve(import.meta.dirname,'../../../../..');", 'const root='+json.dumps(str(ROOT))+';')
  edit('phase58', 'phase59', text.count('phase58'))
 elif name == 'profile.mjs':
  edit('phase58', 'phase59', text.count('phase58'))
  edit('/** Caller imports/primes/warms first, and supplies the exact async request+oracle. */',
       '/** One fresh process: capture compiler imports, API load and first compile; validate after stop. */')
  edit('maxRequests=32', 'maxRequests=1')
  edit("assert(Number.isInteger(maxRequests)&&maxRequests>=1&&maxRequests<=1000);", "assert.equal(maxRequests,1,'Exactly one first-request capture');")
  edit('Inspector encloses sequential awaited run() requests, their supplied correctness checks, and loop/Promise overhead. Caller import, first request and warmup must precede this helper. Serialization and summaries follow inspector stop. Profiled durations are never benchmark ratios.',
       'Inspector encloses exactly one run(): actual compiler imports, API load and first compile. No prior compiler import/request/warmup occurs in this worker. Output validation, hashing, saving, serialization and summaries follow inspector stop. Profiler setup and loop/Promise overhead remain diagnostic; durations are never clean benchmark ratios.')
  edit('resourceUsage is cumulative process lifetime, including caller import/priming/warmup; memory is a final snapshot, not a sampled interval peak.',
       'resourceUsage is cumulative process lifetime, including excluded preflight and inspector setup; memory is a final snapshot, not a sampled interval peak.')
 elif name == 'worker.mjs':
  edit((TOOLS/'phase58/latency/setup-v2.mjs').as_uri(), (out/'setup.mjs').as_uri())
  edit((ROOT/'selfhost/build/phase58/latency-method04/profile.mjs').as_uri(), (out/'profile.mjs').as_uri())
  edit('phase58', 'phase59', text.count('phase58'))
  start = text.index('    const imported=performance.now();await load(prep.image);')
  end = text.index("    if(request.role!=='typescript') {\n      const directory=", start)
  old = text[start:end]
  new = '''    let first;
    const firstWindow=async()=>{
      assert.equal(first,undefined,'Only one first request');
      const imported=performance.now();await load(prep.image);report.hostImportMs=performance.now()-imported;
      const apiStart=performance.now();
      if(request.role!=='typescript')await D.loadApi();
      report.apiLoadMs=request.role==='typescript'?0:performance.now()-apiStart;
      report.apiLoadScope=request.role==='typescript'?'Compiler imports included in hostImportMs':'Ordinary D.loadApi, including ABI checks/adaptation';
      const begin=performance.now();
      try {first=await compile(row)} finally {report.firstRequestMs=performance.now()-begin}
      report.importApiAndFirstMs=report.hostImportMs+report.apiLoadMs+report.firstRequestMs;
    };
    report.cleanTiming=config.mode==='clean';
    if(report.cleanTiming)await firstWindow();
    else {
      assert.equal(config.warmRequests,0);
      report.profile=await profile({mode:config.mode,run:firstWindow,out:request.profileOut,...config.profile,
        moduleUrl:pathToFileURL(request.role==='typescript'?path.join(config.upstream,'bend2/comp.ts'):prep.image.api.file).href});
      assert.equal(report.profile.calls,1);
      report.profileWindow='Actual compiler import + API load + exactly one first compile; output validation after inspector stop';
    }
    // Clean and diagnostic observations use the same complete prepared-byte oracle.
    // Result retention spans profiler stop only; validation/hash/file writes are outside capture.
    report.observation=first.observation;validate(first);report.output=saveCode(request.output,first.code);first=null;
    report.warmRequests=[];
    for(let i=0;i<config.warmRequests;i++) {
      const begin=performance.now(),result=await compile(row),requestMs=performance.now()-begin;
      report.warmRequests.push({index:i,requestMs,output:validate(result)});
    }
'''
  edit(old, new)
 elif name == 'run.py':
  edit("HERE=Path('/home/ai/bend2/build/publish/bend/selfhost/tools/performance/phase58/latency')", 'HERE=Path('+literal(HERE)+')')
  edit(str(ROOT/'selfhost/build/phase58/latency-method04/worker.mjs'), str(out/'worker.mjs'))
  edit(str(ROOT/'selfhost/build/phase58/latency-method04/profile.mjs'), str(out/'profile.mjs'), 2)
  edit("HERE/'setup-v2.mjs'", 'Path('+literal(out/'setup.mjs')+')')
  edit('phase58', 'phase59', text.count('phase58'))
  edit('Phase58', 'Phase59', text.count('Phase58'))
  edit("p.add_argument('--bindings',type=Path,required=True)", "p.add_argument('--bindings',type=Path,default=Path("+literal(out/'bindings.json')+"))")
  edit("p.add_argument('--cases',default='lexer')", "p.add_argument('--cases',default='test-evening-program,lexer')")
  edit("p.add_argument('--roles',default='baseline,candidate')", "p.add_argument('--roles',default='direct,typescript')")
  edit("p.add_argument('--rounds',type=int,default=1)", "p.add_argument('--rounds',type=int,default=3)")
  edit("p.add_argument('--warm-requests',type=int,default=1)", "p.add_argument('--warm-requests',type=int,default=3)")
  edit("choices=['clean','cpu','allocation','trace']", "choices=['clean','cpu','allocation']")
  edit("p.add_argument('--profile-ms',type=int,default=5000)\n", '')
  edit(' and 100<=a.profile_ms<=10000', '')
  edit("p.add_argument('--seconds',type=int,default=60)", "p.add_argument('--seconds',type=int,default=300)")
  edit("assert binding['comparison'] in ['fixed-source','changed-source']", "assert binding['comparison']=='fixed-source' and binding['roles']=="+repr(bindings['roles']))
  edit("and set(roles)<=set(binding['roles'])|{'typescript'}", "and set(roles)<={'direct','typescript'}")
  edit('1f744e18c301372389458aaaf714123a6d29fee6a94ffca3913abf33b7a5d9d6', hashlib.sha256(outputs['profile.mjs'].encode()).hexdigest())
  edit('warmRequests=a.warm_requests', "warmRequests=a.warm_requests if a.mode=='clean' else 0")
  edit('profile=dict(targetMs=a.profile_ms,maxRequests=32', 'profile=dict(targetMs=1,maxRequests=1')
  edit("flags=['--trace-opt','--trace-deopt','--trace-gc-nvp'] if a.mode=='trace' and request['stage']=='sample' else []", 'flags=[]')
  edit('Profiles/traces are separate diagnostic processes, never clean timing.', 'CPU/allocation are separate fresh diagnostic processes: capture actual compiler import, API load and exactly one first compile; no prior compile or warm request, output validation after stop. Never mix profile times into clean statistics.')
  ast.parse(text)
 outputs[name] = text
 derivations.append(dict(parent=before,output=dict(file=str(out/name),sha256=hashlib.sha256(text.encode()).hexdigest()),edits=edits))

for name,(file,sha) in parents.items(): assert identity(file)['sha256']==sha
receipt=dict(kind='phase59-first-request-method-derivation',complete=True,dataOnly=True,targetExecuted=False,
 producer=identity(__file__),selectedAttempt=attempt,selectedEmission=emission,
 scope='Frozen Phase58 method successor. Clean clocks unchanged; separate profile captures exactly actual import/API/first compile, validation afterward. Private Phase59 copies/caches, genuine B2 lineage and per-role complete output oracle retained.',
 derivations=derivations)
out.mkdir(parents=True)
for name,text in outputs.items(): (out/name).write_text(text)
(out/'bindings.json').write_text(json.dumps(bindings,indent=2)+'\n')
(out/'derivation.json').write_text(json.dumps(receipt,indent=2)+'\n')
print(json.dumps({name:identity(out/name) for name in ['run.py','worker.mjs','profile.mjs','setup.mjs','bindings.json','derivation.json']}))

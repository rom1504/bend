#!/usr/bin/env python3
"""Data-only stage-clock successor of the consumed Phase59 first-request worker."""
import argparse, ast, hashlib, json
from pathlib import Path
HERE=Path(__file__).resolve().parent; ROOT=HERE.parents[4]
p=argparse.ArgumentParser(description=__doc__);p.add_argument('out',type=Path);a=p.parse_args()
out=a.out.resolve();assert out.is_relative_to(ROOT/'selfhost/build/phase59') and not out.exists()
parent=ROOT/'selfhost/build/phase59/latency-method01'
clock=HERE.parent/'stages/clock.mjs';deriver=HERE.parent/'stages/derive-driver.py'
def identity(f):
 f=Path(f).resolve();b=f.read_bytes();return dict(file=str(f),sha256=hashlib.sha256(b).hexdigest(),bytes=len(b))
assert identity(clock)['sha256']=='d606d5c9ef43e3afbc60d60ca31bbb5972daf1831c63aee5d4e058822c2f2c37'
assert identity(deriver)['sha256']=='4546095f9f223406e00cdb9d3057c926247398fd5ce804446ab6f2dee2ee59cc'
outputs={};derivations=[]
for name,pin in [('worker.mjs','5a1bff2254d1aeec69268a38f03542ef49148c54976cad8ede865966a7d5d20e'),('run.py','6f115dd34ebba3e3ea1984819878d726de933c3e46e28ba989f1d10494da5717')]:
 source=parent/name;before=identity(source);assert before['sha256']==pin;text=source.read_text();edits=[]
 def edit(old,new,count=1):
  global text
  assert text.count(old)==count,(name,old[:100],text.count(old));text=text.replace(old,new);edits.append(dict(old=old,new=new,count=count))
 if name=='worker.mjs':
  edit("import assert from 'node:assert/strict';", "import assert from 'node:assert/strict';\nimport {STAGE_SYMBOL,createStageClock} from "+json.dumps(clock.as_uri())+';')
  edit('let staged,D,B,C;', 'let staged,D,B,C,stageClock,diagnosticDriver;')
  edit("D=await import(pathToFileURL(image.driver.file));", "D=await import(pathToFileURL(diagnosticDriver.output.file));")
  edit("    const book=B.book_nil();await B.book_load(book,row.source.file,'',new Map());B.book_valid(book);\n    assert.equal(book.hols,0);return {code:C.js_lib(book,true),observation:{checked:true,holes:book.hols,backend:'upstream'}};", '''    const book=B.book_nil();
    let token=stageClock.begin('ts.book-load');
    try {await B.book_load(book,row.source.file,'',new Map())} finally {stageClock.end(token)}
    token=stageClock.begin('ts.book-valid');
    try {B.book_valid(book)} finally {stageClock.end(token)}
    assert.equal(book.hols,0);let code;token=stageClock.begin('ts.js-lib');
    try {code=C.js_lib(book,true)} finally {stageClock.end(token)}
    return {code,observation:{checked:true,holes:book.hols,backend:'upstream'}};''')
  edit("assert.ok(config.roles.includes(request.role));assert.ok(['prepare','sample'].includes(request.stage));", "assert.ok(config.roles.includes(request.role));assert.equal(request.stage,'sample');assert.equal(config.mode,'stages');")
  edit('    report.preflightMs=performance.now()-preflight;\n    let first;', '''    if(request.role!=='typescript') {
      verify(config.stageDriver);diagnosticDriver=JSON.parse(fs.readFileSync(config.stageDriver.file,'utf8'));
      assert.equal(diagnosticDriver.kind,'phase59-private-driver-stage-derivation');
      assert.equal(diagnosticDriver.complete,true);assert.equal(diagnosticDriver.pass,true);assert.equal(diagnosticDriver.exactInverse,true);
      check([diagnosticDriver.source,diagnosticDriver.output,diagnosticDriver.producer,diagnosticDriver.clock]);
      assert.equal(diagnosticDriver.source.file,prep.image.driver.file);assert.equal(diagnosticDriver.source.sha256,prep.image.driver.sha256);
      assert.equal(path.dirname(diagnosticDriver.source.file),path.dirname(diagnosticDriver.output.file));
      assert.equal(path.basename(diagnosticDriver.output.file),'typed-driver-stages.mjs');
      report.originalDriver=prep.image.driver;report.diagnosticDriver=config.stageDriver;
    }
    report.stageClock=identity(new URL('''+json.dumps(clock.as_uri())+'''));
    stageClock=createStageClock();assert.equal(globalThis[STAGE_SYMBOL],undefined);
    globalThis[STAGE_SYMBOL]=stageClock;
    report.preflightMs=performance.now()-preflight;
    let first;''')
  edit('      const imported=performance.now();await load(prep.image);report.hostImportMs=performance.now()-imported;', '''      let token=stageClock.begin('host-import');const imported=performance.now();
      try {await load(prep.image)} finally {report.hostImportMs=performance.now()-imported;stageClock.end(token)}''')
  edit('      const apiStart=performance.now();\n      if(request.role!==\'typescript\')await D.loadApi();\n      report.apiLoadMs=request.role===\'typescript\'?0:performance.now()-apiStart;', '''      token=stageClock.begin('api-load');const apiStart=performance.now();
      try {if(request.role!=='typescript')await D.loadApi()}
      finally {report.apiLoadMs=request.role==='typescript'?0:performance.now()-apiStart;stageClock.end(token)}''')
  edit('      const begin=performance.now();\n      try {first=await compile(row)} finally {report.firstRequestMs=performance.now()-begin}', '''      token=stageClock.begin('first-request');const begin=performance.now();
      try {first=await compile(row)} finally {report.firstRequestMs=performance.now()-begin;stageClock.end(token)}''')
  start=text.index("    report.cleanTiming=config.mode==='clean';")
  end=text.index('    // Clean and diagnostic observations',start)
  edit(text[start:end],'''    report.cleanTiming=false;assert.equal(config.warmRequests,0);
    try {await firstWindow()} finally {
      report.stages=stageClock.snapshot();delete globalThis[STAGE_SYMBOL];
    }
    assert.equal(report.stages.incomplete,0);
    assert.equal(report.stages.events.filter(x=>x.parent===null).length,3);
    report.stageScope='Diagnostic synchronous clocks around one import/API/first compile; original compiler API and output oracle unchanged. Never clean timing.';
''')
  edit("    check(bindings);check(oldConfig.inputs);verify(prep.config);verify(request.preparation);verify(expected.output);", "    check(bindings);check(oldConfig.inputs);verify(prep.config);verify(request.preparation);verify(expected.output);\n    if(diagnosticDriver)check([diagnosticDriver.source,diagnosticDriver.output,diagnosticDriver.producer,diagnosticDriver.clock]);")
 else:
  edit(str(parent/'worker.mjs'),str(out/'worker.mjs'))
  edit("p.add_argument('--mode',choices=['clean','cpu','allocation'],default='clean')", "p.add_argument('--mode',choices=['stages'],default='stages')\np.add_argument('--driver-receipt',type=Path,required=True)")
  edit("p.add_argument('--rounds',type=int,default=3)","p.add_argument('--rounds',type=int,default=1)")
  edit('binding=json.loads(a.bindings.read_text());', "assert a.preparations and not a.prepare_only,'Stage mode reuses completed ordinary preparation'\nbinding=json.loads(a.bindings.read_text());")
  marker='reuse=None\n'
  edit(marker,'''stage=read(a.driver_receipt)
assert stage['kind']=='phase59-private-driver-stage-derivation' and stage['complete'] and stage['pass'] and stage['exactInverse']
assert stage['producer']['sha256']=='''+repr(identity(deriver)['sha256'])+''' and stage['clock']['sha256']=='''+repr(identity(clock)['sha256'])+'''
assert Path(stage['output']['file']).resolve().is_relative_to(ROOT/'selfhost/build/phase59')
inputs += [identity(a.driver_receipt),stage['source'],stage['output'],stage['producer'],stage['clock']]
reuse=None
''')
  edit(' prepareOnly=a.prepare_only,',' prepareOnly=a.prepare_only,stageDriver=identity(a.driver_receipt),')
  edit('CPU/allocation are separate fresh diagnostic processes: capture actual compiler import, API load and exactly one first compile; no prior compile or warm request, output validation after stop. Never mix profile times into clean statistics.', 'Stage mode uses fresh diagnostic processes and insertion-only private driver clocks: one import/API/first compile, no inspector or prior request, output validation afterward. Nested inclusive intervals overlap; use exclusive partition, never clean latency statistics.')
  ast.parse(text)
 outputs[name]=text;derivations.append(dict(parent=before,output=dict(file=str(out/name),sha256=hashlib.sha256(text.encode()).hexdigest()),edits=edits))
result=dict(kind='phase59-stage-method-derivation',complete=True,dataOnly=True,targetExecuted=False,
 producer=identity(__file__),clock=identity(clock),driverDeriver=identity(deriver),derivations=derivations,
 scope='Insertion-only diagnostic driver with unchanged genuine API/prepared byte oracle; one first request, no inspector, original ordinary method preserved.')
out.mkdir(parents=True)
for name,text in outputs.items():(out/name).write_text(text)
(out/'derivation.json').write_text(json.dumps(result,indent=2)+'\n')
print(json.dumps({n:identity(out/n) for n in ['run.py','worker.mjs','derivation.json']}))

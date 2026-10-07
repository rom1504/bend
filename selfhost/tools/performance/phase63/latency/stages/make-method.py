#!/usr/bin/env python3
"""Data-only stage clocks successor of the Phase62 relocated, reviewed fast loop."""
import argparse, ast, hashlib, json, subprocess, sys
from pathlib import Path
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[5];RAW=ROOT/'selfhost/build/phase63'
p=argparse.ArgumentParser(description=__doc__)
p.add_argument('parent',type=Path);p.add_argument('out',type=Path)
p.add_argument('--preparations',type=Path,required=True)
a=p.parse_args();parent=a.parent.resolve(strict=True);out=a.out.resolve()
assert parent.is_relative_to(RAW) and out.is_relative_to(RAW) and not out.exists()
def identity(file):
 file=Path(file).resolve(strict=True)
 return dict(file=str(file),sha256=hashlib.sha256(file.read_bytes()).hexdigest())
def verify(item):assert identity(item['file'])=={k:item[k] for k in ['file','sha256']}
preparation=identity(a.preparations);prep=json.loads(a.preparations.read_text())
assert prep['kind']=='phase61-candidate-image-library-latency' and prep['complete'] and prep['pass']
verify(prep['config']);config=json.loads(Path(prep['config']['file']).read_text())
assert config['prepareOnly'] is True
rows=[];drivers=[]
outputs={}
for name in ['run.py','worker.mjs','setup.mjs','profile.mjs']:
 source=parent/name;before=identity(source);text=source.read_text();edits=[]
 def edit(old,new,count=1):
  global text
  assert text.count(old)==count,(name,old[:120],text.count(old),count)
  text=text.replace(old,new);edits.append(dict(old=old,new=new,count=count))
 n=text.count(str(parent))
 if n:edit(str(parent),str(out),n)
 if name=='run.py':
  edit("choices=['clean','cpu','allocation']", "choices=['clean','cpu','allocation','stages']")
  edit("catalog,node,a.bindings,", "Path(__file__).with_name('clock.mjs'),catalog,node,a.bindings,")
  edit("protocol='Fresh process", "protocol='Stage mode is diagnostic only: nested exclusive wall clocks include instrumentation overhead. Fresh process")
  ast.parse(text)
 elif name=='worker.mjs':
  edit("const entered=performance.now(),", "import {createStageClock,STAGE_SYMBOL} from './clock.mjs';\n\nconst entered=performance.now(),")
  edit("let staged,D,B,C;", """const stageClock=config.mode==='stages'?createStageClock():null;
if(stageClock)globalThis[STAGE_SYMBOL]=stageClock;
const stageBindings=[];
let staged,D,B,C,stageDriverFile;""")
  edit("    D=await import(pathToFileURL(image.driver.file));", "    D=await import(pathToFileURL(stageDriverFile??image.driver.file));")
  edit("    check(bindings);\n    const row=", """    check(bindings);
    if(stageClock&&request.role!=='typescript') {
      stageDriverFile=path.join(path.dirname(prep.image.driver.file),'typed-driver-stages.mjs');
      const receiptFile=stageDriverFile.replace(/\\.mjs$/,'.derivation.json');
      const receipt=JSON.parse(fs.readFileSync(receiptFile,'utf8'));
      assert.equal(receipt.kind,'phase62-private-driver-stage-derivation');
      assert.equal(receipt.complete,true);assert.equal(receipt.pass,true);assert.equal(receipt.exactInverse,true);
      assert.equal(receipt.source.sha256,prep.image.driver.sha256);assert.equal(receipt.source.file,prep.image.driver.file);
      assert.equal(receipt.output.file,stageDriverFile);
      for(const item of [receipt.source,receipt.output,receipt.producer,receipt.clock])verify(item);
      const clockFile=new URL('./clock.mjs',import.meta.url);assert.equal(identity(clockFile.pathname).sha256,receipt.clock.sha256);
      stageBindings.push(identity(receiptFile),receipt.source,receipt.output,receipt.producer,receipt.clock);
      report.stageDriver={receipt:identity(receiptFile),source:receipt.source,output:receipt.output,exactInverse:true};
    }
    const row=""")
  edit("    const book=B.book_nil();await B.book_load(book,row.source.file,'',new Map());B.book_valid(book);\n    assert.equal(book.hols,0);return {code:C.js_lib(book,true),observation:{checked:true,holes:book.hols,backend:'upstream'}};", """    const book=B.book_nil();
    const load=stageClock?.begin('typescript.book-load');
    try {await B.book_load(book,row.source.file,'',new Map())} finally {if(stageClock)stageClock.end(load)}
    const valid=stageClock?.begin('typescript.book-valid');
    try {B.book_valid(book)} finally {if(stageClock)stageClock.end(valid)}
    assert.equal(book.hols,0);
    let code;const emit=stageClock?.begin('typescript.js-lib');
    try {code=C.js_lib(book,true)} finally {if(stageClock)stageClock.end(emit)}
    return {code,observation:{checked:true,holes:book.hols,backend:'upstream'}};""")
  edit("      const imported=performance.now();await load(prep.image);report.hostImportMs=performance.now()-imported;", """      const importStage=stageClock?.begin('worker.host-import');
      const imported=performance.now();await load(prep.image);report.hostImportMs=performance.now()-imported;
      if(stageClock)stageClock.end(importStage);""")
  edit("      const apiStart=performance.now();", "      const apiStage=stageClock?.begin('worker.api-load');\n      const apiStart=performance.now();")
  edit("      report.apiLoadMs=request.role==='typescript'?0:performance.now()-apiStart;", "      report.apiLoadMs=request.role==='typescript'?0:performance.now()-apiStart;\n      if(stageClock)stageClock.end(apiStage);")
  edit("      const begin=performance.now();\n      try {first=await compile(row)} finally {report.firstRequestMs=performance.now()-begin}", """      const compileStage=stageClock?.begin('worker.compile');
      const begin=performance.now();
      try {first=await compile(row)} finally {report.firstRequestMs=performance.now()-begin;if(stageClock)stageClock.end(compileStage)}""")
  edit("    if(report.cleanTiming)await firstWindow();\n    else {", """    if(report.cleanTiming)await firstWindow();
    else if(stageClock) {
      assert.equal(config.warmRequests,0);
      const firstStage=stageClock.begin('worker.first-window');
      try {await firstWindow()} finally {stageClock.end(firstStage)}
      report.stages=stageClock.snapshot();assert.equal(report.stages.incomplete,0);
      report.stageScope='Private insertion-only host driver; same synchronous API calls and output oracle. Exclusive monotonic wall times partition the first window. Includes hook overhead; compare with separate clean workers, never clean speed claims.';
    } else {""")
  edit("    check(bindings);check(caseInputs);check(oldConfig.inputs);verify(prep.config);verify(request.preparation);verify(expected.output);", "    check(stageBindings);check(bindings);check(caseInputs);check(oldConfig.inputs);verify(prep.config);verify(request.preparation);verify(expected.output);")
 outputs[name]=text;rows.append(dict(parent=before,output=dict(file=str(out/name),sha256=hashlib.sha256(text.encode()).hexdigest()),edits=edits))
outputs['clock.mjs']=(HERE/'clock.mjs').read_text()
for row in prep['preparations']:
 assert row['success'];verify(row['result']);r=json.loads(Path(row['result']['file']).read_text())
 assert r==row['observation'] and r['complete'] and r['pass'] and r['stage']=='prepare'
 if r['role']=='typescript':continue
 source=Path(r['image']['driver']['file']);verify(r['image']['driver'])
 output=source.with_name('typed-driver-stages.mjs')
 assert not output.exists()
 subprocess.run([sys.executable,'-B',str(HERE/'derive-driver.py'),str(source),str(output),'--expected-sha',r['image']['driver']['sha256']],check=True)
 drivers.append(dict(role=r['role'],preparation=row['result'],derivation=identity(output.with_suffix('.derivation.json'))))
out.mkdir(parents=True)
for name,text in outputs.items():(out/name).write_text(text)
report=dict(kind='phase62-private-driver-stage-method',complete=True,dataOnly=True,targetExecuted=False,diagnosticOnly=True,
 preparation=preparation,parentDerivation=identity(parent/'derivation.json'),producer=identity(__file__),
 drivers=drivers,clock=identity(out/'clock.mjs'),derivations=rows,
 scope='Phase63 diagnostic successor only. Actual imported API entry observers retain owned private inspect paths. Stage mode reuses exact prepared images/Base caches and complete raw module byte oracles. Driver insertion inverse is verified; timer hooks are synchronous. TS book_load/book_valid/js_lib are coarse semantic boundaries and not falsely equated with Bend stage names. No generated target or compiler source is changed. Existing guarded serial CPU3 launch protocol retained.')
report['pass']=True;(out/'derivation.json').write_text(json.dumps(report,indent=2)+'\n')
print(json.dumps(dict(out=str(out),derivation=identity(out/'derivation.json'),drivers=len(drivers))))

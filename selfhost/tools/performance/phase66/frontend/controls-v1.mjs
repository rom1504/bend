// Root-only bounded control: CHECKED_ATTEMPT NEW_PHASE66_OUT.
// Real unmodified upstream parsing, with append-only diagnostic exports from B1.
import fs from 'node:fs';
import path from 'node:path';
import assert from 'node:assert/strict';
import {createHash} from 'node:crypto';
import {pathToFileURL} from 'node:url';
import {verifyAttempt} from '../../../development/workflow.mjs';

const project=path.resolve(import.meta.dirname,'../../../..');
const [attemptArg,outArg]=process.argv.slice(2),out=path.resolve(outArg||'.');
assert(attemptArg&&outArg&&out.startsWith(path.join(project,'build/phase66')+path.sep)&&!fs.existsSync(out));
fs.mkdirSync(out,{recursive:true});
const hash=x=>createHash('sha256').update(x).digest('hex'),pins=new Map();
function pin(file,want){file=fs.realpathSync(file);const bytes=fs.readFileSync(file),id={file,sha256:hash(bytes),bytes:bytes.length};if(want)assert.equal(id.sha256,want.sha256??want);if(pins.has(file))assert.deepEqual(id,pins.get(file));pins.set(file,id);return id;}
const list=xs=>xs.reduceRight((tail,head)=>({$:'Con',head,tail}),{$:'Nil'});
function array(xs){const out=[];for(;xs?.$==='Con';xs=xs.tail){assert(out.length<65536);out.push(xs.head);}assert.equal(xs?.$,'Nil');return out;}
const term=(tag,name='',kids=[])=>({$:'KTerm',tag,name,id:0,quant:0,kids:list(kids),removed:list([]),originBegin:0,originEnd:0});
const report={kind:'phase66-frontend-upstream-controls',complete:false,pass:false,scope:'Finite parse tree, namespace/display and exact source diagnostic controls; no checker, runtime, timing or full-language claim.',rows:[],helpers:[],inputs:[]};
function save(){report.inputs=[...pins.values()];fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n');}
save();
try{
  pin(import.meta.filename);pin(process.execPath);pin(new URL('../../../development/workflow.mjs',import.meta.url).pathname);
  const directory=fs.realpathSync(attemptArg),receipt=pin(path.join(directory,'attempt.json')),m=await verifyAttempt(directory);
  assert(m.checked&&m.config.strictExact);pin(m.api.file,m.api);pin(m.node.file,m.node);assert.equal(pin(process.execPath).sha256,m.node.sha256);
  const manifestFile=path.join(import.meta.dirname,'candidate-v1/manifest.json'),manifest=JSON.parse(fs.readFileSync(manifestFile));pin(manifestFile);
  for(const x of manifest.files)pin(path.join(m.snapshot.root,x.file.replace(/^selfhost\//,'')),x.afterSha256);
  const ref=path.join(project,'.bootstrap/upstream-phase66/bend2/bend.ts');pin(ref,manifest.referenceSha256);
  const B=await import(pathToFileURL(ref));assert.equal(typeof B.name_key,'function');
  const source=fs.readFileSync(m.api.file,'utf8'),parserSource=process.binding('natives')['internal/deps/acorn/acorn/dist/acorn'];
  const P={exports:{}};new Function('module','exports',parserSource)(P,P.exports);
  const parse=s=>P.exports.parse(s,{ecmaVersion:'latest',sourceType:'module'}),ast=parse(source),decls=ast.body.filter(x=>x.type==='FunctionDeclaration');
  assert.equal(decls.filter(x=>x.id.name==='run_loop').length,1);
  const arities={name_key:1,kp_name:2,kp_show:1},wrappers=[];
  for(const [name,n]of Object.entries(arities)){
    const symbol='$'+name+'$',found=decls.filter(x=>x.id.name===symbol);assert.equal(found.length,1,name);assert.equal(found[0].params.length,n,name+' arity');
    const args=Array.from({length:n},(_,i)=>'a'+i).join(',');wrappers.push(`${name}:(${args})=>run_loop(${symbol}(${args}))`);
  }
  const suffix='\nexport const phase66Diagnostic={'+wrappers.join(',')+'};\n',derived=source+suffix;parse(derived);assert.equal(derived.slice(0,source.length),source);
  const moduleFile=path.join(out,'diagnostic-api.mjs');fs.writeFileSync(moduleFile,derived,{flag:'wx'});pin(moduleFile);
  const loaded=await import(pathToFileURL(moduleFile)),api=loaded.default,D=loaded.phase66Diagnostic;
  report.candidate={attempt:receipt,api:m.api,derived:pin(moduleFile),appendOnly:true,parserSha256:hash(parserSource),upstream:manifest.upstream};save();

  const keys=['plain','Type.member','child:Type.member','dir/child:Box','../other:Type.member','child:one:two',':bare','child:',''];
  const aliases=[['C','child'],['D','dir/child'],['Root',''],['Earlier','child']];
  const imports=list(aliases.map(([alias,ns])=>term('Import',ns,[term('Ref',alias)])));
  for(const key of keys){assert.equal(D.name_key(key),B.name_key(key));report.helpers.push({id:'name_key '+key,pass:true});
    for(const ns of [null,'','child','dir/child','unrelated']){
      const env=ns===null?list([]):list([{$:'KPFile',namespace:ns,aliases:imports}]);
      const expected=B.name_show(ns===null?undefined:{str:'',ns,al:Object.fromEntries(aliases)},key),actual=D.kp_name(env,key);
      report.helpers.push({id:'name_show '+JSON.stringify([ns,key]),expected,actual,pass:actual===expected});assert.equal(actual,expected);
    }
  }save();

  const bit='type Bit is Data:\n  Off{}\n  On{}\n';
  const cases=[
    {id:'member-dot',files:{'main.bend':bit+'def Bit.value() -> Bit: On{}\ndef main() -> Bit: Bit.value()\n'}},
    {id:'alias',files:{'child.bend':bit+'def value() -> Bit: On{}\n','main.bend':'import child.bend as C\ndef main() -> C.Bit: C.value()\n'}},
    {id:'namespace-member-collision',files:{'child.bend':bit+'def value() -> Bit: On{}\n','main.bend':'import child.bend as C\ntype child.Bit is Data:\n  child.On{}\ndef main() -> C.Bit: C.On{}\n'}},
    {id:'member-in-module',files:{'dir/child.bend':bit+'def Bit.value() -> Bit: On{}\n','main.bend':'import dir/child.bend as C\ndef main() -> C.Bit: C.Bit.value()\n'}},
    {id:'relative-alias',files:{'a/child.bend':'import ../b/other.bend as D\ndef value() -> D.Bit: D.On{}\n','b/other.bend':bit,'main.bend':'import a/child.bend as C\nimport b/other.bend as D\ndef main() -> D.Bit: C.value()\n'}},
    {id:'alias-shadow',files:{'child.bend':bit+'def value() -> Bit: On{}\n','main.bend':'import child.bend as C\ndef C.value() -> Type: Data\ndef main() -> C.Bit: C.value()\n'}},
    {id:'imported-fill',files:{'child.bend':bit+'law value:\n  Bit\n','main.bend':'import child.bend as C\ndef C.value(): C.On{}\ndef main() -> C.Bit: C.value()\n'}},
    {id:'unknown-imported-ctor',files:{'child.bend':bit,'main.bend':'import child.bend as C\ndef f(x: C.Bit) -> C.Bit:\n  match x:\n    case C.Missing{}: C.On{}\n'}},
    {id:'imported-ctor-arity',files:{'child.bend':bit,'main.bend':'import child.bend as C\ndef f(x: C.Bit) -> C.Bit:\n  match x:\n    case C.On{a}: C.On{}\n'}},
    {id:'write-sugar',files:{'main.bend':'def f(a: Array<U32>) -> Array<U32>:\n  a[0] = 1;\n  a\n'}},
    {id:'write-call-statement',files:{'main.bend':'def f(a: Array<U32>) -> Array<U32>:\n  Array.set(U32, a, 0, 1);\n  a\n'}},
    {id:'write-call-value',files:{'main.bend':'def f(a: Array<U32>) -> Array<U32>:\n  Array.set(U32, a, 0, 1)\n'}},
    {id:'write-grouped-array',files:{'main.bend':'def f(a: Array<U32>) -> Array<U32>:\n  (a)[0] = 1;\n  a\n'}},
    {id:'match-def',files:{'main.bend':bit+'def value() -> Bit: On{}\ndef main() -> Bit:\n  match value:\n    case On{}: On{}\n'}},
    {id:'match-literal',files:{'main.bend':bit+'def main() -> Bit:\n  match On{}:\n    case On{}: On{}\n'}},
    {id:'match-numeric',files:{'main.bend':bit+'def main() -> Bit:\n  match 1:\n    case On{}: On{}\n'}},
    {id:'match-after-later-binder',files:{'main.bend':bit+'def f(a: Bit, b: Bit) -> Bit:\n  match b:\n    case On{}:\n      match a:\n        case On{}: On{}\n'}},
    {id:'match-consumed',files:{'main.bend':bit+'def f(a: Bit) -> Bit:\n  match a:\n    case On{}:\n      match a:\n        case On{}: On{}\n'}},
    {id:'match-spelling-utf16',files:{'main.bend':'# \u{1f600} before the spelling\n'+bit+'def f(a: Bit) -> Bit:\n  match a:\n    case On{}:\n      match (a):\n        case On{}: On{}\n'}},
  ];
  for(const c of cases){
    const dir=path.join(out,'fixtures',c.id),sources=[];let next=1;
    for(const [relative,text]of Object.entries(c.files)){const file=path.join(dir,relative);fs.mkdirSync(path.dirname(file),{recursive:true});fs.writeFileSync(file,text,{flag:'wx'});pin(file);sources.push(api.f_source_located({$:'FSource',name:file,path:file,text},next,next+text.length+1));next+=text.length+1;}
    const file=path.join(dir,'main.bend'),book=B.book_nil();let reference;
    try{await B.book_load(book,file,'',new Map());reference={accepted:true};}catch(error){assert.equal(error?.$,'Err');reference={accepted:false,error:B.err_show(error)};}
    const result=api.f_load_graph(file,list(sources)),candidate={accepted:result.error==='',...(result.error?{error:result.error}:{})};
    const row={id:c.id,reference,candidate,pass:false};report.rows.push(row);save();assert.deepEqual(candidate,reference,c.id+' parser outcome');
    if(reference.accepted){
      const defs=new Map(array(result.book).map(d=>[d.name,d])),names=[...new Set(book.order)];assert.deepEqual([...defs.keys()],names,c.id+' internal event names');
      row.definitions=[];
      for(const name of names){const got=defs.get(name),want=book.tlds[name];assert.equal(got.kind,want.$);
        const actual={type:D.kp_show(got.typ),value:got.kind==='Def'&&got.value.tag!=='Absent'?D.kp_show(got.value):null,constructors:array(got.ctors).map(d=>({name:d.name,type:D.kp_show(d.typ)}))};
        const expected={type:B.term_show(B.term_lower(want.T)),value:want.$==='Def'&&want.v!==null?B.term_show(B.term_lower(want.v)):null,constructors:want.$==='ADT'?want.c.map(d=>({name:d.k,type:B.term_show(B.term_lower(d.T))})):[]};
        row.definitions.push({name,actual,expected});save();assert.deepEqual(actual,expected,c.id+' '+name+' rendered AST');
      }
    }
    row.pass=true;save();
  }
  for(const id of pins.values())pin(id.file,id);report.complete=true;report.pass=true;save();
}catch(error){report.error={name:error.name,message:error.message,stack:error.stack};save();throw error;}

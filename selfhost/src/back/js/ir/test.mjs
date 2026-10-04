// Functional controls through the public j_library entry: no test-only IR ABI.
// Synthetic KDefs isolate lowering/pass/emission contracts, not frontend typing.
import fs from 'node:fs';
import path from 'node:path';
import assert from 'node:assert/strict';
import {pathToFileURL} from 'node:url';
import {createHash} from 'node:crypto';

const [attemptArg, outArg, ...flags] = process.argv.slice(2);
assert(attemptArg && outArg && flags.every(x=>['--expect-statements','--expect-folds'].includes(x)),
  'test.mjs CHECKED_ATTEMPT NEW_OUT [--expect-statements] [--expect-folds]');
const expectStatements=flags.includes('--expect-statements'), expectFolds=flags.includes('--expect-folds');
const attemptRoot = fs.realpathSync(attemptArg), out = path.resolve(outArg);
assert(!fs.existsSync(out), 'Output must be fresh');
fs.mkdirSync(out);
const attempt = JSON.parse(fs.readFileSync(path.join(attemptRoot,'attempt.json')));
assert.equal(attempt.checked,true);
const hash = file => createHash('sha256').update(fs.readFileSync(file)).digest('hex');
for (const key of ['api','runtime','base']) assert.equal(hash(attempt[key].file),attempt[key].sha256,key);
for (const key of Object.keys(process.env)) if (key.startsWith('BEND_')) delete process.env[key];
Object.assign(process.env,{BEND_TYPED_API:attempt.api.file,BEND_TYPED_RUNTIME:attempt.runtime.file,BEND_BASE:attempt.base.file});
const {loadApi} = await import(pathToFileURL(path.join(attempt.snapshot.root,'tools/typed-driver.mjs')));
const api = await loadApi();
assert.equal(typeof api.j_library,'function');

const list = xs => xs.reduceRight((tail,head)=>({$:'Con',head,tail}),{$:'Nil'});
const term = (tag,name='',kids=[],id=0,quant=0) =>
  ({$:'KTerm',tag,name,kids:list(kids),id,quant,removed:list([]),originBegin:0,originEnd:0});
const variable = id => term('Var','',[],id);
const ref = name => term('Ref',name);
const lam = (id,body,q=2) => term('Lam','',[body],id,q);
const all = (id,a,b,q=2) => term('All','',[a,b],id,q);
const apply = (f,x) => term('App','',[f,x]);
const bind = (id,value,q=2) => term('Bind','',[value],id,q);
const local = (bindings,body) => term('Let','',[...bindings,body]);
const ctor = (name,...args) => term('Ctr',name,args);
const numeral = n => n ? ctor('Succ',numeral(n-1)) : ctor('Zero');
const nat = term('ADT','Nat'), boxed = term('ADT','BoxData');
const fnType = all(1,nat,nat);
const def = (name,value,typ=fnType,kind='Def',ctors=[]) =>
  ({$:'KDef',name,value,typ,kind,arity:0,templates:0,ctors:list(ctors),native:false,unsafe:false});
const boxType = def('BoxData',term('Absent'),term('Typ'),'ADT',
  [{...def('Box',term('Absent'),all(900,nat,boxed),'Ctr'),arity:1}]);
const many = Array.from({length:65},(_,i)=>bind(100+i,variable(1)));
let nested = variable(164);
for (let i=64;i>=0;i--) nested=local([bind(100+i,variable(i?99+i:1))],nested);
const definitions = [boxType,
  def('identity',lam(1,variable(1))),
  def('erase',lam(10,numeral(9),0),all(10,nat,nat,0)),
  def('tick',numeral(1),nat),def('later',numeral(2),nat),
  def('parallel_shadow',lam(10,local([bind(10,numeral(4)),bind(11,variable(10))],variable(11)))),
  def('parallel_reverse',lam(10,local([bind(11,variable(10)),bind(10,numeral(4))],variable(11)))),
  def('lambda_shadow',lam(10,local([bind(11,variable(10))],lam(10,variable(11)))),all(10,nat,all(10,nat,nat))),
  def('nested_shadow',lam(10,local([bind(11,variable(10))],local([bind(10,numeral(4))],variable(11))))),
  def('escaping_capture',lam(10,local([bind(11,variable(10))],local([bind(10,numeral(4))],lam(12,variable(11))))),all(10,nat,all(12,nat,nat))),
  def('empty_let',lam(10,local([],variable(10)))),
  def('many_bindings',lam(1,local(many,variable(164)))),
  def('many_scopes',lam(1,nested)),
  // Constructor emission is opaque Legacy. Source-used y must keep its binder.
  def('legacy_alias',lam(10,local([bind(11,variable(10))],ctor('Box',variable(11)))),all(10,nat,boxed)),
  // A CallPlan retains the source spine even if its generic fallback changes.
  def('callplan_alias',lam(10,local([bind(11,variable(10))],apply(ref('identity'),variable(11))))),
  def('global_once',lam(10,local([bind(11,ref('tick'))],variable(11)))),
  def('global_twice',lam(10,local([bind(11,ref('tick')),bind(12,ref('tick'))],variable(11)))),
  def('global_capture',lam(10,local([bind(11,ref('tick'))],lam(12,variable(11)))),all(10,nat,all(12,nat,nat))),
  def('throw_order',lam(10,local([bind(11,ref('tick')),bind(12,ref('later'))],variable(11)))),
  def('erased_rhs',lam(10,local([bind(11,ref('tick'),0)],variable(10)))),
  def('erased_argument',apply(ref('erase'),ref('tick')),nat),
  def('identity_local',lam(10,local([bind(11,variable(10))],variable(11)))),
  def('identity_shadow',lam(10,local([bind(10,variable(10))],variable(10)))),
  def('identity_application',lam(10,local([bind(11,apply(ref('identity'),variable(10)))],variable(11)))),
  def('multiple_rhs',lam(10,local([bind(11,variable(10)),bind(12,ref('later'))],variable(11))))
];
const report = {kind:'composable-ir-functional-controls',complete:false,pass:false,
  attempt:path.join(attemptRoot,'attempt.json'),apiSha256:attempt.api.sha256,
  scope:'Synthetic KDefs through actual j_library and runtime; no frontend, timing or universal proof claim.',
  statementsRequired:expectStatements,constantFoldsRequired:expectFolds,checks:[]};
const save = () => fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n');
function check(name,action) {action();report.checks.push(name);console.log('PASS '+name);}
save();
try {
  const source = api.j_library(list(definitions)), file=path.join(out,'program.mjs');
  fs.writeFileSync(file,fs.readFileSync(attempt.runtime.file,'utf8')+'\n'+source,{flag:'wx'});
  report.moduleSha256=hash(file);
  report.statementTemporaries=(source.match(/const \$jir\d+=/g)||[]).length;
  if (expectStatements) assert(report.statementTemporaries>0,'Connected statement pass must execute');
  const module = await import(pathToFileURL(file)), library=module.default;
  for (const name of ['parallel_shadow','parallel_reverse','nested_shadow','empty_let','many_bindings','many_scopes','callplan_alias','identity_local','identity_shadow','identity_application']) {
    check(name,()=>{for(const x of [8n,3n,8n])assert.equal(library[name](x),x);});
  }
  for (const name of ['lambda_shadow','escaping_capture']) check(name,()=>{
    const first=library[name](8n),second=library[name](3n);
    for(const input of [4n,9n,4n]) {assert.equal(module.call(first,[input]),8n);assert.equal(module.call(second,[input]),3n);}
  });
  check('legacy-alias-binder-preserved',()=>{
    for(const input of [8n,3n]) {const value=library.legacy_alias(input);assert.equal(value.$,'Box');assert.equal(value.a[0],input);}
  });
  const setGlobal = (name,code) => {module.G[name]={arity:0,code,env:null,bound:[]};};
  check('global-singleton-evaluated-once',()=>{
    let count=0;setGlobal('tick',()=>BigInt(++count));
    assert.equal(library.global_once(0n),1n);assert.equal(library.global_once(0n),2n);assert.equal(count,2);
  });
  check('global-alias-not-duplicated-or-eliminated',()=>{
    let count=0;setGlobal('tick',()=>BigInt(++count));
    assert.equal(library.global_twice(0n),1n);assert.equal(count,2);
  });
  check('global-capture-snapshots',()=>{
    let count=0;setGlobal('tick',()=>BigInt(++count));
    const first=library.global_capture(0n),second=library.global_capture(0n);assert.equal(count,2);
    assert.equal(module.call(first,[17n]),1n);assert.equal(module.call(second,[17n]),2n);
    assert.equal(module.call(first,[3n]),1n);assert.equal(count,2);
  });
  check('first-rhs-throw-suppresses-later-effects',()=>{
    const token=new Error('IR first RHS sentinel'),events=[];
    setGlobal('tick',()=>{events.push('first');throw token;});
    setGlobal('later',()=>{events.push('later');return 2n;});
    assert.throws(()=>library.throw_order(0n),error=>error===token);assert.deepEqual(events,['first']);
  });
  check('erased-rhs-and-argument-stay-delayed',()=>{
    setGlobal('tick',()=>{throw new Error('erased computation ran');});
    assert.equal(library.erased_rhs(8n),8n);assert.equal(library.erased_argument(),9n);
  });
  check('multi-rhs-retains-unused-evaluation',()=>{
    let count=0;setGlobal('later',()=>{count++;return 2n;});
    assert.equal(library.multiple_rhs(8n),8n);assert.equal(count,1);
  });
  // Exact same primitive-owner/telescope contract as test-u32 and Phase29
  // guards. Native flags describe synthetic KDefs, not frontend acceptance.
  const type = name => term('ADT',name), u32=type('U32'), f32=type('F32');
  const literal = (number,kind='U32') => ({$:'KLiteral',kind,number,text:'',originBegin:0,originEnd:0});
  const native = (name,kind='Def',ctors=[],typ=term('Typ'),arity=0) =>
    ({...def(name,term('Absent'),typ,kind,ctors),native:true,arity});
  const owners = [['U32',['U32']],['Word.Nil',['WNil']],['Word.Con',['WCon']],
    ['Bool',['True','False']],['Nat',['Zero','Succ']],['F32',['F32']]];
  const ownerRows = () => [...owners.map(([name,cs])=>native(name,'ADT',cs.map(c=>native(c,'Ctr')))),native('Word')];
  const unary = new Set(['inc','not','shl','shr']);
  const names = ['add','sub','and','or','xor','inc','not','shl','shr','mul','div','mod'];
  const operations = names.map(name=>native('U32.'+name,'Def',[],
    unary.has(name)?all(500,u32,u32):all(500,u32,all(501,u32,u32)),unary.has(name)?1:2));
  operations.push(native('F32.add','Def',[],all(500,f32,all(501,f32,f32)),2));
  const operation = (name,...args) => args.reduce((f,x)=>apply(f,x),ref(name));
  const points = [
    ['add',[4294967295,1],0],['sub',[0,1],4294967295],
    ['and',[2863311530,1431655765],0],['or',[2863311530,1431655765],4294967295],
    ['xor',[4294967295,4294967295],0],['inc',[4294967295],0],
    ['not',[0],4294967295],['shl',[2147483648],0],['shr',[4294967295],2147483647]
  ];
  const constants = points.map(([name,args])=>def('constant_'+name,operation('U32.'+name,...args.map(x=>literal(x))),u32));
  constants.push(def('constant_nested',operation('U32.add',operation('U32.sub',literal(0),literal(1)),literal(1)),u32));
  const scalarRows = [...ownerRows(),...operations,...constants,
    def('variable_add',lam(600,operation('U32.add',variable(600),literal(0))),all(600,u32,u32)),
    def('effect',term('Absent'),u32),
    def('unknown_add',operation('U32.add',ref('effect'),literal(0)),u32),
    def('constant_mul',operation('U32.mul',literal(2),literal(3)),u32),
    def('constant_div',operation('U32.div',literal(7),literal(2)),u32),
    def('constant_mod',operation('U32.mod',literal(7),literal(2)),u32),
    def('constant_float',operation('F32.add',literal(0x3fc00000,'F32'),literal(0x40200000,'F32')),f32)
  ];
  const scalarSource=api.j_library(list(scalarRows)),scalarFile=path.join(out,'scalar-controls.mjs');
  fs.writeFileSync(scalarFile,fs.readFileSync(attempt.runtime.file,'utf8')+'\n'+scalarSource,{flag:'wx'});
  report.scalarModuleSha256=hash(scalarFile);
  const scalar=await import(pathToFileURL(scalarFile));
  for(const [name,args,expected] of points) check('literal-fold-'+name,()=>assert.equal(scalar.default['constant_'+name](),expected));
  check('nested-literal-fold',()=>assert.equal(scalar.default.constant_nested(),0));
  const assignments=scalarSource.split('\n');
  const emitted = name => {const rows=assignments.filter(s=>s.startsWith('G['+JSON.stringify(name)+']='));assert.equal(rows.length,1,name);return rows[0];};
  report.foldedLiteralSites=[...points.map(([name,,expected])=>[name,expected]),['nested',0]]
    .filter(([name,expected])=>emitted('constant_'+name).includes('return '+expected+';')&&!emitted('constant_'+name).includes('/* primitive */')).map(([name])=>name);
  if(expectFolds) check('all-nine-operations-and-nesting-folded',()=>assert.equal(report.foldedLiteralSites.length,10));
  check('variable-operand-not-folded',()=>{
    assert.equal(scalar.default.variable_add(17),17);assert.equal(scalar.default.variable_add(4294967295),4294967295);
    let coercions=0;assert.equal(scalar.default.variable_add({valueOf(){coercions++;return 17;}}),17);assert.equal(coercions,1);
    assert(emitted('variable_add').includes('/* primitive */'));
  });
  check('unknown-effect-operand-evaluated-once',()=>{
    let count=0;scalar.G.effect={arity:0,code:()=>{count++;return 17;},env:null,bound:[]};
    assert.equal(scalar.default.unknown_add(),17);assert.equal(count,1);
    const token=new Error('IR operand sentinel');scalar.G.effect.code=()=>{throw token;};
    assert.throws(()=>scalar.default.unknown_add(),e=>e===token);
  });
  check('mul-refuses-folding-and-observes-Math-imul',()=>{
    assert.equal(scalar.default.constant_mul(),6);assert(emitted('constant_mul').includes('Math.imul'));
    const original=Math.imul;let calls=0;
    try {Math.imul=(a,b)=>{calls++;assert.equal(a,2);assert.equal(b,3);return 123;};assert.equal(scalar.default.constant_mul(),123);assert.equal(calls,1);}
    finally {Math.imul=original;}
  });
  check('div-and-mod-remain-runtime-operations',()=>{
    assert.equal(scalar.default.constant_div(),3);assert.equal(scalar.default.constant_mod(),1);
    assert(emitted('constant_div').includes('Math.floor'));assert(emitted('constant_mod').includes('%'));
    const original=Math.floor;
    try {Math.floor=()=>123;assert.equal(scalar.default.constant_div(),123);} finally {Math.floor=original;}
  });
  check('float-refuses-folding-and-observes-Math-fround',()=>{
    assert.equal(scalar.default.constant_float(),4);assert(emitted('constant_float').includes('Math.fround'));
    const original=Math.fround;let calls=0;
    try {Math.fround=()=>{calls++;return 123.5;};assert.equal(scalar.default.constant_float(),123.5);assert(calls>0);} finally {Math.fround=original;}
  });
  // Same spelling with a non-native implementation must execute that body.
  const forgedAdd={...operations.find(d=>d.name==='U32.add'),native:false,
    value:lam(500,lam(501,literal(123)))};
  const forgedSource=api.j_library(list([...ownerRows(),forgedAdd,
    def('forged',operation('U32.add',literal(1),literal(2)),u32)]));
  const forgedFile=path.join(out,'forged-primitive.mjs');
  fs.writeFileSync(forgedFile,fs.readFileSync(attempt.runtime.file,'utf8')+'\n'+forgedSource,{flag:'wx'});
  const forged=await import(pathToFileURL(forgedFile));
  check('primitive-name-without-native-proof-refused',()=>assert.equal(forged.default.forged(),123));
  check('inputs-unchanged',()=>{
    for (const key of ['api','runtime','base']) assert.equal(hash(attempt[key].file),attempt[key].sha256,key);
  });
  report.complete=report.pass=true;
} catch(error) {report.error=error.stack;process.exitCode=1;}
save();
console.log(JSON.stringify({complete:report.complete,pass:report.pass,checks:report.checks.length,
  statementTemporaries:report.statementTemporaries,error:report.error}));

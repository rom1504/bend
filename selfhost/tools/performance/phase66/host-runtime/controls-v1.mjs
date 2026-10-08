// Root-run only, under the Phase66 serial resource supervisor. No timing claim.
// Actual checked compiler + three upstream fixtures; appended private exports
// only for small canonical type-graph diagnostics, never production admission.
import fs from 'node:fs';
import path from 'node:path';
import assert from 'node:assert/strict';
import {createHash} from 'node:crypto';
import {pathToFileURL} from 'node:url';
import {spawnSync} from 'node:child_process';

const [attemptArg,outArg]=process.argv.slice(2);
assert(attemptArg&&outArg,'Usage: controls-v1.mjs CHECKED_ATTEMPT FRESH_OUT');
const root=path.resolve(import.meta.dirname,'../../../../..'),out=path.resolve(outArg);
assert(out.startsWith(path.join(root,'selfhost/build/phase66')+path.sep)&&!fs.existsSync(out));
fs.mkdirSync(out,{recursive:true});
const hash=x=>createHash('sha256').update(x).digest('hex'),inputs=new Map();
function pin(file,want){file=fs.realpathSync(file);const bytes=fs.readFileSync(file),p={file,sha256:hash(bytes),bytes:bytes.length};if(want?.sha256)assert.equal(p.sha256,want.sha256,file);if(want?.canonicalPath)assert.equal(file,want.canonicalPath);if(inputs.has(file))assert.deepEqual(p,inputs.get(file));inputs.set(file,p);return p;}
const report={kind:'phase66-host-runtime-controls',complete:false,pass:false,diagnosticOnly:true,execution:{node:process.version,execArgv:process.execArgv},cases:[]};
const save=()=>fs.writeFileSync(path.join(out,'report.json'),JSON.stringify({...report,inputs:[...inputs.values()]},null,2)+'\n');
save();
function check(id,f){const row={id,pass:false};report.cases.push(row);save();Object.assign(row,f()??{});row.pass=true;save();}
const list=xs=>xs.reduceRight((tail,head)=>({$:'Con',head,tail}),{$:'Nil'}),nil=()=>list([]);
function array(xs){const a=[];while(xs?.$==='Con'){assert(a.length<65536);a.push(xs.head);xs=xs.tail;}assert.equal(xs?.$,'Nil');return a;}
const term=(tag,name='',kids=[],quant=0,id=0)=>({$:'KTerm',tag,name,id,quant,kids:list(kids),removed:nil(),originBegin:0,originEnd:0});
const atom=()=>term('Absent'),adt=(name,args=[])=>term('ADT',name,args),all=(a,b,name='x',q=1)=>term('All',name,[a,b],q);
const def=(name,typ,arity=0,kind='Def',ctors=[])=>({$:'KDef',name,kind,arity,templates:0,typ,value:atom(),ctors:list(ctors),native:false,unsafe:false});
try{
  pin(import.meta.filename);pin(process.execPath);
  report.attempt=pin(path.join(attemptArg,'attempt.json'));
  const m=JSON.parse(fs.readFileSync(report.attempt.file,'utf8'));
  assert.equal(m.kind,'bend-development-attempt');assert.equal(m.checked,true);
  for(const {frozen} of m.snapshot.sources)pin(frozen.file,frozen);
  for(const p of m.artifacts)pin(p.file,p);
  for(const key of ['api','runtime','base','node'])pin(m[key].file,m[key]);
  assert.equal(process.version,m.node.version);assert.equal(pin(process.execPath).sha256,m.node.sha256);
  const workflow=path.join(m.snapshot.root,'tools/development/workflow.mjs');pin(workflow);
  const {verifyAttempt}=await import(pathToFileURL(workflow));
  await verifyAttempt(path.resolve(attemptArg));
  const hostManifest=JSON.parse(fs.readFileSync(pin(path.join(import.meta.dirname,'host-converters-v2.json')).file,'utf8'));
  pin(path.join(m.snapshot.root,'src/back/js/direct/host.bend'),{sha256:hostManifest.files[0].afterSha256});
  pin(path.join(m.snapshot.root,'src/runtime/js/direct.mjs'),{sha256:'7fe4fbb3ddfdd3c7ea9ccd8d71cecb8f3ce51cd678a8fb7d95fd02cc70aba575'});
  assert.equal(m.config.upstream,fs.realpathSync(path.join(root,'selfhost/.bootstrap/upstream-phase66')));
  const upstream=path.join(root,'selfhost/.bootstrap/upstream-phase66');
  report.image={api:m.api,base:m.base,artifactKind:m.artifactKind};
  // The complete frozen snapshot is already pinned. Clone only the executable
  // host closure; preparation and compilation cannot write the checked attempt.
  const project=path.join(out,'project');
  function copy(relative){const from=path.join(m.snapshot.root,relative),to=path.join(project,relative);const p=pin(from);fs.mkdirSync(path.dirname(to),{recursive:true});fs.copyFileSync(from,to);pin(to,p);}
  function copyTree(relative){for(const e of fs.readdirSync(path.join(m.snapshot.root,relative),{withFileTypes:true})){const next=path.join(relative,e.name);if(e.isDirectory())copyTree(next);else{assert(e.isFile());copy(next);}}}
  for(const name of ['typed-driver','assemble','native-build','node-resource-args','compiler-abi','base-cache-graph'])copy('tools/'+name+'.mjs');
  copy('src/compiler.json');copy('src/runtime.mjs');copyTree('src/runtime/js');
  for(const key of Object.keys(process.env))if(key.startsWith('BEND_')||key==='NODE_OPTIONS')delete process.env[key];
  Object.assign(process.env,{BEND_UPSTREAM:upstream,BEND_BASE:m.base.file,BEND_TYPED_API:m.api.file,BEND_TYPED_RUNTIME:path.join(project,'src/runtime.mjs')});
  const D=await import(pathToFileURL(path.join(project,'tools/typed-driver.mjs'))),originalModule=await import(pathToFileURL(m.api.file)),api=await D.loadApi();
  assert.equal(D.project,project);assert.equal(api,originalModule.default);assert(!originalModule.G,'Named layout required');
  const cached=await D.prepareBase(api,{backendProducts:false});
  assert.equal(cached.preparedWorld?.state.ready,true);
  const base=array(cached.preparedWorld.checked).reverse();
  report.preparation={preparedWorld:true,checkedDefinitions:base.length,privateClone:project};save();

  const runtime=path.join(project,'src/runtime/js/direct.mjs'),runtimeText=fs.readFileSync(runtime,'utf8');
  const R=new Function(runtimeText+'\nreturn {run_tail,run_loop,run_clo,run_lib,jd_tail,f32_bits,f32_from_bits,nat_host};')();
  check('runtime-unary-tail-array-argument',()=>{const arg=[1,2,3];assert.equal(R.run_loop(R.run_tail(x=>{assert.equal(x,arg);return x.length;},arg)),3);});
  check('runtime-unary-deep-closure',()=>{const f=R.run_clo(n=>n?R.run_tail(f,n-1):17);assert.equal(f(100000),17);});
  check('runtime-variadic-and-nullary-tail',()=>{const f=(a,b,n)=>n?R.jd_tail(f,[a+1,b+2,n-1]):[a,b];assert.deepEqual(R.run_loop(R.jd_tail(f,[0,0,100000])),[100000,200000]);assert.equal(R.run_loop(R.jd_tail(()=>11,[])),11);});
  check('runtime-partial-library-arity',()=>{const events=[],f=R.run_lib((a,b,c)=>{events.push([a,b,c]);return a+b+c;},3);const g=f(2),h=g(3);assert.deepEqual(events,[]);assert.equal(h(4),9);assert.equal(f(1,2)(3),6);assert.deepEqual(events,[[2,3,4],[1,2,3]]);});
  check('runtime-nan-payload',()=>{const values=[0x7fc12345,0xffc54321,0x7f800001,0xff800001,0x80000000,0x3f800000];for(const u of values){const input=new Uint32Array(1);input[0]=u;const x=new Float32Array(input.buffer)[0],store=new Float32Array(1);store[0]=x;const expected=new Uint32Array(store.buffer)[0];assert.equal(R.f32_bits(x),expected);assert.equal(R.f32_bits(R.f32_from_bits(u)),expected);}return {values:values.length,oracle:'independent typed-array store, including first cold conversion'};});

  // Export only existing lexical functions from a pinned copy of the exact API.
  const original=fs.readFileSync(m.api.file,'utf8'),parserSource=process.binding('natives')['internal/deps/acorn/acorn/dist/acorn'],parser={exports:{}};
  new Function('module','exports',parserSource)(parser,parser.exports);
  const parse=s=>parser.exports.parse(s,{ecmaVersion:'latest',sourceType:'module'}),tree=parse(original);
  for(const name of ['run_loop','nat_host','$jd_host$','$jd_marshal$','$jd_name$','$jd_host_export$'])assert.equal(tree.body.filter(n=>n.type==='FunctionDeclaration'&&n.id.name===name).length,1,name);
  const suffix='\nexport const phase66HostProbe={host:(b,d)=>run_loop($jd_host$(b,d)),marshal:(b,t,o)=>run_loop($jd_marshal$(b,t,o)),name:n=>run_loop($jd_name$(n)),exported:(b,d)=>run_loop($jd_host_export$(b,d,0))};\n';
  assert(!original.includes('phase66HostProbe'));parse(original+suffix);
  const derivative=path.join(out,'diagnostic-api.mjs');fs.writeFileSync(derivative,original+suffix,{flag:'wx'});pin(derivative);
  const probe=(await import(pathToFileURL(derivative))).phase66HostProbe;
  report.privateProbe={api:pin(derivative),parent:m.api,suffixSha256:hash(suffix),parserSourceSha256:hash(parserSource),publicAbiUnchanged:true};save();
  const U=adt('U32'),N=adt('Nat'),AN=adt('Array',[N]),B=adt('P66Box'),P=adt('P66Pair'),F=adt('P66Function');
  const kind=term('Typ','',[term('Qua','',[],0)]);
  const extras=[def('P66Box',kind,0,'ADT',[def('P66BoxCtor',all(N,B,'payload'),1,'Ctr')]),def('P66Pair',kind,0,'ADT',[def('P66PairCtor',all(B,all(B,all(N,P,'n'),'right'),'left'),3,'Ctr')]),def('P66Function',kind,0,'ADT',[def('P66FunctionCtor',all(all(N,N),F,'callback'),1,'Ctr')])];
  const book=api.book_context(list([...extras,...base]));
  let serial=0;
  function wrapper(ty,arity,body){const d=def('p66_probe_'+serial++,ty,arity),source=probe.host(book,d);assert(!source.includes('JD_UNSUPPORTED'));const file=path.join(out,d.name+'.js');fs.writeFileSync(file,source,{flag:'wx'});pin(file);return new Function('run_loop','nat_host',probe.name(d.name),'return ('+source+');')(R.run_loop,R.nat_host,body);}
  function marshal(ty,outward){const source=probe.marshal(book,ty,outward);assert(source&&!source.includes('JD_UNSUPPORTED'));return new Function('nat_host','return ('+source+');')(R.nat_host);}
  check('wrapper-array-identity-and-copyback',()=>{const a=[2n,3n];const f=wrapper(all(AN,U),1,b=>{assert.equal(b,a);assert.deepEqual(b,[2,3]);b[0]=7;return 5;});assert.equal(f(a),5);assert.deepEqual(a,[7n,3n]);});
  check('wrapper-adt-copy-and-nat-result',()=>{const input={$:'P66BoxCtor',payload:9n};const f=wrapper(all(B,N),1,b=>{assert.notEqual(b,input);assert.equal(b.payload,9);b.payload=21;return b.payload;});assert.equal(f(input),21n);assert.deepEqual(input,{$:'P66BoxCtor',payload:9n});});
  check('wrapper-curried-nat-callback',()=>{const events=[],f=wrapper(all(all(U,all(N,N)),U),1,g=>{events.push('body');const h=g(4);events.push('partial');return h(5);});assert.equal(f(x=>{events.push('callback:'+x);return n=>{assert.equal(n,5n);events.push('leaf');return n+BigInt(x);};}),9);assert.deepEqual(events,['body','callback:4','partial','leaf']);});
  check('wrapper-function-leaf-in-adt',()=>{const events=[],input={$:'P66FunctionCtor',callback:n=>{assert.equal(n,6n);events.push('callback');return n+1n;}},f=wrapper(all(F,U),1,box=>{assert.notEqual(box,input);assert.notEqual(box.callback,input.callback);assert.equal(box.callback(6),7);return 7;});assert.equal(f(input),7);assert.deepEqual(events,['callback']);});
  check('wrapper-export-partial-arity',()=>{const d=def('P66:sum',all(N,all(N,N)),2),text=probe.exported(book,d),events=[];assert(text.startsWith('"P66.sum":run_lib('));const exports=new Function('run_lib','run_loop','nat_host',probe.name(d.name),'return ({'+text+'});')(R.run_lib,R.run_loop,R.nat_host,(a,b)=>{events.push([a,b]);return a+b;});const partial=exports['P66.sum'](2n);assert.deepEqual(events,[]);assert.equal(partial(3n),5n);assert.deepEqual(events,[[2,3]]);});
  check('marshal-composite-lifo-and-immediate-scalar',()=>{const events=[],box=id=>({$:'P66BoxCtor',get payload(){events.push(id);return 2;}}),input={$:'P66PairCtor',left:box('left'),right:box('right'),n:3};const value=marshal(P,true)(input);assert.deepEqual(events,['right','left']);assert.notEqual(value,input);assert.notEqual(value.left,input.left);assert.notEqual(value.right,input.right);assert.equal(value.n,3n);assert.equal(value.left.payload,2n);assert.equal(value.right.payload,2n);});
  check('marshal-immediate-failure-before-queued-work',()=>{const events=[],box=id=>({$:'P66BoxCtor',get payload(){events.push(id);return 2;}}),input={$:'P66PairCtor',left:box('left'),right:box('right'),n:'invalid bigint'};assert.throws(()=>marshal(P,true)(input),SyntaxError);assert.deepEqual(events,[]);});
  check('marshal-unknown-tag-refusal',()=>{assert.throws(()=>marshal(B,true)({$:'Wrong',payload:3}),e=>String(e).includes('P66Box has no tag Wrong'));});

  // Source fixtures are upstream conformance, unlike the private graph probes.
  for(const id of ['marshal_array_depth','marshal_closure','marshal_native_forms']){
    const row={id:'source-'+id,pass:false};report.cases.push(row);save();
    const source=path.join(upstream,'tests/io',id+'.bend');row.source=pin(source);
    for(const ext of ['.js','.c']){const f=path.join(upstream,'tests/io',id+ext);if(fs.existsSync(f))pin(f);}
    const expected=fs.readFileSync(source,'utf8').split('\n').filter(s=>s.startsWith('#|')).map(s=>s.slice(2)).join('\n')+'\n';
    const compiled=await D.inspect(source,{mode:'program',backend:'direct'});
    row.compilation={status:compiled.status,phase:compiled.phase,diagnostic:compiled.diagnostic,checked:compiled.checked};save();
    assert.equal(compiled.status,'ok',compiled.diagnostic);assert.equal(compiled.checked,true);
    for(const file of compiled.files??[])pin(file);
    const file=path.join(out,id+'.mjs');fs.writeFileSync(file,compiled.code,{flag:'wx'});row.module=pin(file);
    const execution=spawnSync(process.execPath,['--stack-size=4096','--max-old-space-size=1024',file],{cwd:path.dirname(source),env:process.env,encoding:'utf8',timeout:30000,maxBuffer:1024*1024});
    row.execution={status:execution.status,signal:execution.signal,error:execution.error?.message,stdout:execution.stdout,stderr:execution.stderr};save();
    assert.ifError(execution.error);assert.equal(execution.signal,null);assert.equal(execution.status,0);assert.equal(execution.stdout,expected);assert.equal(execution.stderr,'');row.pass=true;save();
  }
  for(const p of inputs.values())pin(p.file,p);
  await verifyAttempt(path.resolve(attemptArg));
  report.inputsUnchanged=true;report.count=report.cases.length;report.complete=report.pass=true;
}catch(error){report.error={name:error?.name,message:String(error?.message??error),stack:error?.stack};process.exitCode=1;}
save();console.log(JSON.stringify({complete:report.complete,pass:report.pass,count:report.count,error:report.error}));

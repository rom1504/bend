import fs from 'node:fs';
import path from 'node:path';
import {spawnSync} from 'node:child_process';
import {isDeepStrictEqual} from 'node:util';
import {pathToFileURL, fileURLToPath} from 'node:url';
import {pin, verify} from '../../../selfhost/tools/build/hosted.mjs';

if(!/^Cpus_allowed_list:\s*3$/m.test(fs.readFileSync('/proc/self/status','utf8')))throw Error('CPU3 guard required');
const args=Object.fromEntries(Array.from({length:(process.argv.length-2)/2},(_,i)=>process.argv.slice(2+i*2,4+i*2)));
const out=path.resolve(args['--out']);
fs.mkdirSync(out,{recursive:false});
const apiReceipt=pin(path.resolve(args['--api'])), auth=JSON.parse(fs.readFileSync(apiReceipt.file));
if(!auth.complete||!auth.checked||auth.error) throw Error('checked API required');
verify(auth.api); verify(auth.source);
const api=(await import(pathToFileURL(auth.api.file))).default;
const assets=JSON.parse(fs.readFileSync('selfhost/build/phase194/assets.json'));
const as=assets.assets.assembler, cc=assets.assets.linker;
verify(as); verify(cc);
const policy=assets.toolchains.x86;
const typ={$:'N111U64'}, u32={$:'N111U32'}, loc=name=>({$:'N111Local',name});
const c=n=>({$:'N111Const',lo:Number(BigInt(n)&0xffffffffn),hi:Number(BigInt(n)>>32n)});
const ctor=name=>({$:'N111CtorId',name});
const val=v=>typeof v==='string'?loc(v):typeof v==='object'?v:c(v);
const bin=(name,op,l,r,t=typ)=>({$:'P113DScalar',stmt:{$:'N111Bin',name,typ:t,op,left:val(l),right:val(r)}});
const set=(name,v,t=typ)=>({$:'P113DScalar',stmt:{$:'N111Set',name,typ:t,value:val(v)}});
const iff=(cond,yes,no)=>({$:'P113DIf',condition:loc(cond),yes,no});
const ret=(...args)=>({$:'P113DResult',values:args.map(val)});
const again=(...args)=>({$:'P113DAgain',values:args.map(val)});
const call=symbol=>({$:'P113DScalar',stmt:{$:'N111Call',name:'unused',typ,symbol,args:[]}});
function bend(x) {
  if(Array.isArray(x)) return x.reduceRight((tail,head)=>({$:'Con',head:bend(head),tail}),{$:'Nil'});
  if(x&&typeof x==='object') return Object.fromEntries(Object.entries(x).map(([k,v])=>[k,bend(v)]));
  return x;
}
const ids=api.p198a_test_ids();
const cases=[], controls=[];
const baseParams=['state','__x181_result_out','fuel','word','data'];
const packed=(173n<<40n)|(1n<<56n), full=0xfedcba9876543210n;
function make(kind) {
  const tag=kind==='tag', wrong=kind==='else', raw=kind==='exact';
  const k=tag?packed:raw?full:9;
  const stable=[set('nextword',k),set('nextdata','data')];
  const other=[set('nextword','word'),bin('nextdata','add','data',1)];
  const guard=tag?[bin('t','shr','word',40),bin('t','and','t',65535),bin('b','eq','t',ctor('control-tag'))]:
    [bin('b','eq','word',wrong?7:k)];
  const pre=[bin('pred','sub','fuel',1)];
  if(tag)pre.push({$:'P113DScalar',stmt:{$:'N111Alloca',name:'fixed',bytes:24,align:8}});
  const choice=iff('b',wrong?other:stable,wrong?stable:other);
  const tail=again('pred','nextword','nextdata');
  const positive=[...pre,...guard,choice,tail];
  const no=tag?[bin('z','ne','fuel',0),iff('z',positive,[ret(0,0)])]:positive;
  const root=[bin('z','eq','fuel',0),iff('z',[ret('word','data')],no)];
  return {params:baseParams.slice(),setup:[],root,positive,choice,stable,other,guard,tail};
}
function test(label,expected,create,alter=()=>{},emit=false) {
  const x=make(create);alter(x);
  const actual=api.x198a_body(bend(x.root),bend(x.params),bend(x.setup),ids);
  const base=bend(x.root);
  if(expected) x.stable.push(set('pred',0));
  const wanted=expected?bend(x.root):base;
  if(!isDeepStrictEqual(actual,wanted)){
    fs.writeFileSync(path.join(out,'refusal.json'),JSON.stringify({label,actual,wanted,base,passed:controls},null,2));
    throw Error('unexpected IR '+label);
  }
  controls.push({label,changed:!isDeepStrictEqual(actual,base),expected});
  if(emit) cases.push({label,params:bend(x.params),body:base});
}
test('packed constructor predicate',true,'tag',undefined,true);
test('64-bit scalar terminal code',true,'exact',undefined,true);
test('canonicalizing false arm',true,'else',undefined,true);
test('alternate fuel position',true,'exact',x=>{
  x.params.splice(2,2,'word','fuel');x.tail.values.splice(0,2,loc('nextword'),loc('pred'));
},true);
test('false arm canonical result high bits',true,'else',x=>{x.stable[0].stmt.value=c(full);});
test('captured copy before reassignment',true,'tag',x=>{
  x.stable.splice(0,2,set('scratch1','data'),set('nextdata','scratch1'),set('scratch1',123),set('nextword',packed));
});
const refusals={
  'zero arm observes an unrelated local':x=>{x.root[1].yes=[ret('undetermined','data')];},
  'setup present':x=>{x.setup.push(set('once',7));},
  'compared fuel redefined':x=>{x.root[0].stmt.name='fuel';x.root[1].condition=loc('fuel');},
  'positive complement tests another value':x=>{x.root[1].no[0].stmt.left=loc('data');},
  'reassigned formal in prelude':x=>{x.positive[0].stmt.name='data';x.tail.values[0]=loc('data');},
  'fuel width':x=>{x.positive[0].stmt.typ=u32;},
  'counter subtracts two':x=>{x.positive[0].stmt.right=c(2);},
  'overwritten predecessor in tag prefix':x=>{x.guard[0].stmt.name='pred';},
  'alloca overlaps parameter':x=>{x.positive[1].stmt.name='word';},
  'alloca overlaps arm result':x=>{x.positive[1].stmt.name='nextdata';},
  'truncated shifted constant gives other tag':x=>{x.stable[0].stmt.value=c(packed^(1n<<40n));},
  'unknown constructor identity':x=>{x.guard[2].stmt.right=ctor('missing');},
  'shift count wraps on x86':x=>{x.guard[0].stmt.right=c(104);},
  'unchecked guard effect':x=>{x.positive.splice(3,0,call('p111_rt_keep'));},
  'data-dependent shift':x=>{x.guard[0].stmt.right=loc('data');},
  'fuel used by guard':x=>{x.guard[0].stmt.left=loc('fuel');},
  'load on absorbing path':x=>{x.stable.push({$:'P113DScalar',stmt:{$:'N111Load',name:'value',typ,base:loc('state'),offset:0}});},
  'ownership on absorbing path':x=>{x.stable.push(call('p111_rt_sink'));},
  'published store':x=>{x.stable.push({$:'P113DScalar',stmt:{$:'N111Store',typ,base:loc('state'),offset:0,value:c(1)}});},
  'fuel carried to result':x=>{x.stable[1].stmt.value=loc('fuel');},
  'predecessor observed by result':x=>{x.stable[1].stmt.value=loc('pred');},
  'word copied from another formal':x=>{x.stable[1].stmt.value=loc('word');},
  'rebinding incoming data':x=>{x.stable.push(set('data',0));},
  'arm overwrites backedge fuel':x=>{x.stable.push(set('pred',3));},
  'backedge arity':x=>{x.tail.values.pop();},
  'backedge retains original fuel':x=>{x.tail.values[0]=loc('fuel');},
  'shared continuation observes predecessor':x=>{x.positive.splice(-1,0,set('published','pred'));},
  'ambiguous formal binding':x=>{x.params.push('data');},
  'nonconstant state rebuild':x=>{x.stable[0]=bin('nextword','xor','word',0);},
  'overlong pure prefix':x=>{x.positive.splice(2,0,...Array.from({length:8},(_,i)=>bin('tmp'+i,'eq',0,i)));},
  'oversized scope':x=>{x.stable.push(...Array.from({length:16},(_,i)=>set('tmp'+i,0)));},
};
for(const [label,mutate] of Object.entries(refusals)) test(label,false,'tag',mutate);
test('machine refusal: next tag leaves the arm',false,'tag',refusals['truncated shifted constant gives other tag'],true);
test('machine refusal: mutation on each absorbing visit',false,'tag',x=>{
  x.stable[1]=bin('nextdata','add','data',1);
},true);
test('machine refusal: crossed parameter stabilizes only on the next trip',false,'tag',refusals['word copied from another formal'],true);
const report={cases:controls,api:apiReceipt,source:auth.source,products:[],machine:[],complete:false};
const save=()=>fs.writeFileSync(path.join(out,'controls.json'),JSON.stringify(report,null,2)+'\n');
save();
function run(cmd) {
  const r=spawnSync(cmd[0],cmd.slice(1),{encoding:'utf8',timeout:15000});
  if(r.status!==0||r.stderr)throw Error(JSON.stringify([cmd,r.status,r.stdout,r.stderr]));
  return r.stdout;
}
function list(xs) {const a=[];for(;xs.$==='Con';xs=xs.tail)a.push(xs.head);return a;}
const objs={rendered:[],direct:[]};
for(const [i,x] of cases.entries()) for(const role of ['base','new']) {
  const sym='p198_'+role+i;
  const emitted=role==='base'?api.p198a_plain(sym,x.params,x.body,ids):api.x185_function_copied(sym,x.params,bend([]),x.body,ids);
  if(emitted.error)throw Error(emitted.error);
  const seq=api.x188_many(emitted.chunks), obj=api.x188_assemble(seq);
  if(obj.error)throw Error(obj.error);
  const asm=path.join(out,sym+'.s'), direct=path.join(out,sym+'-direct.o'), rendered=path.join(out,sym+'-rendered.o');
  const renderedText=api.x188_render(seq);
  fs.writeFileSync(asm,'.text\n'+renderedText+'\n.section .note.GNU-stack,"",@progbits\n');
  fs.writeFileSync(direct,Buffer.from(list(obj.bytes)));
  run([as.file,...policy.assemblerFlags,'-o',rendered,asm]);
  objs.rendered.push(rendered);objs.direct.push(direct);
  report.products.push({role,label:x.label,asm:pin(asm),rendered:pin(rendered),direct:pin(direct)});
}
const here=path.dirname(fileURLToPath(import.meta.url)), observer=pin(path.join(here,'observer.c'));
for(const [role,list] of Object.entries(objs)) {
  const exe=path.join(out,role);
  run([cc.file,'-O2','-no-pie','-Wl,-z,noexecstack',observer.file,...list,'-o',exe]);
  const stdout=run([exe]);
  if(!stdout.match(/^checks=\d+ errors=0\n$/))throw Error('observer '+stdout);
  report.machine.push({role,observer,executable:pin(exe),stdout});
}
report.complete=true;save();

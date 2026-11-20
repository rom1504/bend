// Run checked ordinary front-end and both ordinary x86 encoders. Synthetic
// casts never feed the selection API. Negative controls are checked programs.
import fs from 'node:fs';
import path from 'node:path';
import {stageTrace,markedContexts} from './trace.mjs';
import {pathToFileURL,fileURLToPath} from 'node:url';
import {pin,verify} from '../../../../selfhost/tools/build/hosted.mjs';
const argv=process.argv.slice(2);
const opt=Object.fromEntries(Array.from({length:argv.length/2},(_,i)=>argv.slice(i*2,i*2+2)));
if(!/^Cpus_allowed_list:\s*3$/m.test(fs.readFileSync('/proc/self/status','utf8')))throw Error('requires CPU3');
const here=path.dirname(fileURLToPath(import.meta.url)),out=path.resolve(opt['--out']);
const read=p=>JSON.parse(fs.readFileSync(p)), txt=p=>fs.readFileSync(p,'utf8');
const auth=read(opt['--api']);if(!auth.checked||!auth.complete||auth.error)throw Error('unchecked API');
for(const p of [auth.api,auth.source])verify(p);
const api=(await import(pathToFileURL(auth.api.file))).default;
const binding=read('selfhost/build/phase195/ctor-gate-emission-plan01.json').producer.bindingValue;
for(const p of [binding.base,binding.engine,binding.carrier])verify(p);
if(fs.realpathSync(process.execPath)!==fs.realpathSync(binding.engine.file))throw Error('engine');
fs.mkdirSync(out);
const report={complete:false,source:auth.source,api:auth.api,method:pin(fileURLToPath(import.meta.url)),trace:pin(path.join(here,'trace.mjs')),cases:[]};
const save=()=>fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n');
function list(x){const a=[];for(;x.$==='Con';x=x.tail)a.push(x.head);if(x.$!=='Nil')throw Error(x.$);return a;}
function bytes(x){let a=[];const chunks=[];for(;x.$==='Con';x=x.tail){a.push(x.head);if(a.length===65536){chunks.push(Buffer.from(a));a=[];}}if(x.$!=='Nil')throw Error(x.$);chunks.push(Buffer.from(a));return Buffer.concat(chunks);}
function term(t){return {tag:t.$==='KLambda'?'Lam':t.tag??t.kind,name:t.name??'',quant:t.quant,kids:t.kids?list(t.kids).map(term):[]};}
function equation(t){while(t.tag==='Ann')t=t.kids.head;const tag=t.$==='KLambda'?'Lam':t.tag??t.kind;return {tag,name:t.name??t.text??'',id:t.id??t.number,quant:t.quant,kids:tag==='Var'||!t.kids?[]:list(t.kids).map(equation)};}
function descriptor(d,details=false){return {kind:d.kind,name:d.name,arity:d.arity,native:d.native,unsafe:d.unsafe,templates:d.templates,typ:details?term(d.typ):undefined,ctors:details?list(d.ctors).map(v=>({name:v.name,kind:v.kind,typ:term(v.typ)})):undefined};}
const refs=read('selfhost/build/phase195/references01/manifest.json').cases;
const cache=api.p88_cache_prepare(binding.base.file,txt(binding.base.file),txt(binding.carrier.file),binding.stamp);
if(cache.$!=='P86PreparationReady')throw Error('cache '+cache.error);
const once=(s,a,b)=>{if(s.split(a).length!==2)throw Error('nonunique '+a);return s.replace(a,b);};
const envelope=txt(path.join(here,'envelope.bend'));
const variants={envelope,
  'changed-zip':once(envelope,'Fork{Fork{a0, b0}, Fork{a1, b1}}','Fork{Fork{a0, b1}, Fork{a1, b0}}'),
  'changed-recur':once(envelope,'envelope(a0, b0, upper) envelope(a1, b1, upper)','envelope(a0, b1, upper) envelope(a1, b0, upper)'),
  'changed-predicate':once(envelope,'U32.is_gt(a, b)','U32.is_lt(a, b)'),
  'changed-order':once(envelope,'case True{}: Fork{Reading{b}, Reading{a}}','case True{}: Fork{Reading{a}, Reading{b}}')};
for(const id of (opt['--cases']??'tree-bitonic,envelope,changed-zip,changed-recur,changed-predicate,changed-order').split(',')){
 const dir=path.join(out,id);fs.mkdirSync(dir);let file,owner,tree;
 const orig=refs.find(r=>r.id===id);
 if(orig){verify(orig.source);file=orig.source.file;owner='warp';tree='Tree';}
 else {file=path.join(dir,'main.bend');fs.writeFileSync(file,variants[id]);owner='envelope';tree='Signal';}
 const row={id,source:pin(file),owner};report.cases.push(row);save();
 const start=performance.now();const one=api.p86_plan(cache.seed,file,txt(file));
 if(one.$!=='P86PlanReady'){row.error=one.error;save();throw Error(id+' '+one.error);}
 const src=one.request;
 if(id==='tree-bitonic'){const sourceDefs=['flow','warp_node'].map(name=>{const d=api.x198pw_descriptor(src,name);return {name,signature:term(d.typ),value:equation(d.value)};});fs.writeFileSync(path.join(dir,'outer-shapes.json'),JSON.stringify(sourceDefs,null,2)+'\n');row.outerShapes=pin(path.join(dir,'outer-shapes.json'));}
 const desired=id==='envelope'||id.includes('tree-bitonic');
 row.descriptors=[descriptor(api.x198pw_descriptor(src,owner)),descriptor(api.x198pw_descriptor(src,tree),true),...['Bool.xor','U32.is_gt'].map(n=>descriptor(api.x198pw_descriptor(src,n)))];
 row.symbolic=api.x198pw_symbolic(src,owner);row.semantic=api.x198pw_probe(src,owner);
 row.owners=list(api.x198pw_owners(src.scope,src.book,{$:'Nil'}));row.proofMs=performance.now()-start;save();
 if(desired!==(row.semantic.$==='X198PWPlan') || desired!==(row.owners.length===1)){
   row.trace=stageTrace(api,src,owner,orig?'Leaf':'Reading',orig?'Node':'Fork');save();
   throw Error(id+' proof admission '+row.symbolic.$+'/'+row.semantic.$+' owners='+row.owners.length);
 }
 if(!desired || opt['--emit']==='no')continue;
 const lowered=api.x198pw_plan(one);if(lowered.error)throw Error(id+' prep '+lowered.error);
 row.contexts=markedContexts(api,lowered.cursor,owner);save();
 const machine=api.x181_prepared(lowered);if(machine.error)throw Error(id+' selection '+machine.error);
 const code=api.x188_many(machine.chunks),asm=api.x188_render(code),sp=path.join(dir,'program.s');fs.writeFileSync(sp,asm);row.assembly=pin(sp);
 row.plans=[...asm.matchAll(/^p198w_original_(\w+):$/gm)].map(m=>m[1]);save();
 const expected='p114r_FID_'+[...'$direct.'+owner].map(v=>v.codePointAt(0)+'_').join('');
 if(row.plans.length!==1||row.plans[0]!==expected)throw Error(id+' H theorem missing from selected machine');
 const obj=api.x188_assemble(code);if(obj.error){row.objectError=obj.error;save();throw Error(id+' object '+obj.error);}
 const op=path.join(dir,'program.o');fs.writeFileSync(op,bytes(obj.bytes));row.object=pin(op);row.wallMs=performance.now()-start;save();
}
report.complete=true;save();console.log(report.cases.map(r=>[r.id,r.semantic.$,r.plans?.length]));

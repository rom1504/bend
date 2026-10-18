// Bounded admission mutations. These are deliberately corrupted checked-fact
// transports, not newly checked source programs or whole-compiler conformance.
import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
import {fileURLToPath, pathToFileURL} from 'node:url';

const [apiArg, captureArg, outArg] = process.argv.slice(2);
if (!apiArg || !captureArg || !outArg) throw Error('Usage: lower-admission.mjs API CAPTURE FRESH_OUT');
const here = path.dirname(fileURLToPath(import.meta.url));
const root = path.resolve(here, '../../../..');
const apiFile = path.resolve(apiArg), capture = path.resolve(captureArg), out = path.resolve(outArg);
if (!out.startsWith(path.join(root, 'selfhost/build/phase109') + path.sep) || fs.existsSync(out)) throw Error('Expected fresh Phase109 output');
fs.mkdirSync(out);
const pin = file => ({file:path.resolve(file), bytes:fs.statSync(file).size, sha256:crypto.createHash('sha256').update(fs.readFileSync(file)).digest('hex')});
const verify = p => { if (JSON.stringify(pin(p.file)) !== JSON.stringify(p)) throw Error('Changed input ' + p.file); };
const list = xs => xs.reduceRight((tail,head) => ({$:'Con',head,tail}), {$:'Nil'});
const array = x => { const a=[]; while(x.$==='Con'){a.push(x.head);x=x.tail;} if(x.$!=='Nil')throw Error('Malformed transport list'); return a; };
const tag = t => t.$ === 'KLambda' ? 'Lam' : t.$ === 'KLiteral' ? 'Lit' : t.tag;
const atom = (kind, name='', id=0, kids=[]) => ({$:'KTerm',tag:kind,name,id,quant:0,kids:list(kids),removed:list([]),originBegin:0,originEnd:0});
const nodes = t => [t,...array(t.kids ?? list([])).flatMap(nodes)];
const first = (fact, kind) => {const t=nodes(fact.value).find(x=>tag(x)===kind);if(!t)throw Error('Missing fixture node '+kind);return t;};
const catalogue = () => list([['Nil',0,0],['Con',1,2],['SNil',2,0],['SCon',3,2]].map(([name,cid,arity])=>({$:'NxoCtor',name,cid,arity})));
const captureRecord = JSON.parse(fs.readFileSync(path.join(capture,'report.json')));
if (!captureRecord.complete || !captureRecord.result.checked || captureRecord.result.status !== 'ok') throw Error('Capture was not checked');
for (const p of captureRecord.products) verify(p);
const facts = array(JSON.parse(fs.readFileSync(path.join(capture,'native-facts.json'))));
const selected = name => {const f=facts.find(d=>d.name===name);if(!f)throw Error('Missing checked fixture '+name);return structuredClone(f);};
const inputs = [pin(apiFile),pin(fileURLToPath(import.meta.url)),pin(path.join(capture,'report.json')),...captureRecord.products];
const cases=[];
const add = (name, mutate, expected=false, source='nt_reverse', policy='raw') => {
  const fact=selected(source), ctx={fact,ctors:catalogue(),policy};
  if(mutate)mutate(ctx);
  cases.push({name,expected,...ctx});
};
for(const source of ['nt_reverse','String.reverse.go'])for(const policy of ['raw','trusted','fused'])add(source.replaceAll('.','_')+'-'+policy,null,true,source,policy);
add('mat-extra-child',({fact})=>{const t=first(fact,'Mat');t.kids=list([...array(t.kids),atom('Efq')]);});
add('mat-missing-arm',({fact})=>{const t=first(fact,'Mat');t.kids=list(array(t.kids).slice(0,1));});
add('mat-wrong-field-count',({fact})=>{first(fact,'Mat').id=9;});
add('mat-unknown-constructor',({fact})=>{first(fact,'Mat').name='Unknown';});
add('lambda-extra-child',({fact})=>{const t=first(fact,'Lam');t.kids=list([...array(t.kids),atom('Efq')]);});
add('lambda-missing-body',({fact})=>{first(fact,'Lam').kids=list([]);});
add('lambda-erased-quantity',({fact})=>{first(fact,'Lam').quant=0;});
add('lambda-invalid-quantity',({fact})=>{first(fact,'Lam').quant=3;});
add('app-extra-child',({fact})=>{const t=first(fact,'App');t.kids=list([...array(t.kids),atom('Efq')]);});
add('app-missing-argument',({fact})=>{const t=first(fact,'App');t.kids=list(array(t.kids).slice(0,1));});
add('variable-extra-child',({fact})=>{first(fact,'Var').kids=list([atom('Efq')]);});
add('reference-extra-child',({fact})=>{first(fact,'Ref').kids=list([atom('Efq')]);});
add('efq-extra-child',({fact})=>{first(fact,'Efq').kids=list([atom('Ctr','Nil')]);});
add('constructor-wrong-arity',({fact})=>{const t=first(fact,'Ctr');t.kids=list(array(t.kids).slice(0,1));});
add('constructor-unknown-identity',({fact})=>{first(fact,'Ctr').name='Unknown';});
add('unsupported-let',({fact})=>{const t=first(fact,'Ctr');t.tag='Let';});
add('non-tail-self-call',({fact})=>{const t=first(fact,'Ctr'),call=structuredClone(first(fact,'App'));t.kids=list([call,array(t.kids)[1]]);});
add('external-tail-call',({fact})=>{first(fact,'Ref').name='external_worker';});
add('indirect-tail-call',({fact})=>{const t=first(fact,'Ref'),v=first(fact,'Var');t.tag='Var';t.name=v.name;t.id=v.id;});
add('partial-self-call',({fact})=>{const t=first(fact,'App'),ks=array(t.kids);t.kids=list([structuredClone(first(fact,'Ref')),ks[1]]);});
add('oversaturated-self-call',({fact})=>{const t=first(fact,'App'),old=structuredClone(t),v=structuredClone(first(fact,'Var'));t.kids=list([old,v]);});
add('wrong-fact-kind',({fact})=>{fact.kind='UntrustedBody';});
add('zero-parameter-count',({fact})=>{fact.arity=0;});
add('too-many-parameters',({fact})=>{fact.arity=9;});
add('wrong-declared-arity',({fact})=>{fact.arity=1;});
add('catalogue-swapped-identities',ctx=>{const xs=array(ctx.ctors);xs[0].cid=2;xs[2].cid=0;ctx.ctors=list(xs);});
add('catalogue-duplicate-name',ctx=>{const xs=array(ctx.ctors);xs[2].name='Nil';ctx.ctors=list(xs);});
add('catalogue-missing-entry',ctx=>{ctx.ctors=list(array(ctx.ctors).slice(0,3));});
add('catalogue-extra-entry',ctx=>{ctx.ctors=list([...array(ctx.ctors),{$:'NxoCtor',name:'Extra',cid:4,arity:0}]);});
add('catalogue-wrong-order',ctx=>{ctx.ctors=list(array(ctx.ctors).reverse());});
add('catalogue-wrong-arity',ctx=>{const xs=array(ctx.ctors);xs[1].arity=1;ctx.ctors=list(xs);});
add('unknown-policy',ctx=>{ctx.policy='unknown';});

const api=(await import(pathToFileURL(apiFile))).default;
const report={kind:'phase109-owned-lowering-admission',complete:false,scope:'Six authenticated positive controls and bounded mutations; fabricated mutations are not source checker results',inputs,rows:[]};
const save=()=>fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n');
save();
for(const c of cases){
  const inputFile=path.join(out,c.name+'.json');fs.writeFileSync(inputFile,JSON.stringify(c,null,2)+'\n');
  const row={name:c.name,expected:c.expected?'admit':'refuse',input:pin(inputFile)};
  try{
    const result=api.nxo_lower_policy(c.fact,c.ctors,'admission_worker',c.policy);
    row.error=result.error;row.admitted=result.error==='';row.pass=row.admitted===c.expected;
    if(row.admitted){
      const lib={$:'NxLibrary',imports:api.nxlib_runtime_imports_policy(c.policy),functions:list([result.function]),exports:list(['admission_worker'])};
      row.libraryValid=api.nxlib_verify(lib);row.pass&&=row.libraryValid;
    }
  }catch(e){row.exception=String(e);row.pass=false;}
  report.rows.push(row);save();
}
for(const p of inputs)verify(p);
report.complete=report.rows.every(r=>r.pass);report.passed=report.rows.filter(r=>r.pass).length;report.count=report.rows.length;save();
console.log(JSON.stringify({complete:report.complete,passed:report.passed,count:report.count,failed:report.rows.filter(r=>!r.pass).map(r=>r.name)}));
if(!report.complete)process.exitCode=1;

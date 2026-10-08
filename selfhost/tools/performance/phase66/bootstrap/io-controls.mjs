// Source-bound operation controls; does not emit or relabel a checked compiler.
import fs from 'node:fs';
import path from 'node:path';
import assert from 'node:assert/strict';
import {createHash} from 'node:crypto';
import {pathToFileURL} from 'node:url';
const [upstreamArg,stage0Arg,outArg,...extra]=process.argv.slice(2);
assert.ok(upstreamArg&&stage0Arg&&outArg&&!extra.length,
  'Usage: io-controls.mjs UPSTREAM CANDIDATE_STAGE0 FRESH_OUTPUT_DIRECTORY');
const upstream=fs.realpathSync(upstreamArg),stage0=fs.realpathSync(stage0Arg),out=path.resolve(outArg);
fs.mkdirSync(out,{recursive:false});
const sha=x=>createHash('sha256').update(x).digest('hex');
const identity=file=>({file:fs.realpathSync(file),sha256:sha(fs.readFileSync(file))});
const bend=path.join(upstream,'bend2/bend.ts'),comp=path.join(upstream,'bend2/comp.ts');
const inputs=[import.meta.filename,bend,comp,stage0].map(identity);
const report={kind:'phase66-bootstrap-io-controls',version:1,complete:false,pass:false,inputs,cases:[],scope:'Real upstream term normalization on synthetic typed-term books; semantic export classification, not parsing/checking or arbitrary user execution.'};
try {
  assert.equal(inputs[1].sha256,'1d133151652b597a1a035c77c172475e6de096da37f3b9e3adc23c2f75bdfe49');
  assert.equal(inputs[2].sha256,'2b13224ba09a9e39e37cccf06e449c1bdafe5e03a81641654f7d0e455507629c');
  assert.equal(inputs[3].sha256,'ec3506de1558fa1e56cef54345053ffaf7bfcc92b8632eaf96e217c15b8a59c1');
  const B=await import(pathToFileURL(bend));
  const original=fs.readFileSync(comp,'utf8').match(/^function io_base\(book: Bend\.Book, t: HTerm\): HTerm\[\] \| null \{\n[\s\S]*?^\}/m)?.[0];
  assert.ok(original,'Missing pinned private semantic query');
  const reference=new Function('Bend',original.replace('book: Bend.Book, t: HTerm','book, t').replace('): HTerm[] | null {','){')+'; return io_base;')(B);
  const candidateSource=fs.readFileSync(stage0,'utf8');
  const helper=candidateSource.match(/^function bootstrapIoBase\(book,type\)\{\n[\s\S]*?^\}/m)?.[0];
  assert.ok(helper,'Missing candidate query');
  const candidate=new Function('B',helper+'; return bootstrapIoBase;')(B);
  const eligibleSource=candidateSource.match(/const eligible=name=>\{[\s\S]*?\n  \};/)?.[0];
  assert.ok(eligibleSource,'Missing production eligibility predicate');
  const eligible=book=>new Function('book','bootstrapIoBase',eligibleSource+'return eligible;')(book,candidate);
  const def=(T,v=B.Ref('value'),more={})=>({$: 'Def',n:0,x:0,T,v,...more});
  const typ=B.Ref('opaqueType'),arg=B.Ref('opaqueArgument');
  const make=()=>{const b=B.book_nil();b.tlds.IO=def(typ,B.Ref('opaqueIOValue'),{b:true});return b;};
  const check=(name,book,type,wanted)=>{
    const keys=Object.keys(book.tlds),io=book.tlds.IO,value=io?.v;
    const actual=candidate(book,type),expected=reference(book,type);
    assert.deepEqual(actual,expected,name+' exact upstream query');
    // term_wnf keeps arguments in sharing cells; compare their forced values
    // to the independent expected arguments as well as the full query above.
    assert.deepEqual(actual===null?null:actual.map(B.term_force),wanted,name+' expected arguments');
    assert.deepEqual(Object.keys(book.tlds),keys);assert.equal(book.tlds.IO,io);assert.equal(io?.v,value);
    report.cases.push({name,argumentCount:wanted===null?null:wanted.length});
  };
  check('canonical IO with zero arguments',make(),B.Ref('IO'),[]);
  check('canonical IO with one argument',make(),B.App(B.Ref('IO'),arg),[arg]);
  check('canonical IO with two arguments',make(),B.App(B.App(B.Ref('IO'),arg),typ),[arg,typ]);
  check('annotation around IO',make(),B.Ann(B.App(B.Ref('IO'),arg),typ),[arg]);
  const alias=make();alias.tlds.Alias=def(typ,B.App(B.Ref('IO'),arg));
  check('definition alias normalizes to IO',alias,B.Ref('Alias'),[arg]);
  check('unrelated reference',make(),B.Ref('Unknown'),null);
  check('namespace-qualified lookalike',make(),B.App(B.Ref('other:IO'),arg),null);
  check('no IO definition',B.book_nil(),B.Ref('IO'),null);
  const user=make();delete user.tlds.IO.b;check('non-Base IO',user,B.Ref('IO'),null);
  const falseBase=make();falseBase.tlds.IO.b=false;check('explicit non-Base IO',falseBase,B.Ref('IO'),null);
  const adt=make();adt.tlds.IO={$: 'ADT',n:0,g:0,T:typ,c:[],b:true};check('IO is not a definition',adt,B.Ref('IO'),null);
  const eligibility=make();eligibility.tlds.pure=def(typ);eligibility.tlds.io=def(B.App(B.Ref('IO'),arg));
  eligibility.tlds.empty=def(typ,null);eligibility.tlds.base=def(typ,undefined,{b:true});
  eligibility.tlds.template=def(typ,undefined,{x:1});eligibility.tlds.foreign=def(typ,undefined,{i:[]});
  eligibility.tlds.adt={$: 'ADT',n:0,g:0,T:typ,c:[]};
  for(const [name,wanted] of [['pure',true],['io',false],['empty',false],['base',false],['template',false],['foreign',false],['adt',false],['missing',false]]){
    assert.equal(eligible(eligibility)(name),wanted,'eligibility '+name);report.cases.push({name:'eligibility '+name,eligible:wanted});
  }
  for(const input of inputs)assert.deepEqual(identity(input.file),input,'Changed input');
  report.complete=true;report.pass=true;
} catch(error){report.error=String(error?.stack??error);process.exitCode=1;}
fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n',{flag:'wx'});
console.log(JSON.stringify({complete:report.complete,pass:report.pass,cases:report.cases.length,error:report.error}));

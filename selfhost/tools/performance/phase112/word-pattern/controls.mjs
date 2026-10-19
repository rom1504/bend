// Root-run finite structural/evaluation controls; no native timing claim.
import fs from 'node:fs';
import path from 'node:path';
import assert from 'node:assert/strict';
import {createHash} from 'node:crypto';
import {pathToFileURL} from 'node:url';
const [apiFile,outFile]=process.argv.slice(2);
if(!apiFile||!outFile)throw Error('Usage: controls.mjs CHECKED_API FRESH_REPORT');
const api=(await import(pathToFileURL(path.resolve(apiFile)))).default;
const list=xs=>xs.reduceRight((tail,head)=>({$:'Con',head,tail}),{$:'Nil'});
const unlist=xs=>{const a=[];while(xs.$==='Con'){a.push(xs.head);xs=xs.tail;}assert.equal(xs.$,'Nil');return a;};
const term=(tag,kids=[],id=0,name='',quant=0)=>({$:'KTerm',tag,name,id,quant,kids:list(kids),removed:list([]),originBegin:0,originEnd:0});
const variable=id=>term('Var',[],id),word=value=>term('NWord',[],0,String(value));
const lam=(id,body)=>term('Lam',[body],id,'',1);
const mat=(name,fields,yes,no=term('Efq'))=>term('Mat',[yes,no],fields+1,name);
const ctor=(name,kids=[])=>term('Ctr',kids,0,name,1);
const binding=(id,name='v_'+id)=>({$:'NC_Binding',id,word:name,kind:{$:'N_W64'}});
const row=(depth,value,fields,body)=>term('NWRow',[body],depth,String(value),fields);
const env=list([binding(500)]),n=300,baseId=4294967295-n;
const pin=file=>{const data=fs.readFileSync(file);return {file:path.resolve(file),bytes:data.length,sha256:createHash('sha256').update(data).digest('hex')};};
const report={kind:'phase112-word-pattern-controls',complete:false,method:pin(import.meta.filename),api:pin(apiFile),recognition:[],evaluation:[],refusals:[],
  scope:'Finite raw KTerm recognition, mask arithmetic and independent N111 interpretation. Native ownership and checked-source validation are separate gates.'};

function literalPattern(value,hit=word(7),fallback=word(9),depth=0){
  if(depth===32)return mat('WNil',0,hit);
  const bit=(value>>>depth)&1;
  return mat('WCon',2,mat(bit?'True':'False',0,literalPattern(value,hit,fallback,depth+1),
    lam(1000+2*depth,lam(1001+2*depth,fallback))));
}
function plan(rows){return api.p112m_plan_rows(list(rows),list([]),n);}
function applyTerm(body,kind='U32'){return term('NMatch',[mat(kind,1,body),variable(500)]);}
function plannedCode(planned){
  assert.equal(planned.valid,true);
  const code=api.p112m_emit(list([]),planned.rows,list([]),n,n+3);
  code.body=list([{$:'N111Bin',name:'v_'+baseId,typ:{$:'N111U64'},op:'and',left:{$:'N111Local',name:'v_500'},right:{$:'N111Const',lo:4294967295,hi:0}},...unlist(code.body)]);
  return code;
}

// This interpreter is deliberately independent of QBE rendering and runtime
// lowering. It accepts only scalar N111 ops and terminal return/drop helpers;
// a remaining Word materialization or generic constructor helper is a failure.
function execute(code,input){
  assert.equal(code.error,'');
  const locals=new Map([['v_500',BigInt(input)],['state',0n],['scratch',0n]]),memory=new Map();
  const value=v=>{
    if(v.$==='N111Const')return BigInt(v.lo)+(BigInt(v.hi)<<32n);
    assert.equal(v.$,'N111Local');assert.ok(locals.has(v.name),'defined local '+v.name);return locals.get(v.name);
  };
  function run(stmts){
    for(const s of unlist(stmts)){
      if(s.$==='N111Bin'){
        const a=value(s.left),b=value(s.right);let v;
        if(s.op==='and')v=a&b;
        else if(s.op==='shr')v=a>>b;
        else if(s.op==='eq')v=BigInt(a===b);
        else throw Error('unexpected binary '+s.op);
        locals.set(s.name,v);continue;
      }
      if(s.$==='N111Set'){locals.set(s.name,value(s.value));continue;}
      if(s.$==='N111Store'){memory.set(s.offset,value(s.value));continue;}
      if(s.$==='N111If'){const result=run(value(s.condition)?s.yes:s.no);if(result!==undefined)return result;continue;}
      if(s.$==='N111Call'){
        if(s.symbol==='p111_rt_sink')locals.set(s.name,0n);
        else if(s.symbol==='p111_rt_return')locals.set(s.name,memory.get(0));
        else if(s.symbol==='p111_rt_fail')throw Error('fail-stop');
        else throw Error('unexpected runtime '+s.symbol);
        continue;
      }
      if(s.$==='N111Return')return value(s.value);
      throw Error('unexpected statement '+s.$);
    }
  }
  return run(code.body);
}
try{
  for(const depth of [0,1,2,15,16,30,31,32]){
    const expected=Number((1n<<BigInt(depth))-1n);
    assert.equal(api.p112m_mask(depth),expected);report.recognition.push({name:'mask',depth,mask:expected});
  }
  for(const literal of [0,1,10,13,255,65535,2147483648,4294967295,2143289345,2139095040]){
    const tree=literalPattern(literal),rows=api.nw_walk(tree,0,0,{$:'NW_None'});
    assert.equal(rows.valid,true);assert.ok(unlist(rows.rows).length>0);
    const planned=api.p112m_plan_rows(rows.rows,list([]),n);assert.equal(planned.valid,true);
    for(const kind of ['U32','F32']){
      const match=applyTerm(tree,kind);assert.equal(api.nw_applicable(unlist(match.kids)[0]),true);
      const code=api.p112m_match_apply(list([]),match,env,n);
      for(const input of [...new Set([0,literal,(literal^1)>>>0,4294967295])]){
        const expected=input===literal?7n:9n,actual=execute(code,input);assert.equal(actual,expected);
        report.evaluation.push({kind,literal,input,output:Number(actual)});
      }
      assert.equal(execute(code,(1n<<48n)+BigInt(literal)),7n,'high metadata bits masked');
    }
    report.recognition.push({name:'literal',literal,rows:unlist(rows.rows).map(r=>({depth:r.id,value:r.name,fields:r.quant}))});
  }
  // First row wins for overlapping prefixes; never sort reconstructed rows.
  const ordered=plan([row(2,3,0,word(11)),row(1,1,0,word(22)),row(0,0,0,word(33))]);
  assert.equal(ordered.valid,true);
  const orderedCode=plannedCode(ordered);
  for(const [input,expected]of [[3,11],[7,11],[1,22],[5,22],[0,33],[2,33]])assert.equal(execute(orderedCode,input),BigInt(expected));
  report.recognition.push({name:'overlapping-prefix-order',cases:6});
  for(const kind of ['U32','F32']){
    const tail=variable(44),prefix=api.nw_prefix(3,5,tail);
    const restored=plan([row(3,5,1,lam(44,ctor(kind,[prefix])))]);
    assert.equal(restored.valid,true);assert.equal(unlist(unlist(restored.rows)[0].kids)[0].tag,'Var');
    const code=plannedCode(plan([row(0,0,1,lam(44,ctor(kind,[tail])))]));
    for(const input of [0,1,2147483648,2143289345,4294967295]){
      assert.equal(execute(code,input),BigInt(input));
      assert.equal(execute(code,(1n<<48n)+BigInt(input)),BigInt(input));
    }
    report.recognition.push({name:'restore-whole-scalar',kind});
  }
  for(const [name,rows]of [
    ['escaping-whole-word',[row(0,0,1,lam(44,variable(44)))]],
    ['escaping-residual-tail',[row(3,5,2,lam(43,lam(44,variable(44))))]],
    ['one-escaping-row-refuses-whole-plan',[row(32,7,0,word(1)),row(0,0,1,lam(44,variable(44)))]]]){
    assert.equal(plan(rows).valid,false,name);report.refusals.push({name});
  }
  const bitPlan=plan([row(1,1,2,lam(43,lam(44,variable(43))))]);
  assert.equal(bitPlan.valid,true);assert.equal(unlist(bitPlan.rows)[0].quant,1);
  const bitCode=plannedCode(plan([row(1,1,2,lam(43,lam(44,variable(43)))),row(0,0,0,word(3))]));
  for(const [input,expected]of [[1,0],[3,1],[5,0],[7,1],[0,3]])assert.equal(execute(bitCode,input),BigInt(expected));
  report.recognition.push({name:'used-bit-retained-without-tail'});
  const escaping=[
    ['whole-word',lam(44,variable(44))],
    ['residual-word',mat('WCon',2,mat('True',0,lam(44,variable(44)),lam(43,lam(44,variable(44)))))]
  ];
  for(const [name,body]of escaping){
    const match=applyTerm(body),rows=api.nw_walk(body,0,0,{$:'NW_None'});
    assert.equal(rows.valid,true);assert.equal(api.p112m_plan_rows(rows.rows,list([]),n).valid,false);
    assert.deepEqual(api.p112m_match_apply(list([]),match,env,n),api.p112m_original_match_apply(list([]),match,env,n));
    report.refusals.push({name:'exact-generic-fallback-'+name});
  }
  for(const bad of [mat('U64',1,term('Efq')),mat('U32',0,term('Efq')),term('NWPattern',[],2,'U32')]){
    assert.equal(api.nw_applicable(bad),false);report.refusals.push({name:'wrapper-'+bad.tag+'-'+bad.name+'-'+bad.id});
  }
  for(const id of [baseId,baseId-1,baseId-2]){
    for(const [name,t]of [['var',variable(id)],['unused-lambda-binder',lam(id,word(0))],['let-binder',term('Bind',[word(0)],id)]]){
      assert.equal(api.p112m_fresh_terms(list([t]),baseId-2,baseId),false);report.refusals.push({name:'fresh-'+name,id});
    }
    assert.equal(api.p112m_fresh_env(list([binding(id)]),n),false);
    report.refusals.push({name:'fresh-environment-id',id});
  }
  assert.equal(api.p112m_fresh_env(list([binding(99,'v_'+baseId)]),n),false);
  report.refusals.push({name:'fresh-environment-word-alias'});
  report.complete=true;
}catch(error){report.error=error.stack??String(error);process.exitCode=1;console.error(report.error);}
fs.writeFileSync(outFile,JSON.stringify(report,null,2)+'\n',{flag:'wx'});
console.log(JSON.stringify({complete:report.complete,recognition:report.recognition.length,evaluation:report.evaluation.length,refusals:report.refusals.length}));

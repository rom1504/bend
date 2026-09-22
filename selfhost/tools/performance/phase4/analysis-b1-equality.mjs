// P4-024: disposable exact-B1 transformation. Never a checked bootstrap claim.
import fs from 'node:fs';import path from 'node:path';import assert from 'node:assert/strict';import {pathToFileURL} from 'node:url';
import {digest,identity,verifyIdentity} from '../../private-compiler/common.mjs';
export const reviewedB1='0653f21e7e227bf7bf7e3ad777630da64d520534753900636a571ed57a43f810';
export const reviewedBody='07805c1bcb339824102228490203c45ebce00a7694fe5ad31ed55de02d1e4393';
export function nativeB1Equality(source){
 assert.equal(digest(source),reviewedB1,'Unreviewed B1 image');const matches=[...source.matchAll(/function \$String\$eq\$\(a_0, b_0\) \{\n[^\n]*\n\}/g)];assert.equal(matches.length,1);const old=matches[0][0];assert.equal(digest(old),reviewedBody,'Unreviewed String.eq body');
 const body=old.replace('{\n','{\n  if (typeof a_0 === "string" && typeof b_0 === "string" && a_0.isWellFormed() && b_0.isWellFormed()) return a_0 === b_0;\n');
 return {source:source.replace(old,body),stats:{replacements:1,reviewedB1,reviewedBody,scope:'Primitive well-formed strings only; all other values execute exact original body. Experimental derived API, not a new checked bootstrap.'}};
}
if(process.argv[1]&&import.meta.url===pathToFileURL(path.resolve(process.argv[1])).href){
 const [sourceArg,outArg]=process.argv.slice(2);if(!outArg)throw Error('Usage: analysis-b1-equality.mjs CHECKED_B1 NEW_DIRECTORY');const out=path.resolve(outArg);fs.mkdirSync(out);const inputs=[identity(sourceArg),identity(import.meta.filename),identity(new URL('../../private-compiler/common.mjs',import.meta.url)),identity(process.execPath)],report={kind:'phase4-b1-native-equality-preparation',complete:false,newBootstrap:false,started:new Date().toISOString(),inputs};
 try{
  const original=fs.readFileSync(sourceArg,'utf8'),candidate=nativeB1Equality(original),suffix='\nexport const equalityForTest=(a,b)=>run_loop($String$eq$(a,b));\n';
  fs.writeFileSync(path.join(out,'control.mjs'),original);fs.writeFileSync(path.join(out,'candidate.mjs'),candidate.source);for(const [name,text]of [['control-test',original],['candidate-test',candidate.source]])fs.writeFileSync(path.join(out,name+'.mjs'),text+suffix);
  const [a,b]=await Promise.all(['control-test','candidate-test'].map(n=>import(pathToFileURL(path.join(out,n+'.mjs')))));
  const values=['','a','b','abc','abd','a\0b','\0','é','e\u0301','λ','中','🙂','𝄞','\ud800','\udc00','a\ud800','b\ud800','\ud800a','\udc00a','\ud800\ud800','\udc00\ud800','🙂\ud800',null,undefined,0,1,true,false,{},new String('abc')];
  const observe=(module,x,y)=>{try{return {ok:true,value:module.equalityForTest(x,y)}}catch(e){return{ok:false,name:e?.name,message:e?.message}}};const checks=[];
  for(let i=0;i<values.length;i++)for(let j=0;j<values.length;j++){const left=observe(a,values[i],values[j]),right=observe(b,values[i],values[j]);assert.deepEqual(right,left,`${i}:${j}`);checks.push({i,j,result:left});}
  for(const n of [128,512,2048])for(const ending of ['','x','🙂']){const x='ab'.repeat(n),y=x+ending;assert.deepEqual(observe(a,x,y),observe(b,x,y));checks.push({longPrefix:n,ending,passed:true});}
  assert.throws(()=>nativeB1Equality(original+'\n'),/Unreviewed B1/);inputs.forEach(verifyIdentity);Object.assign(report,{complete:true,inputsUnchanged:true,stats:candidate.stats,inputValues:values.length,checks,guardRefusals:1,variants:['control','candidate'].map(id=>({id,...identity(path.join(out,id+'.mjs'))}))});
 }catch(e){report.error=String(e.stack);process.exitCode=1;}
 report.finished=new Date().toISOString();fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n');console.log(JSON.stringify({complete:report.complete,error:report.error,checks:report.checks?.length,variants:report.variants}));
}

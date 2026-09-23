// Independent source-coordinate oracle for the P6-004 quoted-word repair.
// This reads token output; it does not implement compiler parsing or semantics.
import fs from 'node:fs';
import assert from 'node:assert/strict';
import path from 'node:path';
import {pathToFileURL} from 'node:url';
import {createHash} from 'node:crypto';
const [baselineFile,candidateFile,output]=process.argv.slice(2).map(x=>path.resolve(x));
const identity=file=>({file,sha256:createHash('sha256').update(fs.readFileSync(file)).digest('hex')});
const inputs=[identity(import.meta.filename),identity(baselineFile),identity(candidateFile),identity(process.execPath)];
async function view(file,name){const source=fs.readFileSync(file,'utf8');assert.ok(source.includes('function $f_lex$('));const target=output+'.'+name+'.mjs';fs.writeFileSync(target,source+'\nexport const positionControls={f_lex:run_lib($f_lex$,5)};\n',{flag:'wx'});return (await import(pathToFileURL(target))).positionControls;}
const B=await view(baselineFile,'baseline'),C=await view(candidateFile,'candidate');
const rows=[],list=x=>{const out=[];while(x.$==='Con'){out.push(x.head);x=x.tail;}assert.equal(x.$,'Nil');return out;};
const bodies=['plain','a\\nb','a\nb','\n','a\nb\nc','🙂\nλ','a\\\nb','a\\"b','a\\\\b'];
for(const quote of ['"',"'"])for(const body of bodies)for(const suffix of [' target','\n  target']) {
  const source=quote+body+quote+suffix,at=source.lastIndexOf('target'),prefix=source.slice(0,at).split('\n'),expected={line:prefix.length,column:[...prefix.at(-1)].length};
  const observed=list(C.f_lex(source,1,0,0,{$:'Nil'})),old=list(B.f_lex(source,1,0,0,{$:'Nil'}));
  const token=observed.find(t=>t.text==='target');assert.ok(token,JSON.stringify(source));
  assert.equal(token.f_line,expected.line);assert.equal(token.f_col,expected.column);
  const hasPhysicalNewline=body.includes('\n');if(!hasPhysicalNewline)assert.deepEqual(observed,old);
  rows.push({source,expected,token,unchangedWithoutPhysicalNewline:!hasPhysicalNewline,baseline:old.find(t=>t.text==='target')});
}
for(const item of inputs)assert.deepEqual(identity(item.file),item);
const report={kind:'phase6-lexer-coordinate-controls',complete:true,pass:true,scope:'36 direct token-position controls; independent codepoint coordinate oracle, not whole-language conformance.',inputs,rows};
fs.writeFileSync(output,JSON.stringify(report,null,2)+'\n',{flag:'wx'});console.log(JSON.stringify({complete:true,pass:true,controls:rows.length}));

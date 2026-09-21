import fs from 'node:fs';
import path from 'node:path';
import {spawnSync} from 'node:child_process';
import {pathToFileURL} from 'node:url';
const root=path.resolve(import.meta.dirname,'..');
process.env.BEND_LIBRARY_MODE='1';
const {G,call,list}=await import(pathToFileURL(path.join(root,'dist/bend2c.mjs')));
delete process.env.BEND_LIBRARY_MODE;
const runtime=fs.readFileSync(path.join(root,'src/runtime.mjs'),'utf8');
fs.mkdirSync(path.join(root,'build'),{recursive:true});
const tests=JSON.parse(fs.readFileSync(path.join(root,'tests/cases.json'),'utf8'));
let seed=918273;
const random=()=>{seed=(Math.imul(seed,1664525)+1013904223)>>>0;return seed};
for(let i=0;i<40;i++){
  const a=random(),b=random(),c=random();
  tests.push({name:'u32-wrap-'+i,source:`import Base\ndef main() -> U32:\n  ((${a} + ${b}) * ${c} : U32)\n`,want:String(((BigInt(a)+BigInt(b))*BigInt(c))&0xffffffffn)});
}
const results=[];
for(const test of tests){
  const source=test.source||fs.readFileSync(path.join(root,'tests/fixtures',test.file),'utf8');
  const start=performance.now();
  try{
    const ast=call(G.top,[call(G.lex,[source,1,0,0,list([])]),list([])]).a[0];
    const error=call(G.first_error,[ast]);
    if(test.error){if(!error.includes(test.error))throw Error('Expected compile error '+test.error+', got '+error);}
    else{
      if(error)throw Error(error);
      const js=runtime+'\n'+call(G.emit_top,[ast.a[2]])+'\nawait runmain();\n';
      const out=path.join(root,'build/test-program.mjs');fs.writeFileSync(out,js);
      const p=spawnSync(process.execPath,[out],{encoding:'utf8',timeout:15000,maxBuffer:1024*1024});
      if(p.error||p.status!==0)throw Error(p.error?.message||p.stderr);
      if(p.stdout.trim()!==test.want)throw Error('Expected '+JSON.stringify(test.want)+', got '+JSON.stringify(p.stdout.trim()));
    }
    results.push({name:test.name,status:'pass',ms:performance.now()-start});
  }catch(e){results.push({name:test.name,status:'fail',error:e.message});console.error(test.name+': '+e.message)}
}
fs.writeFileSync(path.join(root,'dist/test-report.json'),JSON.stringify(results,null,2)+'\n');
const passed=results.filter(x=>x.status==='pass').length;
console.log(`${passed}/${results.length} local tests passed`);
if(passed!==results.length)process.exitCode=1;

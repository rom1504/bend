import fs from 'node:fs';
import path from 'node:path';
import {spawnSync} from 'node:child_process';
import {pathToFileURL} from 'node:url';
const root=path.resolve(import.meta.dirname,'..');
process.env.BEND_LIBRARY_MODE='1';
const {G,call,list}=await import(pathToFileURL(path.join(root,'dist/bend2c.mjs')));
delete process.env.BEND_LIBRARY_MODE;
const runtime=fs.readFileSync(path.join(root,'src/runtime.mjs'),'utf8');
const upstream=process.env.BEND_UPSTREAM||path.resolve(root,'.bootstrap/upstream');
const rows=[];
const groups=process.argv.slice(2);if(!groups.length)groups.push('run','compile','base','show');
for(const group of groups){
 for(const f of fs.readdirSync(path.join(upstream,'tests',group)).filter(f=>f.endsWith('.bend')).sort()){
  const filename=path.join(upstream,'tests',group,f),source=fs.readFileSync(filename,'utf8');
  const want=source.split('\n').filter(l=>l.startsWith('#|')).map(l=>l.slice(2)).join('\n').trim();
  if(!/^import Base$/m.test(source)||!/^def main\(/m.test(source)||want.startsWith('Error:'))continue;
  const row={test:group+'/'+f,want};
  try{
   const tokens=call(G.lex,[source,1,0,0,list([])]);
   const parsed=call(G.top,[tokens,list([])]);
   const ast=parsed.a[0];
   if(ast.a[0]==='error'){row.status='compile_error';row.got=ast.a[1]}
   else{
    const js=runtime+'\n'+call(G.emit_top,[ast.a[2]])+'\nawait runmain();\n';
    fs.writeFileSync(path.join(root,'build/probe.mjs'),js);
    const p=spawnSync(process.execPath,[path.join(root,'build/probe.mjs')],{encoding:'utf8',timeout:3000,maxBuffer:1024*1024});
    row.got=(p.stdout||'').trim();row.stderr=(p.stderr||'').trim();row.code=p.status;
    row.status=p.error?'timeout':p.status!==0?'runtime_error':row.got===want?'pass':'mismatch';
   }
  }catch(e){row.status='compiler_crash';row.got=e.message}
  rows.push(row);
 }
 console.log(group,rows.filter(x=>x.test.startsWith(group+'/')).reduce((a,x)=>(a[x.status]=(a[x.status]||0)+1,a),{}));
}
fs.writeFileSync(path.join(root,'build/upstream-survey.json'),JSON.stringify(rows,null,2)+'\n');
console.log('TOTAL',rows.reduce((a,x)=>(a[x.status]=(a[x.status]||0)+1,a),{}));

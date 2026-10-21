import fs from 'node:fs';import path from 'node:path';import crypto from 'node:crypto';import{pathToFileURL}from'node:url';
const root=path.resolve(import.meta.dirname,'../../../..'),out=path.resolve(process.argv[2]);
if(fs.existsSync(out)||!out.startsWith(root+'/selfhost/build/phase115/'))throw Error('Fresh control receipt required');
const m=JSON.parse(fs.readFileSync(path.join(import.meta.dirname,'manifest02.json')));
const b=fs.readFileSync(m.api.file);if(b.length!==m.api.bytes||crypto.createHash('sha256').update(b).digest('hex')!==m.api.sha256)throw Error('API changed');
const api=(await import(pathToFileURL(m.api.file))).default;
const table=[[4,4,4,4],[3,3,3,4],[2,2,4,4],[3,2,3,4],[1,1,4,4],[3,1,3,4],[1,1,4,4],[3,1,3,4]],rows=[];
for(let bits=0;bits<8;bits++)for(let policy=0;policy<4;policy++){
 const actual=api.p115_route(policy,!!(bits&4),!!(bits&2),!!(bits&1));
 rows.push({bits,policy,expected:table[bits][policy],actual});if(actual!==table[bits][policy])throw Error('Routing mismatch');
}
fs.writeFileSync(out,JSON.stringify({complete:true,api:m.api,rows,scope:'32 exhaustive Boolean legality/policy combinations. Fixed independent truth table, not whole compiler correctness.'},null,2)+'\n',{flag:'wx'});

// Root-run exact matcher checks; all comparisons execute the generated Bend API.
import fs from 'node:fs';import path from 'node:path';import crypto from 'node:crypto';import {fileURLToPath,pathToFileURL} from 'node:url';
const script=fileURLToPath(import.meta.url),root=path.resolve(path.dirname(script),'../../../../..');
const [apiArg,preparedArg,outArg]=process.argv.slice(2);if(!outArg)throw Error('usage: check-base-chunks.mjs API PREPARED FRESH_OUT');
const pin=file=>{const d=fs.readFileSync(file);return {file:path.resolve(file),bytes:d.length,sha256:crypto.createHash('sha256').update(d).digest('hex')};};
const verify=row=>{const a=pin(row.file);if(a.bytes!==row.bytes||a.sha256!==row.sha256)throw Error('changed '+row.file);};
const manifestFile=path.resolve(preparedArg,'manifest.json'),m=JSON.parse(fs.readFileSync(manifestFile,'utf8')),out=path.resolve(outArg),apiFile=path.resolve(apiArg);
if(!m.complete||m.kind!=='phase110-exact-chunked-base-comparison'||!m.inverseExact)throw Error('invalid prepared comparison');
if(!out.startsWith(path.join(root,'selfhost/build/phase110')+path.sep))throw Error('fresh Phase110 output required');
for(const row of [...m.inputs,m.base,m.source,m.module])verify(row);
const api=(await import(pathToFileURL(apiFile))).default,text=fs.readFileSync(m.base.file,'utf8');
const change=(at)=>text.slice(0,at)+(text[at]==='x'?'y':'x')+text.slice(at+1);
const tests=[['exact',text,true],['empty','',false],['prefix-truncated',text.slice(0,1024),false],['last-truncated',text.slice(0,-1),false],['suffix',text+'\n',false],['prefix',' '+text,false],['first',change(0),false],['middle',change(Math.floor(text.length/2)),false],['chunk-last',change(m.chunkLimit-1),false],['chunk-first',change(m.chunkLimit),false],['last',change(text.length-1),false]];
fs.mkdirSync(out,{recursive:false});const report={kind:'phase110-chunked-base-comparison-controls',complete:false,inputs:[pin(script),pin(apiFile),pin(manifestFile),...m.inputs,m.base,m.source,m.module],rows:[]};
const save=()=>fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n');save();
try{
 if(api.p110_general_base_expected_length()!==m.characters)throw Error('expected length differs');
 for(const [name,input,expected] of tests){const actual=api.p110_general_base_matches(input);report.rows.push({name,characters:input.length,expected,actual});save();if(actual!==expected)throw Error('matcher mismatch '+name);}
 for(const row of report.inputs)verify(row);report.complete=true;save();console.log(JSON.stringify({complete:true,controls:report.rows.length}));
}catch(error){report.error=String(error);save();throw error;}

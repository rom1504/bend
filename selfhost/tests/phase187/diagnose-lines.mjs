// Diagnostic reduction only: the checked Bend assembler owns semantics.
import fs from 'node:fs';
import {pathToFileURL} from 'node:url';
const receipt=JSON.parse(fs.readFileSync(process.argv[2],'utf8'));
const api=(await import(pathToFileURL(receipt.api.file))).default;
const lines=fs.readFileSync(process.argv[3],'utf8').split('\n');
for(let i=0;i<lines.length;i++){
  const line=lines[i].trim();if(!line||line.startsWith('.')||line.startsWith('#')||line.endsWith(':'))continue;
  const r=api.x187_assemble('.text\n'+line+'\n');
  if(r.error&&!r.error.startsWith('undefined local'))console.log(JSON.stringify({line:i+1,text:line,error:r.error}));
}

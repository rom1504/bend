// Syntax-only batch diagnosis using the unchanged pinned upstream parser.
// This neither checks types nor emits or executes candidate code.
import fs from 'node:fs';
import path from 'node:path';
import {pathToFileURL} from 'node:url';
import {pin,verify,workspace,requireThat as need} from '../../tools/build/hosted.mjs';
const args=process.argv.slice(2), out=path.resolve(args[0]), files=args.slice(1);
need(out.startsWith(workspace+'/selfhost/build/')&&!fs.existsSync(out)&&files.length>0,'Fresh output and explicit files required');
fs.mkdirSync(out,{recursive:true});
const assets=JSON.parse(fs.readFileSync(path.join(workspace,'selfhost/manifests/assets-native.json'),'utf8'));
const parser=assets.assets['upstream-bend'];
const parserFile=path.resolve(workspace,parser.file);verify({...parser,file:parserFile});
const B=await import(pathToFileURL(parserFile));
const inputs=[pin(process.execPath),pin(parserFile),...files.map(file=>pin(path.resolve(file)))];
const rows=[];
for(const file of files){
  try{B.parse_book(B.book_nil(),path.dirname(path.resolve(file)),fs.readFileSync(file,'utf8'),'',{});rows.push({file,parsed:true});}
  catch(error){rows.push({file,parsed:false,message:error.message??String(error),diagnostic:error});}
}
inputs.forEach(verify);
const report={kind:'phase186-upstream-syntax-only',complete:true,allParsed:rows.every(r=>r.parsed),inputs,rows,
 scope:'Independent per-file syntax diagnosis only; unresolved references, quantities, types and machine semantics are not checked.'};
fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n');
console.log(JSON.stringify(rows));
process.exitCode=report.allParsed?0:1;

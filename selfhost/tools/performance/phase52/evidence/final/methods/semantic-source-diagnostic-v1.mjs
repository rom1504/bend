import fs from 'node:fs';
import {pathToFileURL} from 'node:url';
const [upstream,source,out]=process.argv.slice(2);
const B=await import(pathToFileURL(upstream+'/bend2/bend.ts'));
try{const book=B.book_nil();await B.book_load(book,source,'',new Map());B.book_valid(book);fs.writeFileSync(out,JSON.stringify({complete:true,checked:true})+'\n',{flag:'wx'});}catch(error){fs.writeFileSync(out,JSON.stringify({complete:true,checked:false,error:B.err_show(error)},null,2)+'\n',{flag:'wx'});process.exitCode=1;}

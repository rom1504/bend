import fs from 'node:fs';
import {pathToFileURL} from 'node:url';
const {inspect,loadApi}=await import('../../../typed-driver.mjs');
const api=await loadApi();
const ary=x=>{let a=[];while(x?.$==='Con'){a.push(x.head);x=x.tail;}return a;};
const result=await inspect(process.argv[2],{mode:'native',api:{...api,nc_compile(book){
 const defs=ary(book).filter(d=>d.name?.includes('fold')||d.name==='main');
 fs.writeFileSync(process.argv[3],JSON.stringify(defs,null,2));
 return {source:'inspection',error:''};
}}});
console.log(JSON.stringify({...result,code:undefined}));
if(result.status!=='ok')process.exitCode=1;

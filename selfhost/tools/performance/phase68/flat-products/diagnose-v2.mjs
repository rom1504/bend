// Read-only compiler diagnostic. Root owns execution; no C build or program run.
import fs from 'node:fs';
import path from 'node:path';
import assert from 'node:assert/strict';
import {createHash} from 'node:crypto';
import {pathToFileURL} from 'node:url';
const [apiArg,inputArg,outArg]=process.argv.slice(2);
const apiPath=path.resolve(apiArg),input=path.resolve(inputArg),out=path.resolve(outArg);
const id=p=>{const bytes=fs.readFileSync(p);return {path:p,sha256:createHash('sha256').update(bytes).digest('hex'),bytes:bytes.length};};
const root=path.resolve(import.meta.dirname,'../../../../..');
const driver=path.join(root,'selfhost/tools/typed-driver.mjs');
const source=fs.readFileSync(apiPath,'utf8');
fs.mkdirSync(out,{recursive:false});
const report={kind:'phase68-product-source-diagnostic',complete:false,api:id(apiPath),input:id(input),method:id(import.meta.filename),driver:id(driver)};
const helper=String.raw`
export function nativeProductDiagnostic(book) {
  const c=(f,...a)=>run_loop(f(...a)),nil={$:'Nil'},list=a=>a.reduceRight((tail,head)=>({$:'Con',head,tail}),nil);
  const array=x=>{const r=[];while(x?.$==='Con'){r.push(x.head);x=x.tail;}if(x?.$!=='Nil')throw Error('Malformed diagnostic list');return r;};
  const kids=t=>array(c($ks$,t)),tag=t=>c($tg$,t),name=t=>c($nm$,t);
  const term=(t,n=3)=>({tag:tag(t),name:name(t),id:c($ix$,t),quantity:c($qt$,t),removed:array(c($rm$,t)),kids:n>0?kids(t).slice(0,12).map(k=>term(k,n-1)):kids(t).length});
  function layout(t) {
    const head=c($nq_layout_type$,book,t),owner=c($lookup$,book,name(head)),ctors=array(c($dc$,owner));
    const result={input:term(t),head:term(head),shape:term(c($nq_layout$,book,t)),owner:{name:c($dn$,owner),kind:c($dk$,owner),arity:c($da$,owner)}};
    if(ctors.length===1){const ctr=ctors[0];let tail=c($nq_layout_specialize$,c($dt$,ctr),c($ks$,head),64);
      result.constructor={name:c($dn$,ctr),arity:c($da$,ctr),telescope:term(c($dt$,ctr))};result.specializedFields=[];
      for(let i=0;i<c($da$,ctr)&&i<8;i++){const h=c($nq_layout_type$,book,tail);result.specializedFields.push(term(h));if(tag(h)!=='All')break;tail=c($kid$,h,1);}
      const end=c($nq_layout_type$,book,tail);result.final=term(end);result.finalExact=c($norm_exact$,end,head);
    }return result;
  }
  const names=c($nc_live_names$,book,list(['main']),nil),signatures=c($book_cached$,c($nq_signatures$,book,names),0);
  const rows=[];
  for(const k of array(names)){const d=c($lookup$,book,k),native=c($db$,d);if(c($dk$,d)!=='Def'||native===true||native?.$==='True')continue;
    const sig=c($lookup$,signatures,k),arity=c($nd_arity$,book,k),row={name:k,arity,type:term(c($dt$,d),5),signature:term(c($dv$,sig)),resultShape:term(c($dt$,sig)),telescope:[]};
    let t=c($dt$,d);for(let i=0;i<24;i++){const h=c($nq_layout_reduce$,t,64);if(tag(h)!=='All'){row.result=layout(h);break;}row.telescope.push({quantity:c($qt$,h),layout:layout(c($kid$,h,0))});t=c($kid$,h,1);}
    if(tag(c($dv$,sig))==='NQSig'){const e=c($nq_entry$,c($ks$,c($dv$,sig)),0,c($da$,sig)),w=c($nq_candidate$,book,k,signatures,e);row.candidate=w;}
    rows.push(row);
  }
  const aliases=['Pair','Sigma','Tuple'].map(k=>{const d=c($lookup$,book,k);return {name:k,kind:c($dk$,d),arity:c($da$,d),type:term(c($dt$,d),5),value:term(c($dv$,d),5)};});
  return {rows,aliases};
}
`;
const derived=path.join(out,'diagnostic-api.mjs');
try {
  for(const name of ['nq_layout_type','nq_signature_def','nq_candidate','norm_exact'])assert(source.includes('function $'+name+'$('),name);
  fs.writeFileSync(derived,source+helper,{flag:'wx'});report.derived=id(derived);
  process.env.BEND_TYPED_API=apiPath;
  process.env.BEND_TYPED_RUNTIME=path.join(root,'selfhost/src/runtime.mjs');
  process.env.BEND_BASE=path.join(root,'selfhost/dist/base.bend');
  const A=await import(pathToFileURL(derived));
  const wrapped={...A.default,nc_compile(book,runtime,requests){report.diagnostic=A.nativeProductDiagnostic(book);throw Error('PRODUCT_DIAGNOSTIC_CAPTURE_COMPLETE');}};
  const D=await import(pathToFileURL(driver));
  report.observation=await D.inspect(input,{mode:'native',api:wrapped,withReport:true});
  assert(report.diagnostic,'Did not reach checked native book');
  assert(String(report.observation.diagnostic??report.observation.reason??'').includes('PRODUCT_DIAGNOSTIC_CAPTURE_COMPLETE'),JSON.stringify(report.observation));
  assert.deepEqual(id(apiPath),report.api);assert.deepEqual(id(input),report.input);assert.deepEqual(id(driver),report.driver);
  report.complete=true;
} catch(error){report.error=error.stack??String(error);process.exitCode=1;}
fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n',{flag:'wx'});
console.log(JSON.stringify({complete:report.complete,report:path.join(out,'report.json'),error:report.error}));

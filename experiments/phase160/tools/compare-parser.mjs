#!/usr/bin/env bun
// Independent pinned parser/loader comparison. No checker, emitter or target.
import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
import {pathToFileURL, fileURLToPath} from 'node:url';

const root=path.resolve(path.dirname(fileURLToPath(import.meta.url)),'../../..');
const requireThat=(condition,message)=>{if(!condition)throw new Error(message);};
const digest=data=>crypto.createHash('sha256').update(data).digest('hex');
const pin=file=>{const raw=fs.readFileSync(file);return {file:path.resolve(file),bytes:raw.length,sha256:digest(raw)};};
const verify=row=>{const actual=pin(row.file);requireThat(actual.bytes===row.bytes&&actual.sha256===row.sha256,'Input changed: '+row.file);};
const options={};
for(let i=2;i<process.argv.length;i+=2){requireThat(process.argv[i].startsWith('--')&&process.argv[i+1],'Expected --key value');options[process.argv[i].slice(2)]=process.argv[i+1];}
requireThat(options.manifest&&options.out,'Required --manifest and fresh --out');
const manifest=JSON.parse(fs.readFileSync(options.manifest,'utf8'));
const report={kind:'phase160-upstream-parser-equivalence',complete:false,sourceChecked:false,
  scope:'Two complete loaded books including Base; same pinned loader/parser; higher-order parser terms lowered to finite syntax. All declaration, constructor, quantity, literal, name, order and metadata fields retained. Only term s source spans omitted. No checker, emitter, generated program or proof execution.',
  manifest:pin(options.manifest),inputs:[...manifest.inputs,manifest.original,manifest.normalized]};
const out=path.resolve(options.out);fs.mkdirSync(out,{recursive:false});
const save=()=>fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n');
save();
try{
  requireThat(manifest.complete&&manifest.targetsRun===false,'Incomplete data preparation');
  requireThat(manifest.source.sha256==='6020f680fd96e59b5a629e3ba898aacfc7f85895e9b2b22f3f1426084f656ce3','Unexpected frozen original');
  report.inputs.forEach(verify);
  const checkerReceipt=manifest.inputs.find(x=>x.file.endsWith('/request-prepare01/checked-api/report.json'));
  requireThat(checkerReceipt,'Missing prior original checking receipt');
  const checked=JSON.parse(fs.readFileSync(checkerReceipt.file,'utf8'));
  requireThat(checked.complete&&checked.checked&&checked.source.sha256===manifest.source.sha256,'Original is not independently checked');
  report.originalCheckingReceipt=checkerReceipt;
  const parserFile=path.join(root,'selfhost/.bootstrap/upstream-phase66/bend2/bend.ts');
  const B=await import(pathToFileURL(parserFile).href);
  const spanless=value=>{
    if(value===undefined)return {$undefined:true};
    if(value===null||typeof value==='string'||typeof value==='boolean')return value;
    if(typeof value==='number'){requireThat(Number.isFinite(value),'Non-finite syntax value');return value;}
    requireThat(typeof value==='object','Unlowered callable in syntax');
    if(Array.isArray(value))return value.map(spanless);
    const result={};
    for(const key of Object.keys(value).sort()){
      if(key==='s'){
        const s=value[key];
        requireThat(s===undefined||(s&&typeof s.beg==='number'&&typeof s.end==='number'&&s.file&&typeof s.file.str==='string'),'Unknown s field');
      }else result[key]=spanless(value[key]);
    }
    return result;
  };
  const term=t=>spanless(B.term_lower(t));
  const ctor=c=>({...c,T:term(c.T)});
  async function syntax(file){
    const text=fs.readFileSync(file,'utf8');
    requireThat((text.match(/^import .*$/gm)||[]).join('\n')==='import Base','Only exact Base import admitted');
    const book=B.book_nil();
    await B.book_load(book,file,'',new Map());
    const rows=new Map();
    for(const name of Object.keys(book.tlds)){
      const d=book.tlds[name];let projected;
      if(d.$==='Def')projected={...d,T:term(d.T),v:d.v===null?null:term(d.v),...(Object.hasOwn(d,'e')?{e:spanless(d.e)}:{})};
      else {requireThat(d.$==='ADT','Unknown top-level kind');projected={...d,T:term(d.T),c:d.c.map(ctor)};}
      rows.set('tld:'+name,JSON.stringify(spanless(projected)));
    }
    for(const name of Object.keys(book.ctrs))rows.set('ctr:'+name,JSON.stringify(spanless(ctor(book.ctrs[name]))));
    requireThat(Object.keys(book.tmps).length===0,'Parser unexpectedly instantiated templates');
    rows.set('book:metadata',JSON.stringify({order:book.order,tlds:Object.keys(book.tlds),ctrs:Object.keys(book.ctrs),hols:book.hols,tmps:[]}));
    return rows;
  }
  const original=await syntax(manifest.original.file);
  if(typeof Bun!=='undefined')Bun.gc(true);
  const normalized=await syntax(manifest.normalized.file);
  requireThat(original.size===normalized.size,'Book row counts differ');
  const hasher=crypto.createHash('sha256');let bytes=0;
  for(const [key,value]of original){
    requireThat(normalized.get(key)===value,'Exact spanless structure differs: '+key);
    const row=JSON.stringify([key,value])+'\n';hasher.update(row);bytes+=Buffer.byteLength(row);
  }
  report.rows=original.size;report.canonicalBytes=bytes;report.canonicalSha256=hasher.digest('hex');
  report.byteEqualPerRow=true;report.complete=true;
  report.inputs.forEach(verify);
}catch(error){report.complete=false;report.error=String(error.stack??error);process.exitCode=1;}
save();console.log(JSON.stringify({complete:report.complete,report:path.join(out,'report.json'),error:report.error??null}));

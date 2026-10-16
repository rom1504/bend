// Root-run finite comparison of the old fresh64 predicate and interval scan.
import fs from 'node:fs';
import path from 'node:path';
import assert from 'node:assert/strict';
import {createHash} from 'node:crypto';
import {pathToFileURL} from 'node:url';
const [apiPath,outPath]=process.argv.slice(2),api=(await import(pathToFileURL(path.resolve(apiPath)))).default;
const list=xs=>xs.reduceRight((tail,head)=>({$:'Con',head,tail}),{$:'Nil'});
const term=(tag,id=0,kids=[])=>({$:'KTerm',tag,name:'',id,quant:0,kids:list(kids),removed:list([]),originBegin:0,originEnd:0});
const variable=id=>term('Var',id),empty=term('Ctr'),unbound='NATIVE_UNBOUND_VARIABLE';
const binding=(id,word='v_'+id)=>({$:'NC_Binding',id,word,kind:{$:'N_W64'}});
const pin=file=>{file=fs.realpathSync(file);const b=fs.readFileSync(file);return {file,bytes:b.length,sha256:createHash('sha256').update(b).digest('hex')};};
const report={complete:false,method:pin(import.meta.filename),api:pin(apiPath),cases:[],scope:'Finite boundaries and malformed Var/env semantics under the unchanged no-wrap n gate; not a universal or whole-compiler proof.'};
try{
  for(const n of [0,273,4294967230]){
    const high=4294967295-n,low=high-63,rows=[
      ['empty',empty,[],[],true],
      ['body-low',variable(low),[],[],false],['body-high',variable(high),[],[],false],
      ['nested-body',term('App',0,[empty,variable(low+17)]),[],[],false],
      ['args-low',empty,[variable(low)],[],false],['args-high',empty,[variable(high)],[],false],
      ['below-range',variable(low-1),[],[],true],
      ['var-is-leaf',term('Var',low-1,[variable(low)]),[],[],true],
      ['env-low',empty,[],[binding(low)],false],['env-high',empty,[],[binding(high)],false],
      ['env-outside',empty,[],[binding(low-1)],true],
      ['env-sentinel',empty,[],[binding(low,unbound)],true],
      ['env-sentinel-first',empty,[],[binding(low,unbound),binding(low)],true],
      ['env-value-first',empty,[],[binding(low),binding(low,unbound)],false]
    ];
    if(high<4294967295)rows.push(['above-range',variable(high+1),[],[],true]);
    for(const [id,body,args,env,expected]of rows){
      const old=api.nd_comb_fresh(body,list(args),list(env),n,64),current=api.nbc_fresh(body,list(args),list(env),n);
      assert.equal(old,expected,id+' old');assert.equal(current,old,id+' equivalence');
      report.cases.push({n,id,low,high,old,current,expected});
    }
  }
  report.complete=true;
}catch(error){report.error=error.stack??String(error);process.exitCode=1;console.error(report.error);}
fs.writeFileSync(outPath,JSON.stringify(report,null,2)+'\n',{flag:'wx'});
console.log(JSON.stringify({complete:report.complete,cases:report.cases.length}));

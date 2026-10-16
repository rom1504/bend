// Root-run emission only. Reuse typed-driver checking, linking and permissions.
import fs from 'node:fs';
import path from 'node:path';
import assert from 'node:assert/strict';
import {createHash} from 'node:crypto';
import {pathToFileURL} from 'node:url';
import * as D from '../../../typed-driver.mjs';

const [baselinePath,candidatePath,outArg]=process.argv.slice(2);
const out=path.resolve(outArg),here=path.join(import.meta.dirname,'fixtures-v2');
assert(out.includes('/selfhost/build/phase99/'));
fs.mkdirSync(out,{recursive:false});
const pin=file=>{file=fs.realpathSync(file);const b=fs.readFileSync(file);return {file,bytes:b.length,sha256:createHash('sha256').update(b).digest('hex')};};
const apis={baseline:(await import(pathToFileURL(path.resolve(baselinePath)))).default,
  candidate:(await import(pathToFileURL(path.resolve(candidatePath)))).default};
const old=await D.loadApi();
const cases=[
  {id:'branches',stdout:'left/right\nleft\nright\nright/left\nleft\nright\nA\nB\nalpha.beta:tail\nplain\n7\nselected-effect\nother-effect\n',stderr:'',args:[]},
  {id:'nct-cat-control',stdout:'right\nleft\nleftright\n',stderr:'',args:[]},
  {id:'strict-unused',expectation:'Native Nat overflow failure must match baseline exit/stdout/stderr; never count a successful 7 as passing.',args:[]},
  {id:'name-key-micro',stdout:'195200000\nalpha:beta\n',stderr:'',args:['alpha:beta']}
];
const report={kind:'phase99-branch-closure-small-emission',complete:false,
  apis:{baseline:pin(baselinePath),candidate:pin(candidatePath)},method:pin(import.meta.filename),
  driver:pin(D.driverPath),driverApi:pin(D.apiPath),base:pin(D.basePath),cases:[],programs:[],
  scope:'Tiny checked sources through the existing driver permission. Emission timing is diagnostic only. Root separately builds/runs all C; this script runs no native subprocess.'};
const save=()=>fs.writeFileSync(out+'/report.json',JSON.stringify(report,null,2)+'\n');
const flagLines=code=>code.split('\n').filter(x=>/^#define NATIVE_(READONLY_OBSERVERS|TYPED_SCALARS|SCALAR_ARRAYS|UNSHARED_ARRAYS|COLD_USER_CTORS|COLD_CTORS) /.test(x));
try{
  for(const row of [cases[3], ...cases.slice(0,3)]){
    const source=pin(path.join(here,row.id+'.bend'));let captured=null;
    const api={...old,nc_compile_checked:(book,runtime,requests,permission)=>{
      const outputs={};
      for(const role of ['baseline','candidate']){
        const start=performance.now(),result=apis[role].nc_compile_checked(book,runtime,requests,permission);
        assert.equal(result.error,'',row.id+' '+role+' '+result.error);
        outputs[role]={result,emitterMs:performance.now()-start};
        const file=out+'/'+row.id+'-'+role+'.c';fs.writeFileSync(file,result.source,{flag:'wx'});
        report.programs.push({...row,id:row.id+'-'+role,role,source,c:pin(file)});
      }
      assert.deepEqual(flagLines(outputs.candidate.result.source),flagLines(outputs.baseline.result.source));
      let shape=null;
      if(row.id==='branches'&&apis.candidate.nc_erase&&apis.candidate.dv&&apis.candidate.lookup){
        const body=apis.candidate.nc_erase(book,apis.candidate.dv(apis.candidate.lookup(book,'select_branch')));
        fs.writeFileSync(out+'/selector-shape.json',JSON.stringify(body,null,2)+'\n');
        shape={closed:apis.candidate.nbc_closed(body,{$:'Nil'}),hasMatch:apis.candidate.nbc_match_list({$:'Con',head:body,tail:{$:'Nil'}})};
      }
      captured={permission,flags:flagLines(outputs.candidate.result.source),shape,
        emitterMs:Object.fromEntries(Object.entries(outputs).map(([role,x])=>[role,x.emitterMs]))};
      return outputs.candidate.result;
    }};
    const result=await D.inspect(source.file,{mode:'native',api});
    assert.equal(result.status,'ok',JSON.stringify(result));assert(captured);
    report.cases.push({...row,source,...captured,emissionPassed:true});save();
  }
  report.complete=true;
}catch(error){report.error=error.stack??String(error);process.exitCode=1;console.error(report.error);}finally{save();}

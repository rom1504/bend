// Root-run saved-API diagnostic: exact compiler predicates, no source edits.
import fs from 'node:fs';import path from 'node:path';import assert from 'node:assert/strict';import {createHash} from 'node:crypto';import {pathToFileURL} from 'node:url';
const[attemptArg,inputArg,outArg]=process.argv.slice(2);assert(attemptArg&&inputArg&&outArg);assert(!fs.existsSync(outArg));const out=path.resolve(outArg);fs.mkdirSync(out);
const sha=x=>createHash('sha256').update(x).digest('hex'),identity=p=>({path:fs.realpathSync(p),sha256:sha(fs.readFileSync(p))});
const attempt=path.resolve(attemptArg),apiFile=path.join(attempt,'equality/api.mjs'),driverFile=path.join(attempt,'snapshot/tools/typed-driver.mjs'),runtime=path.join(attempt,'snapshot/src/runtime.mjs');
const original=fs.readFileSync(apiFile,'utf8'),inputs=[identity(apiFile),identity(driverFile),identity(runtime),identity(inputArg),identity(path.join(attempt,'attempt.json'))];let source=original;
const hook='function $j_flat_root_select$(_book_0, _d_0, _s_0, _normal_0, _graph_0, _locals_0) {';assert.equal(source.split(hook).length,2);
source=source.replace(hook,hook+`
const rootName=$dn$(_d_0);
const rootType=$dt$(_d_0);
const helpers=$j_region_helpers$(_s_0);
const graphDefs=$p42Array(_graph_0);
const localDefs=$p42Array(_locals_0);
const definitions=graphDefs.map(d=>{
  const name=$dn$(d);
  const signature=run_loop($j_flat_signature$(_book_0,$dt$(d),$da$(d),{$:"Nil"},128));
  const componentPlan=run_loop($j_component_cached$(_book_0,name));
  const directPlan=run_loop($j_direct_cached$(_book_0,name));
  const audit=name===rootName?true:run_loop($j_flat_def_audit$(_book_0,_graph_0,_locals_0,d,componentPlan));
  return {name,native:$db$(d),signature,component:$j_pure_valid$(componentPlan),direct:$j_pure_valid$(directPlan),audit};
});
const localDefinitions=localDefs.map(d=>{
  const one={$:"Con",head:d,tail:{$:"Nil"}};
  const audit=run_loop($j_flat_local_audit$(_book_0,_graph_0,_locals_0,one));
  return {name:$dn$(d),native:$db$(d),tag:$tg$($dv$(d)),audit};
});
const signature=run_loop($j_region_signature$(_book_0,rootType,$da$(_d_0)));
const locals=run_loop($j_flat_local_audit$(_book_0,_graph_0,_locals_0,_locals_0));
const guarded=run_loop($j_flat_guarded$(_graph_0,rootName,helpers));
const graph=run_loop($j_flat_graph_audit$(_book_0,_graph_0,_locals_0,rootName,_graph_0));
const rootTerm=run_loop($j_flat_term$(_book_0,_graph_0,$j_region_term$(_s_0)));
const rootAudit=run_loop($j_flat_audit$(_book_0,_graph_0,_locals_0,"",rootTerm,8192));
const flatBook=run_loop($j_flat_book$(_book_0,_graph_0));
const active=run_loop($j_flat_active$(flatBook));
const beforeCache=_book_0.$==="Con"?_book_0.head:null;
const afterCache=flatBook.$==="Con"?flatBook.head:null;
const context={before:beforeCache?{name:$dn$(beforeCache),kind:$dk$(beforeCache),children:$p42Array($dc$(beforeCache)).map(d=>({name:$dn$(d),kind:$dk$(d),native:$db$(d)}))}:null,after:afterCache?{name:$dn$(afterCache),kind:$dk$(afterCache),children:$p42Array($dc$(afterCache)).map(d=>({name:$dn$(d),kind:$dk$(d),native:$db$(d),count:$p42Array($dc$(d)).length}))}:null,coverage:graphDefs.map(d=>{const current=run_loop($lookup$(flatBook,$dn$(d)));return{name:$dn$(d),graphKind:$dk$(d),currentKind:$dk$(current),exact:run_loop($exact_def$(d,current)),one:run_loop($j_covered_defs$(flatBook,_graph_0,{$:"Con",head:d,tail:{$:"Nil"}}))};})};
$p42Rows.push({root:rootName,signature,locals,guarded,graph,rootAudit,active,context,definitions,localDefinitions});
`);
const wrap=[['j_flat_audit','_book_0, _graph_0, _locals_0, _self_0, _t_0, _fuel_0','{kind:"term",tag:$tg$(_t_0),name:$nm$(_t_0),self:_self_0,fuel:_fuel_0}'],['j_flat_type','_book_0, _ty_0, _seen_0, _fuel_0','{kind:"type",tag:$tg$(run_loop($wnf$(_book_0,_ty_0))),name:$nm$(run_loop($wnf$(_book_0,_ty_0))),fuel:_fuel_0}'],['j_flat_call_audit','_book_0, _graph_0, _locals_0, _t_0','{kind:"call",name:$nm$(_t_0),qt:$qt$(_t_0),actual:$terms_len$($ks$(_t_0)),arity:$da$(run_loop($lookup$(_book_0,$nm$(_t_0)))),localTag:$tg$($dv$(run_loop($lookup$(_locals_0,$nm$(_t_0))))),localNative:$db$(run_loop($lookup$(_locals_0,$nm$(_t_0))))}']];
for(const[name,args,row]of wrap){const marker='function $'+name+'$(';assert.equal(source.split(marker).length,2);source=source.replace(marker,'function $p42Original_'+name+'$(');source+=`\nfunction $${name}$(${args}){const r=run_loop($p42Original_${name}$(${args}));if(!r&&$p42Failures.length<150)$p42Failures.push(${row});return r;}\n`;}
source+='\nconst $p42Rows=[],$p42Failures=[];function $p42Array(x){const a=[];while(x.$==="Con"){a.push(x.head);x=x.tail;}return a;}export function p42Admission(){return{rows:$p42Rows,failures:$p42Failures};}\n';
const diagnostic=path.join(out,'api.instrumented.mjs');fs.writeFileSync(diagnostic,source,{flag:'wx'});const acornNative=process.binding('natives')['internal/deps/acorn/acorn/dist/acorn'],acornModule={exports:{}};new Function('module','exports',acornNative)(acornModule,acornModule.exports);acornModule.exports.parse(source,{ecmaVersion:'latest',sourceType:'module'});process.env.BEND_TYPED_API=diagnostic;process.env.BEND_TYPED_RUNTIME=runtime;
const receipt=JSON.parse(fs.readFileSync(path.join(attempt,'attempt.json')));process.env.BEND_BASE=receipt.base?.canonicalPath??receipt.base?.file??path.resolve('selfhost/.bootstrap/upstream-phase23/bend2/base.bend');
const driver=await import(pathToFileURL(driverFile));const result=await driver.inspect(path.resolve(inputArg),{mode:'library'}),module=await import(pathToFileURL(diagnostic));
const report={kind:'phase42-flat-admission-probe',complete:true,checked:result.checked===true,status:result.status,diagnostic:result.diagnostic,producer:identity(import.meta.filename),inputs,instrumented:identity(diagnostic),emittedFlatMarkers:result.code?.split('private flat closed graph').length-1,...module.p42Admission()};
for(const row of inputs)assert.equal(identity(row.path).sha256,row.sha256);fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n',{flag:'wx'});console.log(JSON.stringify(report));assert.equal(result.status,'ok');

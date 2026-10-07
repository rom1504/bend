// Diagnostic operation counters. This module does not execute a compiler.
import assert from 'node:assert/strict';
import {stripTypeScriptTypes} from 'node:module';
import {createHash} from 'node:crypto';
const parserSource=process.binding('natives')['internal/deps/acorn/acorn/dist/acorn'];
const P={exports:{}};new Function('module','exports',parserSource)(P,P.exports);
const parse=s=>P.exports.parse(s,{ecmaVersion:'latest',sourceType:'module'});
const hash=s=>createHash('sha256').update(s).digest('hex');
export const symbol='bend.phase62.work-counts';
const control=`globalThis[Symbol.for(${JSON.stringify(symbol)})]`;
const bendNames=['subst','subst_node','core_rebuild','env_subst_term','env_subst_find',
 'env_tele_fill_loop','env_tele_fill_eager','env_tele_check_loop','tele_check_legacy',
 'norm_eval','norm_eval_node','index_lookup','index_find','index_child_list',
 'infer','check','jd_doc_definition','jd_calls_context','jd_arity','jd_domains',
 'jd_raise','jd_params','jd_live_arity','jd_calls_rows','jd_calls_fact','jd_selected_context',
 'j_call_spine','j_specialize','j_app_type'];
const theoryNames=['term_higher','term_lower','term_wnf','term_force','term_infer','term_check',
 'tele_open','tele_fill','tele_unbind','tele_check'];
const backendNames=['fun_of','tele_unbind','term_open','term_spine','def_raise',
 'js_def','js_expr','js_func','js_host','js_lib'];
const jsName=n=>'$jd$'+[...n].map(c=>/[A-Za-z0-9]/.test(c)?c:'_'+c.codePointAt(0)+'_').join('');
function functions(ast){return ast.body.flatMap(n=>n.type==='ExportNamedDeclaration'?[n.declaration]:[n]).filter(n=>n?.type==='FunctionDeclaration')}
function insertions(source,edits){let s=source;for(const e of [...edits].sort((a,b)=>b.at-a.at))s=s.slice(0,e.at)+e.text+s.slice(e.at);return s}
export function instrument(original,role){
 assert(!original.includes('$p62Counts'));assert(['bend','theory','backend'].includes(role));
 const source=role==='bend'?original:stripTypeScriptTypes(original,{mode:'strip'});
 const ast=parse(source),fs=functions(ast),names=role==='bend'?bendNames:role==='theory'?theoryNames:backendNames;
 const edits=[],probes=[],missing=[],probeBodies=new Set();
 for(const name of names){
  const fname=role==='bend'?jsName(name):name,nodes=fs.filter(n=>n.id.name===fname);
  if(!nodes.length){missing.push(name);continue}assert.equal(nodes.length,1);
  const f=nodes[0];let body=f.body,kind='function-entry';
  if(role==='bend'){
   const first=body.body[0];
   if(first?.type==='ReturnStatement'&&first.argument?.type==='CallExpression'&&first.argument.callee?.name?.endsWith('$scc')){
    const call=first.argument,owner=fs.find(n=>n.id.name===call.callee.name);assert(owner);
    assert.equal(call.arguments[0]?.type,'Literal');assert(Number.isInteger(call.arguments[0].value));
    const loop=owner.body.body.find(n=>n.type==='ForStatement');assert(loop?.body.type==='SwitchStatement');
    const branch=loop.body.cases.find(n=>n.test?.value===call.arguments[0].value);
    assert(branch?.consequent[0]?.type==='BlockStatement');body=branch.consequent[0];kind='scc-logical-entry';
   }else if(first?.type==='ForStatement'){
    assert.equal(first.body.type,'BlockStatement');body=first.body;kind='tail-loop-logical-entry';
   }
  }
  assert(!probeBodies.has(body.start),'Duplicate logical body '+name);probeBodies.add(body.start);
  const index=probes.length;
  edits.push({at:body.start+1,text:`$p62Counts[${index}]++;`,name,kind});
  probes.push({name,kind,bodySha256:hash(source.slice(body.start,body.end))});
 }
 if(role==='backend'){
  const memo=fs.find(n=>n.id.name==='memo');assert(memo);
  const miss=memo.body.body.find(n=>n.type==='IfStatement');assert(miss?.consequent.type==='BlockStatement');
  for(const table of ['FUNS','TELES','OPENS','SPINES']){
   const calls=probes.length;probes.push({name:'memo_'+table+'_calls',kind:'memo-table-call'});
   const misses=probes.length;probes.push({name:'memo_'+table+'_misses',kind:'memo-table-miss'});
   edits.push({at:memo.body.start+1,text:`if(m===${table})$p62Counts[${calls}]++;`,kind:'memo-table-call'});
   edits.push({at:miss.consequent.start+1,text:`if(m===${table})$p62Counts[${misses}]++;`,kind:'memo-table-miss'});
  }
 }
 assert(probes.length>0);
 let suffix='';
 if(role==='bend'){
  const ex=ast.body.filter(n=>n.type==='ExportDefaultDeclaration');assert.equal(ex.length,1);assert.equal(ex[0].declaration.type,'ObjectExpression');
  // Insert binding after 'export default' so the original export retains its value.
  edits.push({at:ex[0].declaration.start,text:'$p62Exports = ',kind:'capture-default-export'});
  suffix='\nfor (const [name,fn] of Object.entries($p62Exports)) if (typeof fn === "function") $p62Exports[name]=function(...args){const old=$p62Counts;$p62Counts=$p62Bucket(name);try{return fn(...args)}finally{$p62Counts=old}};\n';
 }
 const prelude=`\nlet $p62Exports;\nconst $p62Buckets=new Map();\nconst $p62Bucket=name=>{let a=$p62Buckets.get(name);if(!a){a=new Float64Array(${probes.length});$p62Buckets.set(name,a)}return a};\nlet $p62Counts=$p62Bucket("outside-api");\n`;
 suffix+=`${control}.modules[${JSON.stringify(role)}]={names:${JSON.stringify(probes.map(x=>x.name))},reset(){for(const a of $p62Buckets.values())a.fill(0)},phase(name){$p62Counts=$p62Bucket(name)},snapshot(){return Object.fromEntries([...$p62Buckets].map(([k,v])=>[k,Array.from(v)]))}};\n`;
 const middle=insertions(source,edits),output=prelude+middle+suffix;parse(output);
 // Multiple inserts at one offset appear in reverse insertion order.
 let inverse=middle;for(const e of [...edits].reverse().sort((a,b)=>a.at-b.at)){assert.equal(inverse.slice(e.at,e.at+e.text.length),e.text);inverse=inverse.slice(0,e.at)+inverse.slice(e.at+e.text.length)}assert.equal(inverse,source);
 return {output,derivation:{role,originalSha256:hash(original),strippedSha256:hash(source),outputSha256:hash(output),exactInverseToStripped:true,parserSha256:hash(parserSource),probes,missing,edits,scope:'Diagnostic logical entries, not physical allocations or directly comparable AST node counts. TS counts function entries; B2 counts logical tail-loop/SCC visits.'}};
}

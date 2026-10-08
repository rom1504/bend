// Insert observation calls only; preserve all original compiler expressions.
import assert from 'node:assert/strict';
import {createHash} from 'node:crypto';
import {symbol} from './observe.mjs';
const parserSource = process.binding('natives')['internal/deps/acorn/acorn/dist/acorn'];
const P = {exports:{}}; new Function('module','exports',parserSource)(P,P.exports);
const parse = s => P.exports.parse(s,{ecmaVersion:'latest',sourceType:'module'});
const hash = s => createHash('sha256').update(s).digest('hex');
const jsName = n => '$jd$' + [...n].map(c => /[A-Za-z0-9]/.test(c) ? c : '_' + c.codePointAt(0) + '_').join('');
export function instrument(source) {
  assert(!source.includes('$p65Observer'));
  const ast = parse(source), functions = ast.body.filter(n => n.type === 'FunctionDeclaration');
  const edits = [], probes = [], bodies = new Set();
  for (const name of ['subst','subst_node','subst_terms','core_rebuild','core_apply_span','core_beta']) {
    const found = functions.filter(n => n.id.name === jsName(name)); assert.equal(found.length,1,name);
    const f = found[0]; let body = f.body, kind = 'function-entry'; const first = body.body[0];
    if (first?.type === 'ReturnStatement' && first.argument?.type === 'CallExpression' && first.argument.callee?.name?.endsWith('$scc')) {
      const call = first.argument, owner = functions.find(n => n.id.name === call.callee.name);
      assert(owner); assert.equal(call.arguments[0]?.type,'Literal');
      const loop = owner.body.body.find(n => n.type === 'ForStatement'); assert.equal(loop?.body.type,'SwitchStatement');
      const branch = loop.body.cases.find(n => n.test?.value === call.arguments[0].value);
      assert.equal(branch?.consequent[0]?.type,'BlockStatement'); body = branch.consequent[0]; kind = 'scc-logical-entry';
    } else if (first?.type === 'ForStatement') { assert.equal(first.body.type,'BlockStatement'); body = first.body; kind = 'tail-loop-logical-entry'; }
    assert(!bodies.has(body.start)); bodies.add(body.start);
    assert.equal(f.params[0]?.name,'$a0');
    const id = name === 'subst' ? '$a1' : 'undefined';
    edits.push({at:body.start+1,text:`$p65Observer.note(${JSON.stringify(name)},$a0,${id});`,name,kind});
    probes.push({name,kind,bodySha256:hash(source.slice(body.start,body.end))});
  }
  const ex = ast.body.filter(n => n.type === 'ExportDefaultDeclaration'); assert.equal(ex.length,1); assert.equal(ex[0].declaration.type,'ObjectExpression');
  edits.push({at:ex[0].declaration.start,text:'$p65Exports = ',kind:'capture-default-export'});
  let middle = source;
  for (const e of [...edits].sort((a,b)=>b.at-a.at)) middle = middle.slice(0,e.at)+e.text+middle.slice(e.at);
  let inverse = middle;
  for (const e of [...edits].reverse().sort((a,b)=>a.at-b.at)) { assert.equal(inverse.slice(e.at,e.at+e.text.length),e.text); inverse=inverse.slice(0,e.at)+inverse.slice(e.at+e.text.length); }
  assert.equal(inverse,source);
  const prelude = `\nconst $p65Observer=globalThis[Symbol.for(${JSON.stringify(symbol)})]; let $p65Exports;\n`;
  const suffix = '\nfor(const [name,fn] of Object.entries($p65Exports))if(typeof fn==="function")$p65Exports[name]=function(...args){const old=$p65Observer.phase(name);try{return fn(...args)}finally{$p65Observer.phase(old)}};\n';
  const output=prelude+middle+suffix; parse(output);
  return {output,derivation:{parentSha256:hash(source),outputSha256:hash(output),parserSha256:hash(parserSource),exactInverse:true,probes,edits}};
}

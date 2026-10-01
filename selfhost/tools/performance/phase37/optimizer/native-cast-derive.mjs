// Saved-output experiment only. Root executes under the shared supervisor.
import fs from 'node:fs';
import path from 'node:path';
import assert from 'node:assert/strict';
import {createHash} from 'node:crypto';
const [inputArg, tsArg, outArg] = process.argv.slice(2);
assert(inputArg && tsArg && outArg, 'Usage: native-cast-derive.mjs PHASE36_NUMERIC TS_NUMERIC NEW_OUT');
const input = fs.realpathSync(inputArg), typescript = fs.realpathSync(tsArg), out = path.resolve(outArg);
assert(!fs.existsSync(out));
const sha = data => createHash('sha256').update(data).digest('hex');
const identity = file => ({path:fs.realpathSync(file), sha256:sha(fs.readFileSync(file)), bytes:fs.statSync(file).size});
const source = fs.readFileSync(input, 'utf8');
assert.equal(sha(source), '4be6605751c64a403cc73453d62d0562f9bdefad210339637278c0f610e83017');
const native = "native('F32.to_u32',1,x=>!Number.isFinite(x)||x<0||x>=4294967296?0:Math.trunc(x)>>>0);";
assert.equal(source.split(native).length, 2, 'Require exact final native body');
assert(source.indexOf(native) > source.indexOf("native('F32.to_u32'"), 'Earlier saturating registration is overridden');
const expression = '(/* primitive */Math.fround((x3421)*(bitsFloat(1232348160))))';
const generic = 'callOwned(get(G,"F32.to_u32"),[' + expression + '])';
const offsets = [];
for (let start = 0;;) { const at = source.indexOf(generic, start); if (at < 0) break; offsets.push(at); start = at + generic.length; }
assert.equal(offsets.length, 3);
assert(source.lastIndexOf('/* private scalar region */', offsets[0]) > source.indexOf('G["p37.numeric"]='));
assert(offsets[1] < source.indexOf('G["bench"]='));
assert(offsets[2] > source.indexOf('G["bench"]='));
assert(source.slice(offsets[0], offsets[1]).includes('return x3417;'));
const parserText = process.binding('natives')['internal/deps/acorn/acorn/dist/acorn'];
const parser = {exports:{}}; new Function('module','exports',parserText)(parser, parser.exports);
assert.equal(parser.exports.version, '8.16.0');
const parse = text => parser.exports.parse(text, {ecmaVersion:'latest',sourceType:'module'});
const proposalFile = path.join(import.meta.dirname,'../fixtures-new/points-v1.json');
const proposal = JSON.parse(fs.readFileSync(proposalFile));
fs.mkdirSync(out);
const report = {kind:'phase37-private-native-cast-prototype', complete:false, checked:false, certified:false,
  producer:identity(import.meta.filename), parent:identity(input), typescript:identity(typescript),
  proposal:identity(proposalFile),
  parserSha256:sha(parserText), replacements:offsets.map((at,index)=>({offset:at, optimized:index!==1,
    context:['guarded-public-Nat-loop','unchanged-generic-fallback','guarded-private-root-helper'][index]})),
  dependencies:['bench','p37.numeric','F32.to_u32'], modules:[],
  scope:'Replace only two already-guarded private native calls. Keep public native descriptor and generic fallback unchanged. Not compiler admission evidence.'};
for (const counters of [false,true]) for (const variant of ['original','direct']) {
  let text = source;
  if (variant === 'direct') {
    for (const index of [2,0]) text = text.slice(0, offsets[index]) + '$p37NativeCast(' + expression + ')' + text.slice(offsets[index] + generic.length);
    // Copy the final effective implementation for the ablation. Production
    // should share it; the public native descriptor stays unchanged here.
    text = text.replace(native, "function $p37NativeCast(x){" + (counters?'++$p37CastCounts.calls;':'') +
      "return !Number.isFinite(x)||x<0||x>=4294967296?0:Math.trunc(x)>>>0;}\n" +
      "native('F32.to_u32',1,x=>!Number.isFinite(x)||x<0||x>=4294967296?0:Math.trunc(x)>>>0);");
    assert.equal(text.split(generic).length, 2, 'Generic fallback is retained exactly once');
    assert.equal(text.split('$p37NativeCast(' + expression + ')').length, 3);
  }
  if (counters) text += `
const $p37CastCounts={calls:0,arguments:0};
export function privateCastCounts(){return {...$p37CastCounts};}
export function privateCastPoint(x){
 ${variant==='direct' ? `if(regionHostGuard()&&typeof x==='number'&&(Math.fround(x)===x||Number.isNaN(x))&&localGuard(['F32.to_u32']))
   return $p37NativeCast(($p37CastCounts.arguments++,x));` : ''}
 $p37CastCounts.arguments++;return callOwned(get(G,'F32.to_u32'),[x]);
}
`;
  parse(text);
  const file = path.join(out, variant + (counters?'.mjs':'.clean.mjs'));
  fs.writeFileSync(file, text, {flag:'wx'}); report.modules.push({variant,counters,...identity(file)});
}
assert.deepEqual(identity(input),report.parent); assert.deepEqual(identity(typescript),report.typescript);
assert.deepEqual(identity(proposalFile),report.proposal);
report.complete = true;
fs.copyFileSync(import.meta.filename,path.join(out,'consumed-derive.mjs'));
fs.writeFileSync(path.join(out,'derive.json'),JSON.stringify(report,null,2)+'\n',{flag:'wx'});
const cases = proposal.cases.filter(row => row.family === 'numeric-recurrence').map(row => ({id:row.id,point:row.point,
  modules:{original:path.join(out,'original.clean.mjs'),direct:path.join(out,'direct.clean.mjs'),typescript}}));
assert.equal(cases.length,2);
fs.writeFileSync(path.join(out,'compare.json'),JSON.stringify({inputs:[path.join(out,'derive.json'),input,typescript],cases},null,2)+'\n',{flag:'wx'});
console.log(JSON.stringify({complete:true,out,modules:report.modules.length}));

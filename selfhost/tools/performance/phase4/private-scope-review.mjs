// Independent focused exercise of the actual checked-H split workers.
import fs from 'node:fs';
import path from 'node:path';
import assert from 'node:assert/strict';
import {pathToFileURL} from 'node:url';
import {createHash} from 'node:crypto';
import {specializeCompiler} from '../../private-compiler/transform.mjs';
const [inputArg,outArg]=process.argv.slice(2);
if(!outArg)throw Error('Usage: private-scope-review.mjs CHECKED_H NEW_DIRECTORY');
const input=fs.realpathSync(inputArg),out=path.resolve(outArg);fs.mkdirSync(out);
const hash=file=>createHash('sha256').update(fs.readFileSync(file)).digest('hex');
const source=fs.readFileSync(input,'utf8');
const extra='G["scope_review_fork"]=fn(1,function(a){return call(call(get(G,"nb_fork_close"),[ctor("Nil",[]),ctor("Con",["root",ctor("Nil",[])]),]),[a[0]]);});\n';
const enriched=source.replace(/^export \{G,call,list,ctor\};$/m,extra+'export {G,call,list,ctor};');
assert.notEqual(enriched,source);
const candidate=specializeCompiler(enriched,['j_escape','scope_review_fork']);
assert.deepEqual(candidate.stats.calls.scopedDefinitions,['nb_fork_close','j_escape_char_on']);
fs.writeFileSync(path.join(out,'control.mjs'),enriched);
fs.writeFileSync(path.join(out,'candidate.mjs'),candidate.source);
const control=await import(pathToFileURL(path.join(out,'control.mjs'))),fixed=await import(pathToFileURL(path.join(out,'candidate.mjs')));
const rows=[];
for(const value of ['plain','\0','\n','\r','\t','"','\\','\0\n\r\t"\\','🙂']) {
 const expected=control.default.j_escape(value),actual=fixed.default.j_escape(value);
 assert.equal(actual,expected);rows.push({worker:'j_escape',input:value,result:actual});
}
for(const fuel of [0,1,2,32,255]) {
 const expected=control.default.scope_review_fork(fuel),actual=fixed.default.scope_review_fork(fuel);
 assert.deepEqual(actual,expected);rows.push({worker:'nb_fork_close',input:fuel,result:actual});
}
const tools=['../../private-compiler/calls.mjs','../../private-compiler/transform.mjs','../../private-compiler/runtime.mjs','../../private-compiler/constants.mjs','../../private-compiler/tokens.mjs'].map(x=>new URL(x,import.meta.url));
const report={complete:true,scope:'Actual frozen H j_escape and nb_fork_close bodies through generated callers; test-only host roots/wrapper, no full compile or timing claim.',input:{file:input,sha256:hash(input)},tools:[{file:import.meta.filename,sha256:hash(import.meta.filename)},...tools.map(u=>({file:u.pathname,sha256:hash(u)}))],scopedDefinitions:candidate.stats.calls.scopedDefinitions,assertions:rows.length,rows,artifacts:['control.mjs','candidate.mjs'].map(f=>({file:path.join(out,f),sha256:hash(path.join(out,f))}))};
fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n');console.log(JSON.stringify({complete:true,assertions:rows.length,scopedDefinitions:report.scopedDefinitions}));

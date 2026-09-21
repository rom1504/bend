// Freeze a four-cell causal experiment; compare.py performs fresh-process runs.
import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
import {fileURLToPath,pathToFileURL} from 'node:url';
import {transformDirectCalls,globalArities} from './direct-calls.mjs';
import {transformCompactIndex} from './compact-index.mjs';
import {transformPositionalWorkers} from './positional-workers.mjs';

const root=fileURLToPath(new URL('../../../',import.meta.url));
const [destination,cpu='1',repetitions='3',mode='factorial']=process.argv.slice(2);
if(!destination||!['factorial','positional'].includes(mode))throw Error('Usage: node prepare.mjs NEW_DIRECTORY [CPU=1] [REPETITIONS=3] [factorial|positional]');
const out=path.resolve(destination);
if(fs.existsSync(out))throw Error('Output directory must be new');
fs.mkdirSync(path.join(out,'host/tools'),{recursive:true});
const input=path.join(root,'dist/phase1/selfhost-api.mjs');
const original=fs.readFileSync(input,'utf8');
const module=await import(pathToFileURL(input));
const direct=transformDirectCalls(original,{arities:globalArities(module.G),tail:true});
const index=transformCompactIndex(original),combined=transformCompactIndex(direct.source);
let sources={control:original,direct:direct.source,index:index.source,combined:combined.source};
let positional;
if(mode==='positional'){
  positional=transformPositionalWorkers(original);
  sources={control:original,positional:positional.source,'positional-index':transformCompactIndex(positional.source).source};
  fs.copyFileSync(fileURLToPath(new URL('./lexer-probe.mjs',import.meta.url)),path.join(out,'lexer-probe.mjs'));
  sources['positional-index-cursor']='import * as M from "./positional-index.mjs";\nimport {installLexerExperiment} from "./lexer-probe.mjs";\ninstallLexerExperiment(M,"cursor");\nexport {default,G,call,list,ctor} from "./positional-index.mjs";\n';
}
for(const [name,source] of Object.entries(sources))fs.writeFileSync(path.join(out,name+'.mjs'),source);
fs.copyFileSync(path.join(root,'dist/phase1/runtime.mjs'),path.join(out,'runtime.mjs'));
for(const name of ['typed-driver.mjs','compiler-abi.mjs','node-resource-args.mjs','assemble.mjs','native-build.mjs'])
  fs.copyFileSync(path.join(root,'tools',name),path.join(out,'host/tools',name));
const helpers=['prepare.mjs','direct-calls.mjs','compact-index.mjs','positional-workers.mjs','lexer-probe.mjs'].map(name=>fileURLToPath(new URL(name,import.meta.url)));
const hash=text=>crypto.createHash('sha256').update(text).digest('hex');
const provenance={input,sha256:hash(original),mode,direct:direct.stats,index:index.stats,positional:positional?.stats,
  sources:Object.fromEntries(Object.entries(sources).map(([k,v])=>[k,hash(v)])),
  helpers:Object.fromEntries(helpers.map(p=>[p,hash(fs.readFileSync(p))]))};
fs.writeFileSync(path.join(out,'transforms.json'),JSON.stringify(provenance,null,2)+'\n');
const config={node:process.execPath,upstream:path.join(root,'.bootstrap/upstream'),cpu:Number(cpu),
  flags:['--stack-size=4096','--max-old-space-size=4096'],repetitions:Number(repetitions),timeout:180,
  variants:Object.keys(sources).map(name=>({name,kind:'bend',api:path.join(out,name+'.mjs'),
    runtime:path.join(out,'runtime.mjs'),driver:path.join(out,'host/tools/typed-driver.mjs'),
    sourceFiles:[path.join(out,'transforms.json'),...(mode==='positional'?[path.join(out,'positional-index.mjs'),path.join(out,'lexer-probe.mjs')]:[])]})),
  workloads:[{id:'tree-io',input:path.join(root,'tests/fixtures/tree.bend'),expected:'42',caches:['off']}]};
fs.writeFileSync(path.join(out,'config.json'),JSON.stringify(config,null,2)+'\n');
console.log(JSON.stringify({out,mode,sources:provenance.sources},null,2));

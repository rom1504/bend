// P5-017: the core definition-selection component requires no checker helper.
import fs from 'node:fs';import path from 'node:path';import crypto from 'node:crypto';
import {assemble} from '../../assemble.mjs';
const [rootArg,outArg]=process.argv.slice(2);
if(!outArg)throw Error('Usage: core-filter-prepare.mjs FROZEN_SOURCE_ROOT NEW_OUTPUT');
const root=fs.realpathSync(rootArg),out=path.resolve(outArg);fs.mkdirSync(out,{recursive:false});
const identity=file=>({file:fs.realpathSync(file),sha256:crypto.createHash('sha256').update(fs.readFileSync(file)).digest('hex')});
const modules=['term','index','normalize','graph'].map(name=>'src/core/'+name+'.bend');
const inputs=modules.map(file=>identity(path.join(root,file)));
for(const file of modules){const target=path.join(out,'sources',file);fs.mkdirSync(path.dirname(target),{recursive:true});fs.copyFileSync(path.join(root,file),target);}
const source=path.join(out,'component.bend');assemble(modules,source,{root:path.join(out,'sources')});
const report={kind:'phase5-core-filter-component-preparation',complete:true,compilerExecuted:false,inputs,modules,source:identity(source),
 tools:[identity(import.meta.filename),identity(new URL('../../assemble.mjs',import.meta.url).pathname)],
 scope:'Source assembly only. Emit with checked Bend compiler, then run unchanged Phase4 book-final-audit-test.mjs with --require-equivalence.'};
fs.writeFileSync(path.join(out,'preparation.json'),JSON.stringify(report,null,2)+'\n');

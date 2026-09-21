// Emit baseline/candidate parser libraries from one checked, annotated book.
// BEND_TYPED_API selects the checked compiler; argv[2] is a candidate backend API.
import fs from 'node:fs';import path from 'node:path';import {pathToFileURL} from 'node:url';
import {loadApi,inspect,project} from '../../../tools/typed-driver.mjs';import {assemble} from '../../../tools/assemble.mjs';
if(!process.argv[2])throw Error('Provide a candidate backend API module.');
const candidate=(await import(pathToFileURL(path.resolve(process.argv[2])))).default,api=await loadApi();
const directory=path.join(project,'build/js-prof');fs.mkdirSync(directory,{recursive:true});
const modules=JSON.parse(fs.readFileSync(path.join(project,'src/compiler.json'))).modules.filter(x=>x.startsWith('src/core/')||x.startsWith('src/front/')||x.startsWith('src/load/'));
const source=path.join(directory,'frontend.bend');assemble(modules,source,{root:project});
const runtime=fs.readFileSync(path.join(project,'src/runtime.mjs'),'utf8'),baseline=api.j_library_selected;
api.j_roots=()=>({$:'Con',head:'f_parse',tail:{$:'Con',head:'f_lex',tail:{$:'Nil'}}});
api.j_library_selected=(book,defs)=>{for(const [name,emit] of [['baseline',baseline],['candidate',candidate.j_library_selected]]){const start=performance.now(),code=emit(book,defs);fs.writeFileSync(path.join(directory,'frontend-'+name+'.mjs'),runtime+'\n'+code);console.log(name,'emitted',Math.round(performance.now()-start)+'ms')}return ''};
const result=await inspect(source,{mode:'library',api});delete result.code;console.log(JSON.stringify(result));if(result.status!=='ok')process.exitCode=1;

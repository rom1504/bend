/** Diagnostic replacement of the two verified Base Bool workers in H4.
 * Native mode intentionally assumes well-typed Bool inputs. It is not an ABI
 * preserving production patch: malformed host values can change behavior.
 * Staged mode keeps the first application boundary and request fail-stop.
 */
import fs from 'node:fs';
import path from 'node:path';
import {pathToFileURL} from 'node:url';
import {globalArities} from './direct-calls.mjs';
import {transformFlattenCalls} from './flatten-calls.mjs';

export function transformBooleanIntrinsics(source,{mode='native',flatten=false,arities={},assumeTypedBooleans=false,assumeImmutableGlobals=false}={}){
  if(!['native','staged'].includes(mode))throw Error('Expected native or staged Bool mode');
  if(mode==='native'&&!assumeTypedBooleans)throw Error('Native Bool experiment requires explicit typed-Boolean assumption');
  if(flatten&&mode!=='native')throw Error('Staged Bool workers keep their application boundary');
  for(const name of ['False','True']){
    if(!source.includes(`constructorNative["${name}"]=true;`)||source.includes(`constructorNative["${name}"]=false;`))throw Error('Expected native Base Bool constructor provenance');
  }
  let and=0,not=0;
  const code=source.split('\n').map(line=>{
    if(line.startsWith('G["Bool.and"]=')){
      if(!/^G\["Bool.and"\]=matcher\("False",\(\)=>fn\(1,function\(a\)\{const (x\d+)=a\[0\];return build\("False",\[\]\);\}\),\(\)=>matcher1\("True",\(\)=>fn\(1,function\(a\)\{const (x\d+)=a\[0\];return \2;\}\)\)\);$/.test(line))throw Error('Bool.and is not the verified pure Base matcher');
      and++;
      return mode==='native'?'// Rapid experiment retains the existing native Bool.and.':'G["Bool.and"]=fn(1,function(a){const x=a[0];if(x?.request)bad("runtime fail-stop");return fn(1,function(b){return x?b[0]:false;});});';
    }
    if(line.startsWith('G["Bool.not"]=')){
      if(line!=='G["Bool.not"]=matcher("False",()=>ctor("True",[]),()=>matcher1("True",()=>ctor("False",[])));')throw Error('Bool.not is not the verified pure Base matcher');
      not++;
      return mode==='native'?'// Rapid experiment retains the existing native Bool.not.':'G["Bool.not"]=fn(1,function(a){if(a[0]?.request)bad("runtime fail-stop");return !a[0];});';
    }
    return line;
  }).join('\n');
  if(and!==1||not!==1)throw Error('Expected exactly one canonical definition of each Bool worker');
  const flattened=flatten?transformFlattenCalls(code,{arities:{...arities,'Bool.and':2,'Bool.not':1},assumeImmutableGlobals}):{source:code,stats:null};
  return {source:flattened.source,stats:{mode,boolWorkers:2,flatten:flattened.stats,assumption:mode==='native'?'well-typed native Base Bool inputs':'preserve staged first-argument boundary and malformed request guard'}};
}
if(process.argv[1]&&import.meta.url===pathToFileURL(path.resolve(process.argv[1])).href){
  const [input,output,...flags]=process.argv.slice(2);if(!input||!output)throw Error('Usage: node boolean-intrinsics.mjs INPUT OUTPUT [--staged] [--flatten --immutable-globals] [--typed-booleans]');
  if(path.resolve(input)===path.resolve(output))throw Error('Refusing to overwrite original');
  const api=await import(pathToFileURL(path.resolve(input)).href);
  const r=transformBooleanIntrinsics(fs.readFileSync(input,'utf8'),{mode:flags.includes('--staged')?'staged':'native',flatten:flags.includes('--flatten'),arities:globalArities(api.G),assumeTypedBooleans:flags.includes('--typed-booleans'),assumeImmutableGlobals:flags.includes('--immutable-globals')});
  fs.mkdirSync(path.dirname(output),{recursive:true});fs.writeFileSync(output,r.source);fs.writeFileSync(output+'.transform.json',JSON.stringify(r.stats,null,2)+'\n');console.log(JSON.stringify(r.stats));
}

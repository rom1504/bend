// One exact private call-site substitution. Public G entries are untouched.
import fs from 'node:fs';import path from 'node:path';import crypto from 'node:crypto';import assert from 'node:assert/strict';import {pathToFileURL} from 'node:url';
const hash=x=>crypto.createHash('sha256').update(x).digest('hex');
export const expectedImage='4318bbcdb2040ad794387b1466b0bafbe12233e67983224c5a564d13fa5753a3';
const guards={'G["subst_node"]=':'f6d6ffee36b2b6b26d31bc7f45e2d452dd23378f53dec5d7aeb5bece28038d05','G["subst_terms"]=':'acb4386cdbba8228856b1508cdf6b28672d525951e76a7f254fdc8ae2c0c7cdd','function privateWorker1077(':'0240f81e27bb2ba2f8babdee1d0093ab5b084a94aa7e096be2c1be2462d0be20'};
const helpers=`
// P4-025 private finite-data-only workers; original generic entries remain.
function privateSubstShape(value,name,size){if(value===null||typeof value!=='object'||value.$!==name)return false;const fields=value.a;if(!Array.isArray(fields)||fields.length!==size)return false;for(let i=0;i<size;i++)if(!Object.hasOwn(fields,i))return false;return true;}
function privateSubstNodeWorker(term,id,replacement){
 if(!privateSubstShape(term,'KTerm',6))return jump(call(call(get(G,'subst_node'),[term]),[id]),[replacement]);
 const fields=project('KTerm',term);
 return privateTail1075(ctor('KTerm',[fields[0],fields[1],fields[2],fields[3],force(privateSubstTermsWorker(fields[4],id,replacement)),fields[5]]));
}
function privateSubstNodeTail(term,id,replacement){return {bounce:true,privateWorker:privateSubstNodeWorker,args:[term,id,replacement]};}
function privateSubstTermsWorker(terms,id,replacement){
 if(privateSubstShape(terms,'Nil',0))return build('Nil',[]);
 if(!privateSubstShape(terms,'Con',2))return jump(call(call(get(G,'subst_terms'),[terms]),[id]),[replacement]);
 const fields=project('Con',terms),head=fields[0],tail=fields[1];
 return build('Con',[()=>privateTail1077(head,id,replacement),()=>privateSubstTermsTail(tail,id,replacement)]);
}
function privateSubstTermsTail(terms,id,replacement){return {bounce:true,privateWorker:privateSubstTermsWorker,args:[terms,id,replacement]};}
`;
export function substitutionWorkers(source){
 assert.equal(hash(source),expectedImage,'Unsupported private image');const lines=source.split('\n'),record=[];
 for(const [prefix,sha]of Object.entries(guards)){const matches=lines.filter(x=>x.startsWith(prefix));assert.equal(matches.length,1);assert.equal(hash(matches[0]),sha,'Body guard failed: '+prefix);record.push({prefix,sha256:sha,source:matches[0]});}
 const original=record[2].source,from='jump(call(call(get(G,"subst_node"),[x6709]),[x6710]),[x6711])';assert.equal(original.split(from).length,2);
 const changed=original.replace(from,'privateSubstNodeTail(x6709,x6710,x6711)');const result=source.replace(original,changed)+'\n'+helpers;
 for(const item of record.slice(0,2))assert.ok(result.includes(item.source+'\n'));
 return {source:result,stats:{inputSha256:expectedImage,outputSha256:hash(result),changedCallSites:1,guards:record,originalBody:original,changedBody:changed,publicGlobalBodiesUnchanged:true,scope:'Exact private immutable finite-data image only; already-computed arguments. Original staged fallback for all noncanonical field shapes.'}};
}
if(process.argv[1]&&import.meta.url===pathToFileURL(path.resolve(process.argv[1])).href){const [input,outArg]=process.argv.slice(2);if(!outArg)throw Error('Usage: private-substitution-workers.mjs IMAGE NEW_DIRECTORY');const out=path.resolve(outArg);fs.mkdirSync(out);const source=fs.readFileSync(input,'utf8'),result=substitutionWorkers(source);fs.writeFileSync(path.join(out,'image.mjs'),result.source);fs.writeFileSync(path.join(out,'transform.json'),JSON.stringify({complete:true,input:path.resolve(input),toolSha256:hash(fs.readFileSync(import.meta.filename)),...result.stats},null,2)+'\n');}

import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
import {pathToFileURL} from 'node:url';
const [apiFile,outFile]=process.argv.slice(2);
const a=(await import(pathToFileURL(path.resolve(apiFile)))).default;
if(!a.p205t_probe) throw Error('Export p205t_probe, p86_plan and p88_cache_prepare from the checked compiler');
const binding=JSON.parse(fs.readFileSync('selfhost/build/phase197/shared-emission-plan01.json')).producer.bindingValue;
function authenticated(row){const b=fs.readFileSync(row.file);if(b.length!==row.bytes||crypto.createHash('sha256').update(b).digest('hex')!==row.sha256)throw Error('pin');return b.toString();}
const prep=a.p88_cache_prepare(binding.base.file,authenticated(binding.base),authenticated(binding.carrier),binding.stamp);
if(prep.$!=='P86PreparationReady')throw Error('base');
const base='selfhost/tools/bench/catalogs/native45/fixtures/';
const orig=fs.readFileSync(base+'coverage-bst-64.bend','utf8');
const transfer=orig.replaceAll('bst.pick','other.choose').replaceAll('bst.step','other.advance').replaceAll('bst.down','other.descend')
 .replaceAll('bst.up','other.restore').replaceAll('insert.fin','other.close').replaceAll('BFrame','History').replaceAll('BLeaf','Vacant')
 .replaceAll('BNode','Forked').replace(/\bBF\b/g,'Remember').replace(/\bBST\b/g,'Index');
const extra=orig.replace('  inorder(p37.bst.build(', '  U32.add(inorder(bst.up(Nil{}, BLeaf{}), 0), inorder(p37.bst.build(')
 .replace('seed, BLeaf{}), 0)\n','seed, BLeaf{}), 0))\n');
const fixtures=[
 ['original',orig,'changed:2'],['renamed',transfer,'changed:2'],
 ['shared helper',extra,'unchanged'],['direction flip',orig.replace('U32.is_lt(x, v)','U32.is_gt(x, v)'),'unchanged'],
 ['wrong accumulator',orig.replace('bst.up(rest, BNode{acc, v, other})','bst.up(rest, BNode{other, v, acc})'),'unchanged'],
 ['wrong producer tag',orig.replace('BF{v, r, True{}}','BF{v, r, False{}}'),'unchanged'],
 ['unrelated lexer',fs.readFileSync(base+'lexer.bend','utf8'),'unchanged']];
const checks=[];
for(const [label,source,expected] of fixtures){
 const plan=a.p86_plan(prep.seed,path.resolve(base+'coverage-bst-64.bend'),source);
 const observed=a.p205t_probe(plan);
 checks.push({label,expected,observed});fs.writeFileSync(outFile,JSON.stringify(checks,null,2)+'\n');
 if(observed!==expected)throw Error(label+': '+observed);
}

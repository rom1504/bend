// Offline small-control source generator, no compiler imports/execution.
// The copied declarations retain exact production source text and hashes.
import fs from 'node:fs';
import path from 'node:path';
import assert from 'node:assert/strict';
import {createHash} from 'node:crypto';
const out=path.resolve(process.argv[2]);assert(!fs.existsSync(out),'fresh output directory required');
const root=path.resolve(import.meta.dirname,'../../../../..');
const inputs=[],types=[];
const sha=b=>createHash('sha256').update(b).digest('hex');
for(const [file,names] of [
  ['selfhost/src/core/term.bend',['KTerm','KDef']],
  ['selfhost/src/check/prefix-state.bend',['KBasePrefixState','KBasePreparedWorld']],
  ['selfhost/src/load/prefix.bend',['FFreshPrefixState','FReadyPrefixState']]]){
  const p=path.join(root,file),b=fs.readFileSync(p),text=b.toString();
  inputs.push({file:p,sha256:sha(b),bytes:b.length});
  for(const n of names){const m=text.match(new RegExp('^type '+n+' is Data:\\n(?:  .*(?:\\n|$))+','m'));assert(m,n);types.push(m[0].trim());}
}
const decoderFile=path.join(import.meta.dirname,'decoder.bend'),decoder=fs.readFileSync(decoderFile,'utf8');
inputs.push({file:decoderFile,sha256:sha(decoder),bytes:Buffer.byteLength(decoder)});
const strings=['Typ','λ🙂','','Def'];
const rows=[
  [0],[2,0,1,0,0,0,0,1,2],[5,1,3,0,0,1,1,0,0,0],
  [1,2,0],[6,4294967295,3],[8,1,0,0,0,1],[9,1,1],
  [10,5,3,3,3,0,0,0,1],[11,4,4,1,1],
];
const roots=[3,5,6,7,8],stamp='p88-small-control-v1';
const str=s=>[...s].length+'\n'+s+'\n';
const wire=(rs=rows,rt=roots)=>str(stamp)+rs.length+'\n'+strings.length+'\n'+strings.map(str).join('')+rs.map(r=>[r[0],r.length-1,...r.slice(1)].join('\n')+'\n').join('')+rt.join('\n')+'\n';
const mutate=(i,j,n)=>{const copy=structuredClone(rows);copy[i][j]=n;return wire(copy);};
const cases=[
  {name:'shared-full-products-unicode-u32max',wire:wire(),pass:true},
  {name:'wrong-stamp',wire:wire(),expectedStamp:stamp+'!',pass:false},
  {name:'truncated',wire:wire().slice(0,-3),pass:false},
  {name:'trailing',wire:wire()+'x',pass:false},
  {name:'forward-reference',wire:mutate(3,1,3),pass:false},
  {name:'wrong-ref-family',wire:mutate(4,2,1),pass:false},
  {name:'bad-bool',wire:mutate(6,2,2),pass:false},
  {name:'ready-false',wire:mutate(6,2,0),pass:false},
  {name:'invalid-tag',wire:mutate(6,0,12),pass:false},
  {name:'source-span',wire:mutate(1,8,8),pass:false},
  {name:'wrong-root',wire:wire(rows,[3,5,6,1,8]),pass:false},
  {name:'u32-overflow',wire:wire().replace('4294967295\n','4294967296\n'),pass:false},
  {name:'leading-zero',wire:wire().replace('4294967295\n','04294967295\n'),pass:false},
  {name:'wrong-width',wire:wire().replace('\n6\n2\n4294967295\n','\n6\n1\n4294967295\n'),pass:false},
  {name:'node-bound',wire:wire().replace(stamp+'\n9\n',stamp+'\n65537\n'),pass:false},
  {name:'unicode-length',wire:wire().replace('\n2\nλ🙂\n','\n3\nλ🙂\n'),pass:false},
];
assert.equal(new Set(cases.map(c=>c.wire+'\0'+c.expectedStamp)).size,cases.length);
const helpers=`
@unsafe
def p88_control_term(t: KTerm) -> Bool:
  match t:
    case KTerm{a,b,0,0,Nil{},Nil{},1,2}: String.eq(a,"Typ") && String.eq(b,"λ🙂")
    case other: False{}

@unsafe
def p88_control_defs(xs: List<&2,KDef>) -> Bool:
  match xs:
    case Con{KDef{a,b,0,0,t,v,Nil{},False{},False{}},Nil{}}: String.eq(a,"λ🙂") && String.eq(b,"Def") && p88_control_term(t) && p88_control_term(v)
    case other: False{}

@unsafe
def p88_control_index(d: KDef) -> Bool:
  match d:
    case KIndexLeaf{4294967295,xs}: p88_control_defs(xs)
    case other: False{}

@unsafe
def p88_control_positive(result: P88Decoded) -> Bool:
  match result:
    case P88DecodeReady{P88Products{book,FFreshPrefixState{1,True{}},FReadyPrefixState{names,ctors,1,True{}},KBasePreparedWorld{KBasePrefixState{1,0,0,Nil{},True{}},prefix,final,saved,Nil{},Nil{},0,1}}}:
      p88_control_defs(book) && p88_control_defs(prefix) && p88_control_defs(final) && p88_control_defs(saved) && p88_control_index(names) && p88_control_index(ctors)
    case other: False{}

@unsafe
def p88_control_negative(result: P88Decoded) -> Bool:
  match result:
    case P88DecodeError{error}: True{}
    case other: False{}
`;
const checks=cases.map((c,i)=>`  +c${i} = p88_control_${c.pass?'positive':'negative'}(p88_decode_admitted(${JSON.stringify(c.wire)},${JSON.stringify(c.expectedStamp??stamp)},1,8))`).join('\n');
const main=`\n@unsafe\ndef main() -> Bool:\n${checks}\n  ${cases.map((_,i)=>'c'+i).join(' && ')}\n#|True{}\n`;
const source='import Base\n\n'+types.join('\n\n')+'\n\n'+decoder.replace(/^import Base\n/m,'')+'\n'+helpers+main;
fs.mkdirSync(out);fs.writeFileSync(path.join(out,'controls.bend'),source,{flag:'wx'});
fs.writeFileSync(path.join(out,'fixtures.json'),JSON.stringify({kind:'phase88-base-small-controls',inputs,stamp,cases,source:{sha256:sha(source),bytes:Buffer.byteLength(source)},limitation:'Readiness in this synthetic fixture is a decoder shape control, not a real checked Base capability.'},null,2)+'\n',{flag:'wx'});
console.log(JSON.stringify({file:path.join(out,'controls.bend'),cases:cases.length,inputs,sha256:sha(source)}));

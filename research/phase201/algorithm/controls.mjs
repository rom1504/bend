import fs from 'node:fs';
import path from 'node:path';
import {fileURLToPath,pathToFileURL} from 'node:url';
import {pin,verify} from '../../../selfhost/tools/build/hosted.mjs';

const args=Object.fromEntries(process.argv.slice(2).reduce((pairs,item,i,all)=>i%2?pairs:[...pairs,[item,all[i+1]]],[]));
if(!/^Cpus_allowed_list:\s*3$/m.test(fs.readFileSync('/proc/self/status','utf8')))throw Error('guarded CPU3 required');
const receipt=JSON.parse(fs.readFileSync(args['--api']));
if(!receipt.complete||!receipt.checked||receipt.error)throw Error('checked API required');
verify(receipt.api);verify(receipt.source);
const api=(await import(pathToFileURL(receipt.api.file))).default;
const list=values=>values.reduceRight((tail,head)=>({$:'Con',head,tail}),{$:'Nil'});
function unpack(xs){const values=[];while(xs.$==='Con'){values.push(xs.head);xs=xs.tail;}if(xs.$!=='Nil')throw Error('malformed list');return values;}
const patch=(offset,addendLo)=>({$:'X187Relocation',section:1,offset,kind:2,symbol:'.L',addendLo,addendHi:0});
const z=n=>Array(n).fill(0);
const cases=[
  ['empty',[],[],[]],['no patches',[11,22,33],[],[11,22,33]],
  ['first',[...z(4),17],[[0,0xfedcba98]],[152,186,220,254,17]],
  ['last',[7,11,...z(4)],[[2,0x12345678]],[7,11,120,86,52,18]],
  ['adjacent',z(8),[[0,0x80000000],[4,0xffffffff]],[0,0,0,128,255,255,255,255]],
  ['two separated',[5,...z(4),19,20,21,...z(4),6],[[1,2],[8,3]],[5,2,0,0,0,19,20,21,3,0,0,0,6]],
  ['placeholder',[0,0,1,0],[[0,1]],'invalid local branch placeholder'],
  ['overlap',z(10),[[0,1],[2,7]],'overlapping or unordered local branch fixup'],
  ['descending',z(10),[[4,1],[0,7]],'overlapping or unordered local branch fixup'],
  ['truncated',z(4),[[1,7]],'invalid local branch placeholder'],
  ['past end',z(4),[[6,7]],'local branch fixup outside text'],
  ['wrap',z(4),[[0xffffffff,7]],'local branch fixup outside text'],
  ['earlier failure before overlap',[1,...z(9)],[[0,1],[1,7]],'invalid local branch placeholder'],
];
for(const [name,bytes,edits,expected] of cases){
  const ps=list(edits.map(([o,w])=>patch(o,w))), plan=api.x201f_plan(ps,bytes.length,0,list([]));
  const candidate=api.x201f_selected(list([...bytes].reverse()),ps,bytes.length,plan);
  const baseline=api.x188_fixup_bytes(list(bytes),ps,0,list([]));
  for(const result of [candidate,baseline]){
    if(result.$!=='X187Encoded'||unpack(result.relocations).length)throw Error('malformed '+name);
    const got=result.error||unpack(result.bytes);if(JSON.stringify(got)!==JSON.stringify(expected))throw Error(`${name}: ${JSON.stringify(got)}`);
  }
}
const out=path.resolve(args['--out']);fs.mkdirSync(out);
fs.writeFileSync(path.join(out,'report.json'),JSON.stringify({complete:true,api:receipt.api,source:receipt.source,driver:pin(fileURLToPath(import.meta.url)),cases:cases.map(r=>r[0])},null,2)+'\n');

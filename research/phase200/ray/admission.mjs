import fs from 'node:fs';
import path from 'node:path';
import {pathToFileURL,fileURLToPath} from 'node:url';
import {pin,verify} from '../../../selfhost/tools/build/hosted.mjs';
const args=process.argv.slice(2),o=Object.fromEntries(Array.from({length:args.length/2},(_,i)=>args.slice(2*i,2*i+2)));
const receipt=JSON.parse(fs.readFileSync(o['--api']));if(!receipt.complete||!receipt.checked||receipt.error)throw Error('unchecked');
verify(receipt.api);verify(receipt.source);const api=(await import(pathToFileURL(receipt.api.file))).default;
const node=($,rest={})=>({$,...rest}),list=a=>a.reduceRight((tail,head)=>node('Con',{head,tail}),node('Nil'));
const local=name=>node('N111Local',{name}),word=(lo,hi=0)=>node('N111Const',{lo,hi});
const arg=(typ,value)=>node('N111Arg',{typ:node('N111'+typ),value});
const call=(id,count)=>node('N111Call',{name:'answer',typ:node('N111U64'),symbol:'p111_rt_op',args:list([arg('Ptr',local('state')),arg('U32',word(id)),arg('Ptr',local('buffer')),arg('U32',word(count))])});
let ordinary=0;
for(let id=0;id<89;id++)for(let n=0;n<4;n++)for(const enabled of [false,true]){
 const expected=enabled&&((id>=26&&id<=35&&n===2)||([23,36,58].includes(id)&&n===1));
 const got=api.x186_inline_op_when(node(enabled?'True':'False'),call(id,n));
 if((got.$==='X186InlineF32')!==expected)throw Error('admission '+id+'/'+n+'/'+enabled);
 ordinary++;
}
const mutations=[x=>x.typ=node('N111U32'),x=>x.symbol='foreign',x=>x.args.head.value=local('other'),x=>x.args.tail.head.value.hi=1,x=>x.args.tail.tail.head.value=local('state'),x=>x.args.tail.tail.tail.head.value.hi=1,x=>x.args.tail.tail.head.typ=node('N111U64'),x=>x.args.tail.tail.tail.head.value=local('arity')];
for(const mutate of mutations){const x=call(36,1);mutate(x);if(api.x186_inline_op_when(node('True'),x).$!=='X186InlineNone')throw Error('malformed sqrt admitted');}
fs.mkdirSync(o['--out']);fs.writeFileSync(path.join(o['--out'],'report.json'),JSON.stringify({complete:true,api:receipt.api,source:receipt.source,method:pin(fileURLToPath(import.meta.url)),ordinaryAdmissions:ordinary,malformedRefusals:mutations.length},null,2)+'\n');

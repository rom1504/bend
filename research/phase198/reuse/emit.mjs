// Only checked Bend exports perform lowering, recognition, selection, and object emission.
import fs from 'node:fs';
import path from 'node:path';
import {pathToFileURL,fileURLToPath} from 'node:url';
import {pin,verify} from '../../../selfhost/tools/build/hosted.mjs';
const opt=Object.fromEntries(Array.from({length:(process.argv.length-2)/2},(_,i)=>process.argv.slice(2+i*2,4+i*2)));
const out=path.resolve(opt['--out']), read=p=>JSON.parse(fs.readFileSync(p,'utf8'));
const auth=read(opt['--api']);
if(!auth.checked||!auth.complete||auth.error)throw Error('checked API');
verify(auth.source);verify(auth.api);
const api=(await import(pathToFileURL(auth.api.file))).default;
const binding=read('selfhost/build/phase195/ctor-gate-emission-plan01.json').producer.bindingValue;
verify(binding.engine);verify(binding.base);verify(binding.carrier);
if(fs.realpathSync(binding.engine.file)!==fs.realpathSync(process.execPath))throw Error('engine');
fs.mkdirSync(out,{recursive:false});
const report={complete:false,source:auth.source,api:auth.api,driver:pin(fileURLToPath(import.meta.url)),cases:[],controls:[]};
const save=()=>fs.writeFileSync(path.join(out,'report.json'),JSON.stringify(report,null,2)+'\n');
function bytes(x){const chunks=[];let a=[];for(;x.$==='Con';x=x.tail){a.push(x.head);if(a.length===65536){chunks.push(Buffer.from(a));a=[];}}if(x.$!=='Nil')throw Error('bytes');chunks.push(Buffer.from(a));return Buffer.concat(chunks);}
const make=(t,keys,values)=>Object.fromEntries([['$',t],...keys.map((k,i)=>[k,values[i]])]);
const list=vs=>vs.reduceRight((tail,head)=>({$:'Con',head,tail}),{$:'Nil'});
const atom=t=>({$:t}), U64=atom('N111U64'), U32=atom('N111U32'), PTR=atom('N111Ptr');
const local=name=>({$:'N111Local',name}), val=(lo,hi=0)=>({$:'N111Const',lo,hi}), cid=name=>({$:'N111CtorId',name}), arg=(typ,value)=>({$:'N111Arg',typ,value});
const scalar=stmt=>({$:'P113DScalar',stmt}), bin=(name,op,left,right)=>scalar({$:'N111Bin',name,typ:U64,op,left,right});
const ctor='IndependentPair', params=['state','x','y'], buf=local('scratch'), st=arg(PTR,local('state')), work=arg(PTR,buf);
const call=(name,symbol,v)=>scalar({$:'N111Call',name,typ:U64,symbol,args:list([st,v,work])});
const load=(name,offset)=>scalar({$:'N111Load',name,typ:U64,base:buf,offset});
const store=(offset,value)=>scalar({$:'N111Store',typ:U64,base:buf,offset,value:local(value)});
const result=name=>({$:'P113DResult',values:list([local(name)])});
function selected(order,mut='') {
    const makeTag=(x,sub)=>[
        bin('tag','shr',local(x),val(mut==='shift'&&x==='x'?39:40)),bin('tag','and',local('tag'),val(65535)),
        bin('cond','eq',local('tag'),cid(mut==='second-tag'&&x==='y'?'Other':ctor)),
        {$:'P113DIf',condition:local('cond'),yes:list(sub),no:list([result('x')])}];
    const take=(x,first)=>[call('discard','p125_rt_take2',arg(U64,local(x))),load('fld'+first,0),load('fld'+(first+1),8)];
    const box=(name,a,b)=>[store(0,a),store(8,b),call(name,'p125_rt_ctor2',arg(U32,cid(ctor)))];
    const g=i=>'fld'+order[i];
    const core=[...take(mut==='reused-owner'?'x':'y',2),...box('one',g(0),g(1)),...box('two',g(2),g(3)),...box('pair','one','two'),result('pair')];
    if(mut==='effect')core.splice(2,0,call('hidden','p111_rt_keep',arg(U64,local('x'))));
    if(mut==='write-escape')core.splice(2,0,scalar({$:'N111Store',typ:U64,base:local('state'),offset:8,value:local('x')}));
    if(mut==='changed-return')core[core.length-1]=result('one');
    if(mut==='extra-box')core.splice(core.length-1,0,...box('spare','fld0','fld1'));
    if(mut==='clobber')core.splice(3,0,scalar({$:'N111Set',name:'fld0',typ:U64,value:local('fld1')}));
    const rows=makeTag('x',[...take('x',0),...makeTag('y',core)]);
    return api.x198_perm_pick(list(mut==='duplicate-param'?['state','x','x']:mut==='result-out'?['state','__x181_result_out','y']:params),
      list(mut==='setup'?[store(0,'x')]:[]),list(rows));
}
for(let a=0;a<4;a++)for(let b=0;b<4;b++)for(let c=0;c<4;c++)for(let d=0;d<4;d++){
    const vals=[a,b,c,d],diff=vals.map((v,i)=>v===i?-1:i).filter(i=>i>=0);
    const ok=new Set(vals).size===4&&diff.length===2,p=selected(vals);
    if(ok?(p.$!=='X198Perm'||p.ctor!==ctor||p.slot_a!==diff[0]||p.slot_b!==diff[1]):p.$!=='X198NoPerm')throw Error('transposition '+vals+' '+JSON.stringify(p));
    report.controls.push({vals,ok});
}
for(const mut of ['shift','second-tag','reused-owner','effect','write-escape','changed-return','extra-box','clobber','duplicate-param','result-out','setup']){
    if(selected([0,2,1,3],mut).$!=='X198NoPerm')throw Error('fault '+mut);
    report.controls.push({mut,ok:false});
}
save();
const cache=api.p88_cache_prepare(binding.base.file,fs.readFileSync(binding.base.file,'utf8'),fs.readFileSync(binding.carrier.file,'utf8'),binding.stamp);
if(cache.$!=='P86PreparationReady')throw Error('cache');
const refs=read('selfhost/build/phase195/references01/manifest.json').cases;
for(const id of (opt['--cases']??'tree-bitonic').split(',')){
    const ref=refs.find(r=>r.id===id); verify(ref.source);
    const one=api.p86_plan(cache.seed,ref.source.file,fs.readFileSync(ref.source.file,'utf8'));
    if(one.$!=='P86PlanReady')throw Error('front '+one.error);
    const prep=api.p169np_plan(one);if(prep.error)throw Error('lower '+prep.error);
    const machine=api.x181_prepared(prep);if(machine.error)throw Error('select '+machine.error);
    const code=api.x188_many(machine.chunks), rendered=api.x188_render(code);
    const prefix=path.join(out,id);fs.writeFileSync(prefix+'.s',rendered);
    const obj=api.x188_assemble(code);if(obj.error)throw Error('object '+obj.error);
    fs.writeFileSync(prefix+'.o',bytes(obj.bytes));
    const plans=[...rendered.matchAll(/^p198r_original_(\w+):$/gm)].map(m=>m[1]);
    report.cases.push({id,source:ref.source,object:pin(prefix+'.o'),assembly:pin(prefix+'.s'),plans});
    save();
}
report.complete=true;save();

import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
const out=process.argv[2],dir=process.argv[3];
fs.mkdirSync(out);
const rc=JSON.parse(fs.readFileSync(dir+'/report.json'));
const src=fs.readFileSync(rc.api.file);
if(crypto.createHash('sha256').update(src).digest('hex')!==rc.api.sha256)throw Error('api');
let s=src.toString();
const trace={};
for(const [name,code] of [
 ['p205_law','globalThis.hook.push(["law",_rep_0,_join_0,_split_0]);'],
 ['p205_recheck','globalThis.hook.push(["proposal",_changed_0.name]);'],
 ['p205_recheck_c0','globalThis.hook.push(["checked",_changed_0.name]);'],
 ['p205_verify','globalThis.hook.push(["role",_role_0,_state_0.$]);'],
 ['p205_ready','globalThis.raw=_context_0;'],
]) {
 const regex=new RegExp('function \\$'+name+'\\([^\\n]*\\) \\{');
 if(!regex.test(s))throw Error(name);
 s=s.replace(regex, '$&'+code);
}
const a=(await import('data:text/javascript;base64,'+Buffer.from(s).toString('base64'))).default;
const b=JSON.parse(fs.readFileSync('selfhost/build/phase197/shared-emission-plan01.json')).producer.bindingValue;
function contents(pin){const buf=fs.readFileSync(pin.file);if(crypto.createHash('sha256').update(buf).digest('hex')!==pin.sha256)throw Error('asset');return buf.toString()}
const prep=a.p88_cache_prepare(b.base.file,contents(b.base),contents(b.carrier),b.stamp);
for(const f of process.argv.slice(4)){
 globalThis.hook=[]; globalThis.raw=null;
 const plan=a.p86_plan(prep.seed,path.resolve(f),fs.readFileSync(f,'utf8'));const events=globalThis.hook;
 trace[f]={status:plan.$,error:plan.error,matched:events.filter(e=>e[0]==='proposal'||e[0]==='checked'),calls:events.filter(e=>e[0]==='law')};
 if(globalThis.raw && f.includes('unicode-text')){
   const roles=['repeat','join','split','join_rest','pick','push','append'], names=['p37.text.repeat','sjoin','ssplit','sjoin.go','ssplit.pick','ssplit.push','String.append'];
   let bindings=a.missing();for(let i=0;i<3;i++)bindings=a.p205_role(bindings,roles[i],names[i]).value;
   let st={$:'Some',value:bindings};const stOut=[];
   for(let i=0;i<roles.length;i++){
    const eq=a['p205_'+roles[i]+'_equation'](); const d=a.lookup(raw,names[i]);
    const fits=a.p205_signature(d.typ,eq.signature);
    st=a.p205_verify(raw,st,roles[i],eq);
    stOut.push({name:names[i],kind:d.kind,ty:fits.$,v:d.value.tag||d.value.$,state:st.$});
   }
   trace[f].observer=stOut;
   const result=a.p205_tail(raw,a.lookup(raw,'bench').value);
   trace[f].rawBench=result.tag??result.$;
 }
 fs.writeFileSync(out+'/report.json',JSON.stringify(trace,null,2)+'\n');
}

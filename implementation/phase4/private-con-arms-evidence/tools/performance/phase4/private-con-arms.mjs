// Disposable private-image experiment: fuse only exact Con/arity2 literal arms.
import {tokenize} from '../../private-compiler/tokens.mjs';
export function privateConArms(source,{countOnly=false}={}) {
 if(!source.includes('// privateImageMarker:'))throw Error('Requires private compiler image');
 if(!source.includes('function matcher1(name,arm){return fn(1,([x])=>{const a=project(name,x);return a.length?jump(arm(),a):arm()})}'))throw Error('Unreviewed matcher runtime');
 if(!source.includes('constructorNative["Con"]=true;constructorOwn["Con"]="Con";constructors["Con"]=["head","tail",];'))throw Error('Unreviewed Con metadata');
 if(/privateConArgs|privateConArm|privateConCounts/.test(source))throw Error('Reserved experiment identifier');
 const stats={sites:0,refused:0,mode:countOnly?'count-original-arms':'fuse-exact-con-arms'};
 source=source.split('\n').map(line=>{
  if(!line.includes('matcher1("Con",()=>fn(2,function(a){'))return line;
  const ts=tokenize(line),sites=[];
  for(let i=0;i<ts.length;i++){
   const prefix=['matcher1','(','"Con"',',','(',')','=','>','fn','(','2',',','function','(','a',')','{'];
   if(prefix.some((t,j)=>ts[i+j]?.text!==t))continue;
   const end=ts[i+1].close,bodyEnd=ts[i+16].close;
   if(ts[i+9].close!==bodyEnd+1||end!==bodyEnd+2)continue;
   if(ts.slice(i+17,bodyEnd).some(t=>['this','arguments','eval','super'].includes(t.text))){stats.refused++;continue;}
   sites.push({start:ts[i].start,end:ts[end].end,bodyStart:ts[i+16].end,bodyEnd:ts[bodyEnd].start,id:stats.sites++});
  }
  function render(start,end){let result='',at=start;for(const s of sites){if(s.start<at||s.end>end)continue;result+=line.slice(at,s.start);const body=render(s.bodyStart,s.bodyEnd);
   if(countOnly)result+=line.slice(s.start,s.bodyStart)+`privateConCounts[${s.id}]++;`+body+line.slice(s.bodyEnd,s.end);
   else result+=`fn(1,function(privateConArgs){const a=project("Con",privateConArgs[0]);if(a.length!==2){const privateConArm=fn(2,function(a){${line.slice(s.bodyStart,s.bodyEnd)}});return a.length?jump(privateConArm,a):privateConArm;}${body}})`;
   at=s.end;
  }return result+line.slice(at,end);}
  return render(0,line.length);
 }).join('\n');
 if(!stats.sites)throw Error('No exact Con arms');
 if(countOnly)source+='\nconst privateConCounts=new Float64Array('+stats.sites+');\nexport function resetConCounts(){privateConCounts.fill(0)}\nexport function readConCounts(){return Array.from(privateConCounts)}\n';
 return {source,stats};
}

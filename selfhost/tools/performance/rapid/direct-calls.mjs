/** Diagnostic generated-JS transform, not a compiler pass.
 * Only fresh literal argument arrays and exactly saturated known globals qualify.
 * `get` remains before argument evaluation. G is live; invocation guards recheck
 * function arity and bound arguments, so rebinding and partial application work.
 * The worker owns the fresh array, just as it owns apply's former slice.
 */
import fs from 'node:fs';
import path from 'node:path';
import {pathToFileURL} from 'node:url';

function tokens(source) {
  const out=[];
  for(let i=0;i<source.length;) {
    if(/\s/.test(source[i])){i++;continue;}
    if(source.startsWith('//',i))break;
    if(source.startsWith('/*',i)){const end=source.indexOf('*/',i+2);if(end<0)throw Error('Unclosed comment');i=end+2;continue;}
    const start=i,c=source[i];
    if(c==='"'||c==="'") {
      for(i++;i<source.length;i++){if(source[i]==='\\'){i++;continue;}if(source[i]===c){i++;break;}}
    } else if(/[A-Za-z_$]/.test(c)){while(i<source.length&&/[\w$]/.test(source[i]))i++;}
    else if(/[0-9]/.test(c)){while(i<source.length&&/[\w.]/.test(source[i]))i++;}
    else if(c==='`')throw Error('Generated definition contains a template literal; refusing to guess its syntax');
    else i++;
    out.push({text:source.slice(start,i),start,end:i});
  }
  const stack=[];
  for(let i=0;i<out.length;i++){
    const t=out[i].text;
    if(['(','[','{'].includes(t))stack.push(i);
    if([')',']','}'].includes(t)){
      const k=stack.pop();if(k===undefined||'([{'.indexOf(out[k].text)!==')]}'.indexOf(t))throw Error('Unbalanced generated definition');
      out[k].close=i;
    }
  }
  if(stack.length)throw Error('Unbalanced generated definition');
  return out;
}

export function globalArities(G) {
  return Object.fromEntries(Object.entries(G).filter(([,f])=>f?.code&&f.arity>0&&f.bound.length===0).map(([name,f])=>[name,f.arity]));
}

export function transformDirectCalls(source,{arities={},tail=false,owned=false}={}) {
  if(source.includes('function rapidDirectApply('))throw Error('Direct-call transform already applied');
  const stats={calls:0,tailCalls:0,byName:{},mode:(owned?'all-owned-':'')+(tail?'calls-and-tail':'calls')};
  const output=source.split('\n').map(line=>{
    // Exclude runtime implementation and quoted emitted-code snippets therein.
    if(!/^G\[|^if\(!Object\.hasOwn\(G,/.test(line))return line;
    const ts=tokens(line),edits=[];
    for(let i=0;i<ts.length;i++){
      const kind=ts[i].text;if(kind!=='call'&&!(tail&&kind==='jump'))continue;
      if(owned){
        if(ts[i+1]?.text!=='(')continue;
        const callEnd=ts[i+1].close;let comma=i+2;
        while(comma<callEnd&&ts[comma].text!==',')comma=ts[comma].close===undefined?comma+1:ts[comma].close+1;
        if(ts[comma+1]?.text!=='['||ts[comma+1].close+1!==callEnd)continue;
        edits.push({start:ts[i].start,end:ts[i].end,text:kind==='call'?'rapidDirectCall':'rapidDirectJump'});
        stats[kind==='call'?'calls':'tailCalls']++;continue;
      }
      if(ts.slice(i+1,i+6).map(t=>t.text).join(' ')!=='( get ( G ,')continue;
      if(ts[i+7]?.text!==')'||ts[i+8]?.text!==','||ts[i+9]?.text!=='[')continue;
      let name;try{name=JSON.parse(ts[i+6].text);}catch{continue;}
      const arity=arities[name];if(!Number.isInteger(arity)||arity<=0)continue;
      const arrayEnd=ts[i+9].close,callEnd=ts[i+1].close;
      if(arrayEnd+1!==callEnd)continue;
      let count=0,valid=true;
      for(let j=i+10;j<arrayEnd;){
        count++;
        if(ts[j].text==='.'&&ts[j+1]?.text==='.'&&ts[j+2]?.text==='.'){valid=false;break;}
        while(j<arrayEnd&&ts[j].text!==',')j=ts[j].close===undefined?j+1:ts[j].close+1;
        if(j<arrayEnd)j++;
      }
      if(!valid||count!==arity)continue;
      edits.push({start:ts[i].start,end:ts[i].end,text:kind==='call'?'rapidDirectCall':'rapidDirectJump'});
      edits.push({start:ts[callEnd].start,end:ts[callEnd].start,text:','+arity});
      stats[kind==='call'?'calls':'tailCalls']++;
      stats.byName[name]=(stats.byName[name]??0)+1;
    }
    for(const e of edits.sort((a,b)=>b.start-a.start))line=line.slice(0,e.start)+e.text+line.slice(e.end);
    return line;
  }).join('\n');
  let code=output+`\n// Rapid experiment: exact calls own a fresh literal argument array.\nfunction rapidDirectApply(f,args,n=args.length){\n  if(!f?.io&&!f?.typeName&&f?.code&&f.arity===n&&f.bound.length===0)return f.code.call(f.env,args);\n  return apply(f,args);\n}\nfunction rapidDirectCall(f,args,n){return force(rapidDirectApply(f,args,n));}\n`;
  if(tail){
    const before='if(x?.bounce){x=apply(x.f,x.args);continue}';
    if(code.split(before).length!==2)throw Error('Expected exactly one known trampoline branch');
    code=code.replace(before,'if(x?.bounce){x=x.rapidArity===undefined?apply(x.f,x.args):rapidDirectApply(x.f,x.args,x.rapidArity);continue}');
    code+='function rapidDirectJump(f,args,n){return {bounce:true,f,args,rapidArity:n??args.length};}\n';
  }
  return {source:code,code,stats};
}

if(process.argv[1]&&import.meta.url===pathToFileURL(path.resolve(process.argv[1])).href){
  const [input,output,...flags]=process.argv.slice(2);
  if(!input||!output)throw Error('Usage: node direct-calls.mjs INPUT.mjs OUTPUT.mjs [--tail] [--owned]');
  if(path.resolve(input)===path.resolve(output))throw Error('Refusing to overwrite original artifact');
  const api=await import(pathToFileURL(path.resolve(input)).href);
  const result=transformDirectCalls(fs.readFileSync(input,'utf8'),{arities:globalArities(api.G),tail:flags.includes('--tail'),owned:flags.includes('--owned')});
  fs.mkdirSync(path.dirname(output),{recursive:true});fs.writeFileSync(output,result.code);
  fs.writeFileSync(output+'.transform.json',JSON.stringify(result.stats,null,2)+'\n');
  console.log(JSON.stringify(result.stats));
}

// Shared only by the disposable generated-code experiments.
export {tokens as tokenizeGeneratedDefinition};

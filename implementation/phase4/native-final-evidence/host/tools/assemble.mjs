// Deterministic link-time source assembly for the compiler's own modules.
// User programs are parsed and resolved by the Bend frontend, not this tool.
import fs from 'node:fs';
import path from 'node:path';
import {fileURLToPath} from 'node:url';

export function assemble(files, output, {root=path.resolve(import.meta.dirname,'..')}={}) {
  const buckets={type:[],law:[],def:[]},seen={type:new Set(),law:new Set(),def:new Set()};
  for(const relative of files){
    const file=path.isAbsolute(relative)?relative:path.join(root,relative);
    const lines=fs.readFileSync(file,'utf8').split('\n');
    let block=null;
    const flush=()=>{
      if(!block)return;
      const key=block.kind,name=block.name;
      if(seen[key].has(name))throw Error(`Duplicate ${key} ${name} in ${relative}`);
      seen[key].add(name);buckets[key].push(block);block=null;
    };
    for(let i=0;i<lines.length;i++){
      const line=lines[i];
      if(/^import /.test(line)){
        if(!/^import Base\s*(?:#.*)?$/.test(line))throw Error(`Compiler assembly expects shared namespace modules: ${relative}:${i+1}`);
        continue;
      }
      let m=/^(type|law|def)\s+([^\s(<:]+)/.exec(line);
      let unsafe=false;
      if(/^@unsafe\s*$/.test(line)){
        flush();i++;
        while(i<lines.length&&/^\s*$/.test(lines[i]))i++;
        m=/^(def)\s+([^\s(<:]+)/.exec(lines[i]||'');
        if(!m)throw Error(`@unsafe must precede a definition in ${relative}:${i+1}`);
        unsafe=true;
      }else if(/^@unsafe\s+def /.test(line)){
        m=/^@unsafe\s+(def)\s+([^\s(<:]+)/.exec(line);unsafe=true;
      }
      if(m){
        flush();
        const text=unsafe?['@unsafe',lines[i].replace(/^@unsafe\s+/,'')]:[line];
        block={kind:m[1],name:m[2],file:relative,line:i+1,text};
      }else if(block)block.text.push(line);
      else if(line.trim()&&!line.startsWith('#'))throw Error(`Unrecognized top-level text ${relative}:${i+1}: ${line}`);
    }
    flush();
  }
  let text='import Base\n\n# Generated source assembly. Edit the individual src modules.\n';
  const map=[];
  for(const category of ['type','law','def'])for(const b of buckets[category]){
    const lines=b.text.join('\n').trimEnd();
    text+=`\n# Module: ${b.file}:${b.line}\n`;
    const start=text.split('\n').length;
    text+=lines+'\n';
    const annotationLines=lines.startsWith('@unsafe\n')?1:0;
    map.push({file:b.file,sourceLine:b.line,generatedLine:start+annotationLines,lines:lines.split('\n').length-annotationLines,kind:b.kind,name:b.name});
  }
  fs.mkdirSync(path.dirname(output),{recursive:true});fs.writeFileSync(output,text);
  fs.writeFileSync(output+'.map.json',JSON.stringify(map,null,2)+'\n');
  return {output,files:files.length,declarations:map.length,bytes:Buffer.byteLength(text)};
}

if(process.argv[1]&&path.resolve(process.argv[1])===fileURLToPath(import.meta.url)){
  const root=path.resolve(import.meta.dirname,'..');
  const args=process.argv.slice(2);let output=path.join(root,'build/compiler-full.bend');
  if(args[0]==='--output'){args.shift();output=path.resolve(args.shift());}
  const files=args.length?args:JSON.parse(fs.readFileSync(path.join(root,'src/compiler.json'),'utf8')).modules;
  try{console.log(JSON.stringify(assemble(files,output,{root})))}catch(e){console.error(e.message);process.exitCode=1}
}

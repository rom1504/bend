// Strict tokenizer for the self-emitter's one-line definition grammar.
export function tokenize(source) {
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

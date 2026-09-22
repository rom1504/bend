// Keep compiler workers and generated JavaScript programs under the same
// explicit Node resource limits. Never forward evaluation, loaders or debuggers.
export function nodeResourceArgs(argv=process.execArgv) {
  const limits=new Map();
  for(let i=0;i<argv.length;i++) {
    const match=/^--(stack[-_]size|max[-_]old[-_]space[-_]size)(?:=(.*))?$/.exec(argv[i]);
    if(!match)continue;
    const value=match[2]??argv[++i];
    if(!/^[1-9]\d*$/.test(value??'')||!Number.isSafeInteger(Number(value)))
      throw Error('Invalid Node resource limit: '+match[1]);
    limits.set(match[1].replaceAll('_','-'),value);
  }
  return [...limits].map(([name,value])=>'--'+name+'='+value);
}

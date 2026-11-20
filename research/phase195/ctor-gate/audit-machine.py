import pathlib,json,subprocess,re,hashlib,os
os.sched_setaffinity(0,{0});r=pathlib.Path.cwd();out=r/'research/phase195/ctor-gate';b=r/'selfhost/build/phase195';cases=['coverage-bst-64','tree-bitonic','coverage-map-churn-128'];rows=[]
for case in cases:
 old=b/'native45-01'/case/'machine/program.o';off=b/'ctor-off-build01'/case/'machine/program.o';on=b/'ctor-on-build01'/case/'machine/program.o'
 assert old.read_bytes()==off.read_bytes(),('current N1 mismatch',case)
 row={'case':case,'baselineExactObject':True,'files':{role:{'file':str(p.relative_to(r)),'bytes':p.stat().st_size,'sha256':hashlib.sha256(p.read_bytes()).hexdigest()} for role,p in [('N1',old),('off',off),('on',on)]},'hotSymbols':{}}
 for role in ['off','on']:
  p=b/('ctor-'+role+'-build01')/case/'machine/program';text=subprocess.check_output(['objdump','-d','--no-show-raw-insn','-M','intel',str(p)],text=True);blocks=re.split(r'(?m)^(?=[0-9a-f]+ <)',text)
  wanted=[]
  for block in blocks:
   first=block.splitlines()[0] if block else '';m=re.search(r'FID_([0-9_]+)>',first)
   if not m:continue
   name=''.join(chr(int(x)) for x in m[1].split('_') if x)
   if name in ['$product.bst.down','$direct.warp','$direct.Map.seek.go']:
    insn=[x for x in block.splitlines() if re.match(r'\s*[0-9a-f]+:\s',x)]
    counts={'instructions':len(insn),'explicitFrameReferences':sum(bool(re.search(r'\[(?:rbp|rsp)',x)) for x in insn),'constructorCalls':sum('call' in x and '_rt_ctor' in x for x in insn),'stateAllocatorLoads':sum('QWORD PTR [r12+0x8]' in x for x in insn),'name':name,'first':first}
    (out/(case+'-'+role+'-'+name.replace('$','').replace('.','_')+'.asm')).write_text(block);wanted.append(counts)
  row['hotSymbols'][role]=wanted
 rows.append(row)
report={'complete':True,'rows':rows,'scope':'All false-gate complete objects match retained qualified N1. Hot physical owner differences are static counts, not dynamic work; actual hit/miss semantics separately pass unchanged221-check C oracle.'};(out/'machine-audit.json').write_text(json.dumps(report,indent=2)+'\n');print(json.dumps(rows,indent=2))

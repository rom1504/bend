"""Single bounded CPU3 source falsifier; run only after explicit shared-lane GO."""
import argparse,hashlib,json,math,os,re,statistics,subprocess,sys,time
from pathlib import Path
ROOT=Path(__file__).resolve().parents[4];HERE=Path(__file__).resolve().parent
sys.path.insert(0,str(ROOT/'selfhost/tools/bench'));import bench
p=argparse.ArgumentParser();p.add_argument('--out',type=Path,required=True);a=p.parse_args()
assert os.sched_getaffinity(0)=={3};OUT=a.out.resolve();OUT.mkdir(parents=True,exist_ok=False)
START=time.monotonic();DEADLINE=START+27
read=lambda p:json.loads(Path(p).read_text())
def pin(p):
 p=Path(p);return dict(file=str(p),bytes=p.stat().st_size,sha256=hashlib.sha256(p.read_bytes()).hexdigest())
def verify(p):
 q=Path(p['file']);assert pin(q)==p,('input changed',q);return str(q)
freeze=read(HERE/'frozen.json')
for q in freeze['inputs']:verify(q)
verify(freeze['runtime'])
report=dict(complete=False,scope=freeze['scope'],method=pin(__file__),freeze=pin(HERE/'frozen.json'),runtime=freeze['runtime'],cases=[],jobs=[])
def save():
 report['wallSeconds']=time.monotonic()-START;(OUT/'report.json').write_text(json.dumps(report,indent=2)+'\n')
def job(cmd,label,limit=6):
 left=DEADLINE-time.monotonic();assert left>0.1,'internal deadline'
 t=time.monotonic();p=subprocess.run(list(map(str,cmd)),cwd=ROOT,capture_output=True,timeout=min(limit,left))
 sf=OUT/(label+'.stdout');ef=OUT/(label+'.stderr');sf.write_bytes(p.stdout);ef.write_bytes(p.stderr)
 report['jobs'].append(dict(label=label,command=list(map(str,cmd)),seconds=time.monotonic()-t,exit=p.returncode,stdout=pin(sf),stderr=pin(ef)));save()
 assert p.returncode==0 and not p.stderr,(label,p.stderr[:2500]);return p.stdout
seq=0
def execute(exe,inputs,reps,warmups,expected):
 global seq
 seq+=1;cmd=[exe,*bench.native_runtime_arguments({'runtimeArgumentConvention':'bend-rts-v1'}),str(reps),str(warmups),*map(str,inputs)]
 t=time.monotonic();data=job(cmd,'run-'+str(seq),3);wall=time.monotonic()-t
 ms=bench.observation(data,b'',0,dict(expectedStdout=expected,repetitions=reps,warmups=warmups),wall)
 return dict(repetitions=reps,warmups=warmups,elapsedMs=ms,nsPerCall=ms*1e6/reps if reps else None,stdout=data.decode())
def independent(n,seed):
 cells=[seed]*128;acc=0
 for i in range(n):
  k=i&127;acc=(acc+cells[k])&0xffffffff;cells[k]=acc^i
 return str(acc)+'\n'
def witness(obj,folder):
 symbol='p113d_FID_'+'_'.join(str(ord(c))for c in '$product.fold.loop')+'_'
 cmd=['objdump','-d','-M','intel','--no-show-raw-insn','--disassemble='+symbol,str(obj)]
 txt=job(cmd,folder+'-disassembly').decode();ins=[]
 for line in txt.splitlines():
  m=re.match(r'\s*([0-9a-f]+):\s+(.*)',line)
  if m:ins.append((int(m[1],16),' '.join(m[2].split())))
 assert ins,'No direct product fold worker; source falsifier did not preserve direct lowering'
 backs=[dict(address=hex(pc),target=hex(int(s.split()[1],16)))for pc,s in ins if s.startswith('jmp ')and int(s.split()[1],16)<pc]
 reads=[s for pc,s in ins if re.match(r'(mov|add) \w+,DWORD PTR \[',s)]
 writes=[s for pc,s in ins if s.startswith('mov DWORD PTR [')]
 assert backs and len(reads)>=2 and len(writes)>=2,'Two-cell direct body activation missing'
 hot_calls=[s for pc,s in ins if any(int(b['target'],16)<=pc<=int(b['address'],16)for b in backs)and s.startswith('call ')]
 assert not hot_calls,('New calls within recurrence',hot_calls)
 return dict(hotCalls=hot_calls,symbol=symbol,instructions=len(ins),backedges=backs,wordLoads=reads,wordStores=writes,frameOperands=sum('[rbp'in s or'[rsp'in s for pc,s in ins),calls=[s for pc,s in ins if s.startswith('call ')])
try:
 gold=read(ROOT/'selfhost/build/phase198/orbit-live-broad01/report.json')
 for row in freeze['rows']:
  case=row['id'];folder=OUT/case;folder.mkdir()
  for q in [row['ordinary'],row['source'],row['nativeReport'],row['compiler'],row['ordinaryObject'],row['ordinaryExecutable'],row['baseline']['artifact'],row['c']['artifact'],*row['commandInputs']]:verify(q)
  expected=row['point']['expectedStdout'];inputs=row['point']['runtimeArgs'];assert independent(*inputs)==expected
  result=dict(id=case,source=row['source'],ordinary=row['ordinary'],compiler=row['compiler'],oracles=[],pilots={},samples={},machine=None)
  report['cases'].append(result);save()
  obj=folder/'program.o';exe=folder/'program';cmd=row['compilerCommand'][:];cmd[cmd.index(row['ordinary']['file'])]=row['source']['file'];obj.write_bytes(job(cmd,case+'-compiler'))
  assert obj.read_bytes().startswith(b'\x7fELF');result['object']=pin(obj);result['machine']=witness(obj,case);save()
  cmd=row['linkCommand'][:];cmd[cmd.index(row['ordinaryObject']['file'])]=str(obj);cmd[cmd.index(row['ordinaryExecutable']['file'])]=str(exe)
  # Replace only the authenticated ordinary runtime input with the same frozen
  # live runtime used by the retained baseline; target/compiler flags stay exact.
  original=freeze['ordinaryRuntime'];cmd[cmd.index(original['file'])]=freeze['runtime']['file'];job(cmd,case+'-link')
  programs={'baseline':verify(row['baseline']['artifact']),'unroll':str(exe),'c':verify(row['c']['artifact'])};result['products']={k:pin(v)for k,v in programs.items()}
  for args in [inputs,*freeze['edgeCases']]:
   want=independent(*args);obs={k:execute(v,args,1 if args==inputs else 0,0,want)for k,v in programs.items()}
   result['oracles'].append(dict(arguments=args,expected=want,observations=obs))
  save()
  g=next(c for c in gold['cases']if c['id']==case)['summary']['stats'];counts={}
  for role,prog in programs.items():
   estimate=g['c'if role=='c'else'live']['medianMs'];n=max(1,math.ceil(125/estimate));pilots=[]
   for attempt in range(3):
    obs=execute(prog,inputs,n,3,expected);pilots.append(obs)
    if 90<=obs['elapsedMs']<=220:break
    n=max(1,math.ceil(n*125/max(obs['elapsedMs'],1)))
   else:raise ValueError('bounded calibration failure '+role)
   counts[role]=n;result['pilots'][role]=pilots;result['samples'][role]=[]
  order=['baseline','unroll','c']
  for i in range(6):
   base=order if i<3 else list(reversed(order));off=i%3
   for role in base[off:]+base[:off]:
    obs=execute(programs[role],inputs,counts[role],3,expected);assert obs['elapsedMs']>=80,'low resolution'
    result['samples'][role].append(dict(round=i,**obs))
  med={k:statistics.median(v['nsPerCall']for v in vs)for k,vs in result['samples'].items()}
  result.update(medianNs=med,unrollOverBaseline=med['unroll']/med['baseline'],unrollOverC=med['unroll']/med['c'],dispersion={k:(max(v['nsPerCall']for v in vs)-min(v['nsPerCall']for v in vs))/med[k]for k,vs in result['samples'].items()});save()
 report['complete']=True;save()
 if DEADLINE-time.monotonic()>2:
  try:
   import importlib.util
   spec=importlib.util.spec_from_file_location('fold_mca',HERE/'model.py');module=importlib.util.module_from_spec(spec);spec.loader.exec_module(module)
   report['optionalModel']=module.run(OUT/'model',DEADLINE)
  except Exception as error:report['optionalModelError']=repr(error)
 else:report['optionalModelDeferred']='primary screen consumed allotted budget'
 save();print([(r['id'],r['unrollOverBaseline'],r['unrollOverC'])for r in report['cases']])
except Exception as e:
 report['error']=repr(e);save();raise

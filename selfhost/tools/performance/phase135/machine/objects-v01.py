#!/usr/bin/env python3
"""Framed QBE unit transport/cache and mechanical closed-image object linking.
The surrounding supervisor must join successful producer status before publication.
"""
import argparse,fcntl,hashlib,importlib.util,json,os,pathlib,shutil,signal,subprocess,sys,time
sys.dont_write_bytecode=True
ROOT=pathlib.Path(__file__).resolve().parents[5];HERE=pathlib.Path(__file__).resolve().parent
FLAGS=dict(qbe=['-t','amd64_sysv'],assembler=['-mbranches-within-32B-boundaries'],linker=['-no-pie','-Wl,--build-id=none'],libraries=['-pthread','-lm'])
def load(name,file):
 s=importlib.util.spec_from_file_location(name,file);m=importlib.util.module_from_spec(s);s.loader.exec_module(m);return m
P=load('frame_protocol',HERE/'protocol-v01.py');E=load('elf_metadata',HERE/'elf-v01.py')
def pin(path):
 path=pathlib.Path(path).resolve();h=hashlib.sha256();n=0
 with path.open('rb')as f:
  while b:=f.read(65536):h.update(b);n+=len(b)
 return dict(file=str(path),bytes=n,sha256=h.hexdigest())
def verify(p):
 if pin(p['file'])!=p:raise ValueError('Changed artifact '+p['file'])
def hash_json(x):return hashlib.sha256(json.dumps(x,sort_keys=True,separators=(',',':')).encode()).hexdigest()
def save(path,x):
 tmp=path.with_suffix('.tmp');tmp.write_text(json.dumps(x,indent=2)+'\n');tmp.replace(path)
def main():
 ap=argparse.ArgumentParser(description=__doc__)
 for n in ['stream','out','cache','producer','source','runtime']:ap.add_argument('--'+n,type=pathlib.Path,required=True)
 ap.add_argument('--max-unit-bytes',type=int,default=67108864);ap.add_argument('--expected-qbe',type=pathlib.Path);ap.add_argument('--cold',action='store_true');ap.add_argument('--retain-units',action='store_true');ap.add_argument('--seconds',type=float,default=1200)
 a=ap.parse_args();out=a.out.resolve();cache=a.cache.resolve();phase=ROOT/'selfhost/build/phase135'
 if out.exists()or not out.is_relative_to(phase)or not cache.is_relative_to(phase):raise ValueError('Fresh Phase135 output and cache required')
 if a.cold and cache.exists():raise ValueError('Cold reference requires an empty distinct cache')
 if not 0<a.seconds<=3600 or not 0<a.max_unit_bytes<=268435456:raise ValueError('Bounded deadline/unit size required')
 context=dict(policy='p135-framed-bundles-globalized-defined-generated-v1',producer=pin(a.producer),runtime=pin(a.runtime),qbe=pin(ROOT/'selfhost/build/phase108/toolchain/qbe-1.3/qbe'),assembler=pin(shutil.which('as')),linker=pin(shutil.which('gcc')),objcopy=pin(shutil.which('objcopy')),flags=FLAGS,methods=[pin(__file__),pin(HERE/'protocol-v01.py'),pin(HERE/'elf-v01.py')],abi='Pinned scalar w/l QBE; no type prelude; generated symbols globalized only in closed no-PIE image.')
 inputs=[pin(a.source),context['producer'],context['runtime'],context['qbe'],context['assembler'],context['linker'],context['objcopy'],*context['methods']]
 expected=pin(a.expected_qbe)if a.expected_qbe else None
 if expected:inputs.append(expected)
 for x in inputs:verify(x)
 out.mkdir(parents=True);cache.mkdir(parents=True,exist_ok=True);lock=(cache/'writer.lock').open('a');fcntl.flock(lock,fcntl.LOCK_EX)
 r=dict(kind='phase135-framed-machine-build',complete=False,publishable=False,producerStatusVerified=False,source=pin(a.source),context=context,inputs=inputs,cold=a.cold,cache=str(cache),units=[],jobs=[],scope='Machine stage only. External supervisor must bind successful sealed producer exit and current source before publication. No frontend/lowering/emission-cache claim.')
 start=time.monotonic();deadline=start+a.seconds;child=None;current=None;whole=hashlib.sha256();whole_size=0;objects=[];defs=set();max_unit=0
 def persist():r['seconds']=time.monotonic()-start;save(out/'report.json',r)
 def run(label,cmd,directory):
  nonlocal child
  row=dict(label=label,command=list(map(str,cmd)));r['jobs'].append(row);persist();t=time.monotonic()
  with(directory/(label+'.stdout')).open('xb')as so,(directory/(label+'.stderr')).open('xb')as se:
   child=subprocess.Popen(row['command'],cwd=ROOT,stdout=so,stderr=se,start_new_session=True);status=child.wait(timeout=max(.001,deadline-time.monotonic()))
  row.update(exitCode=status,seconds=time.monotonic()-t,stdout=pin(directory/(label+'.stdout')),stderr=pin(directory/(label+'.stderr')));persist()
  if status:raise ValueError('Machine child failed: '+label)
 def begin(kind,index):
  nonlocal current
  if time.monotonic()>=deadline:raise TimeoutError('Machine stage deadline')
  directory=out/f'unit-{index:05d}';directory.mkdir();path=directory/'unit.ssa';f=path.open('xb');current=dict(kind=kind,index=index,directory=directory,path=path,file=f,sha=hashlib.sha256(),bytes=0)
  def write(b):
   nonlocal whole_size
   
   if current['bytes']+len(b)>a.max_unit_bytes:raise ValueError('Unit exceeds declared byte bound')
   current['file'].write(b);current['sha'].update(b);current['bytes']+=len(b);whole.update(b);whole_size+=len(b)
  return write
 def end(kind,index,size):
  nonlocal current,max_unit
  u=current;u['file'].close();assert size==u['bytes'];max_unit=max(max_unit,size);digest=dict(bytes=size,sha256=u['sha'].hexdigest());key=hash_json(dict(context=context,kind=kind,payload=digest));entry=cache/key;hit=entry.exists();urow=dict(index=index,kind=kind,payload=digest,key=key,reused=hit);r['units'].append(urow);persist()
  if hit:
   receipt_path=entry/'receipt.json';receipt=json.loads(receipt_path.read_text())
   if not receipt['complete']or receipt['key']!=key or receipt['context']!=context or receipt['payload']!=digest:raise ValueError('Cache receipt admission mismatch')
   verify(receipt['object']);obj=pathlib.Path(receipt['object']['file']);names=receipt['definitions'];urow['receipt']=pin(receipt_path)
  else:
   entry.mkdir();asm=entry/'unit.s';raw=entry/'raw.o';obj=entry/'unit.o'
   run('qbe',[context['qbe']['file'],*FLAGS['qbe'],'-o',asm,u['path']],entry)
   run('assemble',[context['assembler']['file'],*FLAGS['assembler'],'-o',raw,asm],entry)
   before=E.metadata(raw);symbols=entry/'globalize.txt';symbols.write_text(''.join(x+'\n'for x in before['promoted']))
   if before['promoted']:run('globalize',[context['objcopy']['file'],'--globalize-symbols='+str(symbols),raw,obj],entry)
   else:shutil.copyfile(raw,obj)
   after=E.metadata(obj);E.compare(before,after);names=after['definitions'];receipt=dict(complete=True,key=key,context=context,payload=digest,object=pin(obj),definitions=names,promoted=before['promoted'],allocatedAndRelocationsExact=True,rawObject=pin(raw),assembly=pin(asm),originSource=r['source'])
   save(entry/'receipt.json',receipt);urow['receipt']=pin(entry/'receipt.json');asm.unlink();raw.unlink()
  overlap=defs.intersection(names)
  if overlap:raise ValueError('Duplicate generated definition: '+str(sorted(overlap)[:3]))
  defs.update(names);objects.append(obj);urow['object']=pin(obj)
  if pin(u['path'])['sha256']!=digest['sha256']:raise ValueError('Unit changed during build')
  if not a.retain_units:u['path'].unlink()
  urow['textRetained']=a.retain_units
  if a.retain_units:urow['text']=pin(u['path'])
  current=None;persist()
 persist()
 try:
  with a.stream.open('rb',buffering=0)as stream:r['framing']=P.units(stream,begin,end)
  r['payloadDigest']=dict(bytes=whole_size,sha256=whole.hexdigest());r['maximumUnitBytes']=max_unit;r['maximumAllowedUnitBytes']=a.max_unit_bytes;r['retentionPolicy']='Explicit qualification retains all current grouped IR' if a.retain_units else 'At most one current unit IR; discard after object commit'
  if expected and r['payloadDigest']!=dict(bytes=expected['bytes'],sha256=expected['sha256']):raise ValueError('Unframed stream differs from independent QBE')
  r['expectedPayloadExact']=bool(expected)
  if not objects or 'main'not in defs or 'p111_program'not in defs:raise ValueError('Incomplete closed-image definitions')
  run('link',[context['linker']['file'],*FLAGS['linker'],*objects,context['runtime']['file'],*FLAGS['libraries'],'-o',out/'program'],out)
  r.update(binary=pin(out/'program'),reusedUnits=sum(x['reused']for x in r['units']),builtUnits=sum(not x['reused']for x in r['units']),childSeconds=sum(j['seconds']for j in r['jobs']))
  for x in inputs:verify(x)
  for u in r['units']:verify(u['object']);verify(u['receipt'])
  r['complete']=True
 except BaseException as exc:
  r['error']=repr(exc)
  if child and child.poll()is None:
   try:os.killpg(child.pid,signal.SIGKILL)
   except ProcessLookupError:pass
   child.wait()
 finally:
  if current and not current['file'].closed:current['file'].close()
  persist();fcntl.flock(lock,fcntl.LOCK_UN);lock.close()
 print(json.dumps({k:r.get(k)for k in ['complete','seconds','reusedUnits','builtUnits','payloadDigest','error']}));return 0 if r['complete']else 1
if __name__=='__main__':sys.exit(main())

"""Catalog-independent finite native source controls; dispatch only inside assigned guard."""
import argparse,gzip,hashlib,json,os,re,shutil,subprocess,sys,time
from pathlib import Path
HERE=Path(__file__).resolve().parent
ROOT=HERE.parents[2]
REF=ROOT/'selfhost/build/phase198/progress-native-reproduction01/report.json'
UPSTREAM=ROOT/'selfhost/.bootstrap/upstream-phase182/bend2/main.ts'
BUN=ROOT/'selfhost/.assets/bin/bun'

def sha(p):
 h=hashlib.sha256()
 with open(p,'rb') as f:
  for block in iter(lambda:f.read(1024*1024),b''):h.update(block)
 return h.hexdigest()
def pin(p):
 p=Path(p).resolve();return {'file':str(p),'bytes':p.stat().st_size,'sha256':sha(p)}
def verify(row):
 p=Path(row['file']);actual=pin(p)
 assert all(actual[k]==row[k] for k in ('bytes','sha256')),('changed input',p)
 return p
def read(p):return json.loads(Path(p).read_bytes())
def scon_literals(source):
 """Reprint only actual quoted literals; comments preserved, unsupported escapes rejected."""
 out=[];i=0;count=0
 while i<len(source):
  if source[i]=='#':
   end=source.find('\n',i);end=len(source) if end<0 else end
   out.append(source[i:end]);i=end;continue
  if source[i]!='"':out.append(source[i]);i+=1;continue
  end=i+1
  while end<len(source):
   if source[end]=='\\':end+=2;continue
   if source[end]=='"':break
   end+=1
  assert end<len(source),'unterminated literal'
  literal=json.loads(source[i:end+1]);assert isinstance(literal,str)
  term='SNil{}'
  for ch in reversed(literal):term='SCon{Chr{%d}, %s}'%(ord(ch),term)
  out.append('{'+term+' : String}');count+=1;i=end+1
 return ''.join(out),count

def run(a):
 assert os.sched_getaffinity(0)=={3},'Assigned CPU3 guard required'
 a.out=a.out.resolve();a.out.mkdir(parents=True,exist_ok=False)
 report={'complete':False,'scope':'Finite ordinary source compilation and exact stdout; no benchmark or general compiler-equivalence claim.',
         'inputs':[],'roles':{},'cases':[],'runtimeABI':11102,'runtimeArgumentConvention':'bend-rts-v1'}
 def save():(a.out/'report.json').write_text(json.dumps(report,indent=2)+'\n')
 def remember(p):
  row=pin(p)
  if row not in report['inputs']:report['inputs'].append(row)
  return row
 def command(folder,label,argv,timeout,fds=(),stdout_path=None):
  folder.mkdir(parents=True,exist_ok=True);start=time.monotonic()
  output=stdout_path or folder/(label+'.stdout');error=folder/(label+'.stderr')
  record={'argv':[str(x) for x in argv],'stdout':str(output),'stderr':str(error),'timeout':timeout}
  (folder/(label+'.command.json')).write_text(json.dumps(record,indent=2)+'\n')
  env=os.environ.copy();env['BEND_NO_TELEMETRY']='1'
  with open(output,'xb') as out,open(error,'xb') as err:
   p=subprocess.Popen(record['argv'],cwd=ROOT,stdout=out,stderr=err,pass_fds=fds,env=env)
   try:record['exitCode']=p.wait(timeout=timeout)
   except subprocess.TimeoutExpired:
    p.kill();record['exitCode']=p.wait();record['timedOut']=True
  record['seconds']=time.monotonic()-start;record['stdout']=pin(output);record['stderr']=pin(error)
  (folder/(label+'.process.json')).write_text(json.dumps(record,indent=2)+'\n')
  assert record['exitCode']==0 and not record.get('timedOut'),(label,record)
  assert error.stat().st_size==0,(label,'nonempty stderr',str(error))
  return record
 fds=[]
 try:
  ref=read(a.abi_template);assert ref['complete'] and ref['runtimeABI']==11102 and ref['runtimeArgumentConvention']=='bend-rts-v1'
  remember(__file__);remember(a.abi_template);remember(a.manifest)
  for dep in (ref['compilerCommand'][10],ref['compilerCommand'][12],ref['jobs'][1]['command'][0]):
   historical=next(x for x in ref['inputs'] if Path(x['file']).resolve()==Path(dep).resolve())
   verify(historical);remember(dep)
  runtime=Path(a.runtime or ref['runtime']['file']).resolve()
  expected_runtime=a.runtime_sha256 or (ref['runtime']['sha256'] if runtime==Path(ref['runtime']['file']).resolve() else None)
  assert expected_runtime and sha(runtime)==expected_runtime,'Explicit runtime SHA required for alternate runtime'
  report['runtime']=remember(runtime)
  for role,image,receipt in [('baseline',a.baseline,a.baseline_receipt),('candidate',a.candidate,a.candidate_receipt)]:
   receipt=receipt or image.parent/'results.json';r=read(receipt);row=r['runs'][a.image_run]
   assert row['complete'] and row.get('elfSha256'),'Incomplete compiler image receipt'
   remember(image);remember(receipt)
   fd=os.memfd_create(role+'-compiler');fds.append(fd)
   with gzip.open(image,'rb') as src,os.fdopen(os.dup(fd),'wb') as dst:shutil.copyfileobj(src,dst)
   path='/proc/self/fd/'+str(fd);assert sha(path)==row['elfSha256'],'Decompressed compiler identity mismatch'
   assert Path(path).read_bytes()[:4]==b'\x7fELF'
   report['roles'][role]={'compressed':pin(image),'receipt':pin(receipt),'imageSha256':row['elfSha256'],'imageRun':a.image_run,'compilerSourcePath':r.get('source'),'compilerSourceSha256':r.get('sourceSha256'),'fd':fd}
  manifests=[(a.manifest,read(a.manifest))]
  if a.apps:
   remember(a.apps);manifests.append((a.apps,read(a.apps)))
  rows=[]
  for mp,manifest in manifests:
   for row in manifest['fixtures']:
    row=dict(row);row['sourcePath']=(mp.parent/row['source']).resolve();row['expectedPath']=(mp.parent/row['expected']).resolve();rows.append(row)
  ids=[r['id'] for r in rows];assert len(ids)==len(set(ids))
  if a.cases:assert set(a.cases)<=set(ids);rows=[r for r in rows if r['id'] in a.cases]
  report['selected']=[r['id'] for r in rows];assert rows
  use_upstream=a.upstream!='off' and BUN.is_file() and UPSTREAM.is_file()
  assert a.upstream!='required' or use_upstream,'Requested upstream interpreter unavailable'
  report['upstream']={'available':use_upstream,'mode':a.upstream,'backend':'upstream checked JS IO via Comp.io_run; not pure evaluator'}
  if use_upstream:
   for p in [BUN,UPSTREAM,UPSTREAM.parent/'bend.ts',UPSTREAM.parent/'base.bend',UPSTREAM.parent/'comp.ts',UPSTREAM.parent/'effs/print.js']:remember(p)
  save()
  for row in rows:
   assert re.fullmatch('[a-zA-Z0-9_-]+',row['id'])
   source=row['sourcePath'];expected=row['expectedPath'];remember(source);remember(expected)
   for key,path in [('sourceSha256',source),('expectedSha256',expected)]:
    if key in row:assert sha(path)==row[key]
   variants=['original','scon'] if a.reprint_scon else ['original']
   for variant in variants:
    d=a.out/row['id']/variant;d.mkdir(parents=True)
    text=source.read_text();literal_count=0
    if variant=='scon':text,literal_count=scon_literals(text)
    local=d/'input.bend';local.write_text(text)
    entry={'id':row['id'],'variant':variant,'source':pin(local),'originalSource':pin(source),'expected':pin(expected),'reprintedLiterals':literal_count,'products':{}}
    report['cases'].append(entry);save()
    if use_upstream:
     obs=command(d,'upstream',[BUN,UPSTREAM,local],a.seconds)
     assert Path(obs['stdout']['file']).read_bytes()==expected.read_bytes(),('upstream output',row['id'],variant)
     entry['upstream']=obs;save()
    for role in ['baseline','candidate']:
     rd=d/role;rd.mkdir();fd=report['roles'][role]['fd'];cmd=ref['compilerCommand'].copy()
     assert cmd[8]=='x86-object' and cmd[11]=='cache'
     cmd[0]='/proc/self/fd/'+str(fd);cmd[9]=str(local)
     obj=rd/'program.o';emit=command(rd,'emit',cmd,a.seconds,(fd,),obj)
     assert obj.read_bytes()[:4]==b'\x7fELF'
     binary=rd/'program';link=ref['jobs'][1]['command'].copy();assert link[1]=='-no-pie' and link[-2]=='-o'
     link[2],link[3],link[-1]=str(obj),str(runtime),str(binary)
     linked=command(rd,'link',link,a.seconds)
     observed=command(rd,'execute',[binary,'+RTS','--threads','1','--gpu','off','-RTS'],a.seconds)
     assert Path(observed['stdout']['file']).read_bytes()==expected.read_bytes(),('native output',role,row['id'],variant)
     entry['products'][role]={'object':pin(obj),'binary':pin(binary),'emit':emit,'link':linked,'execution':observed,'outputExact':True};save()
    entry['objectsIdentical']=entry['products']['baseline']['object']['sha256']==entry['products']['candidate']['object']['sha256'];entry['complete']=True;save()
  for row in report['inputs']:verify(row)
  report['complete']=True;save()
 except BaseException as e:
  report['error']={'type':type(e).__name__,'message':str(e)};save();raise
 finally:
  for fd in fds:os.close(fd)
 if report['complete']:print(json.dumps({'complete':True,'cases':len(report['cases'])}))

if __name__=='__main__':
 p=argparse.ArgumentParser(description=__doc__)
 p.add_argument('--out',type=Path,required=True);p.add_argument('--baseline',type=Path,required=True);p.add_argument('--candidate',type=Path,required=True)
 p.add_argument('--baseline-receipt',type=Path);p.add_argument('--candidate-receipt',type=Path);p.add_argument('--image-run',type=int,default=0)
 p.add_argument('--abi-template',type=Path,default=REF);p.add_argument('--runtime',type=Path);p.add_argument('--runtime-sha256')
 p.add_argument('--manifest',type=Path,default=HERE/'manifest.json');p.add_argument('--apps',type=Path,help='Additional catalog-independent fixtures manifest with source/expected paths')
 p.add_argument('--cases',nargs='+');p.add_argument('--reprint-scon',action='store_true');p.add_argument('--upstream',choices=['auto','required','off'],default='auto');p.add_argument('--seconds',type=float,default=35)
 run(p.parse_args())

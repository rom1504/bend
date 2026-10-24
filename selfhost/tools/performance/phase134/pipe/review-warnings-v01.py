#!/usr/bin/env python3
"""Metadata-only audit of QBE split-immediate GAS diagnostics; no targets."""
import argparse,hashlib,json,pathlib,re
ROOT=pathlib.Path(__file__).resolve().parents[5]
def pin(p):
 p=pathlib.Path(p).resolve();h=hashlib.sha256();n=0
 with p.open('rb')as f:
  while b:=f.read(65536):h.update(b);n+=len(b)
 return dict(file=str(p),bytes=n,sha256=h.hexdigest())
def verify(p):assert pin(p['file'])==p,p['file']
def inspect(assembly,stderr):
 lines=pathlib.Path(stderr).read_text().splitlines();assert lines and lines[0]==str(assembly)+': Assembler messages:';wanted={}
 for line in lines[1:]:
  m=re.fullmatch(re.escape(str(assembly))+r':(\d+): Warning: (\d+) shortened to (\d+)',line);assert m,line
  loc,value,low=map(int,m.groups());assert 0<=value<2**64 and low==value&0xffffffff and loc not in wanted;wanted[loc]=(value,low)
 owner='';rows=[];pending=None
 with assembly.open()as f:
  for loc,line in enumerate(f,1):
   text=line.rstrip()
   if text and text[0]not in ' .\t#' and text.endswith(':'):owner=text[:-1]
   if pending:
    expected='\tmovl $'+str(pending['value'])+'>>32, 4+'+pending['destination'];assert text==expected,(loc,text,expected)
    pending['highInstruction']=text;rows.append(pending);pending=None
   if loc in wanted:
    value,low=wanted[loc];m=re.fullmatch(r'\tmovl \$(\d+), (-?\d+\(%rbp\))',text);assert m and int(m[1])==value
    pending=dict(line=loc,owner=owner,destination=m[2],value=value,low=low,high=value>>32,lowInstruction=text)
 assert pending is None and len(rows)==len(wanted)>0
 return rows
p=argparse.ArgumentParser();p.add_argument('--pipe-report',type=pathlib.Path,required=True);p.add_argument('--parent-build',type=pathlib.Path,required=True);p.add_argument('--out',type=pathlib.Path,required=True);a=p.parse_args();assert not a.out.exists();r=json.loads(a.pipe_report.read_text());parent=json.loads(a.parent_build.read_text())
assert not r['complete']and r['error']=="ValueError('assemble failed or diagnosed an error')"and r['compilerExitCode']==r['qbeExitCode']==0
assert len(r['jobs'])==1 and r['jobs'][0]['label']=='assemble'and r['jobs'][0]['exitCode']==0
assert parent['complete'];assert all(j['exitCode']==0 for j in parent['jobs']);job=r['jobs'][0];pj=next(j for j in parent['jobs']if j['label']=='assemble')
for item in [*r['inputs'],r['assembly'],job['stderr'],job['stdout'],r['compilerStderr'],r['qbeStderr'],r['qbeStdout']]:verify(item)
assert all(not r[k]['bytes']for k in ('compilerStderr','qbeStderr','qbeStdout'))and not job['stdout']['bytes']
asmp=pathlib.Path(r['assembly']['file']);pa=pathlib.Path(pj['command'][-1]);left=inspect(asmp,job['stderr']['file']);right=inspect(pa,pj['stderr']['file']);assert len(left)==len(right)==4
assert [(x['owner'],x['destination'],x['high'])for x in left]==[(x['owner'],x['destination'],x['high'])for x in right]
obj=pathlib.Path(job['command'][3]);assert obj.name=='program.o'and obj.is_file();assert obj.open('rb').read(6)==b'\x7fELF\x02\x01'
inputs=[pin(__file__),pin(a.pipe_report),pin(a.parent_build),*r['inputs'],r['assembly'],pin(obj),job['stderr'],job['stdout'],r['compilerStderr'],r['qbeStderr'],r['qbeStdout'],pin(pa),pj['stderr']]
for item in inputs:verify(item)
report=dict(kind='phase134-reviewed-split-immediate-warnings',complete=True,targetsRun=False,inputs=inputs,originalPipe=pin(a.pipe_report),parentBuild=pin(a.parent_build),source=r['source'],producer=r['image'],runtime=r['runtime'],assembly=r['assembly'],retainedObject=pin(obj),irDigest=r['irDigest'],candidateWarnings=left,parentWarnings=right,scope='Every reported low32 truncation is immediately completed by an adjacent high32 store to the next word. This validates that the diagnosed instruction pair stores the specified64-bit immediate; it does not independently prove the semantic value or qualify the new compiler.')
a.out.parent.mkdir(parents=True,exist_ok=True);a.out.write_text(json.dumps(report,indent=2)+'\n');print(json.dumps(dict(complete=True,report=pin(a.out),warnings=len(left))))

#!/usr/bin/env python3
"""Finite byte-transport controls; no compiler or native target is executed."""
import argparse,hashlib,importlib.util,io,json,pathlib,time
HERE=pathlib.Path(__file__).resolve().parent;ROOT=HERE.parents[4]
s=importlib.util.spec_from_file_location('protocol',HERE/'protocol-v01.py');P=importlib.util.module_from_spec(s);s.loader.exec_module(P)
def pin(p):b=p.read_bytes();return dict(file=str(p.resolve()),bytes=len(b),sha256=hashlib.sha256(b).hexdigest())
p=argparse.ArgumentParser();p.add_argument('--out',type=pathlib.Path,required=True);a=p.parse_args();assert not a.out.exists();a.out.parent.mkdir(parents=True,exist_ok=True)
payloads=[(0,b'function l $p113d_a() {\n@entry\nret 0\n}\n'),(0,b'export function l $p111_b() {\n@entry\nret 0\n}\n\n'),(1,b'data $p111_program = { '+b'b 1, '*40000+b'b 0 }\n\n'),(2,b'export function w $main() {\n@entry\nret 0\n}\n\n')]
wire=b''.join(f'# P135/1 BEGIN {k} {i}\n'.encode()+b+f'# P135/1 END {k} {i}\n'.encode()for i,(k,b)in enumerate(payloads))+b'# P135/1 DONE 4\n';rows=[];t=time.monotonic()
class Split(io.BytesIO):
 def __init__(self,b,n):super().__init__(b);self.n=n
 def read(self,n):return super().read(min(n,self.n))
def check(raw,n):
 found=[];active=None
 def begin(k,i):
  nonlocal active
  active=io.BytesIO();found.append((k,i,active));return active.write
 def end(k,i,size):assert len(found[-1][2].getvalue())==size
 r=P.units(Split(raw,n),begin,end);return r,[(k,b.getvalue())for k,i,b in found]
for n in [1,7,127,4096,65536]:
 result,found=check(wire,n);assert found==payloads and result['maximumReadBytes']<=65536 and result['maximumPendingBytes']<=65664;rows.append(dict(name='chunk-'+str(n),pass_=True,stats=result))
neg={'wrong-done':wire.replace(b'DONE 4',b'DONE 3'),'wrong-end':wire.replace(b'END 0 0',b'END 0 9'),'wrong-order':wire.replace(b'BEGIN 0 1',b'BEGIN 0 4'),'truncated':wire[:-8],'trailing':wire+b'x','oversized-header':b'# P135/1 '+b'x'*200+b'\n','unexpected-header':wire.replace(b'BEGIN 0 0',b'BOGUS 0 0')}
for name,raw in neg.items():
 try:check(raw,7)
 except ValueError as e:rows.append(dict(name=name,pass_=True,refusal=str(e)))
 else:raise AssertionError('Invalid protocol accepted: '+name)
r=dict(complete=True,targetsRun=False,inputs=[pin(pathlib.Path(__file__)),pin(HERE/'protocol-v01.py')],rows=rows,wireBytes=len(wire),wireSha256=hashlib.sha256(wire).hexdigest(),seconds=time.monotonic()-t,scope='12 finite transport/refusal controls, including200KBdata line and every-byte chunking; no QBE semantic or native IO qualification.')
a.out.write_text(json.dumps(r,indent=2)+'\n');print(json.dumps(dict(complete=True,controls=len(rows),seconds=r['seconds'])))

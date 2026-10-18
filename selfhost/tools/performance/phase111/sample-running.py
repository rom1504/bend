#!/usr/bin/env python3
"""Brief qualitative RIP/frame snapshots of an explicitly identified own process.

Pauses the tracee briefly per sample. This is not an unbiased CPU profile.
Always detaches; changes no target memory/registers and sends no terminating signal.
"""
import argparse,bisect,ctypes,hashlib,json,os,struct,subprocess,time
from pathlib import Path
p=argparse.ArgumentParser(description=__doc__)
p.add_argument('--pid',type=int,required=True);p.add_argument('--image',type=Path,required=True);p.add_argument('--out',type=Path,required=True)
a=p.parse_args();image=a.image.resolve();proc=Path('/proc')/str(a.pid)
assert (proc/'cmdline').read_bytes().split(b'\0')[0]==os.fsencode(image)
assert proc.stat().st_uid==os.getuid()
a.out.mkdir(parents=True,exist_ok=False)
(a.out/'method.py').write_bytes(Path(__file__).read_bytes())
libc=ctypes.CDLL(None,use_errno=True);libc.ptrace.restype=ctypes.c_long
libc.ptrace.argtypes=[ctypes.c_uint,ctypes.c_uint,ctypes.c_void_p,ctypes.c_void_p]
def trace(op,data=None):
 r=libc.ptrace(op,a.pid,None,data)
 if r==-1: raise OSError(ctypes.get_errno(),os.strerror(ctypes.get_errno()))
 return r
raw=subprocess.check_output(['nm','-n',str(image)],text=True)
symbols=[]
for line in raw.splitlines():
 x=line.split()
 if len(x)==3 and x[1] in ('t','T'):
  name=x[2]
  if name.startswith('p111_FID_'):
   name='Bend:'+''.join(chr(int(v)) for v in name[len('p111_FID_'):].split('_') if v)
  symbols.append((int(x[0],16),name))
addresses=[x[0] for x in symbols]
maps=(proc/'maps').read_text()
(a.out/'maps.txt').write_text(maps)
executable=[]
stack=[]
for line in maps.splitlines():
 fields=line.split(maxsplit=5)
 bounds=[int(v,16) for v in fields[0].split('-')]
 if len(fields)==6 and fields[1]=='r-xp' and fields[5]==str(image):
  executable.append(bounds)
 if len(fields)==6 and fields[5]=='[stack]': stack=bounds
def symbol(ip):
 if not any(lo<=ip<hi for lo,hi in executable):
  return dict(address=hex(ip),symbol='?',offset=0,reason='outside-image-executable-mapping')
 i=bisect.bisect_right(addresses,ip)-1
 if i<0 or not any(lo<=symbols[i][0]<hi for lo,hi in executable):
  return dict(address=hex(ip),symbol='?',offset=0,reason='no-in-image-symbol')
 return dict(address=hex(ip),symbol=symbols[i][1],offset=ip-symbols[i][0])
report=dict(kind='phase111-qualitative-live-stack-samples',pid=a.pid,image=str(image),imageSha256=hashlib.sha256(image.read_bytes()).hexdigest(),maps=dict(file=str((a.out/'maps.txt').resolve()),bytes=len(maps.encode()),sha256=hashlib.sha256(maps.encode()).hexdigest()),imageExecutableRanges=[[hex(lo),hex(hi)] for lo,hi in executable],samples=[],scope='Brief ptrace pauses alter the surrounding wall clock. Fixed-interval samples are qualitative stage clues, not precise CPU shares. Only the exact image executable mappings receive nearest-symbol labels; frame-pointer walks are heuristic. No target data changed.')
for n in range(24):
 attached=False;start=time.monotonic()
 try:
  trace(16);attached=True;os.waitpid(a.pid,0)
  regs=(ctypes.c_ulonglong*27)();trace(12,ctypes.cast(ctypes.byref(regs),ctypes.c_void_p))
  frames=[symbol(int(regs[16]))];fp=int(regs[4])
  try:
   with (proc/'mem').open('rb',buffering=0) as mem:
    for _ in range(8):
     if not stack or not stack[0]<=fp<=stack[1]-16:
      frames.append(dict(address=hex(fp),symbol='?',offset=0,reason='frame-pointer-outside-stack'))
      break
     mem.seek(fp);nextfp,ip=struct.unpack('QQ',mem.read(16));frames.append(symbol(ip))
     if nextfp<=fp: break
     fp=nextfp
  except (OSError,struct.error) as error:
   frames.append(dict(address=hex(fp),symbol='?',offset=0,reason='stack-read-failed',error=str(error)))
  report['samples'].append(dict(at=time.time(),frames=frames))
 finally:
  if attached: trace(17)
 if report['samples']: report['samples'][-1]['pauseSeconds']=time.monotonic()-start
 (a.out/'report.json').write_text(json.dumps(report,indent=2)+'\n')
 time.sleep(.2)
print(json.dumps(report,indent=2))

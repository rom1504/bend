#!/usr/bin/env python3
"""Check the exact candidate helpers: empty text succeeds, second LF write fails."""
import argparse, hashlib, json, pathlib, subprocess
p=argparse.ArgumentParser();p.add_argument('--binary',type=pathlib.Path,required=True);p.add_argument('--out',type=pathlib.Path,required=True);a=p.parse_args()
def pin(f):
 f=f.resolve();b=f.read_bytes();return dict(file=str(f),bytes=len(b),sha256=hashlib.sha256(b).hexdigest())
assert not a.out.exists();a.out.mkdir(parents=True);cmd=[str(a.binary.resolve()),'--threads','1','--gpu','off'];r=dict(complete=False,inputs=[pin(pathlib.Path(__file__)),pin(a.binary)],command=cmd,rows=[])
try:
 z=subprocess.run(cmd,stdout=subprocess.PIPE,stderr=subprocess.PIPE,timeout=10);assert(z.returncode,z.stdout,z.stderr)==(0,b'\n',b'');r['rows'].append(dict(name='empty-text-then-one-newline',passed=True))
 out=a.out/'append.stdout';out.write_bytes(b'prefix:')
 with out.open('ab')as f:z=subprocess.run(cmd,stdout=f,stderr=subprocess.PIPE,timeout=10)
 assert z.returncode==0 and not z.stderr and out.read_bytes()==b'prefix:\n';r['rows'].append(dict(name='exact-candidate-append',passed=True,output=pin(out)))
 with open('/dev/full','wb',buffering=0)as f:z=subprocess.run(cmd,stdout=f,stderr=subprocess.PIPE,timeout=10)
 assert z.returncode==28 and z.stderr==b'No space left on device\n',(z.returncode,z.stderr)
 out=a.out/'failure.stderr';out.write_bytes(z.stderr);r['rows'].append(dict(name='second-newline-write-failure',passed=True,exitCode=z.returncode,stderr=pin(out),reason='Actual unchanged file_write_call returns success without write(2) for zero size; only the subsequent one-byte newline can produce ENOSPC.'))
 for x in r['inputs']:assert pin(pathlib.Path(x['file']))==x
 r['complete']=True
finally:(a.out/'report.json').write_text(json.dumps(r,indent=2)+'\n')
print(json.dumps(r))

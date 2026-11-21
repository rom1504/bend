"""Build two extracted native Bend programs, check both full ELF outputs and time balanced runs."""
import argparse
import hashlib
import json
import os
from pathlib import Path
import statistics
import struct
import subprocess
import sys
import time
from audit import sections
from standalone import ROOT,N,ROW

IMAGE=ROOT/'selfhost/build/phase198/progress-native-image01'
ASSETS=ROOT/'selfhost/build/phase194/assets.json'
DRIVER=ROOT/'selfhost/tools/build/native.py'
FIXTURE=ROOT/'selfhost/build/phase201/elfstandalone03'

def oracle(data):
    table={name:r for name,r in sections(data)}
    def contents(name):
        r=table[name];return data[r[4]:r[4]+r[5]]
    text=b''.join(struct.pack('<I',(-64*i-4)&0xffffffff)+ROW[4:]for i in range(N));assert contents('.text')==text
    assert contents('.rela.text')==b''.join(struct.pack('<QQq',64*i+4,(1<<32)|4,-4)for i in range(N))
    assert contents('.strtab')==b'\0external\0' and len(contents('.symtab'))==48
    assert contents('.rodata')==contents('.data')==contents('.rela.rodata')==contents('.rela.data')==b''
    return hashlib.sha256(data).hexdigest()

def run(out):
    assert os.sched_getaffinity(0)=={3};out=out.resolve();out.mkdir(parents=True,exist_ok=False)
    record=dict(complete=False,prepared=json.loads((FIXTURE/'report.json').read_bytes()),builds={},pairs=[],observations=[],inputs={},scope='Real standalone writer outputs under the same pinned native compiler and runtime. Fixture construction, writer, output and startup all included.')
    def save(): (out/'report.json').write_text(json.dumps(record,indent=2)+'\n')
    save()
    try:
        for role in ('old','new'):
            src=FIXTURE/(role+'.bend');assert hashlib.sha256(src.read_bytes()).hexdigest()==record['prepared'][role]['standalone']['sha256']
            cmd=[sys.executable,'-B',str(DRIVER),'--assets',str(ASSETS),'--host','native','--stage','N1','--target','x86','--mode','cache','--emit','object','--image',str(IMAGE/'program'),'--image-receipt',str(IMAGE/'report.json'),'--source',str(src),'--out',str(out/role),'--seconds','35']
            q=subprocess.run(cmd,cwd=ROOT,capture_output=True,timeout=39);(out/(role+'.build.stdout')).write_bytes(q.stdout);(out/(role+'.build.stderr')).write_bytes(q.stderr)
            if q.returncode:raise ValueError(role+' native build refused: '+q.stdout.decode()[-1200:]+q.stderr.decode()[-500:])
            built=json.loads((out/role/'report.json').read_bytes());assert built['complete'] and built['assemblerSkipped'] and not built['changedInputs'];record['builds'][role]=dict(compiler=built['request']['image'],source=built['request']['source'],binary=built['binary'],runtime=built['runtime'],argv=cmd);save()
        previous=None
        for order in [('old','new'),('new','old'),('old','new'),('new','old')]:
            pair={}
            for role in order:
                cmd=[str(out/role/'program'),'+RTS','--threads','1','--gpu','off','-RTS'];begin=time.monotonic();q=subprocess.run(cmd,cwd=ROOT,capture_output=True,timeout=15);elapsed=time.monotonic()-begin
                assert q.returncode==0 and not q.stderr,(role,q.returncode,q.stderr[-500:]);sha=oracle(q.stdout)
                if previous is None: previous=q.stdout;(out/'oracle.o').write_bytes(previous)
                assert previous==q.stdout;record['observations'].append(dict(role=role,seconds=elapsed,objectBytes=len(q.stdout),sha256=sha));pair[role]=elapsed;save()
            record['pairs'].append(pair['new']/pair['old']);save()
        record['medianPairedNewOverOld']=statistics.median(record['pairs']);record['complete']=True
    except BaseException as exc:record['error']=repr(exc);raise
    finally:save()
    print(json.dumps({k:record[k]for k in ('complete','pairs','medianPairedNewOverOld')}))
if __name__=='__main__':
    p=argparse.ArgumentParser();p.add_argument('--out',type=Path,required=True);run(p.parse_args().out)

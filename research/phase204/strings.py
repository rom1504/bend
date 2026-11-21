"""Compile and time portable Bend String observers on a fixed set of compiler names."""
import gzip
import hashlib
import importlib.util
import json
import os
from pathlib import Path
import shutil
import statistics
import subprocess
import sys
import time
from prepare import HERE, ROOT, BASE

sys.path.insert(0,str(ROOT/'research/phase201/cold'))
from replay import REF, fdpath, sha
IMAGE = ROOT/'selfhost/build/phase201/p203rankimage01/program.gz'
NAMES = ['name','p111v_get','index_hash','x181_register_reserved','state','scratch','p111_rt_sink',
         'x185_copy_name','x185_copy_write','x190_l_bit','$direct.index_hash',
         '$p118borrow.read.p88_string_eq_go','p131i_insert','X181Stack','X185Writes','',
         'x185_local_12345','x185_local_12346','λ','局部','_arg0','_arg1','IndexNode','Absent']
ROUNDS=5000
def inputs():
    return [(s, [s, s+'z', 'Z'+s, s[:-1], NAMES[(i+1)%len(NAMES)]][j])
            for i,s in enumerate(NAMES) for j in range(5)]
def hash32(s, acc):
    for c in s: acc=((acc^ord(c))*16777619)&0xffffffff
    return acc
def expected(op):
    acc=13
    for j in range(ROUNDS):
        for a,b in inputs():
            acc=hash32(a,acc) if op=='hash' else (acc+int(a==b))&0xffffffff
    return acc
def fixture(src,op):
    pairs=inputs()
    # Both roles visit the same in-memory names through a list at run time.
    vals=','.join('X204TestName{'+json.dumps(a,ensure_ascii=False)+','+json.dumps(b,ensure_ascii=False)+'}' for a,b in pairs)
    update='index_hash(left,acc)' if op=='hash' else 'U32.add(acc,Bool.to_u32(p88_string_eq(left,right)))'
    harness=("""
type X204TestName is Data:
  X204TestName{+left: String, +right: String}
@unsafe
def x204_test_scan(rows: List<&2,X204TestName>, +acc: U32) -> U32:
  match rows:
    case Nil{}: acc
    case Con{X204TestName{left,right},rest}: x204_test_scan(rest,"""+update+""")
@unsafe
def x204_test_loop(+rows: List<&2,X204TestName>, n: U32, +acc: U32) -> U32:
  match n:
    case 0: acc
    case k: x204_test_loop(rows,U32.sub(k,1),x204_test_scan(rows,acc))
@unsafe
def main() -> U32:
  x204_test_loop(["""+vals+"],"+str(ROUNDS)+",13)\n").encode()
    spec=importlib.util.spec_from_file_location("cut",ROOT/'research/phase201/elf/standalone.py')
    mod=importlib.util.module_from_spec(spec);spec.loader.exec_module(mod)
    return mod.slice_source(src.encode(),harness)[0]
def edits(src,op):
    if op=='hash':
        i=src.index('@unsafe\ndef index_hash(');j=src.index('# Module:',i)
        return src[:i]+(HERE/'hash.bend').read_text()+'\n'+src[j:]
    i=src.index('def p88_string_eq_go(');j=src.index('def p98_eq_finish(',i)
    neutral=(ROOT/'research/phase202/names/neutral.bend').read_text()
    neutral=neutral.replace('match Char.is_eq(h1, h2):\n        case False{}: False{}\n        case True{}: p202n_eq(t1, t2)','Char.is_eq(h1,h2) && p202n_eq(t1,t2)')
    return src[:i]+neutral+'\n'+src[j:]
def run(out):
    assert os.sched_getaffinity(0)=={3}
    out.mkdir(parents=True)
    src=BASE.read_text(); prod=os.memfd_create('compiler')
    with gzip.open(IMAGE,'rb') as f,os.fdopen(os.dup(prod),'wb') as g:shutil.copyfileobj(f,g)
    assert sha(fdpath(prod))==json.loads((IMAGE.parent/'results.json').read_text())['runs'][0]['elfSha256']
    data={'complete':False,'profiles':{},'producer':sha(fdpath(prod)),'inputs':inputs(),'rounds':ROUNDS}
    def save():(out/'report.json').write_text(json.dumps(data,indent=2)+'\n')
    for op in ['hash','eq']:
        want=expected(op); record={'oracle':want,'roles':{},'pairs':[]};data['profiles'][op]=record
        for role,s in [('old',src),('new',edits(src,op))]:
            d=out/(op+role);d.mkdir();source=d/'input.bend';source.write_bytes(fixture(s,op))
            cmd=REF['compilerCommand'].copy();cmd[0],cmd[9]=fdpath(prod),str(source)
            with (d/'program.o').open('xb') as obj,(d/'compile.err').open('xb') as err:
                r=subprocess.run(cmd,stdout=obj,stderr=err,pass_fds=(prod,),timeout=35)
                if r.returncode or (d/'compile.err').stat().st_size:raise ValueError((role,(d/'compile.err').read_text()[:400]))
            link=REF['jobs'][1]['command'].copy();link[2],link[-1]=str(d/'program.o'),str(d/'program')
            subprocess.run(link,check=True,capture_output=True)
            # Match exact decoded machine workers, not comments or substring-only symbols.
            syms=subprocess.check_output(['nm','--defined-only',str(d/'program.o')],text=True)
            named=[]
            for line in syms.splitlines():
                symbol=line.split()[-1]
                if '_FID_' not in symbol:continue
                raw=symbol.split('_FID_',1)[1].strip('_')
                if all(c in '0123456789_' for c in raw):
                    name=''.join(chr(int(v)) for v in raw.split('_'))
                    if name.endswith(('index_hash','p88_string_eq_go','p202n_eq')): named.append(symbol.split('_FID_')[0]+':'+name)
            record['roles'][role]={'source':sha(source),'object':sha(d/'program.o'),'elf':sha(d/'program'),'workers':named,'seconds':[]}
        for pair in range(5):
            obs={}
            for role in (('old','new') if pair%2==0 else ('new','old')):
                d=out/(op+role);t=time.monotonic()
                r=subprocess.run([d/'program','+RTS','--threads','1','--gpu','off','-RTS'],capture_output=True,check=True,timeout=20)
                elapsed=time.monotonic()-t
                assert r.stdout==f'{want}\n'.encode() and not r.stderr,(op,role,r.stdout,r.stderr)
                obs[role]=elapsed;record['roles'][role]['seconds'].append(elapsed)
            record['pairs'].append(obs['new']/obs['old']);save()
        record['medianRatio']=statistics.median(record['pairs']);save()
    os.close(prod);data['complete']=True;save()
if __name__=='__main__':run(Path(sys.argv[1]).resolve())

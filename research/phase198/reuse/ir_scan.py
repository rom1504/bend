"""Replay first-order typed allocator captures, accepting complete affine field permutations."""
import collections
import hashlib
import itertools
import json
from pathlib import Path
import re
from project import HERE, ROOT, sha

class Refusal(Exception):
    pass

def need(b):
    if not b:
        raise Refusal

def pick(f):
    """Concrete symbolic interpretation assuming both input params hold the candidate CID."""
    params=f['params']
    need(len(params)==3 and not f['setup'] and params[0]=='state' and 'scratch' not in params and len(set(params))==3)
    env={name:(('owner',i) if i else ('state',)) for i,name in enumerate(params)}
    env['scratch']=('scratch',)
    state=env['state']
    scratch=env['scratch']
    cid=None
    takes=[]
    ctors=[]
    mem={}
    steps=0
    def get(v):
        need(v[0]=='N111Local' and v[1] in env)
        return env[v[1]]
    def walk(rows):
        nonlocal steps,cid
        for i,row in enumerate(rows):
            steps+=1
            need(steps<=64)
            if row[0]=='P113DIf':
                need(i==len(rows)-1 and get(row[1])[0]=='match')
                return walk(row[2])
            if row[0]=='P113DResult':
                need(i==len(rows)-1 and len(row[1])==1)
                return get(row[1][0])
            need(row[0]=='P113DScalar')
            s=row[1]
            if s[0]=='N111Bin':
                _,d,t,op,x,y=s
                need(t=='N111U64')
                a=get(x)
                if op=='shr':
                    need(a[0]=='owner' and y==['N111Const',40,0])
                    env[d]=('shift',a[1])
                elif op=='and':
                    need(a[0]=='shift' and y==['N111Const',65535,0])
                    env[d]=('tag',a[1])
                else:
                    need(op=='eq' and a[0]=='tag' and y[0]=='N111CtorId')
                    if cid is None: cid=y[1]
                    need(cid==y[1])
                    env[d]=('match',a[1])
            elif s[0]=='N111Call':
                _,d,t,name,args=s
                need(t=='N111U64' and len(args)==3)
                a,b,c=args
                need(a[1]=='N111Ptr' and get(a[2])==state and c[1]=='N111Ptr' and get(c[2])==scratch)
                if name=='p125_rt_take2':
                    need(b[1]=='N111U64' and get(b[2])[0]=='owner')
                    k=get(b[2])[1]
                    need(k not in takes)
                    takes.append(k)
                    mem.update({0:('field',2*k-2),8:('field',2*k-1)})
                    env[d]=('status',)
                else:
                    need(name=='p125_rt_ctor2' and b[1:] == ['N111U32',['N111CtorId',cid]] and len(ctors)<3)
                    need(0 in mem and 8 in mem)
                    env[d]=('node',mem[0],mem[8])
                    ctors.append(env[d])
            elif s[0]=='N111Set':
                need(s[2]=='N111U64')
                env[s[1]]=get(s[3])
            elif s[0]=='N111Load':
                _,d,t,b,k=s
                need(t=='N111U64' and get(b)==scratch and k in mem)
                env[d]=mem[k]
            elif s[0]=='N111Store':
                _,t,b,k,v=s
                need(t=='N111U64' and get(b)==scratch and k in (0,8))
                mem[k]=get(v)
            else: raise Refusal
        raise Refusal
    ret=walk(f['body'])
    need(set(takes)=={1,2} and len(ctors)==3 and ret==ctors[2] and ret[1:]==tuple(ctors[:2]))
    fields=ret[1][1:]+ret[2][1:]
    need(all(v[0]=='field' for v in fields) and sorted(v[1] for v in fields)==list(range(4)))
    return dict(cid=cid,order=[v[1] for v in fields],steps=steps)

def report():
    out=[]
    for file in sorted((ROOT/'selfhost/build/phase195/allocation-capture01').glob('*/preselection.json')):
        data=json.loads(file.read_text())
        pos=[]
        for fn in data['functions']:
            try: plan=pick(fn)
            except Refusal: continue
            decoded=re.sub(r'(?:\d+_){2,}',lambda m:''.join(chr(int(c)) for c in m[0].strip('_').split('_')),fn['symbol'])
            pos.append(dict(symbol=fn['symbol'],decoded=decoded,**plan))
        out.append(dict(case=data['id'],sha=sha(file),workers=len(data['functions']),admissions=pos))
    return out

if __name__=='__main__':
    (HERE/'ir-census.json').write_text(json.dumps(report(),indent=2)+'\n')

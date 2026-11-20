"""Independent structural witness over the frozen recorder's actual checked KTerms."""
import argparse
import hashlib
import json
from pathlib import Path

def unann(t):
    while t['t']=='Ann':t=t['k'][0]
    return t

def case(t,tag):
    for _ in range(8):
        t=unann(t)
        if t['t']!='Mat':break
        assert len(t['k'])==2
        if t['n']==tag:return t['k'][0]
        t=t['k'][1]
    raise ValueError(('missing',tag))

def match(t,p,env,roles):
    t=unann(t);k=t['k'];op,*xs=p
    if op=='case':return match(case(t,roles[xs[0]]),xs[1],env,roles)
    if op=='lam':
        slot,body=xs;assert t['t']=='Lam' and len(k)==1 and t['q']>0 and slot not in env and t['i'] not in env.values();env[slot]=t['i'];return match(k[0],body,env,roles)
    if op=='v':assert t['t']=='Var' and t['i']==env[xs[0]];return
    if op=='ctr':
        name,*fields=xs;assert t['t']=='Ctr' and t['n']==roles[name] and len(k)==len(fields)
        for kid,q in zip(k,fields):match(kid,q,env,roles)
        return
    if op=='call':
        name,*args=xs;ap=[]
        while t['t']=='App':
            f,a=t['k'];ap.insert(0,a);t=unann(f)
        assert t['t']=='Ref' and not t['k'] and len(args)==len(ap)
        roles.setdefault(name,t['n']);assert roles[name]==t['n'];
        for q,a in zip(args,ap):match(a,q,env,roles)
        return
    if op=='let2':
        assert t['t']=='Let' and len(k)==3
        for j in range(2):
            v=k[j];assert v['t']=='Bind' and len(v['k'])==1 and v['i'] not in env.values();match(v['k'][0],xs[j],env,roles);env['res'+str(j)]=v['i']
        return match(k[2],xs[2],env,roles)
    raise ValueError(op)

def main(source,out):
    data=json.loads(source.read_text());ds={d['name']:d for d in data['cases'][0]['definitions']};v=lambda s:('v',s);ctr=lambda r,*fs:('ctr',r,*fs);call=lambda s,*args:('call',s,*args);lam=lambda s,q:('lam',s,q);arm=lambda s,q:('case',s,q)
    node=lambda a,b:ctr('node',a,b);leaf=lambda x:ctr('leaf',v(x));arms=lambda r,x,y,b:arm(r,lam(x,lam(y,b)));rec=lambda a,b:call('self',v(a),v(b),v('d'));roles=dict(self='warp',leaf='Leaf',node='Node',false='False',true='True')
    rules=[('self',arm('leaf',lam('a',arm('leaf',lam('b',lam('d',call('leafFunction',v('a'),v('b'),v('d')))))))),('self',arms('node','a','b',arms('node','c','e',lam('d',('let2',rec('a','c'),rec('b','e'),call('join',v('res0'),v('res1'))))))),('join',arms('node','a','b',arms('node','c','d',node(node(v('a'),v('c')),node(v('b'),v('d')))))),('leafFunction',lam('a',lam('b',lam('d',call('order',v('a'),v('b'),call('xor',v('d'),call('gt',v('a'),v('b')))))))),('order',lam('a',lam('b',arm('false',node(leaf('a'),leaf('b')))))),('order',lam('a',lam('b',arm('true',node(leaf('b'),leaf('a'))))))]
    evidence=[]
    for role,pat in rules:
        env={};fun=roles[role];match(ds[fun]['value'],pat,env,roles);evidence.append(dict(function=fun,role=role,binderIds=env.copy()))
    assert roles['xor']=='Bool.xor' and roles['gt']=='U32.is_gt'
    out.write_text(json.dumps(dict(captureHash=hashlib.sha256(source.read_bytes()).hexdigest(),roles=roles,matched=evidence),indent=2)+'\n')
if __name__=='__main__':
    p=argparse.ArgumentParser();p.add_argument('--source',type=Path,required=True);p.add_argument('--out',type=Path,required=True);a=p.parse_args();main(a.source,a.out)

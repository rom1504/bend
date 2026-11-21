"""Type-check, native-emit and verify private-spine specialization on an original input."""
import argparse
import json
import os
from pathlib import Path
import re
import statistics
import subprocess
from controls import materialize
from prepare import HERE,ROOT,SOURCE
from private_spine import Refusal,transform
from screen import FLAGS,authenticate,command,execute,pin,read,write
from oracle import run

POINTS=[(0,7,99),(1,7,99),(2,7,99),(3,7,99),(8,0xffffffff,0),
        (31,17,0xffffffff),(64,2,7),(127,3,42)]
BST=[(64,17),(32,0),(0,0),(1,17),(65,123),(16,0xffffffff),(127,128),(257,7)]


def transcript(n,salt,word):
    mask=0xffffffff
    events=[]
    for _ in range(n):
        prev=word
        word=(word*1664525+salt)&mask
        events.append((prev,word))
    value=word^salt
    for a,b in reversed(events):
        value=((value*33)^(a+b))&mask if b%2==0 else (value*17+(a^b))&mask
    return str(value)


def admissions():
    original=SOURCE.read_text()
    other=(HERE/'transcript.bend').read_text()
    result={}
    negative={
        'nonliteral-direction':original.replace('BF{v, r, True{}}','BF{v, r, z}'),
        'observable-list-helper':original.replace('bst.up(rest, BNode{acc, v, other})','List.length(rest)'),
        'empty-in-unproven-position':original.replace('bst.up(rest, BNode{acc, v, other})','bst.up(Nil{}, BNode{acc, v, other})'),
        'wrong-list-multiplicity':original.replace('List<&2, BFrame>','List<&3, BFrame>'),
        'untyped-field':original.replace('v: U32, other: BST, left: Bool','v: U32, other: BST, left: U32'),
        'independently-used-frame':original.replace('BF{v, r, True{}} <> path','BF{v, r, True{}}'),
        'unknown-entry':re.sub(r'insert.fin\(x, bst.down\((?:fuel|8n), x, \((?:tree|t), Nil\{\}\)\)\)', 'other(x)',original),
    }
    for name,src in negative.items():
        try: transform(src)
        except Refusal as e: result[name]=str(e);continue
        raise ValueError('unexpected admission: '+name)
    return dict(negatives=result,positive=[transform(s)[1] for s in [original,other]])


def main(a):
    assert os.sched_getaffinity(0)=={3}
    out=a.out.resolve();out.mkdir()
    req=read(ROOT/'selfhost/build/phase198/p199-integrated-native45-01/coverage-bst-64/machine/report.json')
    for item in req['inputs']:authenticate(item)
    tc=req['toolchain'];cc=authenticate(read(ROOT/'selfhost/build/phase194/assets.json')['assets']['linker'])
    rt=authenticate(read(ROOT/'selfhost/build/phase199/runtime-bundle01/report.json')['variants']['live']['bundle'])
    rows=read(ROOT/'selfhost/build/phase198/p199-integrated-live-plan02/manifest.json')['cases']
    stock=Path(authenticate(next(r for r in rows if r['id']=='coverage-bst-64')['products']['candidate']['artifact']))
    report=dict(complete=False,passSource=pin(HERE/'private_spine.py'),admissions=admissions(),roles={})
    write(out/'report.json',report)
    for label in a.roles.split(','):
        d=out/label;d.mkdir()
        if label=='shape':
            s,rows,expected=materialize('stock')
        elif label=='bst':
            s=SOURCE.read_text();expected=None
        else:
            assert label in ('audit','audit-stock')
            s=(HERE/'transcript.bend').read_text()
            expected=''.join(transcript(*p)+'\n' for p in POINTS)
        if label!='audit-stock':s,admission=transform(s)
        else:admission=None
        src=d/'input.bend';src.write_text(s)
        entry=report['roles'][label]=dict(source=pin(src),admission=admission)
        write(out/'report.json',report)
        command(d,'check',['selfhost/.assets/bin/bun','selfhost/tools/build/check-source.mjs','--source',src,
            '--out',d/'upstream','--manifest','selfhost/src/compiler.json','--upstream','selfhost/.bootstrap/upstream-phase182'])
        up=read(d/'upstream/report.json')
        assert up['complete'] and up['typeAccepted'] and up['unresolvedHoles']==0
        obj=d/'p.o';exe=d/'program'
        cmd=req['compilerCommand'][:];cmd[9]=str(src);command(d,'emit',cmd,obj)
        command(d,'link',[cc,*tc['linkerFlags'],obj,rt,*tc['libraries'],'-o',exe])
        entry.update(check=pin(d/'upstream/report.json'),object=pin(obj),executable=pin(exe))
        if expected is not None:
            p=subprocess.run([str(exe),*FLAGS],capture_output=True,timeout=5)
            (d/'observed').write_bytes(p.stdout);(d/'expected').write_text(expected)
            assert p.returncode==0 and not p.stderr and p.stdout.decode()==expected,(label,p.stderr,p.stdout[:120])
            entry.update(observations=pin(d/'observed'),expected=pin(d/'expected'))
        else:
            cases=[run(*p) for p in BST]
            entry['oracles']=[execute(exe,p,int(i==0),0) for i,p in enumerate(cases)]
            executables={'old':stock,'new':exe};samples=[]
            for seq in ('onno','noon'):
                series=[]
                for letter in seq:
                    role={'o':'old','n':'new'}[letter]
                    series.append([role,execute(executables[role],cases[0],8192,3)])
                samples.append(series)
            entry['samples']=samples
            entry['newOverOld']=[statistics.median(o['nsPerInvocation'] for k,o in s if k=='new')/
                                 statistics.median(o['nsPerInvocation'] for k,o in s if k=='old') for s in samples]
        write(out/'report.json',report)
    report['complete']=True;write(out/'report.json',report)


if __name__=='__main__':
    p=argparse.ArgumentParser();p.add_argument('--roles',default='bst,shape,audit,audit-stock')
    p.add_argument('--out',type=Path,required=True);main(p.parse_args())

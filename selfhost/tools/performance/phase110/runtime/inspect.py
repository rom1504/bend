#!/usr/bin/env python3
"""Inspect frozen worker/runtime machine shapes without executing targets."""
import argparse
from collections import Counter
import hashlib
import json
from pathlib import Path
import re
import shutil
import subprocess

ROOT = Path(__file__).resolve().parents[5]
WORKERS = ['nx_list_reverse','nx_string_reverse','nx_list_tail','nx_list_last']
HELPERS = ['nx_rt_fast_id','nx_rt_rebuild2','nx_rt_fast_field','nx_construct2',
           'nx_rt_rebuild2_c1_k0','nx_rt_rebuild2_c3_k0',
           'nx_rt_pair_rebuild2_c1_k0','nx_rt_pair_rebuild2_c3_k0',
           'nx_rt_pair_take2','nx_rt_fast_take2','ctr_take','rfc_seal','rfc_wrap']

def pin(path):
    raw = path.read_bytes()
    return dict(file=str(path.resolve()),sha256=hashlib.sha256(raw).hexdigest(),bytes=len(raw))

def command(args):
    return subprocess.check_output(list(map(str,args)),text=True)

def main():
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument('--build',type=Path,required=True)
    p.add_argument('--out',type=Path,required=True)
    a=p.parse_args(); build=a.build.resolve(); out=a.out.resolve()
    if out.exists() or not out.is_relative_to(ROOT/'implementation/phase110/evidence'):
        raise ValueError('fresh implementation/phase110/evidence output required')
    receipt=json.loads((build/'report.json').read_text())
    if not receipt.get('complete') or receipt.get('kind')!='phase110-frozen-worker-build':
        raise ValueError('requires complete frozen worker build')
    out.mkdir(parents=True)
    ts={name:Path(shutil.which(name)).resolve() for name in ['objdump','nm','size']}
    report=dict(kind='phase110-offline-machine-shapes',version=1,complete=False,
        targetsRun=False,inputs=[pin(Path(__file__)),pin(build/'report.json')],
        tools={n:dict(pin=pin(f),version=command([f,'--version']).splitlines()[0]) for n,f in ts.items()},profiles=[])
    for worker in receipt['workers']:
        binary=Path(worker['binary']['file'])
        identity=pin(binary)
        if identity!=worker['binary']: raise ValueError('binary differs from build receipt')
        report['inputs'].append(identity)
        symbols={}
        for line in command([ts['nm'],'-S','--defined-only',binary]).splitlines():
            f=line.split()
            if len(f)==4: symbols[f[3]]=dict(address=int(f[0],16),bytes=int(f[1],16),kind=f[2])
        selected=[n for n in WORKERS+HELPERS if n in symbols]
        selected += [n+'.cold' for n in selected if n+'.cold' in symbols]
        rows=[]
        for name in selected:
            asm=command([ts['objdump'],'-d','--no-show-raw-insn','--disassemble='+name,binary])
            dest=out/(worker['name']+'--'+name+'.asm');dest.write_text(asm)
            ins=[]
            for line in asm.splitlines():
                m=re.match(r'^\s*([0-9a-f]+):\s+(\S+)(?:\s+(.*))?$',line)
                if m: ins.append(dict(address=int(m[1],16),mnemonic=m[2],operands=m[3] or ''))
            def calls(body):
                return [re.search(r'<([^>]+)>',i['operands'])[1] if re.search(r'<([^>]+)>',i['operands']) else i['operands'] for i in body if i['mnemonic'].startswith('call')]
            edges=[]
            if name in WORKERS:
                for i in ins:
                    m=re.match(r'([0-9a-f]+) <',i['operands'])
                    if i['mnemonic'].startswith('jmp') and m and symbols[name]['address']<=int(m[1],16)<i['address']:
                        edges.append((int(m[1],16),i['address']))
            loop=None
            if edges:
                start,end=max(edges,key=lambda e:e[1]-e[0]); body=[i for i in ins if start<=i['address']<=end]
                loop=dict(start=hex(start),backedge=hex(end),instructionSites=len(body),calls=calls(body),
                    stackMemorySites=[i for i in body if re.search(r'\([^)]*%(?:rbp|rsp)[^)]*\)',i['operands'])])
            rows.append(dict(name=name,**symbols[name],instructionSites=len(ins),
                mnemonics=dict(Counter(i['mnemonic'] for i in ins)),calls=calls(ins),
                nonlocalJumps=[i['operands'] for i in ins if i['mnemonic'].startswith('jmp') and '<' in i['operands'] and not re.search(r'<'+re.escape(name)+r'(?:\+|>)',i['operands'])],loop=loop,assembly=pin(dest)))
        report['profiles'].append(dict(profile=worker['profile'],backend=worker['backend'],name=worker['name'],binary=identity,
            size=command([ts['size'],binary]),symbols=rows))
    for r in report['inputs']:
        if pin(Path(r['file']))!=r: raise ValueError('input changed during inspection')
    report['complete']=True
    (out/'report.json').write_text(json.dumps(report,indent=2)+'\n')
    print(json.dumps(dict(complete=True,targetsRun=False,profiles=len(report['profiles']),out=str(out))))

if __name__=='__main__': main()

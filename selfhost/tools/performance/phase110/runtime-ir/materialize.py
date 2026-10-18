#!/usr/bin/env python3
"""Append checked private runtime entry and uncommon slow-path imports."""
import argparse
import hashlib
import json
from pathlib import Path

HERE=Path(__file__).resolve().parent
ROOT=HERE.parents[4]

def pin(path):
    raw=path.read_bytes()
    return dict(file=str(path.resolve()),bytes=len(raw),sha256=hashlib.sha256(raw).hexdigest())

def main():
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument('--base',type=Path,required=True)
    p.add_argument('--out',type=Path,required=True)
    a=p.parse_args(); base=a.base.resolve(); out=a.out.resolve()
    if out.exists() or not out.is_relative_to(ROOT/'selfhost/build/phase110'):
        raise ValueError('fresh Phase110 output required')
    mf=base/'manifest.json'; facts=json.loads(mf.read_text())
    if not facts.get('complete') or facts.get('kind') not in ['phase110-additive-runtime-core','phase110-explicit-runtime-variant']:
        raise ValueError('requires complete authenticated Phase110 runtime')
    for r in [*facts['inputs'],*facts['outputs']]:
        if pin(Path(r['file']))!=r: raise ValueError('changed input '+r['file'])
    source=(base/'runtime.c').read_text()
    expected={
      'location':'#define LOC_MASK ((1ull << 40) - 1)',
      'referenceFlag':'#define RFC_BIT  (1ull << 63)',
      'referenceCount':'#define RFC_CNT  ((1u << 24) - 1)',
      'allocatorWidth':'#define ALC_WORDS NCLS_ALL',
      'allocatorClasses':'#define NCLS_ALL  32',
      'allocatorLimit':'#define CAP_WORDS 32768',
      'allocatorHead':'#define ALC_AT(e, i)   (e).alc[(i) * LANE_STEP]',
      'allocatorLength':'#define ALC_LEN(e, c)  ALC_AT(e, ALC_WORDS + (c))'}
    for name,text in expected.items():
        if source.count(text)!=1: raise ValueError('runtime layout differs: '+name)
    out.mkdir(parents=True)
    adapter=HERE/'adapter.inc.c'
    (out/'runtime.c').write_text(source+'\n'+adapter.read_text())
    for name in ['abi.h','abi-extension.h']:
        (out/name).write_bytes((base/name).read_bytes())
    header='''#include "abi.h"
uintptr_t nx_rt_ir_heap(NxRt*);
uintptr_t nx_rt_ir_alc(NxRt*);
uint64_t nx_rt_ir_alloc0(NxRt*);
uint32_t nx_rt_ir_hand0(NxRt*);
uint64_t nx_rt_ir_view(NxRt*,uint64_t);
'''
    (out/'abi-private.h').write_text(header)
    record=dict(kind='phase110-private-runtime-ir-core',complete=True,targetsRun=False,
      inputs=[pin(mf),*facts['outputs'],pin(Path(__file__)),pin(adapter)],
      constants=dict(wordBytes=8,locationBits=40,referenceBit=63,countBits=24,
        heapOff=51413376,allocatorHead0ByteOffset=0,allocatorLength0ByteOffset=256,keepWords=32768,ctrTag=2),
      authenticatedSourceSpellings=expected,
      admission='One active single-thread CPU context, no concurrent mutation, scratch empty at worker entry',
      rfcViewPolicies=['single: aligned64 read in the admitted no-concurrency context','atomic: unchanged rfc_view helper'],
      primitiveSemantics='Production class0 hot lists, heap_hand, heap_alloc_miss and rfc_wrap format; shared/static reconstruction falls back before mutation',
      outputs=[pin(out/n) for n in ['runtime.c','abi.h','abi-extension.h','abi-private.h']])
    (out/'manifest.json').write_text(json.dumps(record,indent=2)+'\n'); print(json.dumps(record))

if __name__=='__main__': main()

"""Reproduce the source-only naming ceiling; never emits or executes code.

This script records the algorithm used by the preparatory inline census. The
existing census-v01.json remains its original observation, not a new run.
"""
import argparse
from collections import Counter
import hashlib
import json
from pathlib import Path
import re
import time

INLINE=re.compile(rb'^v_p113i_([0-9]{1,10})_local_(.*)$')


def encode(value):
    match=INLINE.fullmatch(value)
    if match:return b'Z0'+match[1]+b'_'+match[2],'inline'
    if value.startswith(b'v_p113p_move_'):return b'Z1'+value[len(b'v_p113p_move_'):],'move'
    if value.startswith(b'v_p113p_call_'):return b'Z2'+value[len(b'v_p113p_call_'):],'call'
    return value,'unchanged'


def main():
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument('--source',type=Path,required=True);p.add_argument('--out',type=Path,required=True)
    a=p.parse_args();assert not a.out.exists()
    counts=Counter();families=Counter();saved=Counter();reserved=set();total=0
    digest=hashlib.sha256();started=time.monotonic()
    for line in a.source.open('rb'):
        digest.update(line)
        assert b'"' not in line and b'#' not in line,'Quoted-token scanner required for this artifact'
        for value in re.findall(rb'%([A-Za-z_][A-Za-z0-9_.]*)',line):
            counts[value]+=1;new,kind=encode(value)
            families[kind]+=1;saved[kind]+=len(value)-len(new);total+=len(value)
            if value.startswith(b'Z'):reserved.add(value)
    assert not reserved,'Reserved namespace is already occupied'
    reverse={}
    for value in counts:
        new,kind=encode(value)
        assert new not in reverse or reverse[new]==value,'Observed collision'
        reverse[new]=value
    report=dict(complete=True,targetsRun=False,
        source=dict(file=str(a.source.resolve()),bytes=a.source.stat().st_size,sha256=digest.hexdigest()),
        variableOccurrences=sum(counts.values()),uniqueNames=len(counts),variableTokenBytes=total,
        families=dict(families),bytesRemoved=dict(saved),totalBytesRemoved=sum(saved.values()),
        outputBytes=a.source.stat().st_size-sum(saved.values()),observedMappingInjective=True,
        reservedNamespaceEmpty=True,seconds=time.monotonic()-started,
        scope='Static name-codec ceiling only. No transformed program is emitted or executed.')
    a.out.write_text(json.dumps(report,indent=2)+'\n')


if __name__=='__main__':main()

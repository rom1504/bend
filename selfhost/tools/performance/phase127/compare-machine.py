#!/usr/bin/env python3
"""Read-only same-source ELF comparison for the live-bank causal experiment."""
import argparse
import hashlib
import json
from pathlib import Path
import re
import subprocess
import sys

ROOT=Path(__file__).resolve().parents[4]
sys.path.insert(0,str(ROOT/'selfhost/tools/profiler'))
from run import pin,save


def inspect(path):
    raw=path.read_bytes()
    output=subprocess.check_output(['readelf','-W','-S',str(path)],text=True)
    sections={};data={}
    for line in output.splitlines():
        match=re.match(r'\s*\[\s*\d+\]\s+(\S+)\s+(\S+)\s+([0-9a-fA-F]+)\s+([0-9a-fA-F]+)\s+([0-9a-fA-F]+)\s+\S+\s+(\S+)',line)
        if not match or 'A' not in match[6]:continue
        name,kind=match[1],match[2];address,offset,size=(int(match[n],16)for n in (3,4,5))
        # NOBITS occupies memory but has no bytes in the ELF file.
        content=None if kind=='NOBITS' else raw[offset:offset+size]
        if content is not None and len(content)!=size:raise ValueError('Truncated section')
        sections[name]=dict(kind=kind,address=address,bytes=size,flags=match[6],
                            sha256=hashlib.sha256(content).hexdigest()if content is not None else None)
        data[name]=content
    symbols=subprocess.check_output(['readelf','-W','-s',str(path)],text=True)
    found={int(fields[1],16)for line in symbols.splitlines()if len(fields:=line.split())>=8 and fields[-1]=='p111_program'}
    if len(found)!=1:raise ValueError('Unique descriptor required')
    return sections,data,next(iter(found))


def main():
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument('--before',type=Path,required=True);p.add_argument('--after',type=Path,required=True)
    p.add_argument('--out',type=Path,required=True);a=p.parse_args()
    if a.out.exists():raise ValueError('Fresh result required')
    inputs=[pin(__file__),pin(a.before),pin(a.after)]
    sa,da,pa=inspect(a.before);sb,db,pb=inspect(a.after)
    changed=sorted(n for n in set(sa)|set(sb)if sa.get(n)!=sb.get(n))
    assert set(changed)=={'.data','.note.gnu.build-id'},changed
    assert sa['.text']==sb['.text'] and pa==pb
    assert len(da['.data'])==len(db['.data'])
    differences=[dict(offset=i,before=x,after=y)for i,(x,y)in enumerate(zip(da['.data'],db['.data']))if x!=y]
    expected=pa-sa['.data']['address']+88
    assert 0 <= expected < len(da['.data'])
    capability=da['.data'][expected]
    assert not capability & 4
    assert differences==[dict(offset=expected,before=capability,after=capability|4)],differences
    save(a.out,dict(complete=True,inputs=inputs,textByteIdentical=True,textBytes=sa['.text']['bytes'],
        changedAllocatedSections=changed,dataByteDifferences=differences,before=sa,after=sb,
        scope='Same machine instructions, layout and allocated sections except the verified capability byte and linker build ID. NOBITS is compared as zero-initialized extent, not read as file data.'))
    print(json.dumps(dict(complete=True,textBytes=sa['.text']['bytes'],dataDifferences=differences)))


if __name__=='__main__':main()

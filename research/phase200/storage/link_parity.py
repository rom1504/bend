"""Verify pathname-preserving anonymous object linking against the canonical Phase199 ELF."""
import argparse
from contextlib import ExitStack
import json
import os
from pathlib import Path
import struct
import tempfile
import stream_image as S


def elf_alloc(stream):
    stream.seek(0);data=stream.read();shoff=struct.unpack_from('<Q',data,40)[0]
    size,n,names=struct.unpack_from('<HHH',data,58)
    sections=[struct.unpack_from('<IIQQQQIIQQ',data,shoff+i*size) for i in range(n)]
    st=sections[names];pool=data[st[4]:st[4]+st[5]];result={}
    for x in sections:
        if x[2]&2:
            name=pool[x[0]:pool.index(0,x[0])].decode();result[name]=[x[1],x[2],x[3],x[5],S.hashlib.sha256(data[x[4]:x[4]+x[5]]).hexdigest() if x[1]!=8 else None]
    phoff=struct.unpack_from('<Q',data,32)[0];phsize,phnum=struct.unpack_from('<HH',data,54)
    return result,data[phoff:phoff+phsize*phnum]


def run(out):
    assert os.sched_getaffinity(0)=={3};out=S.common.fresh_output(out,S.ROOT)
    tmp=out/'temp';tmp.mkdir();prior=json.loads(S.PREVIOUS.read_bytes());assert prior['complete'] and not prior['changedInputs']
    old=S.common.verify(prior['object']);binary=S.common.verify(prior['binary']);S.common.verify(prior['runtime'])
    link=next(x['command'] for x in prior['jobs'] if x['label']=='link');assert link.count(str(old))==1 and link.count(str(binary))==1
    report=dict(complete=False,inputs=[S.common.pin(p)for p in (Path(__file__),S.__file__,S.PREVIOUS,old,binary)],jobs=[],outputs={})
    with ExitStack() as stack:
        obj=S.memory_file(stack,'authenticated-direct-object')
        with old.open('rb')as f:assert S.raw_digest(f,obj)==S.data_identity(prior['object'])
        assert S.freeze(obj,64*S.MIB)==S.data_identity(prior['object'])
        alias=out/'program.o';layouts={};headers={}
        for label in ('original','unnamed','named-disk','named-anonymous'):
            elf=S.memory_file(stack,'linked-'+label);word=str(old) if label=='original' else S.fdpath(obj) if label=='unnamed' else str(alias)
            if word==str(alias):alias.symlink_to(old if label=='named-disk' else S.fdpath(obj))
            try:
                cmd=[S.fdpath(elf) if x==str(binary) else word if x==str(old) else x for x in link]
                S.stage(out,label,cmd,[obj,elf],tmp,report['jobs'])
            finally:
                if word==str(alias):alias.unlink()
            report['outputs'][label]=S.freeze(elf,64*S.MIB);layouts[label],headers[label]=elf_alloc(elf)
        report['historicalELFExact']=report['outputs']['original']==S.data_identity(prior['binary'])
        report['samePathWholeELFExact']=report['outputs']['named-disk']==report['outputs']['named-anonymous']
        report['unnamedChangedAllocatedSections']=[n for n,v in layouts['original'].items() if v!=layouts['unnamed'][n]]
        report['programHeadersExact']=headers['original']==headers['unnamed']
        report['complete']=report['historicalELFExact'] and report['samePathWholeELFExact']
    S.common.write_json(out/'report.json',report);print(json.dumps({k:report[k]for k in ('complete','historicalELFExact','samePathWholeELFExact','unnamedChangedAllocatedSections','programHeadersExact')}));assert report['complete']

if __name__=='__main__':
    p=argparse.ArgumentParser();p.add_argument('--out',type=Path,required=True);run(p.parse_args().out)

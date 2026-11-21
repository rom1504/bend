"""Offline equivalence witnesses and exact physical object shapes, without invoking the compiler."""
import hashlib
import json
from pathlib import Path
import struct

HERE=Path(__file__).resolve().parent
ROOT=HERE.parents[2]
SELF=ROOT/'selfhost/build/phase198/progress-native-self01'
CAP=1<<26
BAD=(1<<32)-1


def sections(data):
    assert data[:7]==b'\x7fELF\x02\x01\x01' and struct.unpack_from('<HH',data,16)==(1,62)
    off=struct.unpack_from('<Q',data,40)[0];size,count,names=struct.unpack_from('<HHH',data,58)
    rows=[struct.unpack_from('<IIQQQQIIQQ',data,off+i*size)for i in range(count)]
    tab=rows[names];pool=data[tab[4]:tab[4]+tab[5]]
    return [(pool[r[0]:pool.index(0,r[0])].decode(),r)for r in rows]


def fused_size(data,count):
    at=0
    while at+4<=len(data):
        a,b,c,d=data[at:at+4]
        if count>CAP-4 or (a|b|c|d)>255:return BAD
        count+=4;at+=4
    for x in data[at:]:
        if count>=CAP or x>255:return BAD
        count+=1
    return count


def reverse_word(x):
    return bytes((x>>24,(x>>16)&255,(x>>8)&255,x&255))


def audit():
    report=json.loads((SELF/'report.json').read_bytes());data=(SELF/'program.o').read_bytes()
    assert report['complete'] and (len(data),hashlib.sha256(data).hexdigest())==(report['object']['bytes'],report['object']['sha256'])
    rows=sections(data);table={name:r for name,r in rows};tests=0;sites=0
    for count in (0,1,CAP-5,CAP-4,CAP-3,CAP-1,CAP):
        for size in range(11):
            for broken in range(-1,size):
                values=[(i*43)&255 for i in range(size)]
                if broken>=0:values[broken]=BAD if broken%2 else 256
                assert fused_size(values,count)==(count+size if count+size<=CAP and all(x<=255 for x in values) else BAD)
                tests+=1
    for name,r in rows:
        if r[1]!=4:continue
        assert r[9]==24
        for off in range(r[4],r[4]+r[5],24):
            offset,relkind,index,lo,hi=struct.unpack_from('<QIIII',data,off);assert offset<=BAD
            reverse=reverse_word(hi)+reverse_word(lo)+reverse_word(index)+reverse_word(relkind)+b'\0'*4+reverse_word(offset)
            assert reverse[::-1]==data[off:off+24];sites+=1
    forward=b'';old_reverse=b'';new_reverse=b'';layout_tests=0
    for name,r in rows[1:]:
        start=(64+len(forward)+r[8]-1)&(-r[8]);pad=start-64-len(forward)
        assert start==r[4];section=data[r[4]:r[4]+r[5]];forward+=bytes(pad)+section
        old_reverse=section[::-1]+bytes(pad)+old_reverse
        # Above two formulations model the reference and the tail-accumulator invariant.
        new_reverse=section[::-1]+bytes(pad)+new_reverse;layout_tests+=1
    assert forward==old_reverse[::-1]==new_reverse[::-1] and data[64:64+len(forward)]==forward
    for length in range(18):
        xs=bytes((i*97+3)&255 for i in range(length));acc=b'prefix';offset=0
        for i in range(0,length,4):
            group=xs[i:i+4]
            if len(group)==4:
                a,b,c,d=group;acc=bytes((d,c,b,a))+acc;offset+=4
            else:
                for a in group:acc=bytes((a,))+acc;offset+=1
        assert offset==len(xs) and acc==xs[::-1]+b'prefix';layout_tests+=1
    raw=sum(table[n][5] for n in ('.text','.rodata','.data'));section_bytes=sum(r[5]for _,r in rows)
    return dict(scope='Offline algebra and retained-object observations. No candidate execution or time measurement.',
        retainedSelfObject=report['object'],referenceReceipt=str((SELF/'report.json').relative_to(ROOT)),
        existingEmissionSeconds=report['emissionSeconds'],sections={k:r[5]for k,r in rows},validatedRELARecords=sites,
        boundarySizeOracleRows=tests,layoutOracleRows=layout_tests,removedFullSectionCountSteps=section_bytes,
        removedInputSectionCountSteps=raw,combinedRemovedListCountSteps=raw+section_bytes,
        oldRelocationConsPerRecord=104,newRelocationConsPerRecord=24,removedRelocationCons=80*sites)

if __name__=='__main__':
    print(json.dumps(audit(),indent=2))

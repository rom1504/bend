"""Exercise the two absolute U32 slots over full raw Char words and both boundaries."""
from collections import Counter
import json

ESC = 0xfffffffe
MISSING = 0xffffffff


def cache(words,start):
    return tuple(min(ESC,words[i]) if i<len(words) else MISSING for i in (start,start+1))


def evaluate(start,slots,index,off):
    if index not in (start,start+1):
        return 'outside',None
    cell=slots[index-start]
    if cell==MISSING:
        return 'missing',False
    if cell==ESC:
        return 'escaped',None
    return 'ordinary',bool(not off or ((cell>>(32-off))&1))


def original(words,index,off):
    if index>=len(words):
        return False
    return not off or (words[index] & (1 << (32-off)))!=0


def main():
    atoms=(0,1,127,128,255,256,0x90e8,0x9580,0x1f642,0x10ffff,0x7fffffff,0x80000000,ESC-1,ESC,MISSING)
    cases=[(),atoms,tuple(reversed(atoms)),tuple([0]*35),tuple([0x90e8]*31+[ESC,MISSING,0])]
    cases.extend((x,) for x in atoms)
    counts=Counter()
    for values in cases:
        for start in (0,1,3,7,14,31,32,((1<<48)-1)//33):
            slots=cache(values,start)
            for index in dict.fromkeys((0,1,2,7,14,31,32,len(values),max(0,start-1),start,start+1,start+2,(1<<48)-1)):
                for off in range(33):
                    route,result=evaluate(start,slots,index,off)
                    ordinary=original(values,index,off)
                    if result is None:
                        result=ordinary
                    assert result==ordinary
                    counts[route]+=1
    assert all(counts[k] for k in ('outside','missing','escaped','ordinary'))
    print(json.dumps(dict(checked=sum(counts.values()),byRoute=dict(counts)),indent=2))


if __name__=='__main__':
    main()

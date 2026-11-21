"""A lexical owner holds the original root, selected character and unread suffix."""
from dataclasses import dataclass


@dataclass(frozen=True)
class Cons:
    word: int
    tail: object


def build(words):
    value=None
    for word in reversed(words):
        assert 0 <= word <= 0xffffffff
        value=Cons(word,value)
    return value


class BorrowedCursor:
    def __init__(self,root):
        self.root=root
        self.visits=0
        self.reset()

    def reset(self):
        self.suffix=self.root
        self.index=-1
        self.word=None

    def query(self,position):
        assert position >= 0
        required,off=divmod(position,33)
        if required<self.index:
            self.reset()
        while self.index<required:
            if self.suffix is None:
                self.word=None
                self.index=required
                break
            self.word,self.suffix=self.suffix.word,self.suffix.tail
            self.visits+=1
            self.index+=1
        if self.word is None:return 0
        return int(off==0 or ((self.word>>(32-off))&1))


def controls():
    result=0
    for words in [[],[0],[0xffffffff],[0,0x10ffff,0x80000000,0xffffffff],[0x20,0x800,0x1f642,0x10000,0]]:
        c=BorrowedCursor(build(words))
        positions=list(range(33*(len(words)+2)))
        for order in [positions,list(reversed(positions)),positions[::2]+positions[1::2],[2**63+21,0,32,31,33]]:
            for pos in order:
                ci,off=divmod(pos,33)
                expected=int(ci<len(words) and (off==0 or ((words[ci]>>(32-off))&1)))
                assert c.query(pos)==expected
                result+=1
    return result


def byte_prefix(root):
    """Copy at most seven raw-byte characters into one scalar ABI word."""
    packed=0
    count=0
    reads=0
    while root is not None and count<7:
        reads+=1
        if root.word>255:break
        packed|=root.word<<(8*count)
        count+=1
        root=root.tail
    return packed|(count<<56)|(int(root is None)<<63),reads


def prefix_bit(packed,position):
    ci,off=divmod(position,33)
    count=(packed>>56)&7
    if ci>=count:return 0 if packed>>63 else None
    char=(packed>>(8*ci))&255
    return int(off==0 or ((char>>(32-off))&1))


def prefix_controls():
    checks=fallbacks=0
    for words in [[],[0],[255],[0,1,0,255],[0x100,1],[0,0x10ffff],[127]*7,[0,1,2,3,4,5,6,7,8],
                  [32,0xe9,0,0xffffffff,0]]:
        packed,_=byte_prefix(build(words))
        checker=BorrowedCursor(build(words))
        for pos in [*range(33*(len(words)+2)),2**63+21]:
            expected=checker.query(pos)
            actual=prefix_bit(packed,pos)
            if actual is None:fallbacks+=1
            else:assert actual==expected
            checks+=1
    return checks,fallbacks

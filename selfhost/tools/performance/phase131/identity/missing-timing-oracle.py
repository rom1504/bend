"""Independent arithmetic oracle for alternating found/missing record queries."""

def checksum(size):
    if not isinstance(size,int) or not 0<=size<=256:
        raise ValueError('The frozen proxy has exactly256 original names')
    value=2166136261
    for version in range(1001,1001+size):
        # First query is present after the second update pass. The next name
        # begins with :missing:, which none of the frozen definitions does.
        value=((value*16777619+version)*16777619)&0xffffffff
    return value

def ordinary_stdout():
    return ''.join(str(checksum(n))+'\n' for n in [0,1,16,64,256])

def validate(stdout,repeats,warmups,size):
    if isinstance(stdout,bytes):stdout=stdout.decode('ascii')
    if any(not isinstance(n,int) or not 0<=n<=1000000000 for n in [repeats,warmups]):
        raise ValueError('Invalid repetition counts')
    value=checksum(size)
    prefix=[str(value),str((warmups*value)&0xffffffff),str((repeats*value)&0xffffffff)]
    lines=stdout.splitlines()
    if len(lines)!=4 or stdout!='\n'.join(lines)+'\n' or lines[:3]!=prefix:
        raise ValueError('Independent found/missing output oracle mismatch')
    if not lines[3].isascii() or not lines[3].isdigit() or str(int(lines[3]))!=lines[3]:
        raise ValueError('Noncanonical elapsed milliseconds')
    ms=int(lines[3])
    return dict(complete=True,checksum=value,elapsedMilliseconds=ms,runtimeMilliseconds=ms,
                runtimeSeconds=ms*.001,timerUnit='milliseconds',aboveTwentyMillisecondFloor=ms>=20)

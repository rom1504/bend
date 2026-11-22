"""Executable task contracts. No expected answer is passed into a kernel."""
MASK = (1 << 32)-1

def word(x):
    return x & MASK

def edit_pair(index):
    def sequence(seed):
        chars = []
        for _ in range(256):
            seed = word(seed ^ (seed << 13))
            seed ^= seed >> 17
            seed = word(seed ^ (seed << 5))
            chars.append(seed & 3)
        return chars
    seed = word((index+1)*2654435761)
    a, b = sequence(seed), sequence(word(seed*340573321))
    prev = list(range(257))
    for i,x in enumerate(a,1):
        cur = [i]
        for j,y in enumerate(b,1):
            cur.append(min(prev[j]+1,cur[-1]+1,prev[j-1]+(x!=y)))
        prev = cur
    return word(prev[-1]*2654435761)^word(index+1)

def value(family,n,seed):
    if family=='editdist':
        return word(sum(edit_pair(word(seed+i)) for i in range(1<<n)))
    if family=='list':
        items=[]
        for _ in range(n):
            items.append(seed%16)
            seed=word(1664525*seed+1013904223)
        return word(sum(2*x for x in items if x>1))
    if family=='bst':
        keys=sorted(word(i*(2*seed+1)+seed)%257 for i in range(n))
        result=0
        for k in keys:
            result=word(10*result+k)
        return result
    if family=='expression':
        # Compose affine maps from the root down, opposite to the tuned loop.
        mul,add=1,0
        for i in range(n):
            s=word(seed+i)
            if s%3==0: add=word(add+mul*(3*s))
            elif s%3==1: mul=word(mul*(s%5+1))
            else: add=word(add-mul*(s+7))
        return word(mul*word(seed+n)+add)
    raise ValueError(family)

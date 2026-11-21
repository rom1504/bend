"""Independent path semantics, including the zero-fuel leaf boundary and duplicates."""
from collections import Counter

MASK = (1 << 32) - 1

def insert(tree,key,fuel,stats):
    if tree is None:
        stats['leafInserts'] += 1
        return (None,key,None)
    if fuel == 0:
        stats['cutoffs'] += 1
        return tree
    left,value,right = tree
    stats['frames'] += 1
    if key < value:
        stats['left'] += 1
        return (insert(left,key,fuel-1,stats),value,right)
    stats['right'] += 1
    return (left,value,insert(right,key,fuel-1,stats))

def inorder(tree):
    if tree is not None:
        l,v,r=tree
        yield from inorder(l)
        yield v
        yield from inorder(r)

def run(size,seed):
    tree=None
    stats=Counter()
    for i in range(size):
        value=(((i*((seed*2+1)&MASK)+seed)&MASK)%257)
        tree=insert(tree,value,size+1,stats)
    digest=0
    for value in inorder(tree):
        digest=(10*digest+value)&MASK
    return dict(inputs=[size,seed],digest=digest,counts=dict(stats))

def shape(tree):
    if tree is None:return '_'
    left,value,right=tree
    return '('+shape(left)+','+str(value)+','+shape(right)+')'

"""Independent semantic opcode table: family rules and ISA condition numbers, no source parsing."""
def table():
    rows={}
    for op,extra in [('add',0),('or',1),('and',4),('sub',5),('xor',6),('cmp',7)]:
        for suffix,width in [('b',8),('l',32),('q',64)]:rows[op+suffix]=(1,width,0,extra,0)
    for suffix,width in [('b',8),('l',32),('q',64)]:
        rows['mov'+suffix]=(2,width,0,0,0);rows['test'+suffix]=(13,width,0,0,0)
    rows['movabsq']=(15,64,0,0,0)
    for op,extra in [('shl',4),('shr',5),('sar',7)]:
        for suffix,width in [('l',32),('q',64)]:rows[op+suffix]=(3,width,0,extra,0)
    for suffix,width in [('l',32),('q',64)]:rows['imul'+suffix]=(4,width,0,0,0)
    conditions={'e':4,'z':4,'ne':5,'nz':5,'a':7,'ae':3,'b':2,'be':6,'l':12,'le':14,'g':15,'ge':13,'p':10,'np':11}
    for condition,code in conditions.items():
        rows['set'+condition]=(5,8,144+code,0,0);rows['j'+condition]=(9,0,15,128+code,0)
    for condition in ['e','ne','b','be','a','ae','l','le','g','ge']:
        for suffix,width in [('l',32),('q',64)]:rows['cmov'+condition+suffix]=(16,width,64+conditions[condition],0,0)
    rows.update(movzbl=(6,32,0,0,0),addss=(7,128,88,0,243),subss=(7,128,92,0,243),mulss=(7,128,89,0,243),divss=(7,128,94,0,243),ucomiss=(7,128,46,0,0),comiss=(7,128,47,0,0),movaps=(7,128,40,0,0),pxor=(7,128,239,0,102),pushq=(8,64,80,0,0),popq=(8,64,88,0,0),call=(9,0,232,0,0),jmp=(9,0,233,0,0),movd=(10,0,0,0,0),cvtsi2ssq=(11,64,0,0,0),leaq=(12,64,0,0,0),ret=(14,0,195,0,0))
    return rows

def cases():
    rows=table(); names=set(rows)
    for name in rows:
        names.update(name[:i] for i in range(len(name)))
        names.update([name+'x',name.upper(),name+' ',name+'\0','λ'+name,name+'λ'])
    names.update(['sqrtss','cvttss2siq','cmovzq','cmovnzl','salq','RET','\n',' ','.L','x'*129])
    # A deterministic permutation mixes bucket, arity and valid/invalid cases.
    names=sorted(names,key=lambda x:(sum((i+1)*ord(c) for i,c in enumerate(x))%97,x))
    return [(name,rows.get(name,(0,0,0,0,0))) for name in names]

def mix(acc,fields):
    for field in fields:acc=((acc^field)*16777619)&0xffffffff
    return acc

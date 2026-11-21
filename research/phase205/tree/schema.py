"""Freeze checked erased algebraic equations as alpha-invariant Bend patterns."""
import gzip,json
from pathlib import Path
BASE=Path('selfhost/build/phase200/p205-shapes01')
TAB={'insert.fin':1,'bst.down':2,'bst.step':3,'bst.pick':4,'bst.up':5,
     '$ctor.66_70_':6,'$ctor.66_76_101_97_102_':7,'$ctor.66_78_111_100_101_':8,
     'zc.up':5,'$ctor.90_69_110_100_':'Nil','$ctor.90_76_101_102_116_':9,'$ctor.90_82_105_103_104_116_':10}
schemas=[]
def freeze(t,env):
    tag=t['t'];n=t['n'];i=t['i'];q=t['q'];op=0
    if tag in ('Lam','Bind'):
        op=1;env[i]=len(env)+1;i=env[i];n=''
    elif tag=='Var':
        op=2;i=env[i];n=''
    elif tag in ('Ref','Ctr','Mat') and n in TAB:
        field=TAB[n]
        if isinstance(field,int):op=3;n=str(field)
        else:n=field
    kids=[freeze(k,env) for k in t['k']]
    return f'P205TExpr{{"{tag}",{op},"{n}",{i},{q},['+','.join(kids)+']}'
for source,rows in [('bst',[('entry','p37.bst.insert'),('finish','insert.fin'),('down','bst.down'),('step','bst.step'),('push','bst.pick'),('pop','bst.up')]),
                    ('compact',[('new_push','zc.choose'),('new_pop','zc.up')])]:
    ds={r['name']:r for r in json.load(gzip.open(BASE/(source+'.json.gz')))['defs']}
    for label,name in rows:schemas.append('def p205t_'+label+'() -> P205TExpr:\n  '+freeze(ds[name]['erased'],{})+'\n')
Path(__file__).with_name('schema.bend').write_text('\n'.join(schemas))

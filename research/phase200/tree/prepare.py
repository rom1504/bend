"""Generate private, type-checkable alternatives for the pinned real BST fixture."""
import argparse,json
from hashlib import sha256
from pathlib import Path
from oracle import run

HERE=Path(__file__).resolve().parent
ROOT=HERE.parents[2]
SOURCE=ROOT/'selfhost/tools/bench/catalogs/native45/fixtures/coverage-bst-64.bend'
ENTRY='def p37.bst.insert(+fuel: Nat, +x: U32, tree: BST) -> BST:\n  insert.fin(x, bst.down(fuel, x, (tree, Nil{})))'
ROLES={'compact':'zc.insert','direct':'zr.insert'}
POINTS=[(64,17),(32,0),(0,0),(1,17),(65,123),(16,0xffffffff),(127,128),(257,7)]

def pin(file):
    p=file.resolve();return dict(file=str(p),bytes=p.stat().st_size,sha256=sha256(p.read_bytes()).hexdigest())

def main(out):
    out.mkdir(parents=True,exist_ok=False)
    src=SOURCE.read_text();assert src.count(ENTRY)==1
    m=dict(source=pin(SOURCE),cases=[run(*p) for p in POINTS],roles={})
    assert m['cases'][0]['digest']==861157620 and m['cases'][1]['digest']==1802825775
    for role,name in ROLES.items():
        extra=(HERE/(role+'.bend')).read_text()
        new=extra+'\n'+ENTRY.split('\n')[0]+'\n  '+name+'(fuel, x, tree)'
        generated=out/(role+'.bend');generated.write_text(src.replace(ENTRY,new))
        m['roles'][role]=pin(generated)
    (out/'report.json').write_text(json.dumps(m,indent=2)+'\n')

if __name__=='__main__':
    p=argparse.ArgumentParser();p.add_argument('--out',type=Path,required=True);args=p.parse_args();main(args.out.resolve())

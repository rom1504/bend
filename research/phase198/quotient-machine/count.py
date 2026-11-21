"""Reuse the established native counter against each changed object."""
import argparse
import json
from pathlib import Path
import sys

HERE=Path(__file__).resolve().parent
ROOT=HERE.parents[2]
BUILD=ROOT/'selfhost/build/phase198'
sys.path.insert(0,str(ROOT/'selfhost/tools/bench'))
import bench as B

def run(emission,out):
    doc=B.read(emission)
    assert doc['complete'] and any(c['objectChanged'] for c in doc['cases'])
    census=B.read(BUILD/'runtime-count01/report.json')
    originals={c['id']:c for c in census['cases']}
    producer=HERE.parent/'profile/count.py'
    old=producer.read_text()
    def replace(s,x,y):
        assert s.count(x)==1,x
        return s.replace(x,y)
    adapted=replace(old,"    role=c['products']['candidate'];q=read(",
        "    role=c['products']['candidate'];new_object=selected[c['id']]['object'];q=read(")
    adapted=replace(adapted,"    checked_tool(role['generatedSource'])",
        "    assert role['generatedSource']==originals[c['id']]['object']\n    cmd[cmd.index(role['generatedSource']['file'])]=checked_tool(new_object)")
    adapted=replace(adapted,"'object':role['generatedSource'],'observerBinary'", "'object':new_object,'observerBinary'")
    selected={c['id']:c for c in doc['cases']}
    args=sys.argv
    try:
        sys.argv=[str(producer),'--out',str(out),'--cases',','.join(selected)]
        exec(compile(adapted,str(producer),'exec'),{'__name__':'__main__','__file__':str(producer),'selected':selected,'originals':originals})
    finally:
        sys.argv=args
    raw=B.read(out/'report.json')
    assert raw['complete'] and len(raw['cases'])==len(selected)
    comparison={}
    for c in raw['cases']:
        name=c['id']
        assert c['object']==selected[name]['object']
        rows={}
        for interval in ('first','second'):
            before=originals[name][interval]
            after=c[interval]
            keys={k for k in before.keys()|after.keys() if k.startswith(('divisor ','op 18','op 19'))}
            rows[interval]={k:dict(before=before.get(k,0),after=after.get(k,0)) for k in sorted(keys) if before.get(k,0)!=after.get(k,0)}
        comparison[name]=rows
    B.save(out/'comparison.json',dict(complete=True,method=B.pin(__file__),counter=B.pin(producer),emission=B.pin(emission),
        original=B.pin(BUILD/'runtime-count01/report.json'),candidate=B.pin(out/'report.json'),cases=comparison),fresh=True)
    print(json.dumps({k:v['second'] for k,v in comparison.items()}))

if __name__=='__main__':
    p=argparse.ArgumentParser()
    p.add_argument('--out',required=True,type=Path)
    p.add_argument('--emission',required=True,type=Path)
    o=p.parse_args()
    run(o.emission,o.out)

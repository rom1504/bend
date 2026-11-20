"""Normalize first-order Bend lists in captured diagnostic IR for review."""
import argparse
from pathlib import Path
from projection import read,save


def compact(node):
    if isinstance(node,list):
        return [compact(x) for x in node]
    if not isinstance(node,dict):
        return node
    if node.get('$') in ('Con','Nil'):
        rows=[]
        while node['$']=='Con':
            rows.append(compact(node['head']))
            node=node['tail']
        assert node['$']=='Nil'
        return rows
    return {k:compact(v) for k,v in node.items()}


if __name__=='__main__':
    p=argparse.ArgumentParser()
    p.add_argument('input',type=Path)
    p.add_argument('output',type=Path)
    args=p.parse_args()
    save(args.output,compact(read(args.input)))

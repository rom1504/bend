#!/usr/bin/env python3
"""Disjoint semantic and cross-cutting CPU ancestry views; never sum overlapping frames."""
import argparse
import collections
import hashlib
import json
import re
from pathlib import Path


def identity(file):
    file=Path(file).resolve(strict=True)
    return dict(file=str(file),sha256=hashlib.sha256(file.read_bytes()).hexdigest())


def read(file):return json.loads(Path(file).read_text())


def decode(name):return re.sub(r'_(\d+)_',lambda m:chr(int(m[1])),name.removeprefix('$jd$')).removesuffix('$scc')


SEMANTIC=[
 ('prepared-cache',lambda s:any(n in s for n in ['readBaseCache','decodeBaseCacheFrame','decodeBaseCacheGraphFrame','decodeBaseGraph'])),
 ('source-loading',lambda s:any(n.startswith(('f_prefix_complete','f_complete_','f_source_header','f_prefix_graph_trace')) for n in s)),
 ('checking',lambda s:any(n.startswith(('check_program_diagnostic','check_book','check_from_exact_prefix')) for n in s)),
 ('annotation',lambda s:'annotate_selected' in s or 'annotate_book' in s),
 ('source-reach',lambda s:'reach_book' in s),
 ('plan-selection',lambda s:'jd_plan_selected' in s),
 ('final-library',lambda s:'jd_plan_library' in s or 'jd_library_selected' in s),
 ('layout-proof',lambda s:'j_layout_error' in s),
 ('context-building',lambda s:'book_context' in s),
]


def semantic(names,urls):
    if '(garbage collector)' in names:return 'gc'
    if 'compileSourceTextModule' in names:return 'module-parse'
    if 'post' in names and any('node:inspector' in u for u in urls):return 'profiler-overhead'
    for label,predicate in SEMANTIC:
        if predicate(names):return label
    return 'other'


def mechanism(names,urls):
    if '(garbage collector)' in names:return 'gc'
    if 'compileSourceTextModule' in names:return 'module-parse'
    if any(n.startswith('decodeBase') or n=='readBaseCache' for n in names):return 'cache-decode-and-admission'
    if any(n=='index_hash' for n in names):return 'named-index-hash'
    if any(n.startswith('String.') for n in names):return 'string-library'
    if any(n.startswith(('index_','book_')) or n=='lookup' for n in names):return 'index-book-lookup'
    if any(n.startswith(('subst','env_subst','norm_','telescope_')) or n=='wnf' for n in names):return 'substitution-normalization'
    return 'other'


p=argparse.ArgumentParser(description=__doc__)
p.add_argument('report',type=Path);p.add_argument('--out',type=Path,required=True)
a=p.parse_args();assert not a.out.exists()
campaign=read(a.report);assert campaign['complete'] and campaign['pass'] and campaign['mode']=='cpu'
rows=[]
for row in campaign['rows']:
    assert row['success'];profile=row['observation']['profile']
    assert profile['weightedStatus']=='admitted' and not profile['weightedAccounting']['negativeDeltas']
    raw=read(profile['raw']['file']);assert identity(profile['raw']['file'])['sha256']==profile['raw']['sha256']
    nodes={node['id']:node for node in raw['nodes']};parents={child:node['id'] for node in raw['nodes'] for child in node.get('children',[])}
    chains={}
    for node_id in nodes:
        ids=[node_id]
        while ids[-1] in parents:ids.append(parents[ids[-1]])
        chains[node_id]=[nodes[node]['callFrame'] for node in reversed(ids)]
    by_sem=collections.Counter();by_mech=collections.Counter();cross=collections.Counter();unions=collections.Counter();self_functions=collections.Counter()
    for node_id,weight in zip(raw['samples'],raw['timeDeltas']):
        assert weight>=0
        frames=chains[node_id];names=[decode(f['functionName']) for f in frames];urls=[f.get('url','') for f in frames]
        stage=semantic(names,urls);family=mechanism(names,urls)
        by_sem[stage]+=weight;by_mech[family]+=weight;cross[(stage,family)]+=weight
        self_functions[names[-1]]+=weight
        for label,test in [
            ('string-library',lambda n:any(x.startswith('String.') for x in n)),
            ('index-hash',lambda n:'index_hash' in n),
            ('index-book-lookup',lambda n:any(x.startswith(('index_','book_')) or x=='lookup' for x in n)),
            ('substitution-normalization',lambda n:any(x.startswith(('subst','env_subst','norm_','telescope_')) or x=='wnf' for x in n)),
            ('host-exports',lambda n:'jd_exports' in n or any(x.startswith('jd_host_') for x in n)),
        ]:
            if test(names):unions[label]+=weight
    total=sum(raw['timeDeltas']);assert total==profile['weightedAccounting']['admittedWeightedUs']
    assert sum(by_sem.values())==sum(by_mech.values())==sum(cross.values())==total
    def view(counter):return [dict(name=name,microseconds=value,percent=value/total*100) for name,value in counter.most_common()]
    rows.append(dict(case=row['case'],role=row['role'],worker=row['result'],raw=profile['raw'],
        totalMicroseconds=total,samples=len(raw['samples']),semanticPartition=view(by_sem),
        mechanismPartition=view(by_mech),independentFamilyUnions=view(unions),
        cross=[dict(stage=key[0],mechanism=key[1],microseconds=value,percent=value/total*100) for key,value in cross.most_common()],
        topSelf=view(self_functions)[:35],
        caveat='Two complete independent partitions sum to100%; do not add across views. Family unions overlap '
               'one another. Missing named hash samples do not prove zero cost when code is inlined or unsampled.'))
result=dict(kind='phase63-cpu-ancestry-analysis',complete=True,**{'pass':True},dataOnly=True,targetExecuted=False,
    producer=identity(__file__),source=identity(a.report),rows=rows,
    scope='One candidate-only first-window CPU profile per source, including module/API import. '
          'No paired TS CPU counterfactual; measured work is not automatically excess or removable. '
          'Signed weighted accounting admitted with zero negative samples. GC is separate and unassigned '
          'to allocating stages. SCC names group primary dispatcher members; source anchors require review.')
a.out.parent.mkdir(parents=True,exist_ok=True)
with a.out.open('x') as stream:stream.write(json.dumps(result,indent=2)+'\n')
print(json.dumps(dict(output=identity(a.out),rows=[{k:r[k] for k in ['case','samples','semanticPartition','mechanismPartition','independentFamilyUnions']} for r in rows])))

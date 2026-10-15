#!/usr/bin/env python3
"""Count source occurrences inside exact upstream generated dispatch families."""
import argparse
import json
from pathlib import Path
import re
import sys
sys.dont_write_bytecode = True
from prepare import pin


def inspect(path, names):
    source = path.read_text()
    starts = list(re.finditer(r'(?m)^  WL_CASE\((FID_[A-Z0-9_]+)\)', source))
    families = {}
    for name in names:
        rows = []
        for i, start in enumerate(starts):
            if not re.fullmatch('FID_' + name.upper() + r'(?:_[CK][0-9]+)?', start[1]): continue
            end = starts[i+1].start() if i+1 < len(starts) else len(source)
            block = source[start.start():end]
            row = dict(symbol=start[1], line=source.count('\n', 0, start.start()) + 1, bytes=len(block.encode()))
            row.update({token:len(re.findall(r'\b'+token+r'\(', block)) for token in ['spin_1', 'term_keep', 'term_sink', 'heap_alloc', 'term_clo']})
            rows.append(row)
        assert rows, name
        families[name] = dict(blocks=rows, totals={key:sum(r[key] for r in rows) for key in ['bytes', 'spin_1', 'term_keep', 'term_sink', 'heap_alloc', 'term_clo']})
    tg = re.search(r'INLINE Term spin_1\(', source)
    assert tg
    stop = source.index('\nINLINE ', tg.end())
    body = source[tg.start():stop]
    assert all(key in body for key in ['CID_KTERM', 'CID_KLAMBDA', 'ctr_take(e, _t_0, 8'])
    return dict(c=pin(path), tagObserver=dict(symbol='spin_1', line=source.count('\n',0,tg.start())+1, body=body), families=families)


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--baseline', type=Path, required=True); p.add_argument('--candidate', type=Path, required=True)
    p.add_argument('--out', type=Path, required=True)
    a = p.parse_args(); assert not a.out.exists()
    report = dict(kind='phase98-upstream-generated-dispatch-static-counts', targetsRun=False,
                  method=pin(__file__), baseline=inspect(a.baseline,['infer_node','check_node']), candidate=inspect(a.candidate,['infer_node','check_node']),
                  scope='Syntactic calls within WL_CASE families, including inlined branch work. Not dynamic counts or timing. spin_1 is authenticated below by its complete generated constructor observer body.')
    with a.out.open('x') as f: json.dump(report,f,indent=2);f.write('\n')
    print(json.dumps({role:{name:row['totals'] for name,row in report[role]['families'].items()} for role in ['baseline','candidate']}))


if __name__ == '__main__': main()

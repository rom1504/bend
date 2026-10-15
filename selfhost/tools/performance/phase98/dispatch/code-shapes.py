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
    image_start = source.index('CONSTV u64 STAT_IMG[] = {')
    image_end = source.index('};', image_start)
    cells = re.findall(r'\d+ull|term_(?:pak|ctr)\([^)]*\)', source[image_start:image_end])
    def literal(offset):
        chars = []
        while True:
            chars.append(chr(int(cells[offset].removesuffix('ull'))))
            tail = cells[offset+1]
            if re.fullmatch(r'term_pak\(CID_SNIL, 0\)', tail): return ''.join(chars)
            match = re.fullmatch(r'term_ctr\(CID_SCON, STAT_OFF \+ (\d+)\)', tail)
            assert match
            offset = int(match[1])
    spins = list(re.finditer(r'(?m)^INLINE Term (spin_\d+)\(', source))
    observers = []
    for i, start in enumerate(spins[:-1]):
        block = source[start.start():spins[i+1].start()]
        roots = re.findall(r'o\[0\] = term_ctr\(CID_SCON, STAT_OFF \+ (\d+)\);', block)
        if ('CID_KTERM' in block and 'CID_KLAMBDA' in block and 'o[0] = _f_0;' in block
            and block.count('ctr_take(') == 3 and [literal(int(r)) for r in roots] == ['Lam', 'Lit']):
            observers.append((start, block))
    assert len(observers) == 1
    observer, observer_body = observers[0]
    tag_symbol = observer[1]
    starts = list(re.finditer(r'(?m)^  WL_CASE\((FID_[A-Z0-9_]+)\)', source))
    families = {}
    for name in names:
        rows = []
        for i, start in enumerate(starts):
            if not re.fullmatch('FID_(?:P98_)?' + name.upper() + r'(?:_[A-Z0-9]+)*', start[1]): continue
            end = starts[i+1].start() if i+1 < len(starts) else len(source)
            block = source[start.start():end]
            row = dict(symbol=start[1], line=source.count('\n', 0, start.start()) + 1, bytes=len(block.encode()))
            row.update({token:len(re.findall(r'\b'+token+r'\(', block)) for token in ['term_keep', 'term_sink', 'heap_alloc', 'term_clo']})
            row['tagObserverCalls'] = len(re.findall(r'\b'+tag_symbol+r'\(', block))
            rows.append(row)
        assert rows, name
        families[name] = dict(blocks=rows, totals={key:sum(r[key] for r in rows) for key in ['bytes', 'tagObserverCalls', 'term_keep', 'term_sink', 'heap_alloc', 'term_clo']})
    return dict(c=pin(path), tagObserver=dict(symbol=tag_symbol, line=source.count('\n',0,observer.start())+1,
                body=observer_body, decodedLambdaLiteralTags=['Lam','Lit']), families=families)


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--baseline', type=Path, required=True); p.add_argument('--candidate', type=Path, required=True)
    p.add_argument('--out', type=Path, required=True)
    p.add_argument('--names', nargs='+', default=['infer_node','check_node'])
    a = p.parse_args(); assert not a.out.exists()
    report = dict(kind='phase98-upstream-generated-dispatch-static-counts', targetsRun=False,
                  method=pin(__file__), baseline=inspect(a.baseline,a.names), candidate=inspect(a.candidate,a.names),
                  scope='Syntactic calls within WL_CASE families, including inlined branch work. Not dynamic counts or timing. Tag observer is identified by full constructor projection and decoded Lam/Lit static strings, not a fixed spin number.')
    with a.out.open('x') as f: json.dump(report,f,indent=2);f.write('\n')
    print(json.dumps({role:{name:row['totals'] for name,row in report[role]['families'].items()} for role in ['baseline','candidate']}))


if __name__ == '__main__': main()

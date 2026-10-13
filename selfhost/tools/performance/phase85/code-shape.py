#!/usr/bin/env python3
"""Offline generated-function census + attribution of existing CPU profiles.
Never imports a compiler image or executes a target. Includes nested arrow bodies
in each lexical outer function; wrappers and SCC dispatchers are separate rows.
Source bytes/tokens are NOT V8 bytecode size or proof of optimization failure.
"""
import argparse
from bisect import bisect_right
from collections import Counter, defaultdict
import hashlib
import importlib.util
import json
from pathlib import Path
import re


def pin(path):
    data = path.read_bytes()
    return dict(file=str(path), sha256=hashlib.sha256(data).hexdigest(), bytes=len(data))


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--root', type=Path, default=Path(__file__).resolve().parents[4])
    parser.add_argument('--out', type=Path, required=True)
    args = parser.parse_args()
    root = args.root.resolve()
    lexical = root / 'selfhost/tools/performance/phase53/generated-shape.py'
    spec = importlib.util.spec_from_file_location('lexical', lexical)
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    image = root / 'selfhost/build/phase82/compiler04-b2/full/compiler.mjs'
    source = image.read_text()
    # The older helper also counts named export-transport functions. Restrict
    # this census to $jd$ declarations, excluding repeated nested $dm names.
    begin = source.index('function $jd$')
    ts = module.tokens(source[begin:])
    definitions, i = {}, 0
    while i+3 < len(ts):
        if ts[i][0] != 'function' or not ts[i+1][0].startswith('$jd$'):
            i += 1
            continue
        name = ts[i+1][0]
        j = i+3
        while ts[j][0] != '{':
            j += 1
        depth, end = 1, j+1
        while depth:
            depth += (ts[end][0] == '{') - (ts[end][0] == '}')
            end += 1
        start, finish = begin+ts[i][1], begin+ts[end-1][2]
        raw = source[start:finish].encode()
        key = module.decode(name, True)
        assert key not in definitions, key
        definitions[key] = dict(identifier=name, line=source.count('\n',0,start)+1,
                                endLine=source.count('\n',0,finish)+1,
                                bytes=len(raw),sha256=hashlib.sha256(raw).hexdigest(),
                                tokens=[t[0] for t in ts[j+1:end-1]])
        i = end
    del ts
    source_lines = source.splitlines()
    rows = {}
    for name, item in definitions.items():
        ts = item['tokens']
        calls = Counter(ts[i] for i in range(len(ts)-1)
                        if ts[i].startswith('$jd$') and ts[i+1] == '(')
        scc_calls = [key for key in calls if key.endswith('$scc')]
        wrapper = len(ts) < 80 and len(calls) == 1 and len(scc_calls) == 1
        head = source_lines[item['line']-1].split('{', 1)[0]
        params = re.search(r'\(([^)]*)\)', head)
        rows[name] = dict(identifier=item['identifier'], line=item['line'], endLine=item['endLine'],
                          sourceBytes=item['bytes'], sha256=item['sha256'],
                          tokensIncludingNested=len(ts), arrowsIncludingNested=ts.count('=>'),
                          constDeclarationsIncludingNested=ts.count('const'),
                          parameterCount=len(params[1].split(',')) if params and params[1] else 0,
                          caseLabels=ts.count('case'), continues=ts.count('continue'),
                          callSites=sum(calls.values()), uniqueCallees=len(calls),
                          objectLiteralTags=sum(ts[i:i+2] == ['$', ':'] for i in range(len(ts)-1)),
                          role='scc' if name.endswith('$scc') else 'wrapper' if wrapper else 'body',
                          wrapperTarget=module.decode(scc_calls[0], True) if wrapper else None)
    wrappers = defaultdict(list)
    for name, row in rows.items():
        if row['wrapperTarget']:
            wrappers[row['wrapperTarget']].append(name)
    for name, members in wrappers.items():
        rows[name]['wrappers'] = members
    ordered = sorted(rows, key=lambda name: rows[name]['line'])
    starts = [rows[name]['line'] for name in ordered]
    profiles = json.loads((root/'implementation/phase83/profiles.json').read_text())
    evidence, by_case = {}, {}
    for case, summary in profiles['cpu'].items():
        if not case.endswith('-b2'):
            continue
        path = root / summary['profile']['file']
        assert pin(path)['sha256'] == summary['profile']['sha256']
        data = json.loads(path.read_text())
        nodes = {n['id']: n for n in data['nodes']}
        parents = {child: n['id'] for n in data['nodes'] for child in n.get('children', [])}
        self_ms, inclusive_ms, lexical_anonymous = Counter(), Counter(), Counter()
        def named(frame):
            name = frame['functionName']
            if name.startswith('$jd$'):
                return module.decode(name, True)
            return None
        for node_id, delta in zip(data['samples'], data['timeDeltas']):
            ms = delta / 1000
            frame = nodes[node_id]['callFrame']
            name = named(frame)
            if name in rows:
                self_ms[name] += ms
            elif not frame['functionName'] and frame['url'].endswith('/compiler04-b2/full/compiler.mjs'):
                index = bisect_right(starts, frame['lineNumber']+1)-1
                if index >= 0 and frame['lineNumber']+1 <= rows[ordered[index]]['endLine']:
                    lexical_anonymous[ordered[index]] += ms
            seen = set()
            while node_id:
                name = named(nodes[node_id]['callFrame'])
                if name in rows:
                    seen.add(name)
                node_id = parents.get(node_id)
            for name in seen:
                inclusive_ms[name] += ms
        by_case[case] = dict(requestMs=summary['timings']['requestMs'],
                             namedSelfMs=dict(self_ms), inclusiveMs=dict(inclusive_ms),
                             lexicalAnonymousSelfMs=dict(lexical_anonymous))
        evidence[case] = pin(path)
    total = Counter()
    for case in by_case.values():
        total.update(case['namedSelfMs'])
    selected = set(name for name, _ in total.most_common(35))
    selected.update(sorted(rows, key=lambda n: rows[n]['tokensIncludingNested'], reverse=True)[:20])
    selected.update(['wnf', 'tg', 'nm', 'ix', 'ks', 'kid', 'kt', 'index_find$scc', 'subst$scc', 'norm_eval_node$scc', 'f_lex_scanned$scc'])
    report = dict(kind='phase85-offline-b2-code-shape', targetExecution=False,
                  method='Lexical outer bodies include nested arrows; static sites are not execution counts. Named self samples are disjoint; inclusive rows overlap. Anonymous lexical attribution is separate.',
                  producer=pin(Path(__file__)), lexicalHelper=pin(lexical), image=pin(image),
                  upstream={n:pin(root/'selfhost/.bootstrap/upstream-phase66/bend2'/n) for n in ['bend.ts','comp.ts','main.ts']},
                  profileSummary=pin(root/'implementation/phase83/profiles.json'), profiles=evidence,
                  totals=dict(functions=len(rows),roles=dict(Counter(r['role'] for r in rows.values())),
                              tokens=sum(r['tokensIncludingNested'] for r in rows.values()),
                              arrows=sum(r['arrowsIncludingNested'] for r in rows.values())),
                  largest=[dict(name=n,**rows[n]) for n in sorted(rows,key=lambda n:rows[n]['tokensIncludingNested'],reverse=True)[:20]],
                  hot=[dict(name=n,selfAcrossEightProfilesMs=ms,**rows[n]) for n,ms in total.most_common(35)],
                  selected={n:rows[n] for n in sorted(selected) if n in rows}, byCase=by_case)
    args.out.parent.mkdir(parents=True,exist_ok=True)
    args.out.write_text(json.dumps(report,indent=2)+'\n')
    print(json.dumps(dict(output=str(args.out),totals=report['totals'],largest=[(r['name'],r['tokensIncludingNested'],r['caseLabels']) for r in report['largest'][:12]],hot=[(r['name'],round(r['selfAcrossEightProfilesMs'],1),r['role']) for r in report['hot'][:15]])))

if __name__ == '__main__':
    main()

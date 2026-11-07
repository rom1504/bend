#!/usr/bin/env python3
"""Observe complete checked candidate values; no compiler or target execution.

The frozen v1 observer mistakenly treats call-name Strings as records in its
compact summary. Its complete value artifact is correct. This repairs the
summary into a fresh file and traces unavailable dependencies against actual QBE.
"""
import argparse
import collections
import hashlib
import json
from pathlib import Path
import re


def pin(path):
    path = Path(path).resolve(strict=True)
    data = path.read_bytes()
    return dict(file=str(path), bytes=len(data), sha256=hashlib.sha256(data).hexdigest())


def verify(value):
    got = pin(value['file'])
    assert all(got[key] == value[key] for key in ['file', 'bytes', 'sha256'])
    return Path(got['file'])


def items(value):
    result = []
    while value.get('$') == 'Con':
        assert len(result) < 1000000
        result.append(value['head'])
        value = value['tail']
    assert value.get('$') == 'Nil'
    return result


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--report', type=Path, required=True)
    parser.add_argument('--qbe', type=Path, required=True)
    parser.add_argument('--out', type=Path, required=True)
    args = parser.parse_args()
    assert not args.out.exists(), 'Fresh evidence file required'
    receipt = pin(args.report)
    report = json.loads(verify(receipt).read_text())
    assert report['kind'] == 'phase173-candidate-admission-diagnostic' and report['complete']
    for item in report['inputs']:
        verify(item)
    observation = report['observation']
    value = json.loads(verify(observation).read_text())
    assert value['$'] == 'P173VDReport' and value['error'] == ''
    raw = {}
    for row in items(value['raw']):
        name = row['function']['name']
        assert name not in raw
        calls = items(row['calls'])
        assert all(isinstance(call, str) for call in calls)
        raw[name] = dict(name=name, error=row['error'], calls=calls,
                        result=row['function']['result'], parameters=len(items(row['function']['params'])))
    qbe = pin(args.qbe)
    text = verify(qbe).read_text()
    text = re.sub(r'FID_((?:[0-9]+_)+)', lambda m: ''.join(chr(int(n)) for n in m[1].rstrip('_').split('_')), text)
    ready = set(re.findall(r'^(?:export )?function .*?\$p113d_([^ (]+)\(', text, re.M))
    barriers = {}
    for start in ['$product.p173s_import_go', '$product.p173s_export_go', '$product.p173s_refs_go', '$product.p173c_go']:
        todo, seen, terminal = collections.deque([[start]]), set(), []
        while todo:
            chain = todo.popleft()
            name = chain[-1]
            if name in ready or name in seen:
                continue
            seen.add(name)
            if name not in raw:
                terminal.append(dict(chain=chain, reason='outside selected diagnostic candidates and not emitted'))
            elif raw[name]['error']:
                terminal.append(dict(chain=chain, reason=raw[name]['error']))
            else:
                todo.extend(chain+[called] for called in raw[name]['calls'] if called not in seen)
        barriers[start] = terminal
    result = dict(kind='phase173-candidate-admission-corrected-summary', version=1,
        complete=True, targetsRun=False, inputs=[pin(__file__), receipt, observation, qbe],
        correction='v1 compact summary call entries were null because each name String was read as a record; complete artifact unchanged.',
        scope='Read-only raw-error and emitted-worker dependency observation. Diagnostic candidate set precedes early-ready filtering; graph paths are evidence for investigation, not compiler transformations.',
        candidates=list(raw.values()), errorCounts=dict(collections.Counter(row['error'] for row in raw.values())),
        components=[dict(row, names=items(row['names'])) for row in items(value['components'])],
        firstUnavailablePaths=barriers)
    args.out.write_text(json.dumps(result, indent=2)+'\n')
    print(json.dumps(dict(candidates=len(raw), errors=result['errorCounts'], output=str(args.out))))


if __name__ == '__main__':
    main()

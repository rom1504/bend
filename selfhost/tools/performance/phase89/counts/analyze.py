#!/usr/bin/env python3
"""Validate exact phase marks, then report raw counts and request work trends."""
import argparse
import hashlib
import json
import re
from pathlib import Path


def require(ok, message):
    if not ok:
        raise ValueError(message)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('stderr', type=Path)
    parser.add_argument('out', type=Path)
    a = parser.parse_args()
    raw = a.stderr.read_text()
    rows = [json.loads(line[11:]) for line in raw.splitlines() if line.startswith('P89_COUNTS ')]
    require(rows and rows[0].get('schema') == 1, 'Missing counter header')
    header, marks = rows[0], rows[1:-1]
    require(header['marks'] in (6, 14) and len(marks) == header['marks'], 'Incomplete phase pattern')
    require(header['foreignEvents'] == header['overflow'] == 0, 'Non-owner activity or mark overflow')
    require(rows[-1]['final'] and rows[-1]['mark'] == header['marks'], 'Missing final counter snapshot')
    require(all(m['mark'] == i and not m['final'] for i, m in enumerate(marks)), 'Unordered phase marks')
    count = (len(marks) - 4) // 2
    reported = [int(re.search(r'base_prepare_ms=(\d+)', raw)[1]),
                int(re.search(r'runtime_prepare_ms=(\d+)', raw)[1])]
    requests = re.findall(r'request=(\d+) request_ms=(\d+) consumed_chars=(\d+)', raw)
    require([int(r[0]) for r in requests] == list(range(1, count + 1)), 'Incomplete request receipts')
    reported.extend(int(r[1]) for r in requests)
    phases = []
    previous = {k: 0 for k in marks[0]['counts']}
    for m in rows[1:]:
        require(m['counts'].keys() == previous.keys() and all(m['counts'][k] >= previous[k] for k in previous), 'Counter regression/schema mismatch')
        previous = m['counts']
    for i, name in enumerate(['base', 'runtime'] + [f'request-{i+1}' for i in range(count)]):
        before, after = marks[i * 2:i * 2 + 2]
        ms = after['ms'] - before['ms']
        require(ms == reported[i], 'Phase clock does not match existing IO.now receipt')
        counts = {k: after['counts'][k] - before['counts'][k] for k in before['counts']}
        require(counts['append_chars'] == counts['append_returns'], 'Unbalanced completed append work')
        require(counts['take_calls'] == counts['take_direct'] + counts['take_last'] + counts['take_shared'], 'Constructor classification mismatch')
        require(counts['drop_release'] == counts['drop_last'] + counts['drop_shared'], 'Drop classification mismatch')
        require(counts['alloc_misses'] == counts['alloc_cold'] + counts['alloc_bank'] + counts['alloc_fresh'], 'Allocator classification mismatch')
        phases.append(dict(name=name, instrumentedMs=ms, counts=counts))
    first, last = phases[2], phases[-1]
    trends = {k: dict(first=first['counts'][k], last=last['counts'][k],
                     ratio=last['counts'][k] / first['counts'][k] if first['counts'][k] else None)
              for k in first['counts']}
    report = dict(schema=1, complete=True, stderr=dict(file=str(a.stderr.resolve()), sha256=hashlib.sha256(a.stderr.read_bytes()).hexdigest()),
                  header=header, phases=phases, requestFirstLast=trends, finalCounts=rows[-1]['counts'],
                  limitations=['Counter-only diagnostic; instrumented clocks are not production speed.',
                               'Counts do not measure cache misses/latency or prove a leak.',
                               'Exact generated C and executable identity must be verified by the root harness.'])
    with a.out.open('x') as stream:
        json.dump(report, stream, indent=2)
        stream.write('\n')
    print(json.dumps(dict(complete=True, requests=count, out=str(a.out))))


if __name__ == '__main__':
    main()

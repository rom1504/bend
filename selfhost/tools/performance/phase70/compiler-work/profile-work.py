#!/usr/bin/env python3
"""Data-only attribution of already closed V8 CPU profiles; executes no target."""
import argparse
import hashlib
import json
import re
from collections import defaultdict
from pathlib import Path


WANTED = {
    'nc_compact', 'nc_compact_plain', 'nc_compact_list', 'nc_compact_ctor',
    'nc_definition', 'nc_definition_plain', 'nc_erase', 'nc_erase_annotated$scc',
    'nc_live_names', 'nc_bangs_names', 'nc_foreign_paths', 'ns_prepare', 'ns_defs',
    'ns_compile', 'nc_compile_def', 'nf_candidate', 'nq_candidate', 'nf_retry',
    'nf_admit', 'nf_admit_pass', 'nf_finish_retry', 'nf_worker_kinds',
    'nq_signatures', 'nc_refs', 'nc_term_fork', 'nf_ready_signatures',
    'nq_entry_demand',
}
CONTEXTS = [
    'nc_foreign_paths', 'nc_compile_checked', 'ns_compile', 'ns_defs',
    'nc_compile_def', 'nf_candidate', 'nq_candidate', 'nf_retry',
    'nf_finish_retry', 'nf_finish_show',
]


def pin(path):
    data = path.read_bytes()
    return data, dict(file=str(path.resolve()),
                     sha256=hashlib.sha256(data).hexdigest(), bytes=len(data))


def semantic_name(raw):
    if raw.startswith('$jd$'):
        return re.sub(r'_(\d+)_', lambda m: chr(int(m[1])), raw[4:])
    return raw.strip('$')


def summarize(path, expected, job):
    data, identity = pin(path)
    assert identity['sha256'] == expected['sha256']
    assert identity['bytes'] == expected['bytes']
    profile = json.loads(data)
    nodes = {row['id']: row for row in profile['nodes']}
    parents = {child: row['id'] for row in nodes.values()
               for child in row.get('children', [])}
    totals = defaultdict(int)
    under = defaultdict(lambda: defaultdict(int))
    assert len(profile['samples']) == len(profile['timeDeltas'])
    for node, delta in zip(profile['samples'], profile['timeDeltas']):
        seen = set()
        while node in nodes:
            seen.add(semantic_name(nodes[node]['callFrame']['functionName']))
            node = parents.get(node)
        for name in WANTED & seen:
            totals[name] += delta
            for context in CONTEXTS:
                if context in seen:
                    under[name][context] += delta
    return dict(job=job, profile=identity,
                sampledMs=sum(profile['timeDeltas']) / 1000,
                inclusive=[dict(name=name, sampledMs=totals[name] / 1000,
                    alsoUnder={key: val / 1000 for key, val in under[name].items()})
                    for name in sorted(totals, key=totals.get, reverse=True)])


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--summary', type=Path, required=True)
    parser.add_argument('--out', type=Path, required=True)
    args = parser.parse_args()
    assert not args.out.exists()
    data, summary_pin = pin(args.summary)
    summary = json.loads(data)
    assert summary['complete'] and summary['dataOnly']
    inputs = {row['file']: row for row in summary['inputs']}
    rows = []
    for row in summary['profiles']:
        path = Path(row['report']['file']).parent / 'request.cpuprofile'
        rows.append(summarize(path, inputs[str(path)], row['job']['name']))
    receipt = dict(kind='source-lane-profile-reduction', dataOnly=True,
        targetExecuted=False, summary=summary_pin, producer=pin(Path(__file__))[1],
        scope=('V8 sampled stack unions, not calls or clean wall times. Rows and '
               'contexts overlap; inlining and absent frames can undercount.'),
        profiles=rows)
    args.out.parent.mkdir(parents=True, exist_ok=True)
    with args.out.open('x') as stream:
        json.dump(receipt, stream, indent=2)
        stream.write('\n')


if __name__ == '__main__':
    main()

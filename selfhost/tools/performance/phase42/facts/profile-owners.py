#!/usr/bin/env python3
"""Map anonymous generated-API frames to enclosing emitted Bend definitions."""
import argparse
import bisect
import collections
import hashlib
import json
from pathlib import Path
import re
from urllib.parse import unquote, urlparse

p = argparse.ArgumentParser(description=__doc__)
p.add_argument('profile', type=Path)
p.add_argument('out', type=Path)
a = p.parse_args()
data = json.loads(a.profile.read_text())
nodes = {n['id']: n for n in data['nodes']}
parents = {c: n['id'] for n in data['nodes'] for c in n.get('children', [])}
api_sources = {}
owner = {}
for i, n in nodes.items():
    f = n['callFrame']
    url = f['url']
    if url.endswith('/api.mjs') and url.startswith('file:'):
        if url not in api_sources:
            file = Path(unquote(urlparse(url).path))
            text = file.read_text()
            starts = [(line, m.group(1)) for line, value in enumerate(text.splitlines())
                      if (m := re.match(r'^function \$([^\s(]+)\$\(', value))]
            api_sources[url] = dict(file=str(file), sha256=hashlib.sha256(file.read_bytes()).hexdigest(), starts=starts)
        starts = api_sources[url]['starts']
        at = bisect.bisect_right([s[0] for s in starts], f['lineNumber']) - 1
        if at >= 0:
            owner[i] = starts[at][1]
self_owner = collections.Counter()
family = collections.Counter()
symbols = collections.Counter()
phase = collections.Counter()
sample_count = collections.Counter()
total = sum(data['timeDeltas'])
for i, dt in zip(data['samples'], data['timeDeltas']):
    if i in owner:
        self_owner[owner[i]] += dt
    current = i
    names = set()
    native_names = set()
    while current in nodes:
        native_names.add(nodes[current]['callFrame']['functionName'])
        if current in owner:
            names.add(owner[current])
        current = parents.get(current)
    for prefix in ['j_component_', 'j_pure_', 'j_region_', 'j_layout_', 'j_']:
        if any(n.startswith(prefix) for n in names):
            family[prefix] += dt
            sample_count[prefix] += 1
    if any(n.startswith(('j_component_', 'j_pure_')) for n in names):
        family['component-or-pure'] += dt
        sample_count['component-or-pure'] += 1
    for name in names:
        if name.startswith(('j_component_', 'j_pure_')):
            symbols[name] += dt
    for name in ['inspect', 'inspectWithMemo', 'verifyAttempt', 'validatedCache',
                 'transformChoices', 'transformTailChoices', 'transformEquality']:
        if name in native_names:
            phase[name] += dt
result = dict(kind='phase42-facts-generated-owner-samples', samples=len(data['samples']), sampledMicroseconds=total,
              inputs=[dict(file=str(a.profile.resolve()), sha256=hashlib.sha256(a.profile.read_bytes()).hexdigest()),
                      *[dict(file=s['file'], sha256=s['sha256']) for s in api_sources.values()]],
              scope='Whole capture. Anonymous API closure lines map to enclosing emitted top-level Bend definition. Stack union for each prefix avoids internal double counting; different prefixes and phase rows overlap. Native tail trampolines can erase logical callers; owner mapping cannot reconstruct them.',
              families=[dict(prefix=n, sampledMicroseconds=family[n], samples=sample_count[n], wholeCapturePercent=100 * family[n] / total) for n in ['j_component_', 'j_pure_', 'component-or-pure', 'j_region_', 'j_layout_', 'j_']],
              analysisSymbols=[dict(name=n, inclusiveMicroseconds=t, wholeCapturePercent=100 * t / total) for n, t in symbols.most_common()],
              phases=[dict(name=n, inclusiveMicroseconds=t, wholeCapturePercent=100 * t / total) for n, t in phase.most_common()],
              largestBendSelfOwners=[dict(name=n, sampledMicroseconds=t, wholeCapturePercent=100 * t / total) for n, t in self_owner.most_common(35)])
assert not a.out.exists(), 'Preserve every summary'
a.out.write_text(json.dumps(result, indent=2) + '\n')
print(json.dumps(result, indent=2))

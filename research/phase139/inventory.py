#!/usr/bin/env python3
"""Offline lexical inventory of the frozen compiler and existing QBE owner map.
This is provenance/size evidence, not parsing, dependency analysis or cache admission.
"""
import collections
import hashlib
import json
from pathlib import Path
import re

ROOT = Path(__file__).resolve().parents[2]
SOURCE = ROOT / 'selfhost/build/phase137/integrated-source03/compiler.bend'
OWNERS = ROOT / 'selfhost/build/phase138/profile01/owners.json'
QBE = ROOT / 'selfhost/build/phase130/p137-reproduce01/program.ssa'

def pin(path):
    h = hashlib.sha256()
    with path.open('rb') as stream:
        for data in iter(lambda:stream.read(1 << 20), b''):
            h.update(data)
    return dict(file=str(path.relative_to(ROOT)),bytes=path.stat().st_size,sha256=h.hexdigest())

source_pin = pin(SOURCE)
assert source_pin['sha256'] == '2620d59a3a20fa5d5d27bbf3b12ceb7304439b27093fff1c0f383da03e4ecf38'
rows = []
pending = None
for line, text in enumerate(SOURCE.read_text().splitlines(), 1):
    module = re.match(r'^# Module: (.*):(\d+)$', text)
    if module:
        pending = dict(path=module[1],line=int(module[2]))
    declaration = re.match(r'^(def|type|law|enum|record)\s+([^\s(:]+)', text)
    if declaration:
        rows.append(dict(kind=declaration[1],name=declaration[2],line=line,origin=pending))
        pending = None
module_counts = collections.Counter(r['origin']['path'] if r['origin'] else '[unattributed]' for r in rows)
runs = collections.Counter()
last = None
for row in rows:
    key = row['origin']['path'] if row['origin'] else '[unattributed]'
    if key != last:
        runs[key] += 1
    last = key
selected = {'lookup','f_find','nc_ctor_owned','dg_check_events','nr_visit','p111q_main','p113i_eligible','p137qi_returns'}
positions = [dict(r,lexicalOrdinal=i,totalLexicalDeclarations=len(rows)) for i,r in enumerate(rows) if r['name'] in selected]
owners = json.loads(OWNERS.read_text())
qbe_pin = pin(QBE)
assert qbe_pin['sha256'] == owners['identities']['qbe']['sha256']
functions = data = direct = indirect = 0
static_words = None
descriptor_static_words = None
for line in QBE.open('rb'):
    functions += bool(re.match(rb'^(?:export )?function\b', line))
    data += bool(re.match(rb'^(?:export )?data\b', line))
    for call in re.finditer(rb'\bcall\s+([$%])', line):
        direct += call[1] == b'$'
        indirect += call[1] == b'%'
    if re.match(rb'^(?:export )?data \$p111_static_image ',line):
        static_words = len(re.findall(rb'\bl\s',line))
    if re.match(rb'^(?:export )?data \$p111_program ',line):
        items = re.findall(rb'\bl\s+([^,}]+)',line)
        assert len(items) == 24
        descriptor_static_words = int(items[8])
assert functions == owners['coverage']['functions']
assert static_words == descriptor_static_words and static_words is not None
by_owner = collections.Counter(f['lowered_owner'] or '[unknown]' for f in owners['functions'])
result = dict(complete=True,targetsRun=False,inputs=[pin(Path(__file__)),source_pin,pin(OWNERS),qbe_pin],
    source=dict(physicalLines=len(SOURCE.read_text().splitlines()),lexicalDeclarations=len(rows),
        declarationKinds=dict(collections.Counter(r['kind'] for r in rows)),
        attributedPaths=len(module_counts)-int('[unattributed]' in module_counts),
        unattributedDeclarations=module_counts['[unattributed]'],
        repeatedPathRuns=sum(n>1 for p,n in runs.items() if p!='[unattributed]'),
        largestProvenanceGroups=[dict(path=p,declarations=n,disjointRuns=runs[p]) for p,n in module_counts.most_common(15)],
        selectedPositions=positions),
    qbe=dict(functions=functions,dataDeclarations=data,directCallSites=direct,indirectCallSites=indirect,
        staticImageWords=static_words,descriptorStaticImageWords=descriptor_static_words,
        currentStaticAdmissionLimit=65536,remainingWordsUnderCurrentLimit=65536-static_words,
        ownerMapCoverage=owners['coverage'],
        largestLexicalOwnerGroups=[dict(owner=p,functions=n) for p,n in by_owner.most_common(15)]),
    scope='Static lexical counts only. Provenance paths are not independent modules; positions/counts do not estimate time or dirty dependencies. Owner grouping inherits profiler limitations. Zero textual indirect QBE calls does not exclude runtime dispatch.')
print(json.dumps(result,indent=2))

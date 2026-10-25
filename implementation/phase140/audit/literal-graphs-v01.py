#!/usr/bin/env python3
"""Audit historical changed literals by exact finite DAG identity; no compiler runs."""
import collections
import hashlib
import json
from pathlib import Path
import re
import sys
sys.dont_write_bytecode = True
ROOT = Path(__file__).resolve().parents[3]
sys.path.insert(0, str(ROOT / 'selfhost/tools/profiler'))
from owners import decoded_symbol, pin

CENSUS = ROOT / 'implementation/phase132/incremental-evidence/census.json'
PATTERNS = ROOT / 'implementation/phase132/incremental-evidence/literal-patterns.json'
SOURCES = [ROOT / ('selfhost/build/phase130/' + n + '/program.ssa')
           for n in ['p131-final-self01', 'p132-edited-full01']]
HEADER = re.compile(r'^(?:export )?function [^$]*\$([^ (]+)\(')
DATA = re.compile(r'^(?:export )?data \$(p111_cid_arity|p111_static_image|p111_program) ')
NUMBER = re.compile(r'(?<![\w.$])\d+(?![\w.])')
BASE = 51413504


def read(path, names):
    bodies, data, active, lines, size = {}, {}, None, [], 0
    with path.open() as stream:
        for line in stream:
            if active is None:
                m = HEADER.match(line)
                if m and m[1] in names:
                    active, lines = m[1], [line]
                d = DATA.match(line)
                if d:
                    assert d[1] not in data
                    data[d[1]] = line
            else:
                lines.append(line)
                if line == '}\n':
                    bodies[active] = lines
                    size += sum(map(len, lines))
                    assert size < 32 * 1024 * 1024
                    active, lines = None, []
    assert active is None and set(bodies) == names and len(data) == 3
    arities = [int(v) for v in re.findall(r'\bb (\d+)', data['p111_cid_arity'])]
    words = [int(v) for v in re.findall(r'\bl (\d+)', data['p111_static_image'])]
    descriptor = re.findall(r'\bl ([^,}]+)', data['p111_program'])
    assert len(descriptor) == 24 and int(descriptor[3]) == len(arities) and int(descriptor[8]) == len(words)
    return bodies, arities, words, data


class Pool:
    def __init__(self, arities, words):
        self.arities, self.words, self.nodes, self.identities = arities, words, {}, {}

    def boxed(self, word):
        if word >> 56 != 2:
            return None
        cid = (word >> 40) & 65535
        raw = word & ((1 << 40) - 1)
        offset = raw - BASE
        assert (word >> 32) & 255 == 0
        assert 0 <= cid < len(self.arities)
        count = self.arities[cid]
        assert count > 0 and 0 <= offset and offset + count <= len(self.words)
        return offset, cid

    def prepare(self, roots):
        todo = list(roots)
        while todo:
            word = todo.pop()
            node = self.boxed(word)
            if node is None:
                continue
            offset, cid = node
            if offset in self.nodes:
                assert self.nodes[offset] == cid, 'Conflicting constructor at a pool address'
                continue
            self.nodes[offset] = cid
            fields = self.words[offset:offset+self.arities[cid]]
            for field in fields:
                child = self.boxed(field)
                assert child is None or child[0] < offset, 'Non-backward static edge'
            todo.extend(fields)
        occupied = {}
        for offset, cid in sorted(self.nodes.items()):
            for index in range(offset, offset+self.arities[cid]):
                assert index not in occupied, 'Overlapping static nodes'
                occupied[index] = offset
            fields = tuple(self.word_key(v) for v in self.words[offset:offset+self.arities[cid]])
            # Intern exact structural tuples into one cross-pool identity map.
            key = ('boxed', cid, fields)
            self.identities[offset] = INTERN.setdefault(key, len(INTERN))

    def word_key(self, word):
        node = self.boxed(word)
        if node is not None:
            return ('node', self.identities[node[0]])
        tag = word >> 56
        assert tag in (0, 1)
        if tag == 0:
            assert word <= 0xffffffff
        else:
            cid = (word >> 40) & 65535
            assert (word >> 32) & 255 == 0 and cid < len(self.arities)
            assert self.arities[cid] in (0, 1)
            assert self.arities[cid] != 0 or (word & 0xffffffff) == 0
        return ('immediate', word)


INTERN = {}


def main():
    census, patterns = json.loads(CENSUS.read_text()), json.loads(PATTERNS.read_text())
    names = {r['name'] for r in census['declarations']['changes'] if r['before']['kind'] == 'function'}
    assert len(names) == 476
    left, right = [read(p, names) for p in SOURCES]
    assert left[1] == right[1], 'Constructor arities changed'
    changes, rejected = [], []
    for name in sorted(names):
        a, b = left[0][name], right[0][name]
        if len(a) != len(b):
            rejected.append(dict(function=name, reason='line count differs'))
            continue
        for index, (old, new) in enumerate(zip(a, b)):
            if old == new:
                continue
            x, y = list(NUMBER.finditer(old)), list(NUMBER.finditer(new))
            if NUMBER.sub('@', old) != NUMBER.sub('@', new) or len(x) != len(y):
                rejected.append(dict(function=name, line=index+1, reason='non-numeric instruction difference', before=old.rstrip(), after=new.rstrip()))
                continue
            for xx, yy in zip(x, y):
                av, bv = int(xx[0]), int(yy[0])
                if av != bv:
                    changes.append(dict(function=name, relativeLine=index+1, before=av, after=bv,
                                        instruction='copy' if '=l copy ' in old else 'store' if old.startswith('store') else 'call' if 'call $' in old else 'other'))
    pools = [Pool(left[1], left[2]), Pool(right[1], right[2])]
    for pool, side in zip(pools, ['before', 'after']):
        roots = [c[side] for c in changes]
        assert all(pool.boxed(v) is not None for v in roots), 'Changed numeric value is not a valid pool pointer'
        pool.prepare(roots)
    for row in changes:
        row['equalGraph'] = pools[0].word_key(row['before']) == pools[1].word_key(row['after'])
        row['offsetDelta'] = (row['after'] & ((1 << 40)-1)) - (row['before'] & ((1 << 40)-1))
    by_function = collections.defaultdict(list)
    for row in changes:
        by_function[row['function']].append(row)
    rows = [dict(symbol=name, decoded=decoded_symbol(name), changedOperands=len(entries),
                 equalGraphOperands=sum(e['equalGraph'] for e in entries),
                 onlyEqualGraphBindingChanges=all(e['equalGraph'] for e in entries),
                 instructions=dict(collections.Counter(e['instruction'] for e in entries)))
            for name, entries in sorted(by_function.items())]
    prior_copy = {r['name'] for r in patterns['rows'] if r['onlyDecimalCopyOperandsChanged']}
    result = dict(kind='phase140-historical-literal-graph-audit', complete=True, targetsRun=False,
                  inputs=[pin(Path(__file__)), pin(CENSUS), pin(PATTERNS), *[pin(p) for p in SOURCES],
                          pin(ROOT/'selfhost/build/phase137/integrated-source03/compiler.bend'),
                          pin(ROOT/'selfhost/build/phase128/runtime-borrow01/runtime.c')],
                  originalChangedFunctions=476, priorCopyOnlyFunctions=len(prior_copy),
                  previouslyUnclassifiedFunctions=476-len(prior_copy), rejectedInstructionChanges=rejected,
                  numericOperandChanges=len(changes), equalGraphOperandChanges=sum(r['equalGraph'] for r in changes),
                  onlyPlacementChangedFunctions=sum(r['onlyEqualGraphBindingChanges'] for r in rows),
                  actualGraphChangedFunctions=[r for r in rows if not r['onlyEqualGraphBindingChanges']],
                  previouslyUnclassifiedOnlyPlacement=sum(r['symbol'] not in prior_copy and r['onlyEqualGraphBindingChanges'] for r in rows),
                  instructionKinds=dict(collections.Counter(c['instruction'] for c in changes)),
                  poolWords=[len(p.words) for p in pools], decodedReachableNodes=[len(p.nodes) for p in pools],
                  constructorAritiesEqual=True, crossPoolExactStructuralInterning=True,
                  rows=rows, unequalGraphOperands=[c for c in changes if not c['equalGraph']],
                  scope='Artifact-only finite constructor-DAG comparison under equal constructor IDs/arities. Every compared boxed pointer has valid tag/CID/bounds, disjoint node fields and backward edges; scalar/packed leaves retain exact bits. No arbitrary number normalization, IR rewrite, graph-language proof, runtime identity or cache admission is claimed.')
    out = ROOT/'implementation/phase140/audit/literal-graphs01.json'
    assert not out.exists()
    out.write_text(json.dumps(result, indent=2)+'\n')
    print(json.dumps({k:result[k] for k in ['complete','originalChangedFunctions','numericOperandChanges','equalGraphOperandChanges','onlyPlacementChangedFunctions','previouslyUnclassifiedOnlyPlacement','instructionKinds','poolWords','decodedReachableNodes']}))
    print(json.dumps(dict(actualGraphChanged=[r['decoded'] for r in result['actualGraphChangedFunctions']],rejected=len(rejected),report=pin(out))))


if __name__ == '__main__':
    main()

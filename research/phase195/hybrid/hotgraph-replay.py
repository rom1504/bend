#!/usr/bin/env python3
"""Offline edit-row-only graph experiment; no compiler or target execution.

Reproduce the captured 32-name assignment exactly before predicting a larger
prefix. Python sets model the existing transfer/affinity/color semantics.
Not an allocator implementation or a qualification artifact.
"""
import hashlib
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
source = ROOT / 'selfhost/build/phase195/allocation-capture01/editdist/preselection.json'
functions = json.loads(source.read_text())['functions']
f = next(f for f in functions if f['allocation']['placementRows'] == 99
         and f['allocation']['eligibleNames'] == 75)
a = f['allocation']
homes = {row[0]: row for row in a['homes']}
params = f['params']
tail = [n for n in params[1:] if n != '__x181_result_out']


def locals_in(tree):
    if not isinstance(tree, list) or not tree:
        return []
    if tree[0] == 'N111Local':
        return [tree[1]]
    return [name for item in tree for name in locals_in(item)]


encounter = list(dict.fromkeys(locals_in(f['body']) + locals_in(f['setup'])))
eligible = [name for name in encounter if name in homes and homes[name][1] != 'X181Buffer']
order = sorted(eligible, key=lambda n: -homes[n][3])
assert order[:32] == a['candidates32'], 'Priority/encounter reproduction failed'
assert len(order) == 75


class Replay:
    def __init__(self, names, pool=9):
        self.names = names
        self.allowed = set(names)
        self.parameters = set(tail) & self.allowed
        self.header = set()
        self.graph = {name: set() for name in names}
        self.affinity = {name: set() for name in names}
        self.collect = False
        self.peak = 0
        self.pool = pool
        self.shift_blocked = set()

    def values(self, tree):
        return set(locals_in(tree)) & self.allowed

    def event(self, reads, writes, after, call=False):
        before = reads | (after - writes)
        if self.collect:
            self.peak = max(self.peak, len(before), len(after))
            for name in self.names:
                edges = set()
                if name in before:
                    edges |= before
                if name in after:
                    edges |= after | writes
                if name in writes:
                    edges |= after
                self.graph[name] |= edges - {name}
                if call and name in after - writes:
                    self.graph[name].add(name)
        return before

    def write(self, name):
        return {name} & self.allowed

    def branch(self, condition, yes, no, after):
        y = self.body(yes, after)
        n = self.body(no, after)
        return self.event(self.values(condition) | y, set(), n)

    def scalar(self, s, after):
        kind = s[0]
        if kind == 'N111Set':
            return self.event(self.values(s[3]), self.write(s[1]), after)
        if kind == 'N111Bin':
            if self.collect and s[3] in ('shl', 'shr', 'sar') and s[5][0] != 'N111Const':
                self.shift_blocked |= after | self.write(s[1])
            return self.event(self.values(s[4:]), self.write(s[1]), after)
        if kind == 'N111Load':
            return self.event(self.values(s[3]), self.write(s[1]), after)
        if kind == 'N111Store':
            return self.event(self.values([s[2], s[4]]), set(), after)
        if kind == 'N111Offset':
            return self.event(self.values(s[2:]), self.write(s[1]), after)
        if kind == 'N111Alloca':
            return after
        if kind == 'N111Call':
            assert s[3] != 'p111_rt_op', 'No inline-F32 approximation allowed'
            return self.event(self.values(s[4]), self.write(s[1]), after, True)
        if kind == 'N111Return':
            return self.event(self.values(s[1]), set(), set())
        if kind == 'N111If':
            return self.branch(s[1], [['P113DScalar', x] for x in s[2]],
                               [['P113DScalar', x] for x in s[3]], after)
        raise AssertionError(kind)

    def body(self, body, after):
        live = set(after)
        for s in reversed(body):
            kind = s[0]
            if kind == 'P113DScalar':
                live = self.scalar(s[1], live)
            elif kind == 'P113DIf':
                live = self.branch(s[1], s[2], s[3], live)
            elif kind == 'P113DCall':
                live = self.event(self.values(s[3]), set(s[1]) & self.allowed, live, True)
            elif kind == 'P113DResult':
                live = self.event(self.values(s[1]), set(), set())
            elif kind == 'P113DAgain':
                live = self.event(self.values(s[1]), self.parameters,
                                  self.header | self.parameters)
            else:
                raise AssertionError(kind)
        return live

    def pair(self, name, value):
        if value[0] == 'N111Local' and name in self.allowed and value[1] in self.allowed:
            self.affinity[name].add(value[1])
            self.affinity[value[1]].add(name)

    def affinities(self, body):
        for s in body:
            if s[0] == 'P113DScalar':
                scalar = s[1]
                if scalar[0] == 'N111Set':
                    self.pair(scalar[1], scalar[3])
                elif scalar[0] == 'N111If':
                    self.affinities([['P113DScalar', x] for x in scalar[2]])
                    self.affinities([['P113DScalar', x] for x in scalar[3]])
            elif s[0] == 'P113DIf':
                self.affinities(s[2]); self.affinities(s[3])
            elif s[0] == 'P113DAgain':
                for name, value in zip(tail, s[1]):
                    self.pair(name, value)

    def run(self):
        for _ in range(len(self.names) + 1):
            live = self.body(f['body'], set())
            if live == self.header:
                break
            self.header |= live
        else:
            raise AssertionError('fixed point failed')
        self.collect = True
        live = self.body(f['setup'], self.body(f['body'], set()))
        for name in reversed(params):
            live = self.event(set(), self.write(name), live)
        self.affinities(f['setup']); self.affinities(f['body'])
        groups = [set() for _ in range(self.pool)]
        colors = {}
        for name in self.names:
            position = params.index(name) if name in params else 2**32 - 1
            edges = self.graph[name]
            def legal(color):
                saved = color < 4 or color == 10
                allowed = saved or (name not in edges and position >= [0, 1, 2, 4, 5, 3][color-4])
                if color == 9 and name in self.shift_blocked:
                    allowed = False
                return allowed and not (groups[color] & (edges - {name} if saved else edges))
            preferred = next((c for c in range(self.pool) if groups[c] & self.affinity[name] and legal(c)), None)
            priorities = [4,5,6,7,8,0,1,2,3] if self.pool == 9 else [4,5,6,7,8,9,0,1,2,3,10]
            color = preferred if preferred is not None else next((c for c in priorities if legal(c)), None)
            colors[name] = color
            if color is not None:
                groups[color].add(name)
        return colors


def original_color(name):
    _, kind, index, _ = homes[name]
    return index-1 if kind == 'X181Register' else index+4 if kind == 'X185Transient' else None


original = Replay(order[:32])
c32 = original.run()
assert all(c32[n] == original_color(n) for n in order[:32]), '32-color reproduction failed'
results = {'kind': 'phase195-offline-hot-row-graph-replay', 'source': str(source),
           'sourceBytes': source.stat().st_size, 'sourceSha256': hashlib.sha256(source.read_bytes()).hexdigest(),
           'methodSha256': hashlib.sha256(Path(__file__).read_bytes()).hexdigest(),
           'symbol': f['symbol'], 'reproducedCandidates32': True, 'reproducedColors32': True,
           'scope': 'Static transfer/color replay, not machine output or runtime measurement.', 'variants': []}
for pool, cap in [(pool,cap) for pool in [9,11] for cap in [32,40,48,64,75]]:
    replay = Replay(order[:cap], pool); colors = replay.run()
    gained = [dict(name=n, score=homes[n][3], frameOffset=homes[n][2], color=c)
              for n, c in colors.items() if c is not None and original_color(n) is None]
    lost = [n for n,c in colors.items() if c is None and original_color(n) is not None]
    row = dict(pool=pool, cap=cap, represented=len(colors), homed=sum(c is not None for c in colors.values()),
               gained=gained, lost=lost, peakRepresentedLive=replay.peak,
               unhomed=[dict(name=n, score=homes[n][3], neighbors=len(replay.graph[n])) for n,c in colors.items() if c is None])
    results['variants'].append(row)
print(json.dumps(results, indent=2))

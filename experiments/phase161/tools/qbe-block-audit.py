#!/usr/bin/env python3
"""Offline emitted-QBE block inventory; never executes either program.

Reads one bounded line/block at a time. Numerical-shape equality is diagnostic,
NOT semantic equivalence: numeric constants include values as well as IDs.
"""
import argparse
import collections
import hashlib
import json
import re
from pathlib import Path

LIMIT = 32 * 1024 * 1024
START = re.compile(rb'^(?:export )?(?:(function) \w+ \$([^ (]+)|(?:thread )?(data) \$([^ =]+))')
NUMBER = re.compile(rb'(?<![\w.$])\d+(?![\w.])')
REF = re.compile(rb'\$([A-Za-z0-9_.$]+)')
LOCAL = re.compile(rb'[%@][A-Za-z0-9_.$]+')


def alpha_shape(data):
    names = {}
    def local(m):
        key = m[0]
        if key not in names:
            names[key] = key[:1] + b'local' + str(len(names)).encode()
        return names[key]
    return NUMBER.sub(b'#', LOCAL.sub(local, data))


def decode(name):
    m = re.fullmatch(r'(.*?FID_)((?:\d+_)+)', name)
    if m:
        return m[1].removesuffix('FID_') + ''.join(chr(int(x)) for x in m[2].split('_') if x)
    if name.startswith('$ctor.'):
        return ''.join(chr(int(x)) for x in name[6:].split('_') if x)
    return name


def inventory(path):
    blocks = {}; order = []; current = None; offset = 0; whole = hashlib.sha256()
    with path.open('rb') as f:
        while True:
            line = f.readline(LIMIT + 1)
            if not line:
                break
            if len(line) > LIMIT:
                raise ValueError('line exceeds explicit memory bound')
            whole.update(line)
            m = START.match(line)
            if m:
                if current is not None:
                    row['bytes'] = offset - row['offset']; row['sha256'] = h.hexdigest()
                current = ((m[1] or m[3]).decode(), (m[2] or m[4]).decode())
                if current in blocks:
                    raise ValueError('duplicate symbol: ' + str(current))
                row = dict(offset=offset); blocks[current] = row; order.append(current)
                h = hashlib.sha256()
            if current is None and line.strip():
                raise ValueError('unclassified leading source')
            if current is not None:
                h.update(line)
            offset += len(line)
    if current is not None:
        row['bytes'] = offset - row['offset']; row['sha256'] = h.hexdigest()
    return dict(file=str(path.resolve()), bytes=offset, sha256=whole.hexdigest()), blocks, order


def read_block(f, row):
    if row['bytes'] > LIMIT:
        raise ValueError('block exceeds explicit memory bound')
    f.seek(row['offset']); data = f.read(row['bytes'])
    if hashlib.sha256(data).hexdigest() != row['sha256']:
        raise ValueError('input changed during audit')
    return data


def data_metadata(f, blocks):
    names = {}
    for (kind, name), row in blocks.items():
        if kind == 'data' and re.fullmatch(r'p111_cid_names_\d+', name):
            data = read_block(f, row)
            raw = bytes(int(x) for x in re.findall(rb'\bb (\d+)', data))
            if not raw.endswith(b'\0'):
                raise ValueError('constructor name lacks terminator')
            names[int(name.rsplit('_', 1)[1])] = raw[:-1].decode('utf-8')
    vals = {}
    for name in ['p111_cid_arity', 'p111_cid_hot']:
        data = read_block(f, blocks['data', name])
        vals[name] = [int(x) for x in re.findall(rb'\bb (\d+)', data)]
        if len(vals[name]) != len(names):
            raise ValueError('constructor table length mismatch')
    seg = read_block(f, blocks['data', 'p111_segments'])
    refs = [x.decode() for x in REF.findall(seg)][1:]
    return names, vals, refs


def main():
    p = argparse.ArgumentParser(); p.add_argument('--full', type=Path, required=True)
    p.add_argument('--closure', type=Path, required=True); p.add_argument('--out', type=Path, required=True)
    a = p.parse_args(); pins = []; indexes = []; orders = []
    for path in [a.full, a.closure]:
        pin, blocks, order = inventory(path); pins.append(pin); indexes.append(blocks); orders.append(order)
    left, right = indexes; common = left.keys() & right.keys()
    result = dict(schema='phase161-qbe-block-audit-v1', inputs=pins,
        method='Exact block hashes; numeric-immediate and consistent local/label alpha-renaming shape diagnostics. No optimizer, parser, target execution or semantic equivalence claim.',
        lineAndBlockMemoryLimit=LIMIT, groups={})
    changed_functions = []
    for kind in ['function', 'data']:
        changed = sorted(k for k in common if k[0] == kind and left[k]['sha256'] != right[k]['sha256'])
        removed = sorted(k for k in left.keys() - right.keys() if k[0] == kind)
        added = sorted(k for k in right.keys() - left.keys() if k[0] == kind)
        result['groups'][kind] = dict(full=sum(k[0] == kind for k in left), closure=sum(k[0] == kind for k in right),
            changed=len(changed), removed=[decode(k[1]) for k in removed], added=[decode(k[1]) for k in added],
            changedSymbols=[k[1] for k in changed] if kind == 'data' else [],
            relativeOrderSame=[k for k in orders[0] if k in common and k[0] == kind] == [k for k in orders[1] if k in common and k[0] == kind])
        if kind == 'function': changed_functions = changed
    counts = collections.Counter(); operations = collections.Counter(); examples = []; other = []
    with a.full.open('rb') as fa, a.closure.open('rb') as fb:
        for k in changed_functions:
            x = read_block(fa, left[k]); y = read_block(fb, right[k])
            same_shape = NUMBER.sub(b'#', x) == NUMBER.sub(b'#', y)
            counts['numericImmediateShapeOnly' if same_shape else 'otherShapeChanges'] += 1
            lx = x.splitlines(); ly = y.splitlines()
            if len(lx) != len(ly): counts['differentLineCounts'] += 1
            alpha_same = alpha_shape(x) == alpha_shape(y)
            counts['alphaAndNumericShapeOnly' if alpha_same else 'beyondAlphaAndNumericShape'] += 1
            sample = []
            for i, (u, v) in enumerate(zip(lx, ly), 1):
                if u == v: continue
                counts['changedAlignedLines'] += 1
                shape = NUMBER.sub(b'#', u)
                op = re.match(rb'(?:%[^ ]+ =\w+ )?([a-z][a-z0-9]*)\b', shape)
                operations[(op[1].decode() if op else 'other')] += 1
                if len(sample) < 3 and len(u) < 500 and len(v) < 500:
                    sample.append(dict(line=i, full=u.decode(), closure=v.decode()))
            if not alpha_same:
                other.append(dict(symbol=k[1], decoded=decode(k[1]), full=left[k], closure=right[k], examples=sample))
            elif len(examples) < 4:
                examples.append(dict(symbol=k[1], decoded=decode(k[1]), examples=sample))
        ln, lv, ls = data_metadata(fa, left); rn, rv, rs = data_metadata(fb, right)
        li = {v: k for k, v in ln.items()}; ri = {v: k for k, v in rn.items()}
        if len(li) != len(ln) or len(ri) != len(rn): raise ValueError('duplicate constructor name')
        shared = li.keys() & ri.keys()
        result['constructors'] = dict(full=len(ln), closure=len(rn),
            moved=sum(li[n] != ri[n] for n in shared), removed=[decode(n) for n in sorted(li.keys() - ri.keys())],
            added=[decode(n) for n in sorted(ri.keys() - li.keys())],
            sharedArityAndHotEqual=all(lv[t][li[n]] == rv[t][ri[n]] for n in shared for t in lv),
            movedExamples=[dict(name=decode(n), full=li[n], closure=ri[n]) for n in sorted(shared) if li[n] != ri[n]][:12])
        result['dispatcher'] = dict(full=len(ls), closure=len(rs),
            changedPositions=[dict(fid=i, full=decode(x), closure=decode(y)) for i, (x, y) in enumerate(zip(ls, rs)) if x != y])
    result['functionDifferenceShapes'] = dict(counts=counts, operationCounts=operations, numericExamples=examples,
        otherCount=len(other), other=other[:50], otherListTruncated=len(other)>50)
    result['limitations'] = ['Numerical-immediate shape equality does not prove constructor/FID/value equivalence.',
        'No common-graph isomorphism, packed-static-value remapping proof, ABI compatibility or generated-program execution gate is supplied.',
        'Block hashes include inter-block whitespace, so they are stricter than instruction identity.']
    code = Path(__file__).read_bytes(); result['tool'] = dict(file=str(Path(__file__).resolve()), bytes=len(code), sha256=hashlib.sha256(code).hexdigest())
    a.out.parent.mkdir(parents=True, exist_ok=True); a.out.write_text(json.dumps(result, indent=2) + '\n')
    print(json.dumps(dict(groups={k: {n: v[n] for n in ['full', 'closure', 'changed']} for k, v in result['groups'].items()}, shapes=counts, constructors={k: result['constructors'][k] for k in ['full', 'closure', 'moved', 'sharedArityAndHotEqual']}, dispatcherChanges=len(result['dispatcher']['changedPositions']))))


if __name__ == '__main__':
    main()

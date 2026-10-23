"""Frozen-QBE experiment only: audit private scratch and mask dead field copies.

This is not a compiler pass or semantic admission for arbitrary QBE. Inputs must
be independently checked held-root readers with the exact runtime contract.
No target is built or executed by this script.
"""
import argparse
from collections import Counter
import hashlib
import json
from pathlib import Path
import re

VAR = re.compile(r'%[A-Za-z0-9_.]+')
DEF = re.compile(r'^(%[A-Za-z0-9_.]+) =[lwsd] (\w+) (.*)$')
FUNCTION = re.compile(r'(?m)^((?:export )?function[^\n]*\$([^ (]+)[^\n]*\{\n[\s\S]*?^\})')


def pin(path):
    path = Path(path).resolve(); data = path.read_bytes()
    return dict(file=str(path), bytes=len(data), sha256=hashlib.sha256(data).hexdigest())


def decode(symbol):
    return ''.join(chr(int(x)) for x in symbol.split('_FID_', 1)[1].split('_') if x)


def aliases(lines):
    result = {'%v_scratch': 0}
    assert sum(line == '%v_scratch =l alloc8 2048' for line in lines) == 1
    for line in lines:
        m = re.match(r'^(%\w+) =l add (%\w+), (\d+)$', line)
        if m and m[2] in result:
            assert int(m[3]) % 8 == 0
            assert m[1] not in result
            result[m[1]] = result[m[2]] + int(m[3]) // 8
    return result


def effect(line, addr):
    """Return exact private-scratch slots read/written by this instruction."""
    m = re.match(r'^%\w+ =l loadl (%\w+)$', line)
    if m and m[1] in addr:
        return {addr[m[1]]}, set()
    m = re.match(r'^storel \S+, (%\w+)$', line)
    if m and m[1] in addr:
        return set(), {addr[m[1]]}
    if ' call $' in line:
        m = re.search(r'call \$p118_rt_borrow_fields\(l %state, l %\w+, l (%\w+), w \d+, w (\d+)\)$', line)
        if m:
            assert m[1] == '%v_scratch' and 2 <= int(m[2]) <= 8
            return set(), set(range(int(m[2])))
        m = re.search(r'call \$p111_rt_special_ctor\(l %state, w [12], l (%v_scratch|0), w 0\)$', line)
        if m:
            return set(), set()
        assert not any(x in addr for x in VAR.findall(line)), ('unclassified scratch escape', line)
    return set(), set()


def dce(lines):
    removed = []
    while True:
        refs = Counter(v for line in lines for v in VAR.findall(line))
        addr = aliases(lines)
        discard = set()
        for i, line in enumerate(lines):
            m = DEF.match(line)
            if not m or refs[m[1]] != 1:
                continue
            pure = m[2] in {'copy','add','sub','shl','shr','and','or','xor','ceql','cnel','cultl'}
            safe_load = m[2] == 'loadl' and (m[3] in addr or re.fullmatch(r'%v_p114t_\d+_borrow_field_\d+', m[1]))
            if pure or safe_load:
                discard.add(i); removed.append(line)
        if not discard:
            return lines, removed
        lines = [line for i, line in enumerate(lines) if i not in discard]


def live_after(lines):
    addr = aliases(lines)
    labels = {line: i for i, line in enumerate(lines) if line.startswith('@')}
    successors = []
    for i, line in enumerate(lines):
        if line.startswith('jmp '):
            successors.append([labels[line[4:]]])
        elif line.startswith('jnz '):
            successors.append([labels[x.strip()] for x in line.split(',')[1:]])
        elif line.startswith('ret ') or line == '}':
            successors.append([])
        else:
            successors.append([i + 1] if i + 1 < len(lines) else [])
    effects = [effect(line, addr) for line in lines]
    before, after = [set() for _ in lines], [set() for _ in lines]
    for iteration in range(10000):
        changed = False
        for i in reversed(range(len(lines))):
            out = set().union(*(before[j] for j in successors[i]))
            read, written = effects[i]
            incoming = read | (out - written)
            changed |= incoming != before[i]
            before[i], after[i] = incoming, out
        if not changed:
            return after, addr, iteration + 1
    raise AssertionError('liveness did not converge')


def transform(body, mode):
    original = body.splitlines()
    addr = aliases(original)
    # Every scratch-using call must have its actual runtime footprint audited.
    for line in original:
        effect(line, addr)
    if mode == 'nullary-pointer':
        pattern = r'(call \$p111_rt_special_ctor\(l %state, w [12], l )%v_scratch(, w 0\))'
        result, count = re.subn(pattern, r'\g<1>0\2', body)
        assert count
        return result, dict(nullaryCalls=count)
    lines, before_dce = dce(original)
    live, addr, iterations = live_after(lines)
    removed, kept = [], []
    for i, line in enumerate(lines):
        m = re.match(r'^storel (%v_p114t_\d+_borrow_field_(\d+)), (%\w+)$', line)
        if m:
            assert m[3] in addr and addr[m[3]] == int(m[2])
            if addr[m[3]] not in live[i]:
                removed.append(dict(line=line, slot=addr[m[3]], liveAfter=sorted(live[i])))
                continue
        kept.append(line)
    assert removed
    result, after_dce = dce(kept)
    # All shape/RFC guards, original imports and fallback branches remain.
    def authority(lines):
        return [line for line in lines if 'call $' in line or line.startswith(('jnz ','jmp ','@')) or '_borrow_guard =' in line]
    assert authority(original) == authority(result)
    return '\n'.join(result), dict(removedFieldStores=removed, removedPureDefinitions=before_dce+after_dce,
                                   livenessIterations=iterations)


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--qbe', type=Path, required=True)
    p.add_argument('--runtime', type=Path, required=True)
    p.add_argument('--owner', required=True)
    p.add_argument('--mode', choices=['nullary-pointer','dead-fields'], required=True)
    p.add_argument('--out', type=Path, required=True)
    a = p.parse_args(); out = a.out.resolve(); assert not out.exists()
    inputs = [pin(__file__),pin(a.qbe),pin(a.runtime)]
    source = a.qbe.read_text(); selected = []
    for m in FUNCTION.finditer(source):
        if '_FID_' in m[2] and m[2].startswith('p113d_') and decode(m[2]) == '$p118borrow.read.' + a.owner:
            selected.append(m)
    assert len(selected) == 1
    m = selected[0]; replacement, details = transform(m[1], a.mode)
    result = source[:m.start()] + replacement + source[m.end():]
    out.mkdir(parents=True); product = out/'program.ssa'; product.write_text(result)
    for identity in inputs: assert pin(identity['file']) == identity
    report = dict(complete=True, targetsRun=False, inputs=inputs, mode=a.mode, owner=a.owner,
                  product=pin(product), details=details,
                  scope='Source-connected frozen reader ceiling only. Private scratch must not escape through state, runtime imports or retained pointers. Requires independent source/alias review and ordinary native oracle; no compiler selection or general correctness claim.')
    (out/'report.json').write_text(json.dumps(report,indent=2)+'\n')
    print(json.dumps(dict(report=pin(out/'report.json'),details=details)))


if __name__ == '__main__': main()

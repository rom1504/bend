#!/usr/bin/env python3
"""Create, never overwrite, a source-bound diagnostic C derivative; no targets."""
import argparse
import hashlib
import json
import re
from pathlib import Path

UPSTREAM = '059266225b77c8ca256ac6b25ee5c21449bab151'
TOOLCHAIN = {
    'bend.ts': '1d133151652b597a1a035c77c172475e6de096da37f3b9e3adc23c2f75bdfe49',
    'comp.ts': '2b13224ba09a9e39e37cccf06e449c1bdafe5e03a81641654f7d0e455507629c',
}
KINDS = {'phase89-checked-owned-match-derivative', 'phase89-checked-native-source-derivative'}


def pin(path):
    path = Path(path).resolve()
    b = path.read_bytes()
    return dict(file=str(path), sha256=hashlib.sha256(b).hexdigest(), bytes=len(b))


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('acquisition', type=Path, help='Completed checked acquisition report')
    p.add_argument('--receipt-sha256', required=True, help='Explicit expected acquisition report SHA256')
    p.add_argument('out', type=Path, help='Fresh directory; writes compiler.c and derivation.json')
    p.add_argument('--check-only', action='store_true', help='Validate all anchors/hash; write nothing')
    a = p.parse_args()
    receipt = pin(a.acquisition)
    if receipt['sha256'] != a.receipt_sha256:
        raise ValueError('Acquisition receipt does not match explicit pin')
    acquisition = json.loads(a.acquisition.read_bytes())
    if (acquisition.get('complete') is not True or acquisition.get('upstream') != UPSTREAM
            or acquisition.get('kind') not in KINDS or 'error' in acquisition
            or 'currentPhase' in acquisition):
        raise ValueError('Expected completed checked Phase89 acquisition at pinned upstream')
    if [p['name'] for p in acquisition['phases']] != ['load', 'check', 'emit-js', 'emit-c']:
        raise ValueError('Missing complete checked acquisition phases')

    def verify(expected):
        actual = pin(expected['file'])
        if actual['sha256'] != expected['sha256'] or actual['bytes'] != expected['bytes']:
            raise ValueError('Changed snapshot: ' + expected['file'])
        return actual

    bound = [receipt, verify(acquisition['source']), verify(acquisition['c'])]
    for name, digest in TOOLCHAIN.items():
        matches = [v for v in acquisition['inputs'] if Path(v['file']).name == name]
        if len(matches) != 1 or matches[0]['sha256'] != digest:
            raise ValueError('Missing or ambiguous pinned upstream tool: ' + name)
        bound.append(verify(matches[0]))
    original = bound[2]
    original_bytes = Path(original['file']).read_bytes()
    source = original_bytes.decode('utf-8')
    returns = re.findall(r'^  WL_CASE\(FID_(STRING_APPEND_K[0-9]+)\)\n', source, re.M)
    if len(returns) != 1:
        raise ValueError('Expected exactly one String.append return continuation')
    append_return = returns[0]
    header = Path(__file__).with_name('counters.h')
    changes = []
    reversible = []

    def replace(old, new, label):
        nonlocal source
        if source.count(old) != 1:
            raise ValueError('Expected unique source anchor: ' + label)
        source = source.replace(old, new, 1)
        reversible.append((old, new))
        changes.append(dict(label=label, oldSha256=hashlib.sha256(old.encode()).hexdigest(),
                            newSha256=hashlib.sha256(new.encode()).hexdigest()))

    def body(start, edits):
        if source.count(start) != 1:
            raise ValueError('Expected unique function definition: ' + start)
        begin = source.index(start)
        end = source.index('\n}', begin) + 2
        old = source[begin:end]
        new = old
        for anchor, injection in edits:
            if new.count(anchor) != 1:
                raise ValueError('Expected unique local anchor in ' + start)
            new = new.replace(anchor, injection, 1)
        replace(old, new, start)

    replace('} Env;\n', '} Env;\n\n' + header.read_text(), 'counter declarations')
    for signature, code in [
        ('INLINE u64 heap_alloc(Env e, u32 cls) {', 'P89_INC(alloc_calls); P89_ADD(alloc_words, 1ull << cls);'),
        ('OUTLINE void heap_hand(Env e, u32 cls) {', 'P89_INC(heap_hands);'),
        ('OUTLINE Term rfc_wrap(Env e, Term t, u32 cnt) {', 'P89_INC(wrap_calls);'),
        ('INLINE void rfc_bump(Env e, u64 r, u32 k) {', 'P89_INC(retain_calls); P89_ADD(retain_units, k);'),
        ('OUTLINE void span_fade(Env e, Term t, u64 src, u32 n) {', 'P89_INC(fade_calls); P89_ADD(fade_fields, n);'),
    ]:
        replace(signature, signature + '\n  ' + code, signature)
    body('INLINE void heap_free(Env e, u32 cls, u64 loc) {', [
        ('  e.mem[loc]       = ALC_AT(e, cls);', '  P89_INC(free_calls); P89_ADD(free_words, 1ull << cls);\n  e.mem[loc]       = ALC_AT(e, cls);')])
    body('OUTLINE u64 heap_alloc_miss(Env e, u32 cls) {', [
        ('  DEV u64* H = e.mem;', '  P89_INC(alloc_misses);\n  DEV u64* H = e.mem;'),
        ('    ALC_COLD(e, cls) = 0;', '    ALC_COLD(e, cls) = 0;\n    if (got) P89_INC(alloc_cold);'),
        ('    got = bank_pop(H, cls);', '    got = bank_pop(H, cls);\n    if (got) P89_INC(alloc_bank);'),
        ('    u32 pages = (n << cls) >> PAGE_BITS;', '    P89_INC(alloc_fresh); P89_ADD(fresh_words, (uint64_t)n << cls);\n    u32 pages = (n << cls) >> PAGE_BITS;')])
    body('FAR void term_drop(Env e, Term t) {', [
        ('  DEV u64* H = e.mem;', '  P89_INC(drop_calls);\n  DEV u64* H = e.mem;'),
        ('  for (;;) {\n    if (!term_triv(t)', '  for (;;) {\n    P89_INC(drop_items);\n    if (!term_triv(t)'),
        ('      u64      r = term_loc(t);', '      P89_INC(drop_release);\n      u64      r = term_loc(t);'),
        ('        t = 0;', '        P89_INC(drop_shared);\n        t = 0;'),
        ('        a32_acq(p);', '        P89_INC(drop_last);\n        a32_acq(p);'),
        ('      u64 tag = term_tag(t);', '      P89_INC(drop_nodes);\n      u64 tag = term_tag(t);'),
        ('        Term c = j == 0 ? c0 : H[loc + j];', '        P89_INC(drop_fields);\n        Term c = j == 0 ? c0 : H[loc + j];')])
    body('INLINE u64 ctr_take(Env e, Term t, u32 n, THR Term* out) {', [
        ('  DEV u64* H = e.mem;', '  P89_INC(take_calls); P89_ADD(take_fields, n);\n  DEV u64* H = e.mem;'),
        ('  if (!term_rfc(t)) {', '  if (!term_rfc(t)) {\n    P89_INC(take_direct);'),
        ('    a32_acq(c);', '    P89_INC(take_last);\n    a32_acq(c);'),
        ('  span_fade(e, t, src, n);', '  P89_INC(take_shared);\n  span_fade(e, t, src, n);')])
    # These bounded case spans avoid instrumenting similarly named continuations.
    for name, edits in [
        ('STRING_APPEND', [
            ('      r0 = _b_0;', '      P89_INC(append_finished);\n      r0 = _b_0;'),
            ('      Term _fb_0[2];', '      P89_INC(append_chars);\n      Term _fb_0[2];')]),
        (append_return, [('    WL_OPEN\n', '    WL_OPEN\n    P89_INC(append_returns);\n')]),
        ('NT_CHOOSE', [('    WL_OPEN\n', '    WL_OPEN\n    P89_INC(choose_calls);\n')]),
    ]:
        start = '  WL_CASE(FID_' + name + ')\n'
        if source.count(start) != 1:
            raise ValueError('Expected unique generated case: ' + name)
        begin = source.index(start)
        end = source.index('\n#endif', begin)
        old = source[begin:end]
        if name == append_return and old.count('    r0 = term_ctr(CID_SCON, _nd_0);\n    WL_RETN(1);') != 1:
            raise ValueError('Unexpected String.append return shape')
        new = old
        for anchor, injection in edits:
            if new.count(anchor) != 1:
                raise ValueError('Expected unique generated-case anchor: ' + name)
            new = new.replace(anchor, injection, 1)
        replace(old, new, start.strip())
    replace('  return (Term)(io_tick() / 1000000);',
            '  Term now = (Term)(io_tick() / 1000000);\n  p89_snapshot(now);\n  return now;', 'existing IO.now phase marks')
    restored = source
    for old, new in reversed(reversible):
        if restored.count(new) != 1:
            raise ValueError('Cannot uniquely reverse instrumentation edit')
        restored = restored.replace(new, old, 1)
    if restored.encode('utf-8') != original_bytes:
        raise ValueError('Instrumentation changed bytes outside recorded edits')
    output_bytes = source.encode('utf-8')
    boundary = 1024
    if (output_bytes[:boundary] != original_bytes[:boundary]
            or output_bytes[-boundary:] != original_bytes[-boundary:]):
        raise ValueError('Instrumentation unexpectedly changed source boundary bytes')
    fields = re.findall(r'X\((\w+)\)', header.read_text().split('#define P89_ENUM', 1)[0])
    if len(fields) != 31 or len(set(fields)) != 31 or 'match_joins' in fields:
        raise ValueError('Expected the 31-field diagnostic header')
    for entry in bound:
        verify(entry)
    if a.check_only:
        print(json.dumps(dict(complete=True, acquisition=receipt, edits=len(changes), fields=fields, appendReturn=append_return, boundaryBytes=boundary, inverseRecoversSource=True, outputSha256=hashlib.sha256(output_bytes).hexdigest())))
        return
    a.out.mkdir(parents=True, exist_ok=False)
    output = a.out / 'compiler.c'
    output.write_bytes(output_bytes)
    report = dict(schema=2, complete=True, kind='phase89-31-counter-diagnostic-derivative',
                  acquisition=receipt, upstream=UPSTREAM, boundInputs=bound, source=original, output=pin(output),
                  fields=fields, appendReturn=append_return, boundaryBytes=boundary, inverseRecoversSource=True,
                  method=pin(__file__), header=pin(header), edits=changes,
                  scope='Serial CPU operation-count diagnostic only; owner-thread counts; foreign activity refuses analysis; no timing/promotion claim')
    (a.out / 'derivation.json').write_text(json.dumps(report, indent=2) + '\n')
    print(json.dumps(report['output']))


if __name__ == '__main__':
    main()

#!/usr/bin/env python3
"""Create, never overwrite, a source-bound diagnostic C derivative; no targets."""
import argparse
import hashlib
import json
from pathlib import Path

EXPECTED = '8a636bf108bcc7f8378975b0077a8886be7300556be044b53e27a1023f09c659'


def pin(path):
    path = Path(path).resolve()
    b = path.read_bytes()
    return dict(file=str(path), sha256=hashlib.sha256(b).hexdigest(), bytes=len(b))


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('source', type=Path)
    p.add_argument('out', type=Path, help='Fresh directory; writes compiler.c and derivation.json')
    p.add_argument('--check-only', action='store_true', help='Validate all anchors/hash; write nothing')
    a = p.parse_args()
    original = pin(a.source)
    if original['sha256'] != EXPECTED:
        raise ValueError('Only the exact Phase88 native02 C snapshot is accepted')
    source = a.source.read_text()
    header = Path(__file__).with_name('counters.h')
    changes = []

    def replace(old, new, label):
        nonlocal source
        if source.count(old) != 1:
            raise ValueError('Expected unique source anchor: ' + label)
        source = source.replace(old, new, 1)
        changes.append(dict(label=label, oldSha256=hashlib.sha256(old.encode()).hexdigest(),
                            newSha256=hashlib.sha256(new.encode()).hexdigest()))

    def body(start, edits):
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
        ('STRING_APPEND_K21850', [('    WL_OPEN\n', '    WL_OPEN\n    P89_INC(append_returns);\n')]),
        ('NT_CHOOSE', [('    WL_OPEN\n', '    WL_OPEN\n    P89_INC(choose_calls);\n')]),
        ('NC_MATCH_APPLY_ORIGINAL_TO_K9473', [('    WL_OPEN\n', '    WL_OPEN\n    P89_INC(match_joins);\n')]),
    ]:
        start = '  WL_CASE(FID_' + name + ')\n'
        begin = source.index(start)
        end = source.index('\n#endif', begin)
        old = source[begin:end]
        new = old
        for anchor, injection in edits:
            if new.count(anchor) != 1:
                raise ValueError('Expected unique generated-case anchor: ' + name)
            new = new.replace(anchor, injection, 1)
        replace(old, new, start.strip())
    replace('  return (Term)(io_tick() / 1000000);',
            '  Term now = (Term)(io_tick() / 1000000);\n  p89_snapshot(now);\n  return now;', 'existing IO.now phase marks')
    if a.check_only:
        print(json.dumps(dict(complete=True, edits=len(changes), outputSha256=hashlib.sha256(source.encode()).hexdigest())))
        return
    a.out.mkdir(parents=True, exist_ok=False)
    output = a.out / 'compiler.c'
    output.write_text(source)
    report = dict(schema=1, complete=True, source=original, output=pin(output),
                  method=pin(__file__), header=pin(header), edits=changes,
                  scope='Serial CPU operation-count diagnostic only; owner-thread counts; foreign activity refuses analysis; no timing/promotion claim')
    (a.out / 'derivation.json').write_text(json.dumps(report, indent=2) + '\n')
    print(json.dumps(report['output']))


if __name__ == '__main__':
    main()

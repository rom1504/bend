#!/usr/bin/env python3
"""Fail-closed general host String ABI intervention on saved own-emitted C.

This is a mechanism prototype, not a compiler-produced or qualified release.
Every changed pattern is counted; the original products remain immutable.
"""
import argparse
import hashlib
import json
from pathlib import Path
import re


def pin(path):
    path = Path(path).resolve()
    raw = path.read_bytes()
    return dict(file=str(path), bytes=len(raw), sha256=hashlib.sha256(raw).hexdigest())


def transform(source, mode='all', append=False, compare=False):
    counts = {}

    def replace(old, new, name):
        nonlocal source
        assert source.count(old) == 1, (name, source.count(old))
        source = source.replace(old, new)
        counts[name] = 1

    runtime = Path(__file__).with_name('chunk-runtime.c').read_text()
    # Definitions needing term_keep follow it; the primitive retain/root precede it.
    cut = runtime.index('INLINE Term p101_head')
    replace('INLINE Term term_keep(Env e, Term t) {', runtime[:cut] +
            '\nINLINE Term term_keep(Env e, Term t) {\n'
            '  if (p101_string(t)) { p101_retain(e, t, 1); return t; }', 'keep')
    replace('INLINE Cls blk_cls(Term t) {', runtime[cut:] + '\nINLINE Cls blk_cls(Term t) {', 'runtime')
    replace('      if (tag == TAG_BUF) {',
            '      if (tag == TAG_STR) {\n'
            '        t = p101_release(e, t);\n'
            '        if (t) continue;\n'
            '      } else if (tag == TAG_BUF) {', 'drop')
    replace('    if (term_rfc(f)) {\n      rfc_bump(e, term_loc(f), 1);',
            '    if (p101_string(f)) {\n      p101_retain(e, f, 1);\n'
            '    } else if (term_rfc(f)) {\n      rfc_bump(e, term_loc(f), 1);', 'fade')
    replace('INLINE Loc ctr_take(Env e, Term t, u32 n, THR Term* out) {\n  Corpus H = e.mem;',
            'INLINE Loc ctr_take(Env e, Term t, u32 n, THR Term* out) {\n  Corpus H = e.mem;\n'
            '  if (p101_string(t)) {\n'
            '    if (n != 2) { err_post(H, ERR_FIDS); return 0; }\n'
            '    Loc p = term_loc(t), r = p101_root(e, t);\n'
            '    out[0] = (u32)H[p];\n'
            '    if (p + 1 < H[r + 1]) { out[1] = term_make(TAG_STR, CID_SCON, p + 1); }\n'
            '    else {\n'
            '      out[1] = term_keep(e, H[r + 2]);\n'
            '      term_sink(e, p101_release(e, t));\n'
            '    }\n'
            '    return 0;\n'
            '  }', 'take')
    # Array fill duplicates an arbitrary element via a batched retain.
    replace('      } else if (term_rfc(w)) {\n        rfc_bump(e, term_loc(w), (1u << d) - 1);',
            '      } else if (p101_string(w)) {\n        p101_retain(e, w, (1u << d) - 1);\n'
            '      } else if (term_rfc(w)) {\n        rfc_bump(e, term_loc(w), (1u << d) - 1);', 'array_fill')
    # Generated borrowed field reads: retain all non-String layouts unchanged.
    pattern = r'Loc (no_loc_\d+) = term_peek\(e, ([\w]+)\);\n((?:Term \w+ = e.mem\[\1 \+ \d+\];\n)+)'
    def observer(m):
        return re.sub(r'e.mem\[' + m[1] + r' \+ (\d+)\]',
                      lambda f: f'p101_field(e, {m[2]}, {f[1]})', m[3])
    source, counts['borrowed_matches'] = re.subn(pattern, observer, source)
    assert not re.search(r'Loc no_loc_\d+ = term_peek', source), 'Unrecognized borrowed layout'
    source, counts['observer_dispatch'] = re.subn(
        r'term_rfc\((\w+)\) && \(rfc_view\(e, term_loc\(\1\)\) & RFC_CNT\) > 1',
        lambda m: f'p101_shared(e, {m[1]})', source)
    # The replacement also matched the helper itself: restore its legacy branch.
    source = source.replace(': p101_shared(e, t);',
                            ': term_rfc(t) && (rfc_view(e, term_loc(t)) & RFC_CNT) > 1;')
    replace('        Loc l = term_peek(e, s);\n        show_chr(e.mem[l], \'"\');\n        s = e.mem[l + 1];',
            '        show_chr(p101_head(e, s), \'"\');\n        s = p101_tail(e, s);', 'show')
    # Generic show descriptors may expose String as an ordinary datatype.
    replace('  Term one;\n  char zs[4];', '  Term one;\n  Term p101_fields[2];\n  char zs[4];', 'show_buffer')
    replace('        w   = term_tag(t) == TAG_PAK ? &one : e.mem + term_peek(e, t);',
            '        if (p101_string(t)) {\n'
            '          p101_fields[0] = p101_head(e, t); p101_fields[1] = p101_tail(e, t); w = p101_fields;\n'
            '        } else { w = term_tag(t) == TAG_PAK ? &one : e.mem + term_peek(e, t); }', 'show_generic')
    if mode in ('input', 'all'):
        replace('  Term s    = term_pak(CID_SNIL, 0);\n  Loc  hole = 0;',
                '  Term s = term_pak(CID_SNIL, 0);\n  Loc prev = 0, chunk = 0, at = 0;', 'input_start')
        old = '''    Loc  l = heap_alloc(e, 1);
    Term t = term_ctr(CID_SCON, l);
    e.mem[l] = c;
    if (hole == 0) {
      s = t;
    } else {
      e.mem[hole] = io_seal(e, t, CID_SCON);
    }
    hole = l + 1;
  }
  if (hole != 0) {
    e.mem[hole] = io_seal(e, term_pak(CID_SNIL, 0), CID_SCON);
  }'''
        new = '''    if (chunk == 0 || at == chunk + P101_CHUNK_WORDS) {
      chunk = heap_alloc(e, P101_CHUNK_CLASS);
      e.mem[chunk] = 1;
      e.mem[chunk + 2] = term_pak(CID_SNIL, 0);
      at = chunk + 3;
      Term t = term_make(TAG_STR, CID_SCON, at);
      if (prev == 0) s = t; else e.mem[prev + 2] = t;
      prev = chunk;
    }
    e.mem[at] = ((at - chunk) << 32) | (u32)c;
    e.mem[chunk + 1] = ++at;
  }'''
        replace(old, new, 'input_builder')
    if mode in ('cons', 'all'):
        pattern = (r'u64 (nd_\d+) = heap_alloc\(e, cls_fit\(2\)\);\n'
            r'#if !DEVICE && NATIVE_COLD_CTORS && !NATIVE_HOT_CID_SCON\n'
            r'e.mem\[\1 \+ 0\] = ([^;\n]+);\n'
            r'e.mem\[\1 \+ 1\] = ([^;\n]+);\n#else\n'
            r'e.mem\[\1 \+ 0\] = rfc_seal\(e, \2\);\n'
            r'e.mem\[\1 \+ 1\] = rfc_seal\(e, \3\);\n#endif\n'
            r'([^\n;]+) = term_ctr\(CID_SCON, \1\);')
        source, counts['constructors'] = re.subn(pattern,
            lambda m: f'{m[4]} = p101_cons(e, {m[2]}, {m[3]});', source)
        remaining = re.findall(r'term_ctr\(CID_SCON, (?!STAT_OFF)[^)]*\)', source)
        # In cons-only ablation io_str is deliberately still linked.
        assert not remaining or (mode == 'cons' and remaining == ['term_ctr(CID_SCON, l)']), remaining
        replace('static Term io_node(Env e, u64 cid, Term a, Term b) {',
                'static Term io_node(Env e, u64 cid, Term a, Term b) {\n'
                '  if (cid == CID_SCON) return p101_cons(e, a, b);', 'io_node')
    if append:
        replace('INLINE Term term_word(Env e, Term w) {',
                Path(__file__).with_name('chunk-append.c').read_text() + '\nINLINE Term term_word(Env e, Term w) {', 'append_helper')
        name = 'FID_' + ''.join(str(ord(c)) + '_' for c in '$direct.String.append')
        pattern = r'  WL_CASE\(' + name + r'\)\n  \{.*?\n  \}\}'
        def bulk(m):
            assert 'CID_SNIL' in m[0] and 'CID_SCON' in m[0] and 'ctr_take' in m[0]
            return '  WL_CASE(' + name + ')\n  {\n    Term p101_left = r0, p101_right = r1;\n    WL_OPEN\nr0 = p101_append(e, p101_left, p101_right);\nWL_RETN(1);\n\n  }}'
        source, counts['append_entry'] = re.subn(pattern, bulk, source, flags=re.S)
        assert counts['append_entry'] == 1, 'Canonical saturated String.append worker required'
    if compare:
        replace('INLINE Cls blk_cls(Term t) {', Path(__file__).with_name('chunk-compare.c').read_text() +
                '\nINLINE Cls blk_cls(Term t) {', 'compare_helper')
        name = 'NF_FID_' + ''.join(str(ord(c)) + '_' for c in '$observer.String.cmp')
        pattern = (r'NF_INLINE Term ' + name +
            r'\(Env e, bool seq, Term\* nf_out, Term (\w+), Term (\w+)\) \{')
        matches = list(re.finditer(pattern, source)); assert len(matches) <= 1
        counts['compare_observer'] = len(matches)
        if matches:
            m = matches[0]; depth = 1; end = m.end()
            while depth:
                if source[end] == '{': depth += 1
                if source[end] == '}': depth -= 1
                end += 1
            old = source[m.end():end]
            assert 'CID_LT' in old and 'CID_EQ' in old and 'CID_GT' in old and 'nf_again' in old
            source = source[:m.end()] + ('\nif (!seq && err_seen(e.mem)) return 0;\n'
                f'nf_out[0] = p101_compare(e, {m[1]}, {m[2]});\n'
                'return !err_seen(e.mem);\n}') + source[end:]
    source = '#if defined(__METAL_VERSION__) || defined(__CUDACC_RTC__) || BEND_CUDA || BEND_METAL\n#error "P101 experimental host-only text ABI"\n#endif\n' + source
    return source, counts


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--source', type=Path, required=True)
    p.add_argument('--out', type=Path, required=True)
    p.add_argument('--mode', choices=['input', 'cons', 'all'], default='all')
    p.add_argument('--append', action='store_true')
    p.add_argument('--compare', action='store_true')
    a = p.parse_args()
    a.out.mkdir(parents=True, exist_ok=False)
    report = dict(complete=False, method=pin(__file__), runtime=pin(Path(__file__).with_name('chunk-runtime.c')),
                  source=pin(a.source), mode=a.mode, append=a.append, compare=a.compare,
                  appendRuntime=pin(Path(__file__).with_name('chunk-append.c')),
                  compareRuntime=pin(Path(__file__).with_name('chunk-compare.c')),
                  scope='General generated-C intervention; no compiler/release promotion')
    try:
        c, counts = transform(a.source.read_text(), a.mode, a.append, a.compare)
        (a.out / 'candidate.c').write_text(c)
        report.update(complete=True, candidate=pin(a.out / 'candidate.c'), rewrites=counts)
    except Exception as e:
        report['error'] = repr(e)
        raise
    finally:
        (a.out / 'preparation.json').write_text(json.dumps(report, indent=2) + '\n')
    print(json.dumps(report))


if __name__ == '__main__':
    main()

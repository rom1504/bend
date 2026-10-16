#!/usr/bin/env python3
"""Prepare a reversible Phase98 derivative with composable local NF calls."""
import argparse
import hashlib
import json
from pathlib import Path
import re

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[4]
BASE = ROOT / 'selfhost/build/phase98/origin-guard-source01/compiler.bend'
SHA = '2a72bbdc3d757982d7dd4804d8a1312f9427e3b2822ed9d187424c2d9f4de051'
BRIDGE = ROOT / 'selfhost/src/back/native/bridge.bend'
BOOK = ROOT / 'selfhost/src/back/native/book.bend'


def host_mark(source):
    old = 'nf_finish_plan(book, ss, cs,'
    new = 'nf_finish_plan(book, nf_scheduler_segments(book, ss), cs,'
    assert source.count(old) == 1
    offset = source.index(old)
    return source.replace(old, new), dict(offset=offset, old=old, new=new)


def pin(path):
    path = Path(path).resolve()
    raw = path.read_bytes()
    return dict(file=str(path), bytes=len(raw), sha256=hashlib.sha256(raw).hexdigest())


def patch(source, equal, scoped=False):
    changes = []
    def edit(old, new):
        nonlocal source
        assert old != new and source.count(old) == 1, old[:120]
        offset = source.index(old)
        changes.append(dict(offset=offset, old=old, new=new))
        source = source[:offset] + new + source[offset + len(old):]
    def definition(name):
        start = source.index('def ' + name + '(')
        return source[start:source.index('\n\n', start)]
    old = definition('nc_let_prefix_call')
    edit(old, old.replace('u => nc_let_cut(book, value, body, env, id, n), u =>',
                         'u => nf_scheduler_bind(book, value, body, env, id, n), u =>'))
    old = definition('nc_let_value')
    anchor = '  +tag = tg(value)\n'
    branch = ('  nt_choose(NC_Code, ' + equal + '(tag, "NFCall") && '
        'nf_scheduler_selected(book, nm(value), terms_len(ks(value))) && nc_prefix_vars(ks(value), env), '
        'u => nc_let_emitted(book, value, body, env, id, '
        'nf_scheduler_emitted(nm(value), nc_values(ks(value), env), n)), u =>\n')
    edit(old, old.replace(anchor, anchor + branch) + ')')
    if scoped:
        source, change = host_mark(source)
        changes.append(change)
        old = definition('ns_compile_named_scoped')
        anchor = '    u => ns_compile_fallback_scoped('
        replacement = ('    u => nt_choose(NC_Result, observers && List.is_empty(&2, String, bangs),\n'
            '      v => nf_scheduler_compile(prepared, names, bangs, runtime, requests, observers, sharing),\n'
            '      v => ns_compile_fallback_scoped(')
        assert anchor in old
        edit(old, old.replace(anchor, replacement) + ')')
    helpers = (HERE / 'helpers.bend').read_text()
    if scoped:
        helpers += '\n' + (HERE / 'helpers-scoped.bend').read_text()
    helpers = helpers.replace('String.eq(', equal + '(')
    offset = len(source)
    changes.append(dict(offset=offset, old='', new='\n' + helpers))
    source += '\n' + helpers
    return source, changes


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--out', type=Path, required=True)
    args = parser.parse_args()
    out = args.out.resolve()
    assert out.is_relative_to(ROOT / 'selfhost/build/phase102') and not out.exists()
    assert pin(BASE)['sha256'] == SHA
    original = BASE.read_text()
    candidate, changes = patch(original, 'p88_string_eq', scoped=True)
    reverse = candidate
    for change in reversed(changes):
        at = change['offset']
        assert reverse[at:at + len(change['new'])] == change['new']
        reverse = reverse[:at] + change['old'] + reverse[at + len(change['new']):]
    assert reverse == original
    canonical, canonical_changes = patch(BRIDGE.read_text(), 'String.eq')
    canonical_book, canonical_book_change = host_mark(BOOK.read_text())
    out.mkdir(parents=True)
    (out / 'compiler.bend').write_text(candidate)
    (out / 'canonical-bridge.bend').write_text(canonical)
    (out / 'canonical-book.bend').write_text(canonical_book)
    report = dict(kind='phase102-composable-native-worker-source', complete=True,
        targetsRun=False, releaseQualified=False, method=pin(__file__),
        helpers=pin(HERE / 'helpers.bend'), scopedHelpers=pin(HERE / 'helpers-scoped.bend'), source=pin(BASE),
        candidate=pin(out / 'compiler.bend'), changes=changes, inverseExact=True,
        canonicalSource=pin(BRIDGE), canonicalCandidate=pin(out / 'canonical-bridge.bend'),
        canonicalChanges=canonical_changes,
        canonicalBookSource=pin(BOOK), canonicalBookCandidate=pin(out / 'canonical-book.bend'),
        canonicalBookChanges=[canonical_book_change],
        physicalLineDelta=len(candidate.splitlines()) - len(original.splitlines()),
        byteDelta=len(candidate.encode()) - len(original.encode()),
        scope='Existing worker admission under scoped checked permission; strict ordered saturated call '
        'arguments, existing local producer ownership, boxed result. No new worker '
        'admission, product/observer ABI, runtime or installed release changes. '
        'Reachable bang and raw/provider-unqualified programs retain prior lowering.')
    (out / 'changes.json').write_text(json.dumps(report, indent=2) + '\n')
    print(json.dumps({k:report[k] for k in ('candidate', 'physicalLineDelta', 'byteDelta')}))


if __name__ == '__main__':
    main()

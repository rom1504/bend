#!/usr/bin/env python3
"""Prepare a reversible Phase98 derivative; do not run a compiler."""
import argparse
import hashlib
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[4]
BASE = ROOT / 'selfhost/build/phase98/origin-guard-source01/compiler.bend'
SHA = '2a72bbdc3d757982d7dd4804d8a1312f9427e3b2822ed9d187424c2d9f4de051'


def pin(path):
    path = Path(path).resolve()
    data = path.read_bytes()
    return dict(file=str(path), bytes=len(data), sha256=hashlib.sha256(data).hexdigest())


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--out', type=Path, required=True)
    a = p.parse_args()
    out = a.out.resolve()
    assert out.is_relative_to(ROOT / 'selfhost/build/phase99') and not out.exists()
    assert pin(BASE)['sha256'] == SHA
    source = BASE.read_text()
    candidate = source
    changes = []

    def edit(old, new):
        nonlocal candidate
        assert candidate.count(old) == 1, old[:120]
        changes.append(dict(old=old, new=new, offset=candidate.index(old)))
        candidate = candidate.replace(old, new)

    edit('NE_Text{ns_checked_runtime(book, runtime, packed, unshared)}',
         'NE_Text{ns_checked_runtime_scalars(book, runtime, packed, unshared, observers)}')
    edit('ne_runtime_prepend(runtime, ns_checked_runtime(book, "", packed, unshared))',
         'ne_runtime_prepend(runtime, ns_checked_runtime_scalars(book, "", packed, unshared, observers))')
    start = candidate.index('@unsafe\ndef ns_checked_runtime(')
    end = candidate.index('\n\n', start)
    old = candidate[start:end]
    new = old.replace('def ns_checked_runtime(', 'def ns_checked_runtime_scalars(')
    new = new.replace('+unshared: Bool) -> String:', '+unshared: Bool, +scalars: Bool) -> String:')
    new = new.replace('"#define NATIVE_TYPED_SCALARS " ++ nt_choose(String, packed,',
                      '"#define NATIVE_TYPED_SCALARS " ++ nt_choose(String, scalars,')
    # Existing callers retain the old packed gate. Only the two checked entries
    # pass the independently authenticated, rewrite-free provider certificate.
    wrapper = ('@unsafe\ndef ns_checked_runtime(+book: List<&2, KDef>, +runtime: String, '
               '+packed: Bool, +unshared: Bool) -> String:\n'
               '  ns_checked_runtime_scalars(book, runtime, packed, unshared, packed)\n\n')
    edit(old, wrapper + new)
    reverse = candidate
    for change in reversed(changes):
        at = change['offset']
        assert reverse[at:at + len(change['new'])] == change['new']
        reverse = reverse[:at] + change['old'] + reverse[at + len(change['new']):]
    assert reverse == source
    out.mkdir(parents=True)
    (out / 'compiler.bend').write_text(candidate)
    receipt = dict(kind='phase99-scoped-scalars-source', complete=True, targetsRun=False,
                   method=pin(__file__), source=pin(BASE), candidate=pin(out / 'compiler.bend'),
                   changes=changes, inverseExact=True,
                   physicalLineDelta=len(candidate.splitlines()) - len(source.splitlines()),
                   byteDelta=len(candidate.encode()) - len(source.encode()),
                   scope='Typed scalar locals/private parameters only. Existing field macros, '
                         'arrays, cold constructors, products and host planning keep packed permission. '
                         'Source candidate, not a qualified release or ABI proof.')
    (out / 'changes.json').write_text(json.dumps(receipt, indent=2) + '\n')
    print(json.dumps({k: receipt[k] for k in ['candidate', 'physicalLineDelta', 'byteDelta']}))


if __name__ == '__main__':
    main()

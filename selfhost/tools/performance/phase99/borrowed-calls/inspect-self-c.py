#!/usr/bin/env python3
"""Compare exact observer spans in completed C files; never execute targets."""
import argparse
from collections import Counter
import hashlib
import json
from pathlib import Path
import re
import runpy

ROOT = Path(__file__).resolve().parents[5]
EXTRACT = ROOT / 'selfhost/tools/performance/phase98/comparison/origin-self-c-mechanism.py'
EXTRACT_SHA = '13c25fbb44697a7a241ee1e5722dd63bebef49ae14f98ac2a9112000695f2d04'
FORBIDDEN = ['term_keep(', 'term_sink(', 'ctr_take(', 'spare_free(', 'heap_alloc(']


def pin(path):
    path = Path(path).resolve(); data = path.read_bytes()
    return dict(file=str(path), bytes=len(data), sha256=hashlib.sha256(data).hexdigest())


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--reference', type=Path, required=True)
    parser.add_argument('--candidate', type=Path, required=True)
    parser.add_argument('--source', type=Path, required=True)
    parser.add_argument('--out', type=Path, required=True)
    args = parser.parse_args(); out = args.out.resolve()
    assert out.is_relative_to(ROOT / 'selfhost/build/phase99') and not out.exists()
    assert pin(EXTRACT)['sha256'] == EXTRACT_SHA
    extract = runpy.run_path(str(EXTRACT))
    symbol, decoded, span = (extract[k] for k in ['symbol', 'decoded', 'span'])
    paths = {'reference': args.reference.resolve(), 'candidate': args.candidate.resolve()}
    inputs = {role: pin(path) for role, path in paths.items()}
    inputs['source'] = pin(args.source)
    texts = {role: path.read_text() for role, path in paths.items()}
    tables = {role: extract['functions'](text) for role, text in texts.items()}

    def body(role, name):
        start, end = tables[role][symbol(name)]
        return texts[role][start:end]

    def located(role, name, include=False):
        start, end = tables[role][symbol(name)]
        return dict(name=name, symbol=symbol(name), **span(texts[role], start, end, include))

    owners = {role: sorted(decoded(name)[len('$observer.'):] for name in table
                           if name.startswith(symbol('$observer.'))
                           and not name.startswith(symbol('$observer.adapter.')))
              for role, table in tables.items()}
    rows = []
    for owner in owners['candidate']:
        worker = '$observer.' + owner; adapter = '$observer.adapter.' + owner
        text = body('candidate', worker)
        calls = Counter(decoded(name) for name in re.findall(r'\b(NF_FID_(?:\d+_)+)\(', text))
        calls[worker] -= 1  # The function definition is not a call edge.
        calls = {name: count for name, count in sorted(calls.items()) if count}
        adapter_exists = symbol(adapter) in tables['candidate']
        adapter_text = body('candidate', adapter) if adapter_exists else ''
        original = body('candidate', owner) if symbol(owner) in tables['candidate'] else ''
        redirect = [line for line in original.splitlines(keepends=True)
                    if 'return ' + symbol(adapter) + '(' in line]
        row = dict(owner=owner, newlyAdmitted=owner not in owners['reference'],
                   worker=located('candidate', worker),
                   adapter=located('candidate', adapter) if adapter_exists else None,
                   calls=calls,
                   nonBorrowedCalls=[name for name in calls
                                     if not name.startswith('$observer.')
                                     or name.startswith('$observer.adapter.')],
                   ownershipOperations=[token for token in FORBIDDEN if token in text],
                   borrowedReads=text.count('term_peek('),
                   sharedRedirect=bool(redirect) and all('RFC_CNT) > 1' in line for line in redirect),
                   savedRoots=len(re.findall(r'Term no_root_\d+ =', adapter_text)),
                   adapterCallsWorker=symbol(worker) + '(e, seq, no_observed' in adapter_text)
        if symbol(owner) in tables['reference'] and redirect:
            old = body('reference', owner)
            without = original
            for line in redirect: without = without.replace(line, '', 1)
            # Only a newly admitted owner lacks this redirect in the reference.
            row['ordinaryBodyExactAfterRemovingNewRedirect'] = without == old if row['newlyAdmitted'] else None
        rows.append(row)

    focus = 'p88_string_eq'; focus_row = next((r for r in rows if r['owner'] == focus), None)
    focus_spans = {}
    if focus_row:
        for name in [focus, '$observer.' + focus, '$observer.adapter.' + focus]:
            focus_spans[name] = located('candidate', name, True)
        adapter = body('candidate', '$observer.adapter.' + focus)
        call_at = adapter.index(symbol('$observer.' + focus) + '(e, seq, no_observed')
        cleanup = [adapter.find('term_sink(e, no_root_' + str(i) + ')') for i in range(2)]
        focus_row['bothRootsDisposedAfterCall'] = all(at > call_at for at in cleanup)
        focus_row['owningAdapterHasNoKeep'] = 'term_keep(' not in adapter
    header = {role: dict(re.findall(r'^#define (NATIVE_\w+) (\d+)$', text[:text.index('\n\n')], re.M))
              for role, text in texts.items()}
    cold = {role: sorted(set(re.findall(r'^#undef (NATIVE_HOT_\w+)$', text, re.M)))
            for role, text in texts.items()}
    assertions = {
        'publicEqualityObserverAdmitted': focus_row is not None,
        'publicEqualitySharedRoutePresent': bool(focus_row and focus_row['sharedRedirect']),
        'publicEqualityCallsBorrowedWalker': bool(focus_row and '$observer.p88_string_eq_go' in focus_row['calls']),
        'publicEqualityOriginalOwnedFallbackPreserved': bool(focus_row and focus_row.get('ordinaryBodyExactAfterRemovingNewRedirect')),
        'publicEqualityAdapterOwnsCleanup': bool(focus_row and focus_row.get('bothRootsDisposedAfterCall') and focus_row.get('owningAdapterHasNoKeep') and focus_row['savedRoots'] == 2),
        'allObserverCallsRemainBorrowed': all(not row['nonBorrowedCalls'] for row in rows),
        'allObserverWorkersAvoidListedOwnershipOperations': all(not row['ownershipOperations'] for row in rows),
        'allObserverAdaptersPresent': all(row['adapterCallsWorker'] for row in rows),
        'globalRepresentationFlagsUnchanged': header['reference'] == header['candidate'],
        'noBorrowedKTermProjectionClaim': 'p98_tag_eq_read' not in owners['candidate'],
    }
    result = dict(kind='phase99-own-self-c-borrowed-call-inspection', complete=True,
                  passed=all(assertions.values()), targetsRun=False,
                  method=pin(__file__), extractionMethod=pin(EXTRACT), inputs=inputs,
                  assertions=assertions, globalFlags=header,
                  coverage=dict(reference=len(owners['reference']), candidate=len(owners['candidate']),
                                newlyAdmitted=sorted(set(owners['candidate']) - set(owners['reference'])),
                                removed=sorted(set(owners['reference']) - set(owners['candidate'])),
                                unchanged=sorted(set(owners['reference']) & set(owners['candidate'])),
                                workersWithBorrowedCalls=sum(bool(row['calls']) for row in rows)),
                  observerRows=rows, publicEqualitySpans=focus_spans,
                  coldMacroDelta=dict(added=sorted(set(cold['candidate']) - set(cold['reference'])),
                                      removed=sorted(set(cold['reference']) - set(cold['candidate']))),
                  limits=['Coverage counts static owners and edges, not dynamic calls or speedup.',
                          'Full C inputs may be emitted from different source revisions; only recorded spans are compared.',
                          'Header equality does not imply identical per-constructor cold eligibility; its delta is reported separately.',
                          'No compiler, program or lifetime proof was executed by this method.'])
    for role, path in paths.items(): assert pin(path) == inputs[role], (role, 'changed during inspection')
    assert pin(args.source) == inputs['source']
    out.parent.mkdir(parents=True, exist_ok=True)
    out.write_text(json.dumps(result, indent=2) + '\n')
    print(json.dumps(dict(passed=result['passed'], coverage=result['coverage'], report=pin(out))))


if __name__ == '__main__':
    main()

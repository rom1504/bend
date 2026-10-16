#!/usr/bin/env python3
"""Audit source04 observer guards/adapters/runtime in completed self C; no targets."""
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
SOURCE_SHA = 'c19e926eb7d8d41309c9ed8aa18960c484f3b17681507b57da5418ccfedd31ec'
FORBIDDEN = ['term_keep(', 'term_sink(', 'ctr_take(', 'spare_free(', 'heap_alloc(', 'native_word(', 'term_word(']


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
    assert inputs['source']['sha256'] == SOURCE_SHA
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
        roots = re.findall(r'Term no_root_(\d+) = (\w+);', adapter_text)
        root_words = [word for index, word in roots]
        shared = ''.join('(term_rfc(' + word + ') && (rfc_view(e, term_loc(' + word + ')) & RFC_CNT) > 1) || ' for word in root_words) + '0'
        trivial = ''.join('term_triv(' + word + ') && ' for word in root_words) + '1'
        expected_guard = 'if ((' + shared + ') || (' + trivial + ')) { return ' + symbol(adapter) + '(e, seq, nf_out'
        call_at = adapter_text.find('if (!' + symbol(worker) + '(e, seq, no_observed')
        cleanup = [adapter_text.find('term_sink(e, no_root_' + index + ')') for index, word in roots]
        saved = [adapter_text.find('Term no_root_' + index + ' =') for index, word in roots]
        scalar_cleanup = bool(roots) and call_at >= 0 and all(at < call_at for at in saved) and all(at > call_at for at in cleanup)
        scalar_words = re.findall(r'NF_SCALAR (\w+)', original.splitlines()[0]) if original else []
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
                   combinedGuardExact=len(redirect) == 1 and redirect[0].startswith(expected_guard),
                   redirectLines=redirect, guardRootWords=root_words,
                   scalarParameterWords=scalar_words,
                   narrowedScalarParametersExcluded=not set(root_words) & set(scalar_words),
                   scalarAdapterDisposesSavedRootsAfterCall=scalar_cleanup,
                   adapterHasNoKeep='term_keep(' not in adapter_text,
                   savedRoots=len(roots),
                   adapterCallsWorker=symbol(worker) + '(e, seq, no_observed' in adapter_text,
                   scalarRedirectPresent=bool(redirect))
        if symbol(owner) in tables['reference'] and redirect:
            old = body('reference', owner)
            without = original
            for line in redirect: without = without.replace(line, '', 1)
            old_redirect = [line for line in old.splitlines(keepends=True)
                            if 'return ' + symbol(adapter) + '(' in line]
            for line in old_redirect: old = old.replace(line, '', 1)
            row['ordinaryBodyExactAfterRemovingRedirects'] = without == old
            row['referenceRedirectLines'] = old_redirect
        if symbol(adapter) in tables['reference']:
            row['preexistingAdapterExact'] = adapter_text == body('reference', adapter)
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
    runtime = {}
    for role, text in texts.items():
        start = text.index('// Heap\n'); end = text.index('// Spins\n', start)
        runtime[role] = dict(**span(text, start, end), _text=text[start:end])
    runtime_exact = runtime['reference']['_text'] == runtime['candidate']['_text']
    for record in runtime.values(): del record['_text']

    def runtime_function(role, name):
        text = texts[role]
        matches = list(re.finditer(r'(?m)^(?:INLINE|OUTLINE|FAR) \w+ ' + re.escape(name) + r'\([^\n;]*\) \{', text))
        assert len(matches) == 1, (role, name)
        start = matches[0].start(); pos = text.index('{', start); depth = 0
        for end in range(pos, len(text)):
            if text[end] == '{': depth += 1
            elif text[end] == '}':
                depth -= 1
                if depth == 0: return span(text, start, end + 2, True)
        raise AssertionError(('Unclosed runtime function', name))

    runtime_functions = {name: {role: runtime_function(role, name) for role in texts}
                         for name in ['term_triv', 'term_sink', 'term_keep', 'term_peek', 'ctr_take', 'term_drop', 'rfc_wrap', 'rfc_view']}
    trivia = runtime_functions['term_triv']['candidate']['text']
    sink = runtime_functions['term_sink']['candidate']['text']
    scalar_rows = [row for row in rows if row['scalarRedirectPresent']]
    tag_exact = all(body('reference', name) == body('candidate', name)
                    for name in ['p98_tag_eq', 'p98_tag_eq_read', 'p98_tag_eq_finish'])
    static_at = texts['candidate'].index('CONSTV u64 STAT_IMG[] = { ') + len('CONSTV u64 STAT_IMG[] = { ')
    static_end = texts['candidate'].index(' };', static_at)
    words = re.findall(r'\d+ull|term_(?:pak|ctr)\([^)]*\)', texts['candidate'][static_at:static_end])

    def static_string(index):
        chars = []; seen = set()
        while index not in seen and len(chars) < 128:
            seen.add(index); chars.append(chr(int(words[index].removesuffix('ull'))))
            tail = words[index + 1]
            if tail == 'term_pak(CID_SNIL, 0)': return ''.join(chars)
            match = re.fullmatch(r'term_ctr\(CID_SCON, STAT_OFF \+ (\d+)\)', tail)
            assert match, tail
            index = int(match[1])
        raise AssertionError('Invalid or excessive static String chain')

    tag_literals = [dict(offset=int(value), value=static_string(int(value))) for value in
                    re.findall(r'term_ctr\(CID_SCON, STAT_OFF \+ (\d+)\)', body('candidate', 'p98_tag_eq_read'))]
    assertions = {
        'publicEqualityObserverAdmitted': focus_row is not None,
        'publicEqualityCombinedGuardExact': bool(focus_row and focus_row['combinedGuardExact']),
        'publicEqualityCallsBorrowedWalker': bool(focus_row and '$observer.p88_string_eq_go' in focus_row['calls']),
        'publicEqualityOriginalOwnedFallbackPreserved': bool(focus_row and focus_row.get('ordinaryBodyExactAfterRemovingRedirects')),
        'publicEqualityAdapterOwnsCleanup': bool(focus_row and focus_row.get('bothRootsDisposedAfterCall') and focus_row.get('owningAdapterHasNoKeep') and focus_row['savedRoots'] == 2),
        'allScalarGuardsExactlyAnySharedOrAllSchemaRootsTrivial': bool(scalar_rows) and all(row['combinedGuardExact'] and 1 <= row['savedRoots'] <= 2 for row in scalar_rows),
        'allNarrowedScalarParametersExcludedFromGuards': all(row['narrowedScalarParametersExcluded'] for row in scalar_rows),
        'allScalarOrdinaryFallbacksPreserved': all(row.get('ordinaryBodyExactAfterRemovingRedirects') for row in scalar_rows),
        'allScalarAdaptersOwnCleanupAfterObservation': all(row['scalarAdapterDisposesSavedRootsAfterCall'] and row['adapterHasNoKeep'] for row in scalar_rows),
        'allPreexistingAdaptersUnchanged': all(row.get('preexistingAdapterExact', True) for row in rows),
        'allObserverCallsRemainBorrowed': all(not row['nonBorrowedCalls'] for row in rows),
        'allObserverWorkersAvoidListedOwnershipOperations': all(not row['ownershipOperations'] for row in rows),
        'allObserverAdaptersPresent': all(row['adapterCallsWorker'] for row in rows),
        'globalRepresentationFlagsUnchanged': header['reference'] == header['candidate'],
        'perConstructorColdMacrosUnchanged': cold['reference'] == cold['candidate'],
        'heapThroughRootRuntimeSectionUnchanged': runtime_exact,
        'listedOwnershipRuntimeFunctionsUnchanged': all(row['reference']['text'] == row['candidate']['text'] for row in runtime_functions.values()),
        'trivialPredicateAndConstantTimeSinkExact': 'return term_tag(t) <= TAG_PAK || t == TERM_HOLE || term_loc(t) < HEAP_OFF;' in trivia and re.sub(r'\s+', '', sink) == 'INLINEvoidterm_sink(Enve,Termt){if(!term_triv(t)){term_drop(e,t);}}',
        'tagProjectionFunctionsUnchanged': tag_exact,
        'tagLiteralChainsRemainLamAndLit': [row['value'] for row in tag_literals] == ['Lam', 'Lit'],
        'noBorrowedKTermProjectionClaim': 'p98_tag_eq_read' not in owners['candidate'],
    }
    result = dict(kind='phase99-own-self-c-all-trivial-borrowed-call-inspection', complete=True,
                  passed=all(assertions.values()), targetsRun=False,
                  method=pin(__file__), extractionMethod=pin(EXTRACT), inputs=inputs,
                  assertions=assertions, globalFlags=header,
                  coverage=dict(reference=len(owners['reference']), candidate=len(owners['candidate']),
                                newlyAdmitted=sorted(set(owners['candidate']) - set(owners['reference'])),
                                removed=sorted(set(owners['reference']) - set(owners['candidate'])),
                                unchanged=sorted(set(owners['reference']) & set(owners['candidate'])),
                                workersWithBorrowedCalls=sum(bool(row['calls']) for row in rows)),
                  observerRows=rows, publicEqualitySpans=focus_spans,
                  runtimeSection=runtime, runtimeFunctions=runtime_functions, tagLiterals=tag_literals,
                  coldMacroDelta=dict(added=sorted(set(cold['candidate']) - set(cold['reference'])),
                                      removed=sorted(set(cold['reference']) - set(cold['candidate']))),
                  limits=['Coverage counts static owners and edges, not dynamic calls or speedup.',
                          'Inputs are byte-pinned; the admission collector separately authenticates their same-source producer receipts.',
                          'Runtime equality covers the heap-through-root section and listed functions; generated tables and compiler code are separate.',
                          'Static image nodes are immortal without RFC sharing; no uniquely owned static-root or dynamic branch-frequency claim.',
                          'A true empty internal conjunction is not zero-root admission: the production schema still requires one or two roots.',
                          'No compiler, program or lifetime proof was executed by this method.'])
    for role, path in paths.items(): assert pin(path) == inputs[role], (role, 'changed during inspection')
    assert pin(args.source) == inputs['source']
    out.parent.mkdir(parents=True, exist_ok=True)
    out.write_text(json.dumps(result, indent=2) + '\n')
    print(json.dumps(dict(passed=result['passed'], coverage=result['coverage'], report=pin(out))))


if __name__ == '__main__':
    main()

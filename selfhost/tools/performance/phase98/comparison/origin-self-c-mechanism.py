#!/usr/bin/env python3
"""Inspect exact own-backend self C: no compiler, benchmark or C modification."""
import argparse
import hashlib
import json
from pathlib import Path
import re

ROOT = Path(__file__).resolve().parents[5]
BUILD = ROOT / 'selfhost/build/phase98'
EXPECTED_SOURCE = '2a72bbdc3d757982d7dd4804d8a1312f9427e3b2822ed9d187424c2d9f4de051'
EXPECTED_C = dict(reference='cd3358434c485292993734ae7f4902a0d6240944a08749a769e73abd321c8e1d',
                  candidate='6ae1675a1472afff7a871eb2cf3b42186ca51d0f1b28c03b567863fc4dcdd9d6')


def pin(path):
    path = Path(path).resolve(); data = path.read_bytes()
    return dict(file=str(path), bytes=len(data), sha256=hashlib.sha256(data).hexdigest())


def symbol(name, prefix='NF_FID_'):
    return prefix + ''.join(str(ord(c)) + '_' for c in name)


def decoded(name):
    return ''.join(chr(int(c)) for c in name.removeprefix('NF_FID_').rstrip('_').split('_'))


def span(text, start, end, include=False):
    body = text[start:end]; data = body.encode()
    result = dict(byteStart=len(text[:start].encode()), byteEnd=len(text[:end].encode()),
                  lineStart=text.count('\n', 0, start) + 1,
                  lineEnd=text.count('\n', 0, end - 1) + 1,
                  bytes=len(data), sha256=hashlib.sha256(data).hexdigest())
    if include: result['text'] = body
    return result


def functions(text):
    starts = list(re.finditer(r'(?m)^(?:NF_INLINE|INLINE) (?:Term|Loc|void) (\w+)\([^\n;]*\) \{', text))
    result = {}
    for match in starts:
        start = match.start(); pos = text.index('{', start); depth = 0
        # Selected generated functions contain no literal/comment braces. Limit
        # this scanner to those exact spans and authenticate complete input files.
        while pos < len(text):
            if text[pos] == '{': depth += 1
            elif text[pos] == '}':
                depth -= 1
                if depth == 0:
                    end = pos + 1 + (text[pos + 1:pos + 2] == '\n')
                    break
            pos += 1
        else: raise AssertionError(('Unclosed function', match.group(1)))
        assert match.group(1) not in result, ('Duplicate function', match.group(1))
        result[match.group(1)] = (start, end)
    return result


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--out', type=Path, required=True)
    args = parser.parse_args(); assert not args.out.exists()
    inputs = {}; reports = {}; texts = {}; tables = {}
    for role, directory in [('reference', 'origin-reference01'), ('candidate', 'origin-b1-self01')]:
        report_file = BUILD / directory / 'report.json'
        report = json.loads(report_file.read_text()); reports[role] = report
        assert report['complete'] and report['passed'] and report['inputsUnchanged']
        assert report['source']['sha256'] == EXPECTED_SOURCE
        assert report['source'] == pin(report['source']['file'])
        assert report['row']['output'] == pin(report['row']['output']['file'])
        assert report['row']['output']['sha256'] == EXPECTED_C[role]
        assert report['producer']['binary'] == pin(report['producer']['binary']['file'])
        inputs[role] = dict(report=pin(report_file), source=report['source'], c=report['row']['output'],
                            producerBinary=report['producer']['binary'], producerStage=report['producer']['stage'])
        texts[role] = Path(report['row']['output']['file']).read_text()
        tables[role] = functions(texts[role])
    assert reports['candidate']['source'] == reports['reference']['source']
    assert reports['candidate']['row']['diagnosticFile'] == pin(reports['candidate']['row']['diagnosticFile']['file'])
    assert reports['candidate']['row']['diagnosticFile']['sha256'] == reports['reference']['row']['diagnosticFile']['sha256']

    def body(role, name):
        a, b = tables[role][symbol(name)]; return texts[role][a:b]

    def located(role, name, include=False):
        a, b = tables[role][symbol(name)]
        return dict(name=name, cSymbol=symbol(name), **span(texts[role], a, b, include))

    flags = {}
    for role, text in texts.items():
        end = text.index('\n\n') + 1
        flags[role] = dict(span=span(text, 0, end, True),
                           values=dict(re.findall(r'^#define (NATIVE_\w+) (\d+)$', text[:end], re.M)))
    assert flags['reference']['values']['NATIVE_READONLY_OBSERVERS'] == '0'
    assert flags['candidate']['values']['NATIVE_READONLY_OBSERVERS'] == '1'
    assert {k: v for k, v in flags['reference']['values'].items() if k != 'NATIVE_READONLY_OBSERVERS'} == {
        k: v for k, v in flags['candidate']['values'].items() if k != 'NATIVE_READONLY_OBSERVERS'}

    observer_names = {role: sorted(decoded(name) for name in table if name.startswith(symbol('$observer.')))
                      for role, table in tables.items()}
    assert not observer_names['reference']
    owners = ['String.is_empty', 'String.cmp', 'p98_eq_finish', 'p88_string_eq_go', 'index_hash', 'f_head', 'dg_import_tail']
    assert set(observer_names['candidate']) == {prefix + owner for owner in owners for prefix in ['$observer.', '$observer.adapter.']}
    routes = []
    for owner in owners:
        worker = '$observer.' + owner; adapter = '$observer.adapter.' + owner
        assert symbol(worker) + '(' in body('candidate', adapter)
        route = dict(owner=owner, worker=located('candidate', worker), adapter=located('candidate', adapter))
        if owner == 'String.cmp':
            label = symbol('$direct.String.cmp', 'FID_')
            start = texts['candidate'].index('  WL_CASE(' + label + ')\n')
            end = texts['candidate'].index('#else\n', start)
            assert symbol(adapter) + '(' in texts['candidate'][start:end]
            route['entry'] = dict(name='$direct.String.cmp', cSymbol=label,
                                  **span(texts['candidate'], start, end, True))
            route['condition'] = 'CPU scheduler entry under NATIVE_READONLY_OBSERVERS; product-result adapter.'
        else:
            entry = body('candidate', owner)
            lines = [line for line in entry.splitlines(keepends=True) if 'return ' + symbol(adapter) + '(' in line]
            assert len(lines) == 1 and 'RFC_CNT) > 1' in lines[0]
            start = tables['candidate'][symbol(owner)][0] + entry.index(lines[0])
            route['entry'] = dict(name=owner, cSymbol=symbol(owner),
                                  **span(texts['candidate'], start, start + len(lines[0]), True))
            route['condition'] = 'Redirect when at least one eligible root has reference count greater than one.'
        routes.append(route)

    equality = {role: located(role, 'p88_string_eq_go') for role in texts}
    equality['borrowedWorker'] = located('candidate', '$observer.p88_string_eq_go', True)
    equality['owningAdapter'] = located('candidate', '$observer.adapter.p88_string_eq_go', True)
    old = body('reference', 'p88_string_eq_go'); new = body('candidate', 'p88_string_eq_go')
    redirect = next(line for line in new.splitlines(keepends=True) if 'return ' + symbol('$observer.adapter.p88_string_eq_go') in line)
    assert new.replace(redirect, '', 1) == old
    worker = body('candidate', '$observer.p88_string_eq_go'); adapter = body('candidate', '$observer.adapter.p88_string_eq_go')
    forbidden = ['ctr_take(', 'spare_free(', 'term_sink(', 'term_keep(', 'heap_alloc(']
    assert all(token not in worker for token in forbidden)
    assert 'term_peek(' in worker and 'e.mem[no_loc_' in worker and 'goto nf_again;' in worker
    assert 'U32_BIN(v_4294967285, ==, v_4294967284)' in worker
    assert adapter.index('Term no_root_0 =') < adapter.index(symbol('$observer.p88_string_eq_go') + '(') < adapter.index('term_sink(e, no_root_0)')
    assert adapter.index('Term no_root_1 =') < adapter.index(symbol('$observer.p88_string_eq_go') + '(') < adapter.index('term_sink(e, no_root_1)')
    consume = 'spare_free(e, cls_fit(2), ctr_take(e, v_4294967276, 2, fields));\n'
    at = tables['reference'][symbol('p88_string_eq_go')][0] + old.index(consume)
    equality['referenceConsumingStep'] = span(texts['reference'], at, at + len(consume), True)
    equality['checks'] = dict(originalBodyPreservedAfterRemovingOneRedirect=True,
                              borrowedFieldsUsePeek=True, borrowedLoopHasNoListedConsumeOrAllocateCalls=forbidden,
                              fullU32CharacterComparison=True, rootsDisposedAfterObservation=True)

    tag_names = ['p98_tag_eq', 'p98_tag_eq_read', 'p98_tag_eq_finish', 'p88_string_eq']
    tag = dict(unchangedFunctions=[])
    for name in tag_names:
        assert body('candidate', name) == body('reference', name)
        tag['unchangedFunctions'].append(dict(name=name, reference=located('reference', name), candidate=located('candidate', name)))
    tag_read = body('candidate', 'p98_tag_eq_read')
    assert 'ctr_take(' in tag_read and 'term_sink(' in tag_read and 'term_peek(' not in tag_read
    assert symbol('p88_string_eq_go') + '(' in tag_read
    assert symbol('$observer.p98_tag_eq_read') not in tables['candidate']
    generic_end = tag_read.index('} else {\n', tag_read.index('Term nq_result_20[1];'))
    a = tables['candidate'][symbol('p98_tag_eq_read')][0]
    tag['genericKTermBranch'] = span(texts['candidate'], a, a + generic_end, True)
    tag['conclusion'] = 'Generic tag comparison calls the newly redirected string walker. KTerm projection itself remains consuming and has no direct borrowed tag observer.'
    equality['heldPublicWrapper'] = located('candidate', 'p88_string_eq', True)
    assert body('candidate', 'p88_string_eq').count('term_keep(') == 2

    runtime = []
    for name in ['term_peek', 'ctr_take', 'term_sink', 'term_keep']:
        a, b = tables['candidate'][name]; x, y = tables['reference'][name]
        assert texts['candidate'][a:b] == texts['reference'][x:y]
        runtime.append(dict(name=name, candidate=span(texts['candidate'], a, b, True), reference=span(texts['reference'], x, y)))
    for role in texts:
        assert inputs[role]['c'] == pin(inputs[role]['c']['file'])
    result = dict(kind='phase98-own-backend-self-c-observer-mechanism', complete=True, targetsRun=False,
                  method=pin(__file__), inputs=inputs, sameInputCompilerSource=True,
                  headerFlags=flags, concreteAddedRoutes=routes, equality=equality, tag=tag, unchangedRuntimeHelpers=runtime,
                  limitations=[
                      'Static inspection of complete own-backend self C intended for B2, not the earlier upstream-generated B1 C audit.',
                      'Mapped observer names are concrete definitions and entry routes; no global allocation/RC operation reduction is inferred.',
                      'The string loop avoids per-node consuming operations on its shared-root route; adapters and ordinary fallbacks still own and dispose inputs.',
                      'No direct borrowed KTerm tag projection is claimed. The generic tag branch reaches the shared-root string observer indirectly.',
                      'C shape does not prove runtime lifetime safety, qualify B2, establish dynamic call frequencies or measure speed.'])
    args.out.parent.mkdir(parents=True, exist_ok=True)
    args.out.write_text(json.dumps(result, indent=2) + '\n')
    print(json.dumps(dict(complete=True, targetsRun=False, mappedOwners=len(routes), report=pin(args.out))))


if __name__ == '__main__': main()

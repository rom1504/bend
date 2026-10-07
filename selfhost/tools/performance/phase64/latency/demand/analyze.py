#!/usr/bin/env python3
"""Data-only demand summary; all counts refer to existing diagnostic receipts."""
import argparse
import hashlib
import json
from pathlib import Path


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('report', type=Path)
    parser.add_argument('out', type=Path)
    args = parser.parse_args()
    assert not args.out.exists()
    inputs = {}

    def pin(value):
        file = Path(value['file'] if isinstance(value, dict) else value).resolve(strict=True)
        row = dict(file=str(file), sha256=hashlib.sha256(file.read_bytes()).hexdigest())
        if isinstance(value, dict):
            assert row['sha256'] == value['sha256']
        assert str(file) not in inputs or inputs[str(file)] == row
        inputs[str(file)] = row
        return row

    def read(value):
        return json.loads(Path(pin(value)['file']).read_text())

    report = read(args.report)
    plan = read(report['plan'])
    assert report['complete'] and report['pass'] and not report['failures'] and report['timingClaims'] is False
    assert [row['case'] for row in report['rows']] == ['numeric-recurrence', 'lexer', 'test-map-set-ops']
    assert len(plan['cache']) == 1
    cache = pin(plan['cache'][0])
    frame = Path(cache['file']).read_bytes()
    offset = frame.index(b'\n')
    header = json.loads(frame[:offset]); offset += 1
    assert header['format'] == 'bend-base-cache-frame-3'
    wires = []
    for size, digest in zip(header['segments'], [header['bookGraphSha256'], header['preparedGraphSha256']]):
        segment = frame[offset:offset+size]; offset += size
        assert hashlib.sha256(segment).hexdigest() == digest
        wires.append(json.loads(segment))
    assert offset == len(frame) and wires[0][:2] == [1, 0]
    book_count = len(wires[0][3]); prepared_count = len(wires[1][3]); count = book_count+prepared_count
    assert wires[1][:2] == [1, book_count]
    assert (book_count, prepared_count, count) == (35378, 11379, 46757)

    def counts(ids):
        book = sum(index < book_count for index in ids)
        return dict(nodes=len(ids), percentDecoded=100*len(ids)/count,
            bookNodes=book, percentBook=100*book/book_count,
            preparedNodes=len(ids)-book, percentPrepared=100*(len(ids)-book)/prepared_count)

    backend_names = {'api:reach_book', 'api:annotate_selected', 'api:jd_plan_selected',
        'api:jd_foreign_error', 'api:j_layout_error', 'api:jd_foreign_paths', 'api:jd_modules', 'api:jd_plan_library'}
    rows = []
    for row in report['rows']:
        assert row['success'] and row['execution']['complete'] and row['execution']['returncode'] == 0
        worker = read(row['result'])
        assert worker == row['observation'] and worker['complete'] and worker['pass']
        assert worker['timingClaims'] is False
        pin(worker['emittedModule']); pin(worker['output']['reference'])
        assert worker['emittedModule']['sha256'] == worker['output']['reference']['sha256']
        demand = read(worker['demand'])
        assert demand['schema'] == 'phase64-base-demand-1' and demand['decodedNodes'] == count
        phases = {p['name']: set(p['nodeIds']) for p in demand['phases']}
        accessed = set(demand['accessedNodeIds'])
        assert len(accessed) == demand['accessedNodes'] and all(0 <= i < count for i in accessed)
        assert set().union(*phases.values()) == accessed
        phase_rows = []
        for phase in demand['phases']:
            assert len(phases[phase['name']]) == phase['nodeCount']
            assert sum(phase['fields'].values()) == phase['reads']
            phase_rows.append(dict(name=phase['name'], reads=phase['reads'], **counts(phases[phase['name']]),
                definitionBodyNodes=len(phase['definitionBodies']),
                distinctDefinitionNames=len({item['definition'] for item in phase['definitionBodies']}),
                topFields=list(phase['fields'].items())[:8]))
        semantic = set().union(*(ids for name, ids in phases.items() if name != 'cache-decode'))
        excluded = {'cache-decode', 'api:check_program_diagnostic_world', 'api:book_context'}
        after_exclusion = set().union(*(ids for name, ids in phases.items() if name not in excluded))
        backend = set().union(*(ids for name, ids in phases.items() if name in backend_names))
        rows.append(dict(case=row['case'], worker=pin(row['result']), rawDemand=pin(worker['demand']),
            allAccess=counts(accessed), untouched=counts(set(range(count))-accessed),
            postCacheApiAccess=counts(semantic), cacheOnlyAccess=counts(phases['cache-decode']-semantic),
            selectedBackendAccess=counts(backend),
            exclusionDiagnostic=dict(excludedPhases=sorted(excluded), remainingAccess=counts(after_exclusion),
                warning='Excludes whole top-level phases including necessary source checks. It is not a semantics-preserving alternative or a prediction after removing Base scans.'),
            phases=phase_rows, rawLimits=demand['limits']))
    for value in plan['inputs']+plan['files']+plan['copiedOriginals']:
        pin(value)
    root = Path(__file__).resolve().parents[6]
    source_files = [root/'selfhost/build/phase63/checked-state09/snapshot/src'/name
        for name in ['driver/api.bend', 'check/prefix-state.bend', 'core/index.bend', 'core/normalize.bend']]
    source_pins = [pin(file) for file in source_files]
    for value in list(inputs.values()):
        pin(value)
    result = dict(kind='phase64-state09-demand-analysis', complete=True, **{'pass': True},
        dataOnly=True, targetExecuted=False, timingClaims=False, producer=pin(__file__),
        report=pin(args.report), plan=pin(report['plan']), cache=cache,
        graph=dict(bookNodes=book_count, preparedNodes=prepared_count, eagerConstructedNodes=count,
            bookSegmentBytes=header['segments'][0], preparedSegmentBytes=header['segments'][1],
            eagerConstructionRatio=1, idMapping='The helper registers raw nodes in decode order; book IDs0..35377, prepared IDs35378..46756. Shared book nodes are registered once.',
            validationCaveat='Raw record validation and eager construction occur before proxy registration. Cache-decode read counters do not count that work; optional prepared data is validated if admitted.'),
        rows=rows, sourceEvidence=source_pins, inputs=list(inputs.values()),
        conclusion='Current post-cache phases read about96% of eagerly decoded nodes. Lazy materialization alone has little unused-node headroom. Broad TODO and maximum/index/context scans should be addressed before reassessing demand.',
        limits='One request per case; proxy reads are not allocations or time. Node counts do not weight object size. Per-phase sets overlap. Counterfactual phase exclusion is an opportunity diagnostic, not a valid compiler change.')
    args.out.parent.mkdir(parents=True, exist_ok=True)
    with args.out.open('x') as stream:
        stream.write(json.dumps(result, indent=2)+'\n')
    print(json.dumps(dict(output=pin(args.out), rows=len(rows), eagerNodes=count)))


if __name__ == '__main__':
    main()

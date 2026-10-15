#!/usr/bin/env python3
"""Freeze two candidate-helper faults before inspecting Phase98 laws/tests."""
import datetime
import hashlib
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[5]
HERE = Path(__file__).resolve().parent


def pin(path):
    data = path.read_bytes()
    return dict(path=str(path.relative_to(ROOT)), bytes=len(data), sha256=hashlib.sha256(data).hexdigest())


def save(path, value):
    with path.open('x') as stream:
        json.dump(value, stream, indent=2)
        stream.write('\n')


def main():
    rows = [
        dict(id='bad07-dispatch-loses-alternative',
             file='selfhost/build/phase98/dispatch-frozen02/selectors.canonical.bend',
             function='p98_check_node_stage1',
             before='    case False{}: p98_check_node_stage2(String.eq(tag, "Mat") || String.eq(tag, "Efq"), tag)',
             after='    case False{}: p98_check_node_stage2(String.eq(tag, "Mat"), tag)',
             expectedBehavior='Collapsing a grouped dispatch predicate drops the Efq alternative. The selected result must still be branch 2 for this valid tag.',
             witness=dict(expression='p98_check_node_select("Efq")', returnType='P98CheckNode',
                          baselineValueBend='P98CheckNode2{}', challengeValueBend='P98CheckNodeDefault{}')),
        dict(id='bad08-held-observation-repeats-left',
             file='selfhost/tools/performance/phase98/comparison/held-helpers01.bend',
             function='p98_eq_observe',
             before='  P98EqHeld{p98_eq_walk(a, b, True{}), a, b}',
             after='  P98EqHeld{p98_eq_walk(a, b, True{}), a, a}',
             expectedBehavior='The complete observation must return the original left and right values, not two copies of left. This faults the returned-helper-value contract; p98_string_eq may still return the correct Bool, so no whole-compiler semantic regression is claimed.',
             witness=dict(expression='p98_eq_observe("left", "right")', returnType='P98EqHeld',
                          baselineValueBend='P98EqHeld{False{}, "left", "right"}',
                          challengeValueBend='P98EqHeld{False{}, "left", "left"}')),
    ]
    for row in rows:
        source = (ROOT/row['file']).read_text()
        assert source.count(row['before']) == 1
        changed = source.replace(row['before'], row['after'], 1).encode()
        row.update(schema='phase98-independent-challenge-v1', kind='bad', source=pin(ROOT/row['file']),
                   expectedOccurrences=1, line=source[:source.index(row['before'])].count('\n')+1,
                   changedSourceBytes=len(changed), changedSourceSha256=hashlib.sha256(changed).hexdigest(),
                   admission='predicted well-typed; root must check', targetsRun=False,
                   provenance=dict(classification='synthetic-semantic-fault',
                                   selection='Candidate helper source and intended interface only; Phase98 law bodies, finite cases, oracles and results not inspected before freeze.'))
        w = row['witness']; path=HERE/(row['id']+'.witness.bend')
        with path.open('x') as stream:
            for suffix,key in [('actual','expression'),('baseline_expected','baselineValueBend'),('challenge_expected','challengeValueBend')]:
                stream.write('@unsafe\ndef p98_'+row['id'].replace('-','_')+'_'+suffix+'() -> '+w['returnType']+':\n  '+w[key]+'\n\n')
        w['source']=pin(path)
        save(HERE/(row['id']+'.json'),row)
    save(HERE/'candidate-manifest02.json',dict(schema='phase98-independent-challenge-supplement-v1',
        frozenAt=datetime.datetime.now(datetime.timezone.utc).isoformat(),method=pin(Path(__file__)),
        previous=[pin(HERE/'manifest.json'),pin(HERE/'literal-manifest01.json')],
        cases=[pin(HERE/(r['id']+'.json')) for r in rows],counts=dict(bad=2,good=0),targetsRun=False))
    manifests=[HERE/f for f in ['manifest.json','literal-manifest01.json','candidate-manifest02.json']]
    save(HERE/'all-manifest01.json',dict(schema='phase98-independent-challenges-aggregate-v1',
        frozenAt=datetime.datetime.now(datetime.timezone.utc).isoformat(), manifests=[pin(p) for p in manifests],
        cases=[case for path in manifests for case in json.loads(path.read_text())['cases']],
        counts=dict(bad=8,good=2),targetsRun=False,
        boundary='All ten choices frozen before reading Phase98 law bodies, finite case bodies, oracles or results.'))


if __name__ == '__main__':
    main()

#!/usr/bin/env python3
"""Bind a new native image to actual unmodified emitted C and guarded Clang."""
import argparse
import json
from pathlib import Path
from support import Bindings, ROOT, backend_policy, baseline, pin, read, entry_definitions


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--binary', type=Path, required=True)
    p.add_argument('--stage', choices=['b1', 'b2'], required=True)
    p.add_argument('--source', type=Path, required=True)
    p.add_argument('--emission-receipt', type=Path, required=True)
    p.add_argument('--build-guard', type=Path, required=True)
    p.add_argument('--out', type=Path, required=True)
    a = p.parse_args()
    assert not a.out.exists()
    b = Bindings(); ctx = baseline(b)
    b.bind(__file__); b.bind(Path(__file__).with_name('support.py'))
    source, binary, emission_pin = b.bind(a.source), b.bind(a.binary), b.bind(a.emission_receipt)
    emission = read(emission_pin['file'])
    assert emission['complete']
    if a.stage == 'b1':
        assert emission['holes'] == 0 and {'load', 'check', 'emit-c'} <= {r['name'] for r in emission['phases']}
        assert emission['upstream']['revision'] == ctx['upstream']
        assert b.bind(emission['source']) == source
        c = b.bind(emission['c'])
        for row in [emission['method'], emission['host'], *emission['loadedFiles'], *emission['upstream']['inputs']]: b.bind(row)
        producer = 'pinned upstream TypeScript C backend; upstream C runtime'
    else:
        assert emission['kind'] == 'phase98-native-qualification-request'
        assert emission['passed'] and emission['inputsUnchanged'] and emission['producer']['stage'] == 'b1'
        if emission['purpose'] == 'changed-backend':
            assert emission['row']['diagnosticExact'] and emission['semanticQualificationRequired']
            assert backend_policy(emission['backendPolicy'], source, b) == emission['backendPolicy']
        else:
            assert emission['purpose'] == 'compare' and emission['row']['exactC']
        assert b.bind(emission['source']) == source
        assert emission['producer']['source'] == source, 'B2 must be self-emitted by the candidate B1'
        for row in emission['inputs']: b.bind(row)
        c = b.bind(emission['row']['output'])
        producer = 'candidate native B1 self-emitted C; own C runtime'
    guard_pin = b.bind(a.build_guard / 'process.json'); process = read(guard_pin['file'])
    assert process['complete'] and process['returncode'] == 0 and not process.get('stoppedFor') and not process.get('interrupted')
    inputs_pin = b.bind(a.build_guard / 'inputs.json')
    build_inputs = read(inputs_pin['file'])
    for row in build_inputs: b.bind(dict(file=row.get('file', row.get('path')), sha256=row['sha256'], bytes=row['bytes']))
    assert any(r['sha256'] == c['sha256'] and r['bytes'] == c['bytes'] for r in build_inputs), 'Guarded Clang inputs must bind exact emitted C'
    cc = ctx['clang']['file']; command = process['command']; tail = command[command.index(cc):]
    filtered = [x for x in tail if x != '-ftime-report']
    assert len(filtered) == 9 and filtered[5] == '-o'
    assert str((ROOT / filtered[4]).resolve()) == c['file']
    assert str((ROOT / filtered[6]).resolve()) == binary['file']
    assert filtered[:4] + filtered[5:6] + filtered[7:] == ctx['optimizationFlags']
    assert entry_definitions(Path(source['file']).read_text()) == entry_definitions(Path(ctx['source']['file']).read_text())
    b.unchanged()
    report = dict(kind='phase98-private-native-build', complete=True, stage=a.stage, source=source, binary=binary,
                  c=c, cPatched=False, emission=emission_pin, producer=producer, guard=guard_pin,
                  buildInputs=inputs_pin, clang=ctx['clang'], command=command, optimizationFlags=ctx['optimizationFlags'],
                  method=pin(__file__), inputs=list(b.rows.values()), argvSentinel=a.stage == 'b2',
                  publicAdmission=False, imageQualified=False,
                  scope='Source/emitter/guarded-Clang binding only; self-consistency and semantic qualification gates are separate.')
    a.out.parent.mkdir(parents=True, exist_ok=True)
    with a.out.open('x') as f: json.dump(report, f, indent=2); f.write('\n')
    print(json.dumps(dict(complete=True, stage=a.stage, source=source, binary=binary, receipt=str(a.out))))


if __name__ == '__main__': main()

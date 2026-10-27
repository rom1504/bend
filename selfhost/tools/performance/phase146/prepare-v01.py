#!/usr/bin/env python3
"""Compose explicit Bend overlays on qualified final04; prepare root-owned jobs."""
import argparse
import importlib.util
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[4]
spec = importlib.util.spec_from_file_location('compose', ROOT/'selfhost/tools/performance/phase131/prepare.py')
C = importlib.util.module_from_spec(spec)
spec.loader.exec_module(C)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--out', type=Path, required=True)
    parser.add_argument('--api-out', type=Path, required=True)
    parser.add_argument('--module', type=Path, action='append', required=True)
    parser.add_argument('--export', action='append', default=[])
    parser.add_argument('--control', action='append', default=[])
    args = parser.parse_args()
    out, api = args.out.resolve(), args.api_out.resolve()
    assert out.is_relative_to(ROOT/'selfhost/build/phase146') and not out.exists()
    assert api.is_relative_to(ROOT/'selfhost/build/phase111') and not api.exists()
    selection = ROOT/'implementation/phase144/final04/candidate.json'
    parent = json.loads(selection.read_text())
    assert parent['complete'] and parent['nativeQualified']
    assert parent['source']['sha256'] == '865cff6a02da261952cac824bed0fe91882e60f1c6e4062fbe57f5804745c4ed'
    for key in ['source','sourceManifest','checkedApi','api','native','runtime','base','preferredCarrierReceipt']:
        assert C.pin(parent[key]['file']) == parent[key], key
    pm = json.loads(Path(parent['sourceManifest']['file']).read_text())
    old = Path(parent['source']['file']).read_text()
    modules = [p.resolve() for p in args.module]
    assert len(modules) == len(set(modules))
    text, added, protected = C.compose(old, [p.read_text() for p in modules], {'p128raw_session_finish'}, set())
    before, after = C.blocks(old, combine=True), C.blocks(text, combine=True)
    changed = sorted(n for n in before if C.norm(before[n]) != C.norm(after[n]))
    assert changed == ['p128raw_session_finish']
    for name in set(pm['protectedDeclarations']) | set(pm['unchangedProofDeclarations']):
        assert C.norm(before[name]) == C.norm(after[name]), name
    prior = json.loads(Path(parent['checkedApi']['file']).read_text())
    exports = list(dict.fromkeys([*prior['exports'], *args.export]))
    assert all(name in after for name in exports)
    out.mkdir(parents=True)
    source = out/'compiler.bend'
    source.write_text(text)
    for index, module in enumerate(modules):
        (out/f'module{index}.bend').write_bytes(module.read_bytes())
    manifest = dict(kind='phase146-retained-context-composition', complete=True, checked=False,
        nativeQualified=False, selected=False, targetsRun=False, source=C.pin(source),
        parent=parent['source'], parentManifest=parent['sourceManifest'], parentQualification=parent['qualification'],
        overrides=changed, added=added, sourceLines=len(text.splitlines()), parentLines=len(old.splitlines()),
        protectedDeclarations=pm['protectedDeclarations'], unchangedProofDeclarations=pm['unchangedProofDeclarations'],
        allOtherOriginalDeclarationsNormalizedExact=True, runtime=parent['runtime'], exports=exports,
        controls=args.control, inputs=[C.pin(__file__), C.pin(C.__file__), C.pin(selection),
            parent['source'], parent['sourceManifest'], *[C.pin(p) for p in modules]],
        scope='Private context retention only. Public verifiers and final actual-function checks remain. Composition is not source checking, measurement, proof or qualification.')
    (out/'manifest.json').write_text(json.dumps(manifest, indent=2)+'\n')
    guard = ROOT/'selfhost/tools/performance/phase111/guard.py'
    checker = guard.with_name('check-api.py')
    runner = ROOT/'selfhost/tools/performance/phase143/controls-v01.mjs'
    bun = ROOT/'selfhost/.bootstrap/bun-1.4.3/bun'
    jobs = []

    def job(name, command, seconds):
        jobs.append(dict(name=name, command=['python3','-B',str(guard),'--out',str(out/(name+'-guard')),
            '--seconds',str(seconds),'--cpu','3','--rss-mib','3072','--available-mib','16384',
            '--file-mib','64','--',*map(str,command)]))

    job('checked-api', ['python3','-B',checker,'--source',source,'--out',api,*exports], 120)
    if args.control:
        job('controls', [bun,runner,api/'report.json',out/'controls',*args.control], 90)
    (out/'jobs.json').write_text(json.dumps(dict(kind='phase146-source-gates', complete=True,
        targetsRun=False, manifest=C.pin(out/'manifest.json'), inputs=[C.pin(p) for p in [guard,checker,runner,bun]],
        jobs=jobs), indent=2)+'\n')
    print(json.dumps(dict(source=manifest['source'], added=len(added), lines=manifest['sourceLines'], jobs=str(out/'jobs.json'))))


if __name__ == '__main__':
    main()

#!/usr/bin/env python3
"""Prepare exact profilers for the selected checked C entry; source/data only."""
import ast
import hashlib
import json
import os
from pathlib import Path

ROOT = Path(__file__).resolve().parents[5]
HERE = Path(__file__).resolve().parent


def pin(path):
    path = Path(path).resolve(strict=True)
    data = path.read_bytes()
    return dict(file=str(path), sha256=hashlib.sha256(data).hexdigest(), bytes=len(data))


def write(path, value):
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open('x') as stream:
        stream.write(value if isinstance(value, str) else json.dumps(value, indent=2)+'\n')


def main():
    assert os.sched_getaffinity(0) == {0}
    rows = []

    def derive(parent, expected, target, edits):
        source = pin(parent)
        assert source['sha256'] == expected, parent
        text = parent.read_text()
        changed = []
        for old, new, count in edits:
            assert text.count(old) == count, (parent, old, text.count(old), count)
            text = text.replace(old, new)
            changed.append(dict(before=old, after=new, count=count))
        if target.suffix == '.py':
            ast.parse(text, feature_version=9)
        write(target, text)
        receipt = dict(kind='phase70-selected-c-entry-method-derivation', parent=source,
            output=pin(target), edits=changed, producer=pin(__file__), targetsExecuted=False,
            scope='Source-preflight correction: selected driver invokes nc_compile_checked. Observe and require that exported entry when available; preserve nc_compile fallback. Other semantic oracles, source output, profiler sampling and resource guards unchanged.')
        write(target.with_suffix('.derivation.json'), receipt)
        rows.append(receipt)
        return pin(target)

    old = ROOT/'selfhost/tools/performance/phase68/compilation'
    new = HERE/'compilation'
    derive(old/'worker.mjs', '496c2633d29a6e0278ff00db92620eef77d5915d6b1f7720d4b83e4b7a68170a',
        new/'worker.mjs', [
        ("'nc_foreign_scope','kf_source','nc_foreign_source','nc_compile'];",
         "'nc_foreign_scope','kf_source','nc_foreign_source','nc_compile','nc_compile_checked'];", 1),
        ("'nc_annotated_context','nc_foreign_paths','nc_compile'])assert(report.stages[name]?.calls>0",
         "'nc_annotated_context','nc_foreign_paths',typeof api.nc_compile_checked==='function'?'nc_compile_checked':'nc_compile'])assert(report.stages[name]?.calls>0", 1)])
    for filename, digest in [
        ('run.py','cc5e8b7587aea619d321e0e37291940b49563e74246858d23b0c21dd36a51135'),
        ('analyze.py','10d5b0cb3164184fdb7040d7024a8db09cf3ce8b0d4520704884668b22d5588f')]:
        derive(old/filename, digest, new/filename,
               [('ROOT = HERE.parents[4]', 'ROOT = Path('+repr(str(ROOT))+')', 1)])
    manifest_path = ROOT/'selfhost/build/phase70/methods01/methods.json'
    assert pin(manifest_path)['sha256'] == 'a4bcf5e95c23a576a777d532951da8a07cbecf1b2249e3d1ba1044aec0cc9ece'
    manifest = json.loads(manifest_path.read_text())
    parent = next(r['output'] for r in manifest['methods'] if r['name']=='prepare-compilation.py')
    prepared = derive(Path(parent['file']), parent['sha256'], HERE/'prepare-compilation-v2.py', [
        ('HERE = Path('+repr(str(old))+')', 'HERE = Path('+repr(str(new))+')', 1),
        ("pin(HERE/'prepare-selected-v1.py')", "pin(ROOT/'selfhost/tools/performance/phase68/compilation/prepare-selected-v1.py')", 1)])
    derive(Path(prepared['file']), prepared['sha256'], HERE/'prepare-profiles-only-v2.py', [
        ('"""Freeze selected B1/B2 and explicitly owned prior exact-C oracles; data only."""',
         '"""Prepare two Base jobs and four diagnostic profile jobs only; no targets."""', 1),
        ('for round_ in range(args.rounds):', 'for round_ in range(0):', 1),
        ("scope='Fresh processes and mandatory prepared Bend Base.",
         "scope='Diagnostic-only plan: two Base preparations and four profiles; no clean timing jobs. Fresh processes and mandatory prepared Bend Base.", 1)])
    write(HERE/'profile-entry-upgrade.json', dict(kind='phase70-selected-c-entry-methods',
        producer=pin(__file__), parentManifest=pin(manifest_path), methods=rows,
        originalPlanRetained=pin(ROOT/'selfhost/build/phase70/compiler69-profile01/plan.json'),
        finding='The inherited worker required a call to nc_compile; sealed69 driver selects nc_compile_checked instead. Found by source inspection before any original-plan target execution.',
        originalPlanExecuted=False, targetsExecuted=False))
    print(json.dumps(dict(manifest=pin(HERE/'profile-entry-upgrade.json'), targetsExecuted=False)))


if __name__ == '__main__':
    main()

#!/usr/bin/env python3
"""Prepare/authenticate Phase118 native qualification; never run a target."""
import argparse
import hashlib
import json
from pathlib import Path
import re
import shutil
import sys

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[3]
PHASE = ROOT / 'selfhost/tools/performance/phase111'
KIND = 'phase118-request-bound-native-qualification-plan'
DECL = re.compile(r'^(?:@unsafe\n)?(?:def|type|law) ([A-Za-z0-9_.]+)\b', re.M)
REQUIRED = ['p88_cache_prepare', 'p86_prepare', 'p86_plan', 'p111_runtime_admission',
            'p111_emit_admitted', 'p111_compile_source']


def require(ok, message):
    if not ok:
        raise ValueError(message)


def read(path):
    return json.loads(Path(path).read_text())


def pin(path):
    p = Path(path).resolve(strict=True)
    h, size = hashlib.sha256(), 0
    with p.open('rb') as f:
        for data in iter(lambda: f.read(1024 * 1024), b''):
            h.update(data)
            size += len(data)
    return dict(file=str(p), bytes=size, sha256=h.hexdigest())


def verify(row):
    actual = pin(row['file'])
    require(actual == row, 'Changed/noncanonical input: ' + row['file'])
    return Path(actual['file'])


def unique(rows):
    out = {}
    for row in rows:
        require(row['file'] not in out or out[row['file']] == row, 'Conflicting pins')
        out[row['file']] = row
    return list(out.values())


def blocks(text, combine=False):
    hits, out = list(DECL.finditer(text)), {}
    for i, hit in enumerate(hits):
        body = text[hit.start():hits[i + 1].start() if i + 1 < len(hits) else len(text)]
        out[hit[1]] = (out.get(hit[1], '') if combine else '') + body
    return out


def norm(text):
    return '\n'.join(x.rstrip() for x in text.splitlines()
                     if x.strip() and not x.lstrip().startswith('#'))


def source_contract(source, manifest):
    """Replay the recorded declaration overlay, not a compiler transformation."""
    require(manifest.get('complete') and manifest['source'] == pin(source), 'Source manifest mismatch')
    parent = verify(manifest['parent'])
    for row in manifest['inputs']:
        verify(row)
    modules = [row for row in manifest['inputs']
               if row['file'].endswith('.bend') and row != manifest['parent']]
    require(modules, 'Frozen Phase118 module inputs required')
    base = parent.read_text()
    before, added, overlaps, snapshots = blocks(base), {}, set(), []
    for i, module in enumerate(modules):
        snapshot = source.parent / ('module' + str(i) + '.bend')
        record = pin(snapshot)
        require(all(record[k] == module[k] for k in ['bytes', 'sha256']), 'Module snapshot mismatch')
        snapshots.append(record)
        current = blocks(snapshot.read_text(), combine=True)
        overlap = set(added) & set(current)
        require(overlap <= set(manifest.get('moduleOverrides', [])), 'Unrecorded module override')
        overlaps |= overlap
        added.update(current)
    require(overlaps == set(manifest.get('moduleOverrides', [])), 'Module override inventory mismatch')
    require(set(before) & set(added) == set(manifest['overrides']), 'Parent override inventory mismatch')
    hits = list(DECL.finditer(base))
    parts = [base[:hits[0].start()]]
    for i, hit in enumerate(hits):
        original = base[hit.start():hits[i + 1].start() if i + 1 < len(hits) else len(base)]
        parts.append(added[hit[1]].rstrip() + '\n\n'
                     if hit[1] in added and not original.lstrip().startswith('law ') else original)
    parts.extend('\n' + body for name, body in added.items() if name not in before)
    require(''.join(parts).encode() == source.read_bytes(), 'Exact full-source composition replay failed')
    final = blocks(source.read_text())
    entry = blocks((HERE / 'integrated-entry.bend').read_text())
    for name in ['p111_emit_admitted', 'p118e_lowered', 'p118e_verified']:
        require(norm(final[name]) == norm(entry[name]), 'Changed request-bound lowering/verification hook: ' + name)
    bridge = ['main', 'p111_native_args', 'p111_native_request', 'p111_compile_source',
              'p111_compile_prepared', 'p111_emit_plan']
    for name in bridge:
        require(norm(final[name]) == norm(before[name]), 'Native bridge changed: ' + name)
    return dict(kind='phase118-integrated-request-bound-entry', transportVersion=118,
                entry='p111_emit_admitted', pipeline='array', mode='cache',
                explicitVerificationPasses=1, fullCompositionReplay=True,
                nativeBridgeDeclarations=bridge, snapshots=snapshots,
                scope='New integrated-entry contract; not the Phase113/114 staged renderer gate.')


def verify_plan(path):
    plan = read(path)
    require(plan.get('kind') == KIND, 'Phase118 native plan required')
    for row in plan['inputs']:
        verify(row)
    return plan


def main():
    p = argparse.ArgumentParser(description=__doc__)
    modes = p.add_subparsers(dest='mode', required=True)
    prep = modes.add_parser('prepare')
    for name in ['api', 'source', 'runtime', 'out']:
        prep.add_argument('--' + name, type=Path, required=True)
    prep.add_argument('--tag', required=True)
    prep.add_argument('--hosted-seconds', type=int, default=1200)
    prep.add_argument('--native-seconds', type=int, default=1200)
    prep.add_argument('--build-seconds', type=int, default=120)
    check = modes.add_parser('verify')
    check.add_argument('--plan', type=Path, required=True)
    a = p.parse_args()
    if a.mode == 'verify':
        verify_plan(a.plan)
        print(json.dumps(dict(complete=True, targetsRun=False, plan=pin(a.plan))))
        return
    source, api, runtime, out = [getattr(a, key).resolve() for key in ['source', 'api', 'runtime', 'out']]
    require(not out.exists() and out.is_relative_to(ROOT / 'selfhost/build/phase118'), 'Fresh Phase118 plan required')
    require(re.fullmatch(r'p118-[a-z0-9_-]+', a.tag), 'Lowercase p118- tag required')
    require(min(a.hosted_seconds, a.native_seconds, a.build_seconds) > 0, 'Positive limits required')
    sr, ar, rr = source.parent / 'manifest.json', api.parent / 'report.json', runtime.parent / 'report.json'
    composed, checked, built = read(sr), read(ar), read(rr)
    require(checked.get('complete') and checked.get('checked') and checked['api'] == pin(api), 'Checked API required')
    require(set(REQUIRED) <= set(checked['exports']) and pin(source) in checked['inputs'], 'API export/source mismatch')
    require([str(Path(x).resolve()) for x in checked['command'] if x.endswith('.bend')] == [str(source)], 'API checked another source')
    require(built.get('complete') and built.get('object') == pin(runtime), 'Complete exact runtime build required')
    contract = source_contract(source, composed)
    assets_path = PHASE / 'native-assets01.json'
    assets = read(assets_path)
    require(assets.get('complete'), 'Frozen native assets required')
    selection = read(verify(assets['selection']))
    admission = read(verify(assets['admission']))
    require(selection['admission'] == assets['admission'] and admission.get('qualified') and admission.get('complete'), 'Seed admission mismatch')
    require(admission['assets']['base'] == assets['base'] and admission['assets']['cache'] == assets['cache'], 'Base/cache mismatch')
    artifacts = {name: ROOT / 'selfhost/build/phase111' / (a.tag + '-' + suffix)
                 for name, suffix in [('hosted', 'full-emit'), ('n1', 'n1'), ('self', 'self'),
                                      ('n1Focused', 'n1-focused'), ('n2Focused', 'n2-focused'), ('n2Full45', 'n2-full45')]}
    artifacts['comparison'] = ROOT / 'selfhost/build/phase118' / (a.tag + '-qbe-comparison.json')
    artifacts['jobs'] = ROOT / 'selfhost/build/phase113' / (a.tag + '-qualification')
    artifacts['guard'] = ROOT / 'selfhost/build/phase118' / (a.tag + '-qualification-guard')
    require(not any(x.exists() for x in artifacts.values()), 'Artifact destination already exists')
    py = [str(Path(sys.executable).resolve()), '-B']
    hosted = HERE / 'native-hosted.mjs'
    build, emit = PHASE / 'build.py', PHASE / 'native-emit.py'
    focused, full45 = PHASE / 'coverage/native-run.py', PHASE / 'coverage/full45/native-run.py'
    runner = ROOT / 'selfhost/tools/performance/phase113/run-jobs.py'
    n1, n2 = artifacts['n1'] / 'program', artifacts['self'] / 'build/program'
    def focus(label, image, target):
        return dict(name=label, seconds=180, command=py + [str(focused), '--image', str(image), '--runtime', str(runtime), '--suite', 'focused', '--seconds', '30', '--build-seconds', '30', '--out', str(target)])
    jobs = [dict(name='authenticate-plan', seconds=30, command=py + [str(Path(__file__).resolve()), 'verify', '--plan', str(out)]),
            dict(name='full-hosted-integrated-emission', seconds=a.hosted_seconds, command=[checked['command'][0], str(hosted), str(api), str(source), str(artifacts['hosted']), 'cache', 'array']),
            dict(name='n1-build', seconds=3 * a.build_seconds + 30, command=py + [str(build), '--source', str(artifacts['hosted'] / 'program.ssa'), '--runtime', str(runtime), '--out', str(artifacts['n1']), '--seconds', str(a.build_seconds)]),
            focus('n1-focused19', n1, artifacts['n1Focused']),
            dict(name='native-self-emission-n2-build', seconds=a.native_seconds + 3 * a.build_seconds + 60, command=py + [str(emit), '--image', str(n1), '--source', str(source), '--out', str(artifacts['self']), '--mode', 'cache', '--runtime', str(runtime), '--seconds', str(a.native_seconds), '--build-seconds', str(a.build_seconds)]),
            dict(name='exact-hosted-native-qbe', seconds=60, command=py + [str(HERE / 'native-comparison.py'), '--plan', str(out), '--out', str(artifacts['comparison'])]),
            focus('n2-focused19', n2, artifacts['n2Focused']),
            dict(name='n2-original-full45', seconds=300, command=py + [str(full45), '--partition', 'all45', '--image', str(n2), '--runtime', str(runtime), '--seconds', '120', '--build-seconds', '10', '--out', str(artifacts['n2Full45'])])]
    methods = [Path(__file__), HERE / 'native-comparison.py', HERE / 'integrated-entry.bend', hosted,
               build, emit, focused, full45, runner, PHASE / 'guard.py', assets_path,
               PHASE / 'coverage/manifest.json', PHASE / 'coverage/full45/manifest.json',
               ROOT / 'selfhost/tools/performance/programs/support.py']
    toolchain = [Path(sys.executable).resolve(), Path(checked['command'][0]).resolve(),
                 ROOT / 'selfhost/build/phase108/toolchain/qbe-1.3/qbe',
                 Path(shutil.which('as')).resolve(), Path(shutil.which('gcc')).resolve()]
    inputs = [*[pin(x) for x in methods + toolchain + [sr, ar, rr, source, api, runtime]],
              *composed['inputs'], *contract['snapshots'], *checked['inputs'], *built['inputs'], built['source'],
              assets['selection'], assets['admission'], assets['base'], assets['cache']['carrier']]
    for suite in [read(PHASE / 'coverage/manifest.json'), read(PHASE / 'coverage/full45/manifest.json')]:
        rows = list(suite.get('inputs', []))
        for case in suite['fixtures']:
            rows.extend(case[key] for key in ['source', 'origin', 'stdoutFile', 'expectationFile', 'independentPriorEvidence'] if key in case)
        inputs.extend(dict(row, file=str((ROOT / row['file']).resolve())) for row in rows)
    inputs = unique(inputs)
    for row in inputs:
        verify(row)
    seconds = sum(job['seconds'] for job in jobs) + 60
    guard = py + [str(PHASE / 'guard.py'), '--out', str(artifacts['guard']), '--seconds', str(seconds), '--rss-mib', '4096', '--available-mib', '16384', '--file-mib', '128', '--cpu', '3', '--', *py, str(runner), '--plan', str(out), '--out', str(artifacts['jobs'])]
    plan = dict(kind=KIND, complete=True, targetsRun=False, inputs=inputs, source=pin(source), api=pin(api), runtime=pin(runtime),
                sourceManifest=pin(sr), apiReport=pin(ar), runtimeReport=pin(rr), transportContract=contract,
                assets={key: assets[key] for key in ['base', 'cache', 'selection', 'admission']}, jobs=jobs,
                artifacts={k: str(v) for k, v in artifacts.items()}, rootGuardCommand=guard,
                guard=dict(cpu=3, rssMiB=4096, availableMiB=16384, fileMiB=128, seconds=seconds),
                scope='Root-only integrated hosted→N1→native-self→N2 raw-QBE reproduction plus unchanged ordinary focused19/full45 suites. New Phase118 entry contract, not the old staged hook; no ELF fixed point, N2 self-emission, timing or installed promotion claim.')
    out.parent.mkdir(parents=True, exist_ok=True)
    with out.open('x') as f:
        json.dump(plan, f, indent=2)
        f.write('\n')
    print(json.dumps(dict(complete=True, targetsRun=False, plan=pin(out), rootGuardCommand=guard)))


if __name__ == '__main__':
    main()

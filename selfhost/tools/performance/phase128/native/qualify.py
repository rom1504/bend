"""Bind actual Phase128 native acquisition and semantic receipts; no target runs."""
import argparse
import filecmp
import hashlib
import json
from pathlib import Path

from prepare import ROOT, read, require, unique

BASE = ROOT / 'selfhost/build/phase114/native-final02-transport-manifest.json'
BASE_SHA = '58361b0ad4f5cae149344ae47b6c085b5220a7355f8fbd2f88c1e41fc25aaebf'
BUILDER = ROOT / 'selfhost/tools/performance/phase123/build-aligned.py'
BUILDER_SHA = '67fffc05bdbedf2fcf13eace395fd203f45a981b3a1d7de000d465fcc2693701'
NATIVE = ROOT / 'selfhost/tools/performance/phase125/native'
VERIFIED = set()


def pin(path):
    path = Path(path).resolve()
    h = hashlib.sha256()
    with path.open('rb') as f:
        for chunk in iter(lambda: f.read(1024 * 1024), b''):
            h.update(chunk)
    return dict(file=str(path), bytes=path.stat().st_size, sha256=h.hexdigest())


def verify(row):
    key = (row['file'], row['bytes'], row['sha256'])
    if key not in VERIFIED:
        require(pin(row['file']) == row, 'Changed input: ' + row['file'])
        VERIFIED.add(key)
    return Path(row['file'])


def pins(value):
    if isinstance(value, dict):
        if all(k in value for k in ['file', 'bytes', 'sha256']):
            yield value
        for item in value.values():
            yield from pins(item)
    elif isinstance(value, list):
        for item in value:
            yield from pins(item)


def build(receipt, qbe, runtime, tools):
    require(receipt.get('complete') and receipt.get('kind') == 'phase123-branch-aligned-qbe-build'
            and receipt.get('cachedRuntime') and receipt.get('perProgramC') is False
            and receipt.get('cproc') is False, 'Aligned cached-runtime build required')
    require(qbe in receipt['inputs'] and runtime in receipt['inputs'], 'Build product/runtime mismatch')
    require(any(r['sha256'] == BUILDER_SHA and r['bytes'] == pin(BUILDER)['bytes'] for r in receipt['inputs']), 'Build method differs')
    jobs = receipt['jobs']
    require([r['label'] for r in jobs[:3]] == ['qbe', 'assemble', 'link']
            and all(r['exitCode'] == 0 for r in jobs), 'Build stages incomplete')
    q, a, l = [r['command'] for r in jobs[:3]]
    require(q[1:4] == ['-t', 'amd64_sysv', '-o'] and len(q) == 6 and q[-1] == qbe['file'], 'QBE arguments changed')
    require(len(a) == 5 and a[1:3] == ['-mbranches-within-32B-boundaries', '-o'] and a[4] == q[4], 'Assembler arguments changed')
    require(l[1:] == ['-no-pie', a[3], runtime['file'], '-pthread', '-lm', '-o', receipt['binary']['file']], 'Link arguments changed')
    for key, command in [('qbe', q), ('assembler', a), ('linker', l)]:
        require(pin(command[0]) == tools[key] and tools[key] in receipt['inputs'], 'Machine tool changed: ' + key)
    for row in pins(receipt):
        verify(row)
    return receipt['binary']


def main():
    p = argparse.ArgumentParser(description=__doc__)
    for name in ['admission', 'hosted', 'n1-build', 'self-emission', 'n2-build',
                 'n1-focused', 'n2-focused', 'n2-full45', 'out']:
        p.add_argument('--' + name, type=Path, required=True)
    a = p.parse_args()
    require(not a.out.exists() and a.out.resolve().is_relative_to(ROOT / 'selfhost/build/phase128'), 'Fresh Phase128 receipt required')
    require(pin(BASE)['sha256'] == BASE_SHA and pin(BUILDER)['sha256'] == BUILDER_SHA, 'Frozen method changed')
    base, admission = read(BASE), read(a.admission)
    require(admission['kind'] == 'phase128-checked-native-acquisition-admission'
            and admission['complete'] and admission['sourceChecked'], 'Fresh Phase128 admission required')
    files = [a.admission, a.hosted, a.n1_build, a.self_emission, a.n2_build,
             a.n1_focused, a.n2_focused, a.n2_full45]
    inputs = [pin(__file__), pin(Path(__file__).with_name('prepare.py')), pin(BASE), pin(BUILDER), *map(pin, files)]
    inputs += list(pins(admission))
    h, n1b, native, n2b = map(read, [a.hosted, a.n1_build, a.self_emission, a.n2_build])
    require(h['complete'] and h['kind'] == 'phase118-integrated-checked-source-qbe-emission'
            and h['transportVersion'] == 118 and h['entry'] == 'p111_emit_admitted'
            and h['pipeline'] == 'array' and h['explicitVerificationPasses'] == 1, 'Hosted route mismatch')
    require(all(h.get(k) for k in ['sourceChecked', 'runtimeAdmitted', 'irVerified']), 'Hosted gates incomplete')
    require(admission['api'] in h['inputs'] and admission['checkedApi'] in h['inputs'], 'Hosted producer mismatch')
    n1 = build(n1b, h['product'], admission['runtime'], base['tools'])
    require(native['complete'] and native['kind'] == 'phase125-aligned-native-source-qbe-emission'
            and native['gates']['emission'] == 'passed' and native['image'] == n1
            and native['imageReceipt'] == pin(a.n1_build), 'Native emitter/image lineage mismatch')
    n2 = build(n2b, native['product'], admission['runtime'], base['tools'])
    if native.get('buildReport'):
        require(native['buildReport'] == pin(a.n2_build), 'Embedded N2 build differs from actual separate build')
    require(h['mode'] == native['mode'] == 'cache', 'Self-emission mode differs')
    assets = base['nativeAssets']
    for expected in [admission['source'], assets['base'], assets['cache']['carrier'], assets['selection'], assets['admission']]:
        require(all(expected in report['inputs'] for report in [h, native]), 'Source/Base/cache mismatch')
    jobs = [r for r in native['jobs'] if r['label'] == 'native-request']
    require(len(jobs) == 1 and jobs[0]['status'] == 'complete' and jobs[0]['exitCode'] == 0
            and jobs[0]['stdout'] == native['product'] and jobs[0]['stderr']['bytes'] == 0, 'Raw native output binding differs')
    for report in [h, n1b, native, n2b]:
        inputs += list(pins(report))
    verify(h['product']); verify(native['product'])
    require(h['product']['bytes'] == native['product']['bytes'] and
            filecmp.cmp(h['product']['file'], native['product']['file'], shallow=False), 'Raw hosted/N1 self-emission differs')
    focused = ROOT / 'selfhost/tools/performance/phase111/coverage/manifest.json'
    broad = focused.parent / 'full45/manifest.json'
    for file, image, corpus, positive, refused in [(a.n1_focused, n1, focused, 16, 3),
            (a.n2_focused, n2, focused, 16, 3), (a.n2_full45, n2, broad, 45, 0)]:
        report, frozen = read(file), read(corpus)
        names = [r['name'] for r in frozen['fixtures']]
        require(report['complete'] and report['passed'] and report['kind'] == 'phase125-aligned-native-source-semantic-coverage', 'Incomplete native semantics')
        require(report['names'] == names and [r['name'] for r in report['rows']] == names, 'Coverage corpus differs')
        require(pin(corpus) in report['inputs'] and pin(NATIVE / 'coverage.py') in report['inputs'], 'Coverage authority missing')
        require(image in report['inputs'] and admission['runtime'] in report['inputs'], 'Coverage image/runtime mismatch')
        require(report['summary']['semanticPasses'] == positive and report['summary']['expectedRefusals'] == refused
                and report['summary']['pending'] == 0, 'Coverage summary differs')
        for row, case in zip(report['rows'], frozen['fixtures']):
            require(row['expected'] == case['expect'], 'Independent output oracle changed')
            if row['semanticPass']:
                emitted = read(verify(row['emission']))
                built = read(verify(row['build']))
                case_source = dict(case['source'], file=str((ROOT / case['source']['file']).resolve()))
                require(emitted['complete'] and emitted['image'] == image and case_source in emitted['inputs'], 'Covered source/emitter mismatch')
                require(build(built, emitted['product'], admission['runtime'], base['tools']) == row['binary'], 'Covered binary mismatch')
                execution = [j for j in built['jobs'] if j['label'] == 'execute']
                require(len(execution) == 1 and built['outputExact']
                        and verify(execution[0]['stdout']).read_bytes() == case['expect']['stdout'].encode()
                        and verify(execution[0]['stderr']).read_bytes() == case['expect']['stderr'].encode(), 'Covered observation differs')
                inputs += [row['emission'], row['build']]
            else:
                require(row['expectedRefusal'] and row['status'] == 'source-refused', 'Unqualified negative case')
        inputs += [pin(corpus), *list(pins(report))]
    inputs = unique(inputs)
    for row in inputs:
        verify(row)
    result = dict(kind='phase128-native-qualification', complete=True, nativeQualified=True, targetsRun=False,
        source=admission['source'], api=admission['api'], runtime=admission['runtime'], admission=pin(a.admission),
        sourceBinding=admission['sourceBinding'], checkedApi=admission['checkedApi'],
        n1=n1, n2=n2, hostedQbe=h['product'], nativeQbe=native['product'], byteExact=True,
        reports={key: pin(getattr(a, key)) for key in ['hosted', 'n1_build', 'self_emission', 'n2_build', 'n1_focused', 'n2_focused', 'n2_full45']},
        installed=False, selected=False, inputs=inputs,
        scope='Actual hosted → N1 → independently built N2 lineage; raw QBE equality, 19 focused cases on each image and 45 ordinary cases on N2. No old qualification plan is relabeled. No ELF identity, N2→N3, performance or installed-selection claim.')
    a.out.parent.mkdir(parents=True, exist_ok=True)
    a.out.write_text(json.dumps(result, indent=2) + '\n')
    print(json.dumps(dict(complete=True, nativeQualified=True, report=pin(a.out))))


if __name__ == '__main__':
    main()

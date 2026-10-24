#!/usr/bin/env python3
"""Archive a qualified Phase134 checkpoint with real timing and native45 evidence.

Data only. Principal joins and complete bytes are rechecked; compiler execution
is never repeated. Large binaries/QBE remain separately pinned build artifacts.
"""
import argparse
import filecmp
import gzip
import hashlib
import importlib.util
import json
from pathlib import Path
import re
import shutil
import sys
import tarfile

sys.dont_write_bytecode = True
if hashlib.sha256(Path(__file__).with_name('archive.py').read_bytes()).hexdigest() != 'cef5d66099bd3ec0ec0b8ced1f5a96b460c0aab012323b082f7a49ca562795d8':
    raise ValueError('Frozen original archive method changed')
spec = importlib.util.spec_from_file_location('p134_archive_plan', Path(__file__).with_name('plan.py'))
P = importlib.util.module_from_spec(spec); spec.loader.exec_module(P)


def main():
    ap = argparse.ArgumentParser(description=__doc__)
    for name in ['qualification', 'wrapper-equality', 'out']:
        ap.add_argument('--' + name, type=Path, required=True)
    ap.add_argument('--timing-report', type=Path, action='append', required=True)
    ap.add_argument('--timing-summary', type=Path, action='append', required=True)
    ap.add_argument('--extra', action='append', default=[], help='Unique archive-name=metadata-path, e.g. memory.json=...')
    a = ap.parse_args(); out = a.out.resolve()
    P.require(not out.exists() and out.is_relative_to(P.ROOT / 'implementation/phase134'), 'Fresh Phase134 implementation capsule required')
    P.require(len(a.timing_report) == len(a.timing_summary), 'Pair each timing report with its actual summary')
    members, inputs = {}, {}

    def retain(item):
        old = inputs.get(item['file']); P.require(old is None or old == item, 'Conflicting artifact identity')
        if old is None: P.verify(item); inputs[item['file']] = item
        return Path(item['file'])

    def read(path):
        path = retain(P.pin(path)); return P.read(path)

    def add(name, path):
        P.require(re.fullmatch(r'[A-Za-z0-9_./-]+', name) and not name.startswith('/') and '..' not in Path(name).parts and name not in members, 'Invalid/duplicate archive member')
        item = P.pin(path); retain(item)
        P.require(item['bytes'] <= 16 * 1024**2, 'Only small metadata in evidence archive; binaries/QBE stay separately pinned')
        members[name] = item

    q = read(a.qualification)
    P.require(q.get('kind') == 'phase134-native-streaming-research-qualification' and q.get('complete') and q.get('nativeQualified') and q.get('requiredQbeByteExact') and not q.get('installed') and not q.get('selected'), 'Completed uninstalled native qualification required')
    parent, base, t = P.authorities()
    P.require(q['producerSelection'] == P.pin(P.SELECTION) and q['producer'] == parent['n3'] and q['runtime'] == parent['runtime'], 'Actual qualified producer/runtime differs')
    P.require(P.pin(Path(__file__).with_name('qualify.py')) in q['inputs'], 'Frozen qualification method missing')
    variant = q.get('variant', 'streaming')
    if variant != 'streaming':
        method = {'bounded-packet-writer': 'qualify-batch.py', 'no-copy-writer': 'qualify-no-copy.py', 'no-copy-verification-reuse': 'qualify-reuse.py'}.get(variant)
        P.require(method and P.pin(Path(__file__).with_name(method)) in q['inputs'], 'Variant qualifier authority missing')
    images = {k: q[k] for k in ['n1', 'n2', 'n3'] if k in q}
    for item in [q['source'], q['api'], q['runtime'], q['producer'], *images.values()]: retain(item)
    left_key, right_key = ('q1', 'q2') if q['policy'] == 'q1-q2' else ('q2', 'q3')
    P.require(q['policy'] in {'q1-q2', 'q2-q3'} and q['reproducedQbe'] == dict(left=q['qbe'][left_key], right=q['qbe'][right_key]), 'Declared reproduction policy differs')
    left, right = [retain(q['qbe'][k]) for k in [left_key, right_key]]
    P.require(filecmp.cmp(left, right, shallow=False), 'Complete reproduced compiler QBE differs')
    first = q['n1'] if q['policy'] == 'q1-q2' else q['n2']
    final = q['n2'] if q['policy'] == 'q1-q2' else q['n3']
    P.require(q['finalImage'] == final and len(q['semanticGates']) == 3, 'Final native image/gate inventory differs')
    for gate, expected in zip(q['semanticGates'], [(first,16,3),(final,16,3),(final,45,0)]):
        P.require((gate['image'],gate['semanticPasses'],gate['expectedRefusals']) == expected, 'Native gate generation/count differs')
        report = read(retain(gate['report']))
        P.require(report.get('complete') and report.get('passed') and report['summary']['pending'] == 0 and report['summary']['semanticPasses'] == expected[1] and report['summary']['expectedRefusals'] == expected[2], 'Native gate no longer complete')
        P.require(gate['report'] in q['inputs'], 'Gate receipt absent from qualified input inventory')
    contract = q['sourceContract']
    P.require(contract['source'] == q['source'] and contract['api'] == q['api'] and contract['completeSourceReplay'] and contract['originalVerifierBytesUnchanged'], 'Qualification source contract differs')
    source_manifest = read(retain(contract['sourceManifest'])); api = read(retain(contract['checkedApi']))
    P.require(source_manifest['source'] == q['source'] and api['complete'] and api['checked'] and api['status'] == 0 and q['source'] in api['inputs'] and api['api'] == q['api'], 'Independent checked source identity differs')
    add('qualification.json', a.qualification)
    for name in ['sourceManifest', 'checkedApi', 'finiteControls']:
        add('source/' + name + '.json', retain(contract[name]))
    for name in ['nativeWriterControls', 'nativeWriterBuild']:
        if name in contract: add('source/' + name + '.json', retain(contract[name]))
    for key, item in q['reports'].items(): add('qualification/' + key + '.json', retain(item))
    add('parent-selection.json', P.SELECTION)

    timing_blocks = []
    runner = P.load(t.RUNNER, 'p134_archive_timing')
    for index, (raw_path, summary_path) in enumerate(zip(a.timing_report, a.timing_summary)):
        raw, summary = read(raw_path), read(summary_path)
        P.require(raw.get('complete') and raw.get('passed') and raw.get('inputsUnchanged') and not raw.get('checkOnly') and raw['cpuAffinity'] == [3], 'Actual clean CPU3 timing required')
        P.require(summary.get('complete') and P.pin(raw_path) in summary['inputs'] and summary['roles'] == raw['roles'] and summary['observations'] == len(raw['rows']) == 27, 'Raw timing/summary join differs')
        P.require(raw['roles']['phase111']['binary'] == parent['n2'] and raw['roles']['phase111']['source'] == parent['source'] and raw['roles']['phase112']['binary'] in images.values() and raw['roles']['phase112']['source'] == q['source'], 'Timing attributes the wrong compiler/source')
        P.require(raw['roles']['upstream'] == base['roles']['upstream'] and raw['cases'] == base['cases'] and raw['rounds'] == 3 and raw['modes'] == ['cache'] and all(r['passed'] and r['outputExact'] and r['stderrExact'] for r in raw['rows']), 'Frozen timing corpus/policy/output changed')
        calculated = runner.summarize(raw['rows'], raw['cases'], raw['rounds'])
        P.require(raw['summary'] == summary['summary'] == calculated, 'Timing summary is not derived from actual observations')
        manifest = read(retain(raw['manifest']))
        P.require(manifest['roles'] == raw['roles'], 'Timing manifest role identity differs')
        for item in raw['inputs']: retain(item)
        for suffix, path in [('raw.json',raw_path),('summary.json',summary_path),('manifest.json',raw['manifest']['file'])]: add(f'timing/{index}-{suffix}',path)
        timing_blocks.append(dict(report=P.pin(raw_path), summary=P.pin(summary_path), measuredImage=raw['roles']['phase112']['binary'], ratios=calculated['cache']['threeCaseGeometricRatios']))
    P.require(any(b['measuredImage'] == final for b in timing_blocks), 'Final qualified image must have an actual timing block; do not infer its speed')

    wrappers = read(a.wrapper_equality)
    P.require(wrappers.get('complete') and wrappers.get('all45ByteExact') and wrappers['image'] == final and wrappers['runtime'] == q['runtime'] and len(wrappers['cases']) == 45, 'Actual final native45 bridge required')
    P.require(wrappers['reusedMeasuredScreen'] == parent['generatedPrograms']['measuredScreen'] and P.pin(P.__file__) in wrappers['inputs'], 'Wrapper bridge method/screen identity differs')
    old_eq = read(retain(parent['generatedPrograms']['equality']))
    for row, old in zip(wrappers['cases'], old_eq['cases']):
        P.require(row['name'] == old['name'] and row['expectedQbe'] == old['nativeQbe'] and row['measuredBinary'] == old['measuredBinary'], 'Measured wrapper inventory changed')
        request = read(retain(row['receipt']))
        P.require(request['complete'] and request['byteExact'] and request['exitCode'] == 0 and not request['changedInputs'] and request['stderr']['bytes'] == 0 and request['image'] == final and request['source'] == old['source'] and request['runtime'] == q['runtime'] and request['product'] == row['nativeQbe'] and request['expectedQbe'] == row['expectedQbe'], 'Native wrapper request identity/status differs')
        P.require(filecmp.cmp(retain(row['nativeQbe']), retain(row['expectedQbe']), shallow=False), 'Native wrapper complete bytes differ')
        retain(row['measuredBinary']); add('wrappers/' + row['name'] + '.json', row['receipt']['file'])
    add('wrapper-equality.json', a.wrapper_equality)
    add('reused-program-runtime.json', retain(wrappers['reusedMeasuredScreen']))
    for value in a.extra:
        name, sep, path = value.partition('='); P.require(sep and path, 'Use --extra archive-name=path')
        add('extra/' + name, path)
    add('method.py', __file__)

    out.mkdir(parents=True)
    archive = out / 'evidence.tar.gz'
    with archive.open('xb') as target, gzip.GzipFile(filename='', fileobj=target, mode='wb', compresslevel=9, mtime=0) as compressed:
        with tarfile.open(fileobj=compressed, mode='w|') as tar:
            for name, item in members.items():
                info = tarfile.TarInfo(name); info.size = item['bytes']; info.mtime = 0; info.mode = 0o644
                with Path(item['file']).open('rb') as source: tar.addfile(info, source)
    with tarfile.open(archive, 'r:gz') as tar:
        P.require(tar.getnames() == list(members), 'Archive member order/inventory differs')
        for name, item in members.items():
            h = hashlib.sha256(); size = 0
            with tar.extractfile(name) as member:
                for chunk in iter(lambda: member.read(1048576), b''): h.update(chunk); size += len(chunk)
            P.require(size == item['bytes'] and h.hexdigest() == item['sha256'], 'Archived member differs')
    source_archive = out / 'compiler.bend.gz'
    with source_archive.open('xb') as target, gzip.GzipFile(filename='', fileobj=target, mode='wb', compresslevel=9, mtime=0) as compressed, Path(q['source']['file']).open('rb') as source:
        shutil.copyfileobj(source, compressed, 1048576)
    h = hashlib.sha256(); size = 0
    with gzip.open(source_archive, 'rb') as source:
        for chunk in iter(lambda: source.read(1048576), b''): h.update(chunk); size += len(chunk)
    P.require((size,h.hexdigest()) == (q['source']['bytes'],q['source']['sha256']), 'Compressed source roundtrip differs')
    for item in inputs.values(): P.verify(item)
    capsule = dict(kind='phase134-final-native-research-checkpoint', complete=True, nativeQualified=True,
        source=q['source'], archive=P.pin(source_archive), evidenceArchive=P.pin(archive), sourceManifest=contract['sourceManifest'],
        checkedApi=contract['checkedApi'], api=q['api'], runtime=q['runtime'], runtimeReport=parent['runtimeReport'],
        **images, finalImage=final, qualification=P.pin(a.qualification),
        preferredCarrier=parent['preferredCarrier'], preferredCarrierReceipt=parent['preferredCarrierReceipt'], preferredStamp=parent['preferredStamp'], legacyCarrierReceipt=parent['legacyCarrierReceipt'],
        requestReproduction=dict(products=q['qbe'], policy=q['policy'], finalQbeByteExact=True, comparedProducts=q['reproducedQbe'], elfFixedPointClaimed=False),
        compilerTiming=timing_blocks, generatedPrograms=dict(equality=P.pin(a.wrapper_equality), producingNativeImage=final, independentNativeQbeMatches=45, reusedMeasuredScreen=wrappers['reusedMeasuredScreen'], freshRuntimeMeasurement=False),
        members=[dict(name=name, source=item) for name,item in members.items()], inputs=list(inputs.values()),
        method=P.pin(__file__), variant=variant, installed=False, selected=False, productionSelectionChanged=False,
        scope='Actual qualified final native image, separate fresh same-block compiler timings and exact45 native-output transfer to retained Phase131 program products. Historical program timings are reused, not rerun or relabeled as a fresh score. Source and metadata are archived; native images/QBE/toolchain remain separately pinned build artifacts.')
    with (out / 'candidate.json').open('x') as f: json.dump(capsule,f,indent=2); f.write('\n')
    print(json.dumps(dict(complete=True, targetsRun=False, candidate=P.pin(out/'candidate.json'), members=len(members), archiveBytes=archive.stat().st_size)))


if __name__ == '__main__': main()

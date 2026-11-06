#!/usr/bin/env python3
"""Collect exact Phase169 receipts offline; execute no compiler or program."""
import argparse
import hashlib
import json
import tarfile
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
RUN = ROOT / 'selfhost/build/phase169'


def read(path):
    return json.loads(path.read_text())


def pin(path):
    path = path.resolve()
    h = hashlib.sha256()
    with path.open('rb') as stream:
        for block in iter(lambda: stream.read(1048576), b''):
            h.update(block)
    return dict(file=str(path.relative_to(ROOT)), bytes=path.stat().st_size,
                sha256=h.hexdigest())


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--out', type=Path, required=True)
    a = p.parse_args()
    assert not a.out.exists(), 'Fresh evidence snapshot required'
    a.out.mkdir(parents=True)
    result = dict(phase=169, productionChanged=False, qualifiedCompiler='Phase152',
                  nativeBuilds=[], otherReports=[], guards=[], sources=[], externalLargeOutputs=[])
    selected = set()
    for path in sorted(RUN.glob('*/report.json')):
        r = read(path)
        selected.add(path)
        identity = dict(name=path.parent.name, receipt=pin(path), complete=r.get('complete'))
        if r.get('kind') == 'bend-native-build':
            identity.update({k: r.get(k) for k in ['wallSeconds', 'emitAndQbeSeconds',
                'stage', 'irDigest', 'assembly', 'object', 'binary', 'imageBinding',
                'runtime', 'sourceIR', 'expectedQbe', 'expectedStdout', 'error']})
            identity['source'] = (r.get('request') or {}).get('source')
            identity['machineJobs'] = [dict(label=j.get('label'), seconds=j.get('seconds'),
                complete=j.get('complete')) for j in r.get('jobs', [])]
            result['nativeBuilds'].append(identity)
        else:
            identity.update({k: r[k] for k in ['scope', 'passed', 'rows', 'summary',
                'groups', 'checks', 'seconds', 'proofAccepted', 'sourceChecked',
                'error', 'profilesUsable', 'aggregate', 'cases', 'plan', 'wallSeconds',
                'status', 'budgetOverrunSeconds'] if k in r})
            result['otherReports'].append(identity)
    for path in sorted(RUN.glob('*-guard/process.json')):
        r = read(path)
        assert 'finished' in r, 'Active target: ' + str(path)
        close = ROOT / 'selfhost/build-retention' / (
            'phase169-' + path.parent.name.removesuffix('-guard') + '-close') / 'report.json'
        assert close.is_file(), 'Unsealed run: ' + str(path)
        result['guards'].append(dict(receipt=pin(path), retention=pin(close),
            complete=r['complete'], seconds=r['wallSeconds'],
            stoppedFor=r.get('stoppedFor'), peakRssBytes=r['peakTreeRssBytes'],
            minimumFreeBytes=r['minimumDiskFreeBytes']))
        selected.update([path, close])
    for path in sorted(RUN.rglob('*manifest.json')):
        r = read(path)
        if 'source' in r:
            result['sources'].append(dict(receipt=pin(path), source=r['source'],
                protectedUnchanged=r.get('protectedUnchanged'),
                replacements=r.get('replacements'), additiveReplacements=r.get('additiveReplacements')))
        selected.add(path)
    for path in RUN.rglob('*'):
        if path.is_file() and (path.name in ['report.json', 'process.json', 'exports.json',
                'request.json', 'derivation.json', 'analysis.json', 'base-binding.json']
                or path.name.endswith('.stderr') or path.name == 'samples.txt'):
            selected.add(path)
        if path.is_file() and (path.name in ['stdout', 'stderr'] or
                path.name.endswith(('.stdout', '.stderr'))):
            if path.stat().st_size <= 1048576:
                selected.add(path)
            else:
                result['externalLargeOutputs'].append(pin(path))
    result['executionLaneSeconds'] = sum(r['seconds'] for r in result['guards'])
    result['failedGuards'] = sum(not r['complete'] for r in result['guards'])
    result['limits'] = ['Guard seconds exclude agent reasoning/editing and archive maintenance.',
        'Quota/token billing telemetry is unavailable; no quota estimate is claimed.',
        'Source checking, exact products, finite controls and bootstrap agreement are separate gates.',
        'Raw outputs over1MiB are pinned external artifacts, not included in this receipt capsule.',
        'Experimental native closure and unchanged full canonical source are distinct workloads.']
    (a.out / 'metrics.json').write_text(json.dumps(result, indent=2) + '\n')
    capsule = a.out / 'receipts.tar.gz'
    with tarfile.open(capsule, 'w:gz') as tar:
        for path in sorted(selected):
            tar.add(path, arcname=str(path.relative_to(ROOT)), recursive=False)
    files = [pin(path) for path in sorted(selected)]
    with tarfile.open(capsule, 'r:gz') as tar:
        assert len(tar.getmembers()) == len(files)
        for item in files:
            with tar.extractfile(item['file']) as stream:
                data = stream.read()
            assert len(data) == item['bytes'] and hashlib.sha256(data).hexdigest() == item['sha256']
    (a.out / 'capsule.json').write_text(json.dumps(dict(method=pin(Path(__file__)),
        archive=pin(capsule), files=files, reopenedVerified=True), indent=2) + '\n')
    print(json.dumps(dict(guards=len(result['guards']), seconds=result['executionLaneSeconds'],
                         failed=result['failedGuards'], archive=pin(capsule))))


if __name__ == '__main__':
    main()

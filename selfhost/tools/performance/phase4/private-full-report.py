#!/usr/bin/env python3
"""Audit ALL planned private full-source observations; retain incomplete attempts.

Usage: private-full-report.py PLAN_JSON NEW_ARCHIVE_DIRECTORY
No summary is produced unless every intended row and final input audit pass.
"""
import gzip
import datetime
import hashlib
import json
import math
from pathlib import Path
import statistics
import sys


def digest(data):
    return hashlib.sha256(data).hexdigest()


def require(condition, message):
    if not condition:
        raise ValueError(message)


class Archive:
    def __init__(self, output):
        self.output = output
        self.files = {}
        self.entries = {}
        self.objects = {}
        self.resolutions = {}
        self.missing = set()

    def capture(self, file):
        file = Path(file).absolute()
        raw = file.read_bytes()
        record = {'file': str(file), 'canonicalPath': str(file.resolve(strict=True)),
                  'sha256': digest(raw), 'bytes': len(raw)}
        require(str(file) not in self.files or self.files[str(file)] == record,
                'Input drift during audit: ' + str(file))
        self.files[str(file)] = record
        return raw

    def read(self, file):
        return json.loads(self.capture(file))

    def preserve(self, file):
        file = Path(file).absolute()
        raw = self.capture(file)
        key = digest(raw)
        relative = 'objects/' + key + '.gz'
        if key not in self.objects:
            target = self.output / relative
            target.parent.mkdir(exist_ok=True)
            target.write_bytes(gzip.compress(raw, mtime=0))
            require(gzip.decompress(target.read_bytes()) == raw, 'Archive restoration failure')
            self.objects[key] = relative
        self.entries[str(file)] = {'source': str(file), 'canonicalPath': str(file.resolve()),
                                  'artifact': relative, 'rawSha256': key, 'rawBytes': len(raw),
                                  'artifactSha256': digest((self.output / relative).read_bytes())}
        return key

    def verify(self, record):
        require(isinstance(record, dict), 'Invalid identity record')
        raw = self.capture(record['file'])
        require(digest(raw) == record['sha256'], 'Recorded hash mismatch: ' + str(record['file']))
        if 'canonicalPath' in record:
            require(str(Path(record['file']).resolve()) == record['canonicalPath'], 'Recorded canonical path mismatch')
        if 'bytes' in record:
            require(len(raw) == record['bytes'], 'Recorded byte length mismatch')

    def resolution(self, record):
        require(str(Path(record['file']).resolve(strict=True)) == record['canonicalPath'], 'Consumed resolution changed')
        require(record['file'] not in self.resolutions or self.resolutions[record['file']] == record['canonicalPath'], 'Resolution drift during audit')
        self.resolutions[record['file']] = record['canonicalPath']

    def absent(self, file):
        require(not Path(file).exists(), 'Missing input appeared')
        self.missing.add(file)

    def finish(self):
        for file, canonical in self.resolutions.items():
            self.resolution({'file': file, 'canonicalPath': canonical})
        for file in list(self.missing):
            self.absent(file)
        for record in list(self.files.values()):
            self.verify(record)


def finite(value, name, positive=False):
    require(type(value) in (int, float) and math.isfinite(value) and
            (value > 0 if positive else value >= 0), 'Invalid numeric field: ' + name)
    return value


def audit_row(selected, plan, archive, expected):
    directory = Path(selected['directory']).absolute()
    names = ['measurement.json', 'stdout', 'stderr', 'request/launch.json',
             'request/result.json', 'request/request.json', 'request/worker.stdout', 'request/worker.stderr']
    # Retain everything available before rejecting an incomplete attempt.
    for name in names:
        if (directory / name).exists():
            archive.preserve(directory / name)
    require(all((directory / name).is_file() for name in names), 'Missing required run record/log')
    m = archive.read(directory / 'measurement.json')
    launch = archive.read(directory / 'request/launch.json')
    result = archive.read(directory / 'request/result.json')
    request = archive.read(directory / 'request/request.json')
    require(m['kind'] == 'phase4-private-full-source' and m['version'] == 1, 'Unknown measurement kind')
    require(m['complete'] is True and type(m['returncode']) is int and m['returncode'] == 0 and m['inputsUnchanged'] is True, 'Failed outer measurement')
    require(launch['kind'] == 'bend-private-compiler-launch' and result['kind'] == 'bend-private-compiler-request', 'Unknown request/launch kind')
    require(launch['complete'] is True and type(launch['status']) is int and launch['status'] == 0 and launch['signal'] is None, 'Failed launcher')
    require(launch['timedOut'] is False and launch['outputLimit'] is False, 'Timeout or output limit')
    require(launch['proofStatus'] == result['proofStatus'] == 'fixedpoint', 'Missing completed checked proof')
    require(result['complete'] is True and result['result'] == launch['result'], 'Result/launch mismatch')
    verdict = result['result']
    require(verdict['status'] == 'ok' and verdict['checked'] is True and verdict['phase'] == 'compile' and type(verdict['exitCode']) is int and verdict['exitCode'] == 0, 'Not a successful checked emission')
    require(request == result['request'] == launch['request'], 'Request records differ')
    require(request['input'] == plan['source'] and request['mode'] == 'library', 'Wrong source or emission mode')
    resources = ['--stack-size=4096', '--max-old-space-size=12288']
    require(launch['resourceArgs'] == result['node']['args'] == resources and launch['timeoutMs'] == 3600000, 'Resource configuration differs')
    require(result['affinity'] == 'Cpus_allowed_list:\t2', 'Worker did not use CPU2')
    require(result['imageManifest'] == launch['imageManifest'], 'Cross-image manifest mismatch')
    archive.verify(launch['imageManifest'])
    manifest_file = Path(launch['imageManifest']['file'])
    image_root = manifest_file.parent
    archive.preserve(manifest_file)
    manifest = archive.read(manifest_file)
    require(manifest['complete'] is True and manifest['proofStatus'] == 'fixedpoint', 'Incomplete image manifest')
    require(digest(archive.capture(image_root / 'image.mjs')) == selected['imageSha256'], 'Wrong selected image')
    artifact_names = [a['relative'] for a in manifest['artifacts']]
    require(len(set(artifact_names)) == len(artifact_names) and 'image.mjs' in artifact_names, 'Invalid image artifact inventory')
    for artifact in manifest['artifacts']:
        relative = Path(artifact['relative'])
        require(not relative.is_absolute() and '..' not in relative.parts, 'Unsafe image artifact path')
        file = image_root / relative
        require(file.resolve().is_relative_to(image_root.resolve()), 'Image artifact escaped directory')
        archive.verify({'file': str(file), 'sha256': artifact['sha256'], 'bytes': artifact['bytes']})
    archive.verify(manifest['base'])
    require(len(m['inputs']) == 7, 'Unexpected measurement input inventory')
    tool, node, launcher, image_identity, image, source, h = m['inputs']
    require(image_identity['file'] == str(manifest_file) and image_identity['sha256'] == launch['imageManifest']['sha256'], 'Measurement selected different manifest')
    require(image['file'] == str(image_root / 'image.mjs') and image['sha256'] == selected['imageSha256'], 'Measurement selected different image')
    require(source['file'] == plan['source'] and source['sha256'] == plan['sourceSha256'] and h['file'] == plan['expectedH'] and h['sha256'] == plan['expectedHSha256'], 'Measurement source/H identity mismatch')
    require(Path(tool['file']).name == 'private-full-source.py', 'Unexpected measurement tool')
    require(launcher['file'] == launch['launcher']['file'] and launcher['sha256'] == launch['launcher']['sha256'], 'Outer/inner launcher mismatch')
    for record in [launch['node'], result['node']]:
        require(record['file'] == node['file'] and record['sha256'] == node['sha256'], 'Node executable mismatch')
        archive.verify(record)
    require(launch['node']['version'] == result['node']['version'], 'Node version mismatch')
    expected_command = ['taskset', '-c', '2', node['file'], '--stack-size=4096', '--max-old-space-size=3072', launcher['file'], str(image_root), plan['source'], 'library', str(directory / 'request'), '--cpu=2', '--heap-mb=12288', '--timeout-ms=3600000']
    require(m['command'] == expected_command, 'Outer command mismatch')
    require(launch['command'] == 'taskset' and launch['args'] == ['-c', '2', node['file'], *resources, str(image_root / 'runner/worker.mjs'), str(image_root), str(directory / 'request/request.json'), str(directory / 'request')], 'Worker command mismatch')
    require(Path(m['launch']['file']).absolute() == directory / 'request/launch.json', 'Measurement launch path mismatch')
    archive.verify(m['launch'])
    for record in m['inputs'] + launch['launcherTools'] + result['inputs']['files']:
        archive.verify(record)
    require(launch['launcher'] == launch['launcherTools'][0], 'Launcher inventory mismatch')
    archive.preserve(tool['file'])
    for record in launch['launcherTools']:
        archive.preserve(record['file'])
    caches = []
    for record in result['inputs']['files']:
        if '/cache/base-' in record['file']:
            archive.preserve(record['file'])
            cache = archive.read(record['file'])
            require(cache['version'] == 2 and cache['validatedBy'] == 'check_book' and cache['compilerSha256'] == selected['imageSha256'] and cache['baseSha256'] == manifest['base']['sha256'] and cache['sourcePath'] == manifest['base']['file'], 'Base cache lineage mismatch')
            caches.append({'identity': record, 'compilerSha256': cache['compilerSha256'], 'baseSha256': cache['baseSha256'], 'bookSha256': cache['bookSha256'], 'generated': cache['generated']})
    require(len(caches) == 1, 'Expected one preexisting validated Base cache read')
    for resolution in result['inputs']['resolutions']:
        archive.resolution(resolution)
    for missing in result['inputs']['missing']:
        archive.absent(missing)
    emitted = directory / 'request/generated.mjs'
    pending = directory / 'request/generated.mjs.pending'
    require(launch['emitted']['file'] == m['emitted']['file'] == str(emitted) and result['emitted']['file'] == str(pending), 'Emitted path mismatch')
    require(launch['emitted']['published'] is True and archive.capture(emitted) == expected, 'Published bytes differ from proven H')
    require(all(x['sha256'] == plan['expectedHSha256'] and x['bytes'] == len(expected) for x in [m['emitted'], launch['emitted'], result['emitted']]), 'Emitted identity mismatch')
    request_ms = finite(m['requestMs'], 'requestMs', True)
    wall_ms = finite(m['wallMs'], 'wallMs', True)
    require(request_ms == launch['requestMs'] == result['requestMs'], 'Request timing mismatch')
    require(m['launchWallMs'] == launch['wallMs'] and request_ms <= finite(launch['wallMs'], 'launch.wallMs', True) <= wall_ms, 'Inconsistent timing boundaries')
    finite(m['maxRssKiB'], 'maxRssKiB', True)
    finite(m['userSeconds'], 'userSeconds')
    finite(m['systemSeconds'], 'systemSeconds')
    require(isinstance(m['startedUtc'], str) and isinstance(m['finishedUtc'], str), 'Invalid observation dates')
    require(datetime.datetime.fromisoformat(m['startedUtc'].replace('Z', '+00:00')) <= datetime.datetime.fromisoformat(m['finishedUtc'].replace('Z', '+00:00')), 'Reversed observation dates')
    return dict(passed=True, imageSha256=selected['imageSha256'], wallMs=wall_ms, requestMs=request_ms, maxRssKiB=m['maxRssKiB'], userSeconds=m['userSeconds'], systemSeconds=m['systemSeconds'], startedUtc=m['startedUtc'], finishedUtc=m['finishedUtc'], baseCache=caches[0])


def main(plan_file, output):
    plan_file, output = Path(plan_file).absolute(), Path(output).absolute()
    output.mkdir()  # Existing output refusal is an ordinary invocation error.
    archive = Archive(output)
    rows, errors, plan = [], [], None
    def error(scope, exception):
        errors.append({'run': scope, 'error': str(exception) or type(exception).__name__, 'type': type(exception).__name__})
    preflight = True
    expected = None
    try:
        archive.preserve(Path(__file__))
        archive.preserve(plan_file)
        plan = archive.read(plan_file)
        require(isinstance(plan, dict) and plan['version'] == 1, 'Malformed plan')
        require(isinstance(plan['runs'], list) and len(plan['runs']) > 0, 'Plan has no run inventory')
        expected = archive.capture(plan['expectedH'])
        require(digest(expected) == plan['expectedHSha256'], 'Expected H drift')
        require(digest(archive.capture(plan['source'])) == plan['sourceSha256'], 'Source drift')
        archive.preserve(plan['expectedH'])
        archive.preserve(plan['source'])
    except Exception as exception:
        preflight = False
        error('plan', exception)
    runs = plan.get('runs', []) if isinstance(plan, dict) else []
    if not isinstance(runs, list):
        runs = []
    ids, directories, variant_images = set(), set(), {}
    for index, selected in enumerate(runs):
        row = {'index': index, 'id': selected.get('id', 'invalid-' + str(index)) if isinstance(selected, dict) else 'invalid-' + str(index), 'variant': selected.get('variant') if isinstance(selected, dict) else None, 'passed': False}
        rows.append(row)
        try:
            require(isinstance(selected, dict), 'Malformed run entry')
            require(isinstance(selected['id'], str) and bool(selected['id']) and selected['id'] not in ids, 'Invalid or duplicate run ID')
            ids.add(selected['id'])
            require(isinstance(selected['variant'], str) and bool(selected['variant']), 'Invalid variant')
            directory = str(Path(selected['directory']).resolve())
            require(directory not in directories, 'Duplicate observation directory')
            directories.add(directory)
            require(selected['variant'] not in variant_images or variant_images[selected['variant']] == selected['imageSha256'], 'Variant changed image identity')
            variant_images[selected['variant']] = selected['imageSha256']
            # Archive missing/failed attempts even if another global input failed.
            observed = audit_row(selected, plan, archive, expected)
            require(preflight, 'Global plan/source preflight failed')
            row.update(observed)
        except Exception as exception:
            row['error'] = str(exception) or type(exception).__name__
            error(row['id'], exception)
    try:
        archive.finish()
    except Exception as exception:
        error('final-input-audit', exception)
    complete = bool(rows) and not errors and all(row['passed'] for row in rows)
    report = {'kind': 'phase4-private-full-source-comparison', 'complete': complete, 'plan': plan, 'rows': rows, 'errors': errors, 'inputsRechecked': not any(x['run'] == 'final-input-audit' for x in errors), 'scope': 'Every planned observation required. Same source, CPU2, CLI and limits. Fresh processes, preexisting distinct validated Base caches; OS caches not flushed; other cores active.', 'rssScope': 'Linux RUSAGE_CHILDREN ru_maxrss: maximum child high-water RSS reported through waited descendants, not simultaneous aggregate process-tree memory.', 'timingScope': 'Request is host inspect plus consumed-read audit. Outer process wall includes CLI startup/supervision/publication but excludes measurement-wrapper final hashing.'}
    if complete:
        report['summary'] = {}
        for variant in dict.fromkeys(row['variant'] for row in rows):
            group = [row for row in rows if row['variant'] == variant]
            report['summary'][variant] = {'samples': len(group), **{key: {'median': statistics.median(row[key] for row in group), 'min': min(row[key] for row in group), 'max': max(row[key] for row in group)} for key in ['wallMs', 'requestMs', 'maxRssKiB']}}
    else:
        report['timingsWithheld'] = 'At least one planned observation or provenance check is incomplete or failed. No successful-only summary.'
    (output / 'comparison.json').write_text(json.dumps(report, indent=2) + '\n')
    (output / 'manifest.json').write_text(json.dumps({'version': 1, 'files': list(archive.entries.values()), 'consumedInputsBeforeAfter': list(archive.files.values()), 'resolutionsRechecked': archive.resolutions, 'missingRechecked': sorted(archive.missing)}, indent=2) + '\n')
    print(json.dumps({'complete': complete, 'runs': len(rows), 'errors': errors, 'archiveBytes': sum(p.stat().st_size for p in output.rglob('*') if p.is_file())}))
    return 0 if complete else 1


if __name__ == '__main__':
    if len(sys.argv) != 3:
        raise SystemExit('Usage: private-full-report.py PLAN_JSON NEW_ARCHIVE_DIRECTORY')
    raise SystemExit(main(sys.argv[1], sys.argv[2]))

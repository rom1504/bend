#!/usr/bin/env python3
"""Root-run serial native89 CLI controls; no compiler logic or shared-file edits."""
import argparse
import json
import shutil
import subprocess
import sys
from pathlib import Path

from admission import (ROOT, HERE, MANIFEST, LEGACY_IMAGE, DEFAULT_CACHE,
                       authenticate, pin, verify, require, read)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('out', type=Path, help='Fresh directory below selfhost/build/phase89')
    args = parser.parse_args()
    out = args.out.resolve()
    require(out.is_relative_to(ROOT/'selfhost/build/phase89'), 'Output outside Phase89 evidence')
    out.mkdir(parents=True, exist_ok=False)
    image = Path(read(MANIFEST)['producer']['image']['file'])
    auth = authenticate(image, DEFAULT_CACHE)
    gates = read(auth['qualification']['gates']['file'])
    report = dict(kind='phase89-native-launcher-controls', complete=False, passed=False,
                  method=pin(__file__), authentication=auth, rows=[],
                  scope='Four exact-C public CLI emissions, five public refusals and one private admission-input refusal. No generated-program execution or native B2.')

    def save():
        (out/'report.json').write_text(json.dumps(report, indent=2)+'\n')

    def execute(name, command, target, expected_error=None, expected_output=None,
                existing=None, public=True):
        require(authenticate(image, DEFAULT_CACHE) == auth, 'Admission changed before control')
        row = dict(name=name, command=list(map(str, command)), publicCli=public, passed=False)
        report['rows'].append(row); save()
        result = subprocess.run(row['command'], capture_output=True, text=True)
        (out/(name+'.stdout')).write_text(result.stdout)
        (out/(name+'.stderr')).write_text(result.stderr)
        row.update(returncode=result.returncode, expectedError=expected_error)
        if target.exists():
            row['output'] = pin(target)
        if public:
            logs = [line.removeprefix('Native request evidence: ') for line in result.stderr.splitlines()
                    if line.startswith('Native request evidence: ')]
            require(len(logs) == 1, 'Missing public launcher evidence: '+name)
            original = Path(logs[0]).resolve()
            require(original.is_relative_to(ROOT/'selfhost/build/native/requests'), 'Wrong request log path')
            archived = out/(name+'-request')
            shutil.copytree(original, archived)
            records = []
            for path in sorted(original.rglob('*')):
                if path.is_file():
                    before = pin(path); copied = pin(archived/path.relative_to(original))
                    require(all(before[k] == copied[k] for k in ('sha256', 'bytes')), 'Evidence copy changed')
                    records.append(dict(original=before, copy=copied))
            row['requestEvidence'] = dict(original=str(original), copied=str(archived), files=records)
            request = read(archived/'report.json')
            row['requestComplete'] = request['complete']
            process_path = archived/'guard/process.json'
            if process_path.exists():
                process = read(process_path)
                require(not process.get('stoppedFor'), 'Resource/deadline stop is not a semantic refusal')
                row['nativeProcess'] = process
        if expected_error is not None:
            passed = result.returncode != 0 and expected_error in result.stderr
            passed = passed and (pin(target) == existing if existing is not None else not target.exists())
            if public:
                passed = passed and not row['requestComplete']
        else:
            passed = result.returncode == 0 and target.exists() and row.get('requestComplete')
            passed = passed and all(row['output'][k] == expected_output[k] for k in ('sha256', 'bytes'))
            row['oracle'] = expected_output; row['exactC'] = bool(passed)
        row['bindingsUnchanged'] = authenticate(image, DEFAULT_CACHE) == auth
        row['passed'] = bool(passed and row['bindingsUnchanged']); save()
        require(row['passed'], 'Unexpected launcher result: '+name)

    def command(source, target, selected_image=image, extra=()):
        return [sys.executable, '-B', HERE/'native.py', source, '--image', selected_image,
                '-o', target, '--seconds', '90', *extra]

    try:
        save()
        for case, source_path in [('small', ROOT/'selfhost/tools/performance/phase77/fixtures/small.bend'),
                                  ('file-io', HERE/'native-b2/file-io.bend')]:
            oracle_row = next(r for r in gates['rows'] if r['name'] == 'live-'+case)
            source_pin = pin(source_path)
            require(all(source_pin[k] == oracle_row['source'][k] for k in ('sha256', 'bytes')), 'Wrong fixture bytes')
            for mode in ('cached', 'live'):
                name = mode+'-'+case; target = out/(name+'.c')
                execute(name, command(source_path, target, extra=['--live'] if mode == 'live' else []),
                        target, expected_output=oracle_row['oracle'])
                require(pin(source_path) == source_pin, 'Source changed')
        small = ROOT/'selfhost/tools/performance/phase77/fixtures/small.bend'
        target = out/'old-image.c'
        execute('old-image', command(small, target, LEGACY_IMAGE), target,
                expected_error='Unqualified Phase89 image/source/C/build tuple')
        alternate = out/'alternate-cache-receipt.json'
        alternate.write_bytes(DEFAULT_CACHE.read_bytes())
        target = out/'alternate-cache.c'
        execute('alternate-cache', command(small, target, extra=['--cache-receipt', alternate]), target,
                expected_error='Unqualified cache receipt path')
        for name, text, error in [
            ('extra-import', 'import Base\nimport ./other.bend as Other\n\ndef main() -> U32:\n  42\n', 'rejects additional import'),
            ('unaudited-effect', 'import Base\n\ndef main() -> IO(Unit):\n  IO.sleep(1)\n', 'rejects foreign path')]:
            source = out/(name+'.bend'); source.write_text(text); target = out/(name+'.c')
            execute(name, command(source, target), target, expected_error=error)
        target = out/'cached-small.c'; before = pin(target)
        execute('existing-output', command(small, target), target,
                expected_error='Output already exists', existing=before)
        altered = out/'altered-manifest.json'; altered.write_bytes(MANIFEST.read_bytes()+b'\n')
        code = ('import sys; from pathlib import Path; sys.path.insert(0,sys.argv[1]); '
                'import admission; admission.MANIFEST=Path(sys.argv[2]); '
                'admission.authenticate(Path(sys.argv[3]),admission.DEFAULT_CACHE)')
        execute('changed-manifest', [sys.executable, '-B', '-c', code, HERE, altered, image],
                out/'changed-manifest.c', expected_error='Untrusted Phase89 admission manifest', public=False)
        report.update(complete=True, passed=True)
    except Exception as error:
        report['error'] = str(error)
        raise
    finally:
        save()
    print(json.dumps(dict(complete=True, passed=True, controls=len(report['rows']), report=pin(out/'report.json'))))


if __name__ == '__main__':
    main()

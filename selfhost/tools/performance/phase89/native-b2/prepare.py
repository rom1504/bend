#!/usr/bin/env python3
"""Offline fixtures and expected observations; never runs a compiler/program."""
import argparse
import hashlib
import json
import shutil
from pathlib import Path

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[4]


def pin(path):
    path = Path(path).resolve()
    data = path.read_bytes()
    return dict(file=str(path), sha256=hashlib.sha256(data).hexdigest(), bytes=len(data))


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('out', type=Path)
    args = parser.parse_args()
    out = args.out.resolve()
    out.mkdir(parents=True, exist_ok=False)
    sources = {}
    for name in ['argv', 'file-io']:
        target = out / (name + '.bend')
        shutil.copyfile(HERE / (name + '.bend'), target)
        sources[name] = pin(target)
    decoder = ROOT / 'selfhost/tools/performance/phase88/base/fixtures03/controls.bend'
    sources['decoder'] = pin(decoder)
    assert sources['decoder']['sha256'] == '3c1d8ebea28c3e7ebe952a144c064f40824fc322bcb0d663e0e6f9dcb42fa619'
    payloads = {'empty': b'', 'unicode': 'line 1\nλ🙂\n'.encode(), 'ascii': b'abc\n'}
    inputs = {}
    for name, data in payloads.items():
        file = out / (name + '.txt')
        file.write_bytes(data)
        inputs[name] = pin(file)
    missing = out / 'deliberately-missing.txt'
    assert not missing.exists()
    # A nonempty sparse file tests the exact16MiB bound without allocating payload.
    sparse = out / 'oversize-sparse.txt'
    with sparse.open('xb') as stream:
        stream.truncate(16777217)
    manifest = dict(
        kind='phase89-native-b2-falsifiers', version=1, preparation=pin(__file__),
        methods=[pin(HERE / name) for name in ['argv.bend', 'file-io.bend', 'file-io.derivation.json', 'emit-b2.mjs', 'verify-run.py']],
        sources=sources, inputs=inputs,
        sparse=pin(sparse),
        emission={'argv': 'any', 'decoder': 'conservative', 'file-io': 'conservative'},
        decoderExpected=dict(stdout='True{}\n', stderr='', exitCode=0, assertions=16),
        argvCases=[[], ['alpha'], ['alpha', 'two words', 'λ🙂']],
        argvConventions=dict(upstream='Executable path, then payload', retained='Payload only'),
        fileCases=[
            dict(id=name, mode='copy', input=inputs[name]['file'], output=str(out / (name + '.copy')),
                 expect=dict(exitCode=0, stdout='copy-ok\n', stderr='file-control-ok\n',
                             outputSha256=inputs[name]['sha256'])) for name in ['empty', 'unicode']
        ] + [
            dict(id='missing', mode='copy', input=str(missing), output=str(out / 'missing.copy'),
                 expect=dict(exitCode=2, stdout='', stderrContains='No such file or directory', outputAbsent=True)),
            dict(id='early-eof', mode='early-eof', input=inputs['ascii']['file'], output=str(out / 'unused-eof.copy'),
                 expect=dict(exitCode=1, stdout='', stderr='input was not completely read\n', outputAbsent=True)),
            dict(id='oversize', mode='copy', input=str(sparse), output=str(out / 'unused-oversize.copy'),
                 expect=dict(exitCode=1, stdout='', stderr='input exceeds 16 MiB\n', outputAbsent=True)),
        ],
        limitation='Offline preparation only. New Bend controls have not been checked. Missing-file message assumes LC_ALL=C on Linux. '
                   'File control expects one program argument: natural upstream argv0 or explicit retained-runtime sentinel.')
    (out / 'manifest.json').write_text(json.dumps(manifest, indent=2, ensure_ascii=False) + '\n')
    print(json.dumps(dict(manifest=str(out / 'manifest.json'), sources=sources)))


if __name__ == '__main__':
    main()

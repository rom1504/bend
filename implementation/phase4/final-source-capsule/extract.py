#!/usr/bin/env python3
"""Verify a historical compiler capsule; optionally extract into a NEW directory."""
import argparse
import gzip
import hashlib
import io
import json
from pathlib import Path


def digest(data):
    return hashlib.sha256(data).hexdigest()


def require(ok, message):
    if not ok:
        raise ValueError(message)


def checked_bytes(root, item, compressed=False):
    data = (root / item['archive']).read_bytes()
    require(digest(data) == item['archiveSha256'], 'Archive hash mismatch: ' + item['archive'])
    size = item['bytes']
    require(type(size) is int and 0 <= size <= 64 * 1024 * 1024, 'Invalid uncompressed size')
    if compressed:
        with gzip.GzipFile(fileobj=io.BytesIO(data)) as stream:
            data = stream.read(size + 1)
    require(len(data) == size and digest(data) == item['sha256'], 'Restored identity mismatch: ' + item['archive'])
    return data


def verify(root):
    manifest_bytes = (root / 'manifest.json').read_bytes()
    manifest = json.loads(manifest_bytes)
    require(manifest['kind'] == 'phase4-final-source-capsule' and manifest['version'] == 1, 'Unknown capsule format')
    require(manifest['inputsUnchanged'] is True, 'Capsule creation did not verify inputs')
    artifacts = manifest['artifacts']
    require({x['name'] for x in artifacts} == {'b1.mjs', 'h.mjs', 'compiler.bend', 'runtime.mjs'} and len(artifacts) == 4, 'Unexpected artifact inventory')
    restored = {}
    for item in artifacts:
        require(Path(item['archive']).name == item['archive'], 'Unsafe archive name')
        restored[item['name']] = checked_bytes(root, item, compressed=True)
    proof = json.loads(checked_bytes(root, manifest['proof']))
    checked = json.loads(checked_bytes(root, manifest['checkedBuild'], compressed=True))
    require(proof['complete'] is True and len(proof['stages']) == 2, 'Incomplete historical proof')
    stages = proof['stages']
    require(all(x['code'] == 0 and x.get('signal') is None and x['inputsVerified'] is True for x in stages), 'Unsuccessful historical stage')
    require(stages[0]['outputSha256'] == stages[1]['compilerSha256'] == stages[1]['outputSha256'] == digest(restored['h.mjs']), 'Historical H identity mismatch')
    require(proof['initialCompiler']['sha256'] == stages[0]['compilerSha256'] == digest(restored['b1.mjs']), 'Historical B1 identity mismatch')
    require(proof['sourceSha256'] == digest(restored['compiler.bend']) and proof['runtimeSha256'] == digest(restored['runtime.mjs']), 'Historical source/runtime mismatch')
    require(checked['kind'] == 'phase4-checked-overlay' and checked['complete'] is True and checked['inputsUnchanged'] is True and checked['requestedRootsExist'] is True, 'Unchecked historical B1')
    require(checked['api']['sha256'] == digest(restored['b1.mjs']) and checked['source']['sha256'] == digest(restored['compiler.bend']), 'Checked build identity mismatch')
    return manifest, digest(manifest_bytes), restored


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('output', nargs='?', help='new output directory; its parent must exist')
    parser.add_argument('--verify-only', action='store_true')
    args = parser.parse_args()
    if args.verify_only == bool(args.output):
        parser.error('choose either --verify-only or NEW_OUTPUT_DIRECTORY')
    root = Path(__file__).resolve().parent
    manifest, manifest_sha, restored = verify(root)
    record = {'kind': 'historical-capsule-extraction', 'complete': True, 'capsuleVersion': manifest['version'], 'manifestSha256': manifest_sha, 'newBootstrap': False, 'artifacts': []}
    if args.output:
        output = Path(args.output).absolute()
        # Exclusive directory creation refuses existing files, directories and symlinks.
        output.mkdir()
        for name, data in restored.items():
            target = output / name
            with target.open('xb') as stream:
                stream.write(data)
            require(target.read_bytes() == data, 'Extracted file drift: ' + name)
            record['artifacts'].append({'file': str(target), 'bytes': len(data), 'sha256': digest(data)})
        (output / 'extraction-record.json').write_text(json.dumps(record, indent=2) + '\n')
    else:
        record['artifacts'] = [{'name': name, 'bytes': len(data), 'sha256': digest(data)} for name, data in restored.items()]
    print(json.dumps(record, indent=2))


if __name__ == '__main__':
    main()

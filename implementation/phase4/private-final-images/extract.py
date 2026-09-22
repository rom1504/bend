#!/usr/bin/env python3
"""Verify and restore exact historical private images into a NEW directory."""
import argparse
import gzip
import hashlib
import io
import json
from pathlib import Path, PurePosixPath


def sha(data):
    return hashlib.sha256(data).hexdigest()


def need(ok, message):
    if not ok:
        raise ValueError(message)


def safe_relative(value):
    need(isinstance(value, str) and value != '' and '\\' not in value, 'Invalid artifact path')
    parts = PurePosixPath(value)
    need(not parts.is_absolute() and '..' not in parts.parts and str(parts) == value, 'Unsafe artifact path')
    return value


def verify(root):
    raw_manifest = (root / 'manifest.json').read_bytes()
    catalog = json.loads(raw_manifest)
    need(catalog['kind'] == 'phase4-private-image-capsule' and catalog['version'] == 1, 'Unknown capsule format')
    need(catalog['inputsUnchanged'] is True, 'Creation inputs were not verified')
    objects = {}
    for key, record in catalog['objects'].items():
        need(len(key) == 64 and all(x in '0123456789abcdef' for x in key), 'Invalid object digest')
        archive = record['archive']
        allowed = archive == 'objects/' + key + '.gz' or archive in ['../final-source-capsule/' + x + '.gz' for x in ['b1.mjs', 'h.mjs', 'compiler.bend', 'runtime.mjs']]
        need(allowed, 'Unexpected object archive path')
        compressed = (root / archive).read_bytes()
        need(sha(compressed) == record['archiveSha256'] and len(compressed) == record['archiveBytes'], 'Compressed object drift: ' + key)
        size = record['bytes']
        need(type(size) is int and 0 <= size <= 64 * 1024 * 1024, 'Invalid object size')
        with gzip.GzipFile(fileobj=io.BytesIO(compressed)) as stream:
            data = stream.read(size + 1)
        need(len(data) == size and sha(data) == key, 'Restored object drift: ' + key)
        objects[key] = data
    need(set(catalog['images']) == {'scope-fixed', 'profile-combined'}, 'Unexpected image inventory')
    restored = {}
    for name, entry in catalog['images'].items():
        files = entry['files']
        need('manifest.json' in files, 'Missing historical manifest')
        data = {safe_relative(relative): objects[key] for relative, key in files.items()}
        manifest = json.loads(data['manifest.json'])
        need(sha(data['manifest.json']) == entry['manifestSha256'], 'Historical manifest mismatch')
        need(manifest['kind'] == 'bend-private-compiler-image' and manifest['version'] == 1 and manifest['complete'] is True and manifest['proofStatus'] == 'fixedpoint', 'Incomplete historical image')
        artifacts = manifest['artifacts']
        need(len({x['relative'] for x in artifacts}) == len(artifacts), 'Duplicate historical artifact')
        need(set(data) == {'manifest.json', *[x['relative'] for x in artifacts]}, 'Historical inventory mismatch')
        for artifact in artifacts:
            payload = data[safe_relative(artifact['relative'])]
            need(sha(payload) == artifact['sha256'] and len(payload) == artifact['bytes'], 'Historical artifact mismatch: ' + artifact['relative'])
        need(files['image.mjs'] == entry['imageSha256'], 'Selected compiler image mismatch')
        profile = manifest.get('optimizationProfile', 'default')
        need(profile == entry['optimizationProfile'] == ('default' if name == 'scope-fixed' else 'phase4-boolean-stable'), 'Profile mismatch')
        restored[name] = data
    return catalog, sha(raw_manifest), restored


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('output', nargs='?', help='NEW directory, with an existing parent')
    parser.add_argument('--verify-only', action='store_true')
    args = parser.parse_args()
    if args.verify_only == bool(args.output):
        parser.error('choose --verify-only or NEW_OUTPUT_DIRECTORY')
    catalog, digest, restored = verify(Path(__file__).resolve().parent)
    record = {'kind': 'historical-private-image-restoration', 'complete': True, 'newBootstrap': False, 'newPrivateBuild': False, 'catalogSha256': digest, 'images': {}}
    if args.output:
        output = Path(args.output).absolute()
        output.mkdir()
        for name, files in restored.items():
            for relative, data in files.items():
                file = output / name / relative
                file.parent.mkdir(parents=True, exist_ok=True)
                with file.open('xb') as stream:
                    stream.write(data)
                need(file.read_bytes() == data, 'Extraction drift: ' + str(file))
            record['images'][name] = {'directory': str(output / name), 'manifestSha256': sha(files['manifest.json']), 'imageSha256': sha(files['image.mjs']), 'filesVerified': len(files)}
        (output / 'extraction-record.json').write_text(json.dumps(record, indent=2) + '\n')
    else:
        record['images'] = {name: {'manifestSha256': sha(files['manifest.json']), 'imageSha256': sha(files['image.mjs']), 'filesVerified': len(files)} for name, files in restored.items()}
    print(json.dumps(record, indent=2))


if __name__ == '__main__':
    main()

#!/usr/bin/env python3
"""Write minimal native89 capsule selection from actual authentication dependencies.

No extraction, deletion, compiler or generated-program execution occurs.
Shared dependencies are tracked repository files plus the Phase88 restoration chain.
"""
import argparse
import json
from pathlib import Path

from admission import (ROOT, HERE, MANIFEST, ASSETS, LEGACY_IMAGE, DEFAULT_CACHE,
                       authenticate, authenticate_build, pin, verify, require, read)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('output', type=Path, help='New nativeAssets JSON to bind in evidence03 receipt')
    args = parser.parse_args()
    image = Path(read(MANIFEST)['producer']['image']['file'])
    current = authenticate(image, DEFAULT_CACHE)
    legacy = authenticate_build(LEGACY_IMAGE, DEFAULT_CACHE)
    records = {}

    def remember(record):
        value = verify(record)
        require(Path(value['file']).is_relative_to(ROOT), 'Dependency outside canonical repository')
        previous = records.setdefault(value['file'], value)
        require(previous == value, 'Conflicting dependency identities')

    def walk(value):
        if isinstance(value, dict):
            if 'sha256' in value and 'bytes' in value and ('file' in value or 'path' in value):
                remember(value)
            else:
                for child in value.values():
                    walk(child)
        elif isinstance(value, list):
            for child in value:
                walk(child)

    walk(current); walk(legacy)
    for auth in (current, legacy):
        # authenticate reads this guard, but does not require historical mutable
        # production inputs or the build-time Clang executable at launch time.
        remember(read(auth['build']['file'])['guard'])
    for path in [MANIFEST, ASSETS, Path(current['runtime']['file']).parent/'receipt.json',
                 HERE.parent/'programs/support.py']:
        remember(pin(path))
    own, shared = [], []
    for record in sorted(records.values(), key=lambda p: p['file']):
        path = Path(record['file']); relative = str(path.relative_to(ROOT))
        is_own = (path.is_relative_to(ROOT/'selfhost/build/phase89') or path.is_relative_to(HERE))
        (own if is_own else shared).append(dict(record, file=relative))
    require(own and str(image.relative_to(ROOT)) in {p['file'] for p in own}, 'Missing native image')
    for record in records.values():
        verify(record)
    require(authenticate(image, DEFAULT_CACHE) == current
            and authenticate_build(LEGACY_IMAGE, DEFAULT_CACHE) == legacy, 'Dependencies changed')
    selection = dict(kind='phase89-qualified-native-assets', complete=True, canonicalRoot=str(ROOT),
        executable=str(image.relative_to(ROOT)), files=[p['file'] for p in own], identities=own,
        sharedDependencies=shared, method=pin(__file__), admission=pin(MANIFEST),
        scope='Only actual native89 authentication/launch dependencies. Shared dependencies are tracked repository files plus preserved Phase88 capsule assets; historical mutable acquisition inputs are excluded.')
    with args.output.open('x') as stream:
        json.dump(selection, stream, indent=2); stream.write('\n')
    print(json.dumps(dict(nativeAssets=pin(args.output), selectedFiles=len(own),
                         sharedFiles=len(shared), selectedBytes=sum(p['bytes'] for p in own), targetJobsRun=0)))


if __name__ == '__main__':
    main()

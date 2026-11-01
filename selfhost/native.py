#!/usr/bin/env python3
"""Run the qualified public native CLI selected by the current release manifest."""
import hashlib
import json
import os
from pathlib import Path
import sys


def main():
    root = Path(__file__).resolve().parent.parent
    selector = root / 'selfhost/manifests/current.json'
    current = json.loads(selector.read_text())
    if (current.get('kind') != 'bend-current-bindings' or current.get('version') != 1
            or current.get('complete') is not True
            or current.get('gateStatus', {}).get('qualified') is not True):
        raise ValueError('No complete qualified current compiler release')
    item = current['components']['nativeCli']
    if (item['host'], item['stage'], item['protocol']) != ('native', 'N1', 'native-public-cli-v1'):
        raise ValueError('Current native CLI protocol differs')
    row = item['image']
    relative = Path(row['file'])
    if relative.is_absolute() or '..' in relative.parts or not row['file'].startswith('selfhost/dist/'):
        raise ValueError('Native CLI image must be inside the installed dist tree')
    image = root / relative
    if image.resolve(strict=True) != image or not os.access(image, os.X_OK):
        raise ValueError('Native CLI image is not a canonical executable')
    if current['files'].get(row['file']) != row:
        raise ValueError('Native CLI image is absent from installed inventory')
    digest = hashlib.sha256()
    size = 0
    with image.open('rb') as stream:
        for block in iter(lambda: stream.read(1024 * 1024), b''):
            size += len(block)
            digest.update(block)
    if size != row['bytes'] or digest.hexdigest() != row['sha256']:
        raise ValueError('Native CLI image changed; verify the installed release')
    os.execv(image, [str(image), *sys.argv[1:]])


if __name__ == '__main__':
    try:
        main()
    except (OSError, ValueError, KeyError, TypeError) as error:
        print('bend-native: ' + str(error), file=sys.stderr)
        raise SystemExit(1)

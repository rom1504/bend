#!/usr/bin/env python3
"""Verify/acquire explicitly pinned build assets, without consulting experiment history."""
import argparse
import hashlib
import json
import os
from pathlib import Path
import shutil
import sys
import tempfile

sys.dont_write_bytecode = True
from common import ROOT, pin, require, verify, workspace, write_json


def load_assets(path, root=None):
    root = workspace(root)
    path = Path(path).resolve(strict=True)
    document = json.loads(path.read_text())
    require(document.get('kind') == 'bend-build-assets' and document.get('version') == 1,
            'Versioned operational build asset manifest required')
    require(document.get('complete') is True and isinstance(document.get('assets'), dict),
            'Complete named asset map required')
    require(0 < len(document['assets']) <= 128, 'Asset manifest must be bounded')
    for key, row in document['assets'].items():
        require(isinstance(key, str) and key and isinstance(row, dict), 'Invalid asset name')
        require(isinstance(row.get('file'), str) and isinstance(row.get('bytes'), int)
                and row['bytes'] >= 0 and len(row.get('sha256', '')) == 64,
                'Invalid asset identity: ' + key)
        require(all(c in '0123456789abcdef' for c in row['sha256']), 'Invalid SHA256')
        relative = Path(row['file'])
        require(relative.is_absolute() or '..' not in relative.parts, 'Escaping asset path')
    document['_workspace'] = root
    document['_manifest'] = pin(path)
    return document


def location(document, key):
    require(key in document['assets'], 'Undeclared asset: ' + key)
    path = Path(document['assets'][key]['file'])
    return path if path.is_absolute() else document['_workspace'] / path


def asset(document, key):
    row = document['assets'][key]
    actual = pin(location(document, key))
    require(all(actual[k] == row[k] for k in ('bytes', 'sha256')),
            'Asset identity mismatch: ' + key)
    if row.get('executable'):
        require(os.access(actual['file'], os.X_OK), 'Nonexecutable tool/image: ' + key)
    return actual


def image(document, key, host, stage, target):
    metadata = document.get('images', {}).get(key)
    require(isinstance(metadata, dict), 'Image capability/lineage binding required: ' + key)
    require(metadata.get('host') == host and metadata.get('stage') == stage,
            'Host/stage differ from recorded producer lineage')
    require(target in metadata.get('targets', []), 'Image does not support target: ' + target)
    return asset(document, key), metadata


def runtime_argument_convention(provider):
    """Read the actual image/runtime binding, never the active upstream pin."""
    require(provider is None or isinstance(provider, dict), 'Runtime provider metadata required')
    convention = (provider or {}).get('runtimeArgumentConvention', 'bend-legacy-v1')
    require(convention in ('bend-legacy-v1', 'bend-rts-v1'),
            'Unknown runtime argument convention: ' + str(convention))
    return convention


def runtime_provider(document, key):
    require(key in document['assets'], 'Undeclared runtime provider: ' + str(key))
    row = document['assets'][key]
    policy = document.get('runtimePolicies', {}).get(key, {})
    require(isinstance(policy, dict), 'Invalid runtime provider policy')
    for field in ('runtimeArgumentConvention', 'runtimeABI'):
        label = 'runtime argument conventions' if field == 'runtimeArgumentConvention' else 'runtime ABI declarations'
        require(field not in row or field not in policy or row[field] == policy[field],
                'Conflicting '+label+': ' + key)
    provider = dict(row, **policy)
    runtime_argument_convention(provider)
    runtime_abi(provider)
    return provider


def runtime_abi(provider):
    value = (provider or {}).get('runtimeABI')
    require(value is None or (type(value) is int and 0 < value <= 0xffffffff),
            'Runtime ABI must be an explicit positive integer')
    return value


def native_toolchain(document, target):
    require(target in ('qbe', 'x86'), 'Unsupported native machine target')
    policy = document.get('toolchains', {}).get(target)
    require(isinstance(policy, dict) and policy.get('target') == 'amd64_sysv',
            'Explicit amd64_sysv '+('QBE' if target == 'qbe' else target)+' toolchain policy required')
    require(policy.get('assemblerFlags') == ['-mbranches-within-32B-boundaries']
            and policy.get('linkerFlags') == ['-no-pie']
            and policy.get('libraries') == ['-pthread', '-lm'],
            'Unknown machine policy; qualify a separate adapter for different flags')
    return policy


def runtime_arguments(provider, *, application=False):
    convention = runtime_argument_convention(provider)
    options = ['--threads', '1', '--gpu', 'off']
    if convention == 'bend-rts-v1':
        # --RTS protects every following application token, even literal +RTS.
        return ['+RTS', *options, '-RTS', *(['--RTS'] if application else [])]
    return [*options, *(['--'] if application else [])]


def prepared_base(document, mode, base_key='base', carrier_key='prepared-base'):
    base = asset(document, base_key)
    require(0 < base['bytes'] <= 16777216, 'Base exceeds bounded reader')
    if mode == 'live':
        return base, None, '', [base]
    require(mode == 'cache', 'Unknown preparation mode')
    binding = document.get('preparedBase')
    require(isinstance(binding, dict) and binding.get('base') == base_key
            and binding.get('carrier') == carrier_key, 'Prepared Base binding missing')
    identity = binding['sourceIdentity']
    require(identity['base'] == base['sha256'] and identity['path'] == base['file'],
            'Prepared Base source identity/path differs; use live mode or qualify a new binding')
    require(binding.get('sourceBegin') == identity['begin'] == 1
            and binding.get('sourceEnd') == identity['end'], 'Prepared span binding mismatch')
    original_stamp = 'p88-private-base-text-1:' + hashlib.sha256(json.dumps(
        identity, separators=(',', ':'), ensure_ascii=False).encode()).hexdigest()
    stamp = original_stamp if binding.get('format') == 'p88-private-base-text-1' else (
        'p130-word-pair-v1:' + original_stamp)
    require(binding.get('format') in ('p88-private-base-text-1', 'p130-word-pair-v1')
            and binding.get('stamp') == stamp, 'Prepared routing stamp mismatch')
    carrier = asset(document, carrier_key)
    require(0 < carrier['bytes'] <= 16777216 and isinstance(binding.get('stamp'), str)
            and binding['stamp'], 'Invalid bounded carrier/stamp')
    # This manifest is an explicitly admitted operational binding. The historical
    # producer/cache proof remains separate provenance, never recursively reread.
    return base, carrier, binding['stamp'], [base, carrier]


def acquire(document, bindings, keys=None):
    selected = keys or list(document['assets'])
    unknown = set(bindings) - set(document['assets'])
    require(not unknown, 'Unknown supplied assets: ' + ', '.join(sorted(unknown)))
    copied, retained = [], []
    needed = sum(document['assets'][k]['bytes'] for k in selected
                 if not location(document, k).exists())
    require(shutil.disk_usage(document['_workspace']).free >= needed + 5 * 1024**3,
            'Acquisition requires its full asset bytes plus the 5 GiB reserve')
    for key in selected:
        dest = location(document, key)
        if dest.exists():
            asset(document, key)
            retained.append(key)
            continue
        require(not dest.is_symlink(), 'Dangling asset symlink: ' + str(dest))
        require(key in bindings, 'Missing asset; supply --from ' + key + '=ABS_FILE')
        source = pin(bindings[key])
        expected = document['assets'][key]
        require(all(source[k] == expected[k] for k in ('bytes', 'sha256')),
                'Supplied asset does not match manifest: ' + key)
        require(dest.absolute() == dest.resolve() and
                dest.is_relative_to(document['_workspace'] / 'selfhost/.assets'),
                'Only selfhost/.assets destinations may be acquired; external pins must already exist')
        dest.parent.mkdir(parents=True, exist_ok=True)
        with tempfile.NamedTemporaryFile(dir=dest.parent) as temp:
            with Path(source['file']).open('rb') as stream:
                shutil.copyfileobj(stream, temp, 1024 * 1024)
            temp.flush()
            os.fchmod(temp.fileno(), 0o755 if expected.get('executable') else 0o644)
            got = pin(temp.name)
            require(all(got[k] == expected[k] for k in ('bytes', 'sha256')), 'Copy mismatch')
            os.link(temp.name, dest)  # Atomic no-clobber publication.
        verify(source)
        asset(document, key)
        copied.append(key)
    return dict(kind='bend-build-assets-acquisition', version=1, complete=True,
                manifest=document['_manifest'], copied=copied, retained=retained,
                assets={key: asset(document, key) for key in selected}, targetsRun=False)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('operation', choices=['verify', 'acquire'])
    parser.add_argument('--workspace', type=Path)
    parser.add_argument('--manifest', type=Path, required=True)
    parser.add_argument('--key', action='append')
    parser.add_argument('--from', dest='overrides', action='append', default=[])
    parser.add_argument('--bindings', type=Path)
    parser.add_argument('--receipt', type=Path)
    args = parser.parse_args()
    doc = load_assets(args.manifest, args.workspace)
    if args.operation == 'acquire':
        supplied = json.loads(args.bindings.read_text()) if args.bindings else {}
        for entry in args.overrides:
            require('=' in entry, '--from requires KEY=PATH')
            key, value = entry.split('=', 1)
            require(key not in supplied, 'Duplicate asset input: ' + key)
            supplied[key] = value
        result = acquire(doc, supplied, args.key)
    else:
        result = dict(complete=True, manifest=doc['_manifest'],
                      assets={key: asset(doc, key) for key in args.key or doc['assets']},
                      targetsRun=False)
    if args.receipt:
        require(not args.receipt.exists(), 'Fresh acquisition receipt required')
        write_json(args.receipt, result)
    print(json.dumps(result))


if __name__ == '__main__':
    main()

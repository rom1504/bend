#!/usr/bin/env python3
"""Public x86 transport: qualified release emission default, explicit .s assembly."""
import argparse
import json
import os
from pathlib import Path
import secrets
import shutil
import subprocess
import sys
import tempfile

sys.dont_write_bytecode = True
import assets
import native
import request
from common import changed_inputs, clean_environment, pin, require, verify

ROOT = Path(__file__).resolve().parents[3]


def options(argv):
    parser = argparse.ArgumentParser(prog='bend --target x86',
        description='Emit .s assembly, or build an ELF with -o or --run using the installed emission default. Existing outputs are refused.')
    parser.add_argument('--target', choices=['x86'], default='x86')
    parser.add_argument('source', type=Path)
    destination = parser.add_mutually_exclusive_group(required=True)
    destination.add_argument('-o', '--output', type=Path)
    destination.add_argument('--run', action='store_true')
    parser.add_argument('--live', action='store_true', help='Prepare Base live instead of the authenticated cache')
    split = argv.index('--') if '--' in argv else len(argv)
    args = parser.parse_args(argv[:split])
    args.program_args = argv[split+1:] if split < len(argv) else []
    require(args.run or not args.program_args, 'Arguments after -- require --run')
    return args


def installed(row, current, root):
    relative = Path(row['file'])
    require(not relative.is_absolute() and '..' not in relative.parts
            and row['file'].startswith('selfhost/dist/') and current['files'].get(row['file']) == row,
            'Provider/image is absent from the installed inventory')
    file = root/relative
    require(file.resolve(strict=True) == file, 'Installed artifact symlink refused')
    return pin(verify(dict(row, file=str(file))))


def selected(root):
    selector = pin(root/'selfhost/manifests/current.json')
    current = json.loads(verify(selector).read_text())
    require(current.get('kind') == 'bend-current-bindings' and current.get('version') == 1
            and current.get('complete') is True and current.get('gateStatus', {}).get('qualified') is True,
            'No qualified current compiler release')
    item = current.get('components', {}).get('x86')
    require(isinstance(item, dict) and (item['host'], item['stage'], item['protocol']) ==
            ('native', 'N2', 'native-x86-source-v1') and item.get('capabilities') == ['x86'],
            'No qualified installed x86 N2 component')
    default_emission = item.get('defaultEmission', 'assembly')
    require(default_emission in ('assembly', 'object'), 'Unsupported installed x86 emission default')
    image = installed(item['image'], current, root)
    require(os.access(image['file'], os.X_OK), 'Installed x86 compiler is not executable')
    runtime = installed(current['providers']['qbeRuntime'], current, root)
    base = installed(current['providers']['base'], current, root)
    document = assets.load_assets(root/'selfhost/manifests/assets-native.json', root)
    require(document['upstream'] == current['upstream'], 'Current selector/asset upstream differs')
    declared_image, metadata = assets.image(document, 'x86-n2', 'native', 'N2', 'x86')
    require(declared_image == image and metadata.get('protocol') == item['protocol']
            and all(metadata['sourceIdentity'][k] == item['sourceIdentity'][k] for k in ('bytes','sha256'))
            and metadata.get('defaultEmission', 'assembly') == default_emission
            and assets.runtime_argument_convention(metadata) == assets.runtime_argument_convention(item),
            'Installed x86 image/source/protocol binding differs from operational assets')
    provider = assets.runtime_provider(document, 'qbe-runtime')
    require(assets.asset(document, 'qbe-runtime') == runtime and assets.runtime_abi(provider) == 11102
            and all(metadata['linkedRuntime'][k] == runtime[k] for k in ('bytes','sha256'))
            and metadata.get('linkedRuntimeABI') == 11102
            and assets.runtime_argument_convention(provider) == assets.runtime_argument_convention(metadata),
            'Installed x86 runtime binding differs')
    declared_base = assets.asset(document, 'base')
    require(all(declared_base[k] == base[k] for k in ('bytes','sha256')), 'Installed Base differs from operational Base')
    assets.native_toolchain(document, 'x86')
    require('BENDRTS' not in os.environ, 'Public x86 requires ambient BENDRTS to be unset')
    return document, provider, [selector, document['_manifest'], image, runtime, base, declared_base]


def output_path(value):
    output = Path(os.path.abspath(value))
    require(output.parent.resolve(strict=True) == output.parent, 'Output parent symlink refused')
    require(not output.exists() and not output.is_symlink(), 'Output already exists; refusing to overwrite an input or artifact')
    return output


def publish(product, output, executable):
    """Copy beside output, then atomically link without clobbering any path."""
    output = output_path(output)
    directory = os.open(output.parent, os.O_RDONLY | os.O_DIRECTORY | os.O_NOFOLLOW)
    temporary = '.bend-x86-'+secrets.token_hex(16)
    created = False
    try:
        fd = os.open(temporary, os.O_WRONLY | os.O_CREAT | os.O_EXCL | os.O_NOFOLLOW, 0o600, dir_fd=directory)
        created = True
        with os.fdopen(fd, 'wb') as stream, verify(product).open('rb') as source:
            shutil.copyfileobj(source, stream, 65536)
            stream.flush(); os.fchmod(stream.fileno(), 0o755 if executable else 0o644); os.fsync(stream.fileno())
        # Both names are resolved against the held directory, including on a
        # racing destination creation. Existing files and symlinks cause EEXIST.
        os.link(temporary, output.name, src_dir_fd=directory, dst_dir_fd=directory, follow_symlinks=False)
    finally:
        if created: os.unlink(temporary, dir_fd=directory)
        os.close(directory)


def diagnostics(report):
    rows = [report.get('compilerStderr'), report.get('process', {}).get('stderr'),
            *[job.get('stderr') for job in report.get('jobs', [])]]
    seen, printed = set(), False
    for row in rows:
        if row and row['bytes'] and row['file'] not in seen:
            sys.stderr.buffer.write(verify(row).read_bytes()); seen.add(row['file']); printed = True
    if not printed and not report.get('complete'):
        print(report.get('error', 'x86 compilation failed'), file=sys.stderr)


def main(argv=None, root=ROOT):
    args = options(list(sys.argv[1:] if argv is None else argv))
    clean_environment()
    source = pin(args.source)
    output = output_path(args.output) if args.output else None
    assembly = output is not None and output.suffix == '.s'
    document, provider, inputs = selected(root)
    # A pre-object qualified release has no defaultEmission field. Keeping its
    # assembly route also makes restoring the old selector/assets a rollback.
    emission = 'assembly' if assembly else document['images']['x86-n2'].get('defaultEmission', 'assembly')
    inputs += [source, pin(__file__), pin(root/'selfhost/native.py'), pin(root/'selfhost/cli.mjs')]
    build_root = Path(os.path.abspath(os.environ.get('BEND_PUBLIC_BUILD_ROOT', root/'selfhost/build')))
    require(build_root.is_relative_to(root/'selfhost/build'), 'Public build directory must remain inside selfhost/build')
    require(build_root.resolve() == build_root, 'Public build directory symlink refused')
    build_root.mkdir(parents=True, exist_ok=True)
    with tempfile.TemporaryDirectory(prefix='public-x86-', dir=build_root) as folder:
        work = Path(folder)
        options_ = argparse.Namespace(workspace=root, assets=Path(document['_manifest']['file']),
            image_key='x86-n2', image=None, image_receipt=None, source=Path(source['file']), host='native',
            stage='N2', target='x86', emit=emission,
            mode='live' if args.live else 'cache', base_key='base',
            carrier_key='prepared-base', engine_key='bun', out=work/'build', seconds=600,
            expected=None, plan=False, ir=None, runtime_key='qbe-runtime', runtime=None,
            runtime_argument_convention=None, runtime_abi=None, retain_ir=False, expected_stdout=None,
            output_stage=None, output_protocol='native-x86-source-v1')
        report = request.execute(options_) if assembly else native.build(options_)
        diagnostics(report)
        if not report.get('complete'): return 1
        require(not changed_inputs(inputs + report['inputs']), 'Public compiler inputs changed during compilation')
        product = report['product'] if assembly else report['binary']
        if output:
            publish(product, output, not assembly)
            return 0
        command = [str(verify(product)), *assets.runtime_arguments(provider, application=True), *args.program_args]
        result = subprocess.run(command, check=False)
        return result.returncode if result.returncode >= 0 else 128-result.returncode


if __name__ == '__main__':
    try: raise SystemExit(main())
    except (OSError, ValueError, KeyError, TypeError) as error:
        print('bend-x86: '+str(error), file=sys.stderr); raise SystemExit(1)

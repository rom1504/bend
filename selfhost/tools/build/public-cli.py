#!/usr/bin/env python3
"""Prepare the public C-emitting CLI from the one canonical Bend source.

Metadata/source transport only. Checking, native acquisition, linking, behavioral
qualification and installation are separate root-supervised operations.
"""
import argparse
import hashlib
import json
from pathlib import Path
import sys

sys.dont_write_bytecode = True
from common import ROOT, fresh_output, pin, require, verify, write_json
import source as assembly


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--manifest', type=Path, default=ROOT / 'selfhost/src/compiler.json')
    parser.add_argument('--source-root', type=Path, default=ROOT / 'selfhost')
    parser.add_argument('--package', type=Path, default=ROOT / 'selfhost/dist/native')
    parser.add_argument('--out', type=Path, required=True)
    args = parser.parse_args()
    # The incumbent package supplies only checked asset bytes/cache identity.
    # It never supplies a frontend or backend declaration to the new compiler.
    package = args.package.resolve(strict=True)
    package_pin = pin(package / 'BUILD.json')
    old = json.loads(Path(package_pin['file']).read_text())
    if old.get('kind') == 'bend-public-cli-package':
        require(old.get('complete') and old.get('protocol') == 'native-public-cli-v1',
                'Complete operational public CLI package required')
        authority_assets = old['assets']
        base_identity = old['baseIdentity']
        cache_stamp = old['cacheStamp']
        cache_identity = authority_assets['base.p88']
    else:
        require(old.get('kind') == 'phase103-native-cli-package-build' and old['native']['complete'],
                'Explicit incumbent CLI asset package required')
        authority_assets = old['inputs']['assets']
        base_identity = old['inputs']['baseIdentity']
        cache_stamp = old['inputs']['cache']['stamp']
        cache_identity = old['inputs']['cache']['carrier']
    entry = ROOT / 'selfhost/src/host/native-cli.bend'
    host = ROOT / 'selfhost/src/host/native-os.c'
    template = ROOT / 'selfhost/src/runtime/native/runtime-template.json'
    runtime = ROOT / 'selfhost/src/runtime/native/runtime.c'
    inputs = [pin(__file__), pin(Path(assembly.__file__)), pin(args.manifest),
              package_pin, pin(entry), pin(host), pin(template), pin(runtime)]
    source = assembly.maintained_assemble(args.manifest, args.source_root, 'qbe')
    if isinstance(source, tuple):
        source = source[0]
    manifest = json.loads(args.manifest.read_text())
    inputs += [pin(args.source_root / name) for name in manifest['modules']]
    _, blocks = assembly.blocks(source)
    by_name = assembly.grouped(blocks)
    require(len(by_name.get('main', [])) == 1, 'Exactly one source main required')
    required = ['p86_compile', 'p86_plan', 'p86_prepare', 'p88_cache_prepare', 'p86_effect_read']
    require(all(name in by_name for name in required), 'Missing shared compiler entry')
    main_block = by_name['main'][0]
    entry_bytes = entry.read_bytes()
    _, entry_blocks = assembly.blocks(entry_bytes)
    added = set(assembly.grouped(entry_blocks)) - {'main'}
    require(not (added & set(by_name)), 'Public entry declarations collide with shared compiler')
    config_names = {'cli_base_identity', 'cli_cache_stamp', 'cli_digest'}
    require(not (config_names & (set(by_name) | added)), 'Configuration declaration collision')
    assets = {}
    for name, expected in authority_assets.items():
        file = package / 'assets' / name
        actual = pin(file)
        require(actual['bytes'] == expected['bytes'] and actual['sha256'] == expected['sha256'],
                'Changed packaged asset: ' + name)
        assets[name] = actual
        inputs.append(actual)
    require(set(assets) == {'base.bend', 'base.p88', *('runtime.c.part'+str(i) for i in range(5)),
                           *('effs/'+n+'.c' for n in ['args','print','print_err','now',
                                                    'file_open','file_read','file_size','file_write','file_close'])},
            'Unexpected public CLI asset inventory')
    parts = json.loads(template.read_text())
    require(parts['runtimeSha256'] == pin(runtime)['sha256'] and len(parts['parts']) == 5,
            'Maintained C runtime/template mismatch')
    for index, text in enumerate(parts['parts']):
        require(Path(assets['runtime.c.part'+str(index)]['file']).read_text() == text,
                'Incumbent runtime part differs from maintained template')
    require(pin(base_identity)['sha256'] == assets['base.bend']['sha256'],
            'Prepared Base identity bytes changed')
    inputs.append(pin(base_identity))
    require(cache_identity['sha256'] == assets['base.p88']['sha256']
            and cache_stamp.startswith('p88-private-base-text-1:'), 'Wrong Base carrier contract')
    config = '\n# Immutable public CLI asset identities.\n'
    for name, value in [('cli_base_identity', base_identity), ('cli_cache_stamp', cache_stamp)]:
        config += 'def '+name+'() -> String:\n  '+json.dumps(value)+'\n'
    config += '@unsafe\ndef cli_digest(+name: String) -> String:\n  '
    config += '\n  '.join('kc(String, String.eq(name, '+json.dumps(name)+'), u => '+
                            json.dumps(value['sha256'])+', u => ' for name, value in assets.items())
    config += '""'+')'*len(assets)+'\n'
    old_read = b'source : String <- p86_read_file(directory ++ "/" ++ file)'
    new_read = b'source : String <- cli_read(directory ++ "/" ++ file, cli_digest("effs/" ++ file))'
    effect = by_name['p86_effect_read']
    require(len(effect) == 1 and effect[0]['data'].count(old_read) == 1, 'Effect-read seam differs')
    require(source.count(old_read) == 1, 'Ambiguous effect read')
    modified = source[:main_block['offset']] + source[main_block['offset']+len(main_block['data']):]
    modified = modified.replace(old_read, new_read)
    # Preserve the public option grammar and filesystem/error contract. The old
    # image's version string must not mislabel this newly acquired profile.
    version_old = b'"bend-native phase103 / phase102-lowering04 / native B2"'
    version = 'bend-native / shared-source '+hashlib.sha256(source).hexdigest()[:12]
    require(entry_bytes.count(version_old) == 1, 'Public version seam differs')
    entry_bytes = entry_bytes.replace(version_old, json.dumps(version).encode())
    modified += b'\n' + config.encode() + b'\n' + entry_bytes
    _, final_blocks = assembly.blocks(modified)
    final = assembly.grouped(final_blocks)
    require(all(len(items) == len(by_name.get(name, items)) for name, items in final.items()),
            'Unexpected declaration multiplicity')
    changed = [name for name in by_name if assembly.normalized(by_name[name]) != assembly.normalized(final[name])]
    require(set(changed) == {'main', 'p86_effect_read'}, 'Unexpected compiler body change')
    require(set(final) - set(by_name) == added | config_names, 'Unexpected added declaration')
    out = fresh_output(args.out, ROOT)
    (out / 'compiler.bend').write_bytes(modified)
    (out / 'native-os.c').write_bytes(host.read_bytes())
    for name, row in assets.items():
        destination = out / 'assets' / name
        destination.parent.mkdir(parents=True, exist_ok=True)
        destination.write_bytes(Path(row['file']).read_bytes())
    for row in inputs:
        verify(row)
    receipt = dict(kind='bend-public-cli-source-profile', version=1, complete=True,
                   targetsRun=False, qualified=False, installed=False,
                   canonicalSource=dict(bytes=len(source), sha256=hashlib.sha256(source).hexdigest()),
                   source=pin(out / 'compiler.bend'), inputs=inputs,
                   changedDeclarations=changed, addedDeclarations=sorted(added | config_names),
                   allOtherBodiesIdentical=True, versionText=version,
                   assetAuthority=package_pin, baseIdentity=base_identity, cacheStamp=cache_stamp,
                   assets={name: pin(out / 'assets' / name) for name in assets},
                   foreignProvider=pin(out / 'native-os.c'),
                   scope='One shared compiler, a public IO entry and exact effect-byte authentication. '
                         'No source checking, native build, fixed point, behavioral qualification or installation is inferred.')
    write_json(out / 'report.json', receipt)
    print(json.dumps(dict(complete=True, targetsRun=False, source=receipt['source'], report=str(out / 'report.json'))))


if __name__ == '__main__':
    main()

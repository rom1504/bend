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
import assets as build_assets


EFFECTS = ('args', 'print', 'print_err', 'now', 'file_open', 'file_read',
           'file_size', 'file_write', 'file_close')
ASSET_NAMES = {'base.bend', 'base.p88', *('runtime.c.part'+str(i) for i in range(5)),
               *('effs/'+name+'.c' for name in EFFECTS)}


def same_identity(actual, expected):
    return isinstance(expected, dict) and all(actual.get(k) == expected.get(k)
                                              for k in ('bytes', 'sha256'))


def template_parts(template, runtime):
    require(template['bytes'] <= 16777216 and runtime['bytes'] <= 16777216,
            'Runtime transport exceeds bound')
    artifact = json.loads(verify(template).read_text())
    parts = artifact.get('parts')
    require(artifact.get('version') == 1 and artifact.get('runtimeSha256') == runtime['sha256']
            and isinstance(parts, list) and len(parts) == 5
            and all(isinstance(part, str) for part in parts), 'C runtime/template mismatch')
    encoded = [part.encode('utf8') for part in parts]
    require(b''.join(encoded) == verify(runtime).read_bytes(),
            'Runtime template parts do not round-trip exactly')
    return encoded, build_assets.runtime_argument_convention(artifact)


def fresh_assets(file, root=ROOT):
    """Read explicit prepared data; no compiler or carrier decoding runs here."""
    document = build_assets.load_assets(file, root)
    mapping = document.get('publicCliAssets')
    keys = ('base', 'decimalCarrier', 'carrierReceipt', 'runtime', 'runtimeTemplate',
            'runtimeTemplateReceipt')
    require(isinstance(mapping, dict) and set(mapping) == {*keys, 'effects'},
            'Explicit publicCliAssets mapping required')
    require(isinstance(mapping['effects'], dict) and set(mapping['effects']) == set(EFFECTS),
            'Exactly nine public CLI effects required')
    require(all(isinstance(mapping[k], str) for k in keys)
            and all(isinstance(v, str) for v in mapping['effects'].values()),
            'Public CLI asset keys must be strings')
    rows = {key: build_assets.asset(document, mapping[key]) for key in keys}
    effects = {name: build_assets.asset(document, mapping['effects'][name]) for name in EFFECTS}
    inputs = [document['_manifest'], *rows.values(), *effects.values()]
    require(all(row['bytes'] <= 16777216 for row in [*rows.values(), *effects.values()]),
            'Public CLI asset transport exceeds bound')
    carrier = json.loads(verify(rows['carrierReceipt']).read_text())
    require(carrier.get('kind') == 'bend-prepared-base-carrier' and carrier.get('version') == 1
            and carrier.get('complete') is True
            and same_identity(rows['base'], carrier.get('base'))
            and same_identity(rows['decimalCarrier'], carrier.get('decimalCarrier')),
            'Prepared decimal Base receipt differs from selected assets')
    identity = carrier.get('sourceIdentity', {})
    base_identity = rows['base']['file']
    require(identity.get('format') == 'p88-private-base-text-1'
            and identity.get('path') == base_identity and identity.get('base') == rows['base']['sha256']
            and carrier.get('sourceBegin') == identity.get('begin') == 1
            and isinstance(identity.get('end'), int) and identity['end'] > 1
            and carrier.get('sourceEnd') == identity['end'], 'Prepared Base source identity differs')
    stamp = 'p88-private-base-text-1:' + hashlib.sha256(json.dumps(
        identity, separators=(',', ':'), ensure_ascii=False).encode()).hexdigest()
    require(carrier.get('originalStamp') == stamp, 'Prepared decimal Base stamp differs')
    base_bytes = verify(rows['base']).read_bytes()
    decimal = verify(rows['decimalCarrier']).read_bytes()
    require(base_bytes and decimal.startswith((str(len(stamp))+'\n'+stamp+'\n').encode()),
            'Prepared decimal Base header differs')
    prepared = json.loads(verify(rows['runtimeTemplateReceipt']).read_text())
    require(prepared.get('kind') == 'bend-native-template' and prepared.get('version') == 2
            and prepared.get('complete') is True
            and prepared.get('exactRoundTrip') is True and prepared.get('chunks') == 5
            and same_identity(rows['runtimeTemplate'], prepared.get('artifact'))
            and same_identity(rows['runtime'], prepared.get('runtime')),
            'Runtime template receipt differs from selected assets')
    parts, convention = template_parts(rows['runtimeTemplate'], rows['runtime'])
    require(build_assets.runtime_argument_convention(prepared) == convention
            and build_assets.runtime_argument_convention(
                build_assets.runtime_provider(document, mapping['runtime'])) == convention,
            'Runtime argument convention bindings differ')
    payloads = {'base.bend': base_bytes, 'base.p88': decimal,
                **{'runtime.c.part'+str(i): part for i, part in enumerate(parts)},
                **{'effs/'+name+'.c': verify(row).read_bytes() for name, row in effects.items()}}
    return dict(authority=document['_manifest'], inputs=inputs, payloads=payloads,
                baseIdentity=base_identity, cacheStamp=stamp, runtimeArgumentConvention=convention,
                receipts={key: rows[key] for key in ('carrierReceipt', 'runtimeTemplateReceipt')})


def incumbent_assets(package):
    # The incumbent supplies checked asset bytes, never compiler declarations.
    package = package.resolve(strict=True)
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
    require(set(authority_assets) == ASSET_NAMES, 'Unexpected public CLI asset inventory')
    template = pin(ROOT / 'selfhost/src/runtime/native/runtime-template.json')
    runtime = pin(ROOT / 'selfhost/src/runtime/native/runtime.c')
    inputs = [package_pin, template, runtime]
    payloads = {}
    for name, expected in authority_assets.items():
        actual = pin(package / 'assets' / name)
        require(same_identity(actual, expected), 'Changed packaged asset: ' + name)
        payloads[name] = verify(actual).read_bytes()
        inputs.append(actual)
    parts, convention = template_parts(template, runtime)
    for index, part in enumerate(parts):
        require(payloads['runtime.c.part'+str(index)] == part,
                'Incumbent runtime part differs from maintained template')
    require(pin(base_identity)['sha256'] == authority_assets['base.bend']['sha256'],
            'Prepared Base identity bytes changed')
    inputs.append(pin(base_identity))
    require(cache_identity['sha256'] == authority_assets['base.p88']['sha256']
            and cache_stamp.startswith('p88-private-base-text-1:'), 'Wrong Base carrier contract')
    return dict(authority=package_pin, inputs=inputs, payloads=payloads, baseIdentity=base_identity,
                cacheStamp=cache_stamp, runtimeArgumentConvention=convention, receipts={})


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--manifest', type=Path, default=ROOT / 'selfhost/src/compiler.json')
    parser.add_argument('--source-root', type=Path, default=ROOT / 'selfhost')
    asset_source = parser.add_mutually_exclusive_group()
    asset_source.add_argument('--package', type=Path, default=ROOT / 'selfhost/dist/native')
    asset_source.add_argument('--assets', type=Path,
                              help='Operational asset manifest with explicit publicCliAssets bindings')
    parser.add_argument('--out', type=Path, required=True)
    args = parser.parse_args()
    selected = fresh_assets(args.assets) if args.assets else incumbent_assets(args.package)
    base_identity, cache_stamp = selected['baseIdentity'], selected['cacheStamp']
    payloads = selected['payloads']
    require(set(payloads) == ASSET_NAMES, 'Unexpected public CLI asset inventory')
    assets = {name: dict(bytes=len(data), sha256=hashlib.sha256(data).hexdigest())
              for name, data in payloads.items()}
    entry = ROOT / 'selfhost/src/host/native-cli.bend'
    host = ROOT / 'selfhost/src/host/native-os.c'
    inputs = [pin(__file__), pin(Path(assembly.__file__)), pin(args.manifest),
              pin(build_assets.__file__), pin(entry), pin(host), *selected['inputs']]
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
    for name, data in payloads.items():
        destination = out / 'assets' / name
        destination.parent.mkdir(parents=True, exist_ok=True)
        destination.write_bytes(data)
    for row in inputs:
        verify(row)
    receipt = dict(kind='bend-public-cli-source-profile', version=1, complete=True,
                   targetsRun=False, qualified=False, installed=False,
                   canonicalSource=dict(bytes=len(source), sha256=hashlib.sha256(source).hexdigest()),
                   source=pin(out / 'compiler.bend'), inputs=inputs,
                   changedDeclarations=changed, addedDeclarations=sorted(added | config_names),
                   allOtherBodiesIdentical=True, versionText=version,
                   assetAuthority=selected['authority'], assetReceipts=selected['receipts'],
                   baseIdentity=base_identity, cacheStamp=cache_stamp,
                   runtimeArgumentConvention=selected['runtimeArgumentConvention'],
                   assets={name: pin(out / 'assets' / name) for name in assets},
                   foreignProvider=pin(out / 'native-os.c'),
                   scope='One shared compiler, a public IO entry and exact effect-byte authentication. '
                         'No source checking, native build, fixed point, behavioral qualification or installation is inferred.')
    write_json(out / 'report.json', receipt)
    print(json.dumps(dict(complete=True, targetsRun=False, source=receipt['source'], report=str(out / 'report.json'))))


if __name__ == '__main__':
    main()

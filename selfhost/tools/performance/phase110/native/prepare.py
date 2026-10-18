#!/usr/bin/env python3
"""Prepare the full native selected-library source and a small checked bridge.

No compiler or target execution. Reuse the mature checked frontend unchanged;
apply only exact declaration overrides inside the appended experiment modules.
"""
import argparse
import hashlib
import importlib.util
import json
import re
import subprocess
import sys
from pathlib import Path

sys.dont_write_bytecode = True
HERE = Path(__file__).resolve().parent
PHASE = HERE.parent
ROOT = HERE.parents[4]
OLD = PHASE.parent / 'phase109'
spec = importlib.util.spec_from_file_location('p109_native_prepare', OLD / 'native/prepare.py')
BASE = importlib.util.module_from_spec(spec)
spec.loader.exec_module(BASE)
N = BASE.N
pin, verify = BASE.pin, BASE.verify


def blocks(source):
    starts = list(re.finditer(r'^(?:@unsafe\n)?(def|type|law) ([A-Za-z0-9_.]+)\b', source, re.M))
    result = {}
    kinds = {}
    for index, match in enumerate(starts):
        kind, name = match.group(1), match.group(2)
        if name in result:
            if kind == 'law' and kinds[name] == 'def':
                continue
            if kind != 'def' or kinds[name] != 'law':
                raise ValueError('duplicate declaration ' + name)
        end = starts[index + 1].start() if index + 1 < len(starts) else len(source)
        result[name] = source[match.start():end].split('\n# Module:', 1)[0].strip()
        kinds[name] = kind
    return result


def pinned_relative(record):
    path = ROOT / record['file']
    found = pin(path)
    if found['sha256'] != record['sha256'] or ('bytes' in record and found['bytes'] != record['bytes']):
        raise ValueError('frozen source differs ' + str(path))
    return path


def compose_modules(profile='baseline'):
    if profile not in ['baseline', 'compact-general', 'compact-general-stored', 'compact-general-wrapper']:
        raise ValueError('unknown native runtime profile')
    common = PHASE.parent / 'phase106/ir'
    modules = [common / (name + '.bend') for name in ['model', 'optimize', 'verify', 'json', 'c']]
    modules += [PHASE.parent / 'phase107/backends/qbe.bend']
    modules += [OLD / 'nx' / (name + '.bend') for name in ['library', 'runtime', 'c']]
    modules += [OLD / 'lower' / (name + '.bend') for name in ['model', 'verify', 'lower', 'admission', 'nx', 'policy']]
    modules += [PHASE / 'laws/helper.bend', PHASE / 'lower/policy.bend']
    modules += [PHASE / 'nx' / (name + '.bend') for name in ['model', 'verify', 'c', 'qbe', 'pair', 'json']]
    source = '\n\n'.join(path.read_text() for path in modules)
    # Keep the seven production take declarations exactly; its co-located
    # structural test helpers are omitted from image acquisition deliberately.
    take = PHASE / 'nx/take.bend'
    take_names = ['nx110_take_import', 'nx110_take_stmt', 'nx110_take_fallback', 'nx110_take_body',
                  'nx110_take_functions', 'nx110_take_upgrade', 'nx110_take_pair_library']
    take_blocks = blocks(take.read_text())
    source += '\n\n' + '\n\n'.join(take_blocks[name] for name in take_names)
    modules += [take]
    # Safe import declarations resolve the generic helpers immediately, so
    # general must precede library rather than merely be present later.
    runtime_names = ['lower', 'library'] if profile == 'baseline' else ['lower', 'general', 'library']
    if profile == 'compact-general-wrapper':
        runtime_names.insert(runtime_names.index('library'), 'wrapper-spare')
    runtime_modules = [PHASE / 'runtime-ir' / (name + '.bend') for name in runtime_names]
    call_modules = [PHASE / 'calls' / (name + '.bend') for name in ['model', 'verify', 'lower', 'nx', 'runtime-library']]
    call_modules += [PHASE / 'runtime-ir/namespace.bend']
    source += '\n\n' + '\n\n'.join(path.read_text() for path in runtime_modules + call_modules)
    modules += runtime_modules + call_modules
    call_manifest = PHASE / 'calls/overrides.json'
    call_file = PHASE / 'calls/overrides.bend'
    call_blocks = blocks(call_file.read_text())
    edits = []
    for row in json.loads(call_manifest.read_text())['declarations']:
        old = blocks((ROOT / row['original']).read_text())[row['name']]
        if hashlib.sha256(old.encode()).hexdigest() != row['sha256'] or source.count(old) != 1:
            raise ValueError('call override original mismatch ' + row['name'])
        new = call_blocks[row['name']]
        source = source.replace(old, new, 1)
        edits.append({'name': row['name'], 'oldSha256': row['sha256'], 'newSha256': hashlib.sha256(new.encode()).hexdigest()})
    exact_manifests = [PHASE / 'runtime-ir/overrides.json', PHASE / 'calls/runtime-overrides.json', PHASE / 'runtime-ir/namespace-overrides.json']
    if profile != 'baseline':
        exact_manifests += [PHASE / 'runtime-ir/predicate-overrides.json', PHASE / 'runtime-ir/general-overrides.json']
    if profile == 'compact-general-stored':
        exact_manifests += [PHASE / 'runtime-ir/stored-field-overrides.json']
    if profile == 'compact-general-wrapper':
        exact_manifests += [PHASE / 'runtime-ir/wrapper-spare-overrides.json']
    for manifest in exact_manifests:
        for row in json.loads(manifest.read_text())['replacements']:
            if hashlib.sha256(row['old'].encode()).hexdigest() != row['oldSha256'] or hashlib.sha256(row['new'].encode()).hexdigest() != row['newSha256']:
                raise ValueError('exact override hash mismatch ' + row['name'])
            if (ROOT / row['origin']).read_text().count(row['old']) != 1 or source.count(row['old']) != 1:
                raise ValueError('exact override original mismatch ' + row['name'])
            source = source.replace(row['old'], row['new'], 1)
            edits.append({key: row[key] for key in ['name', 'oldSha256', 'newSha256']})
    blocks(source)
    readable = [manifest.with_suffix('.bend') for manifest in exact_manifests if manifest.with_suffix('.bend').exists()]
    return source, modules, [call_manifest, call_file, *exact_manifests, *readable], edits, take_names


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--out', type=Path, required=True)
    parser.add_argument('--profile', choices=['baseline', 'compact-general', 'compact-general-stored', 'compact-general-wrapper'], default='baseline')
    parser.add_argument('--worker-runtime', type=Path, help='Authenticated emitted-worker runtime; required for stored-field admission')
    args = parser.parse_args()
    out = args.out.resolve()
    admission_kind = {'compact-general-stored': 'stored-field', 'compact-general-wrapper': 'wrapper-spare'}.get(args.profile)
    if admission_kind and args.worker_runtime is None:
        raise ValueError(admission_kind + ' profile requires --worker-runtime for exact composed-source/runtime admission')
    if not out.is_relative_to(ROOT / 'selfhost/build/phase110') or out.exists():
        raise ValueError('fresh source directory under selfhost/build/phase110 required')
    release, binding = N.load(stage='b2', live=False)
    if release['source']['sha256'] != BASE.SELECTED_SOURCE:
        raise ValueError('selected source changed; review mature entry boundary')
    source = verify(release['source']).read_text()
    old = '@unsafe\ndef main() -> IO(U32):\n  do IO<U32>:\n    args : List<&1,String> <- IO.args()\n    p86_cli(args)'
    if source.count(old) != 1:
        raise ValueError('unexpected selected main')
    renamed = old.replace('def main()', 'def p110_previous_main()')
    retained = source.replace(old, renamed, 1)
    if retained.replace(renamed, old, 1) != source:
        raise ValueError('entry rename inverse mismatch')
    for name in ['p86_plan', 'p86_prepare', 'p88_cache_prepare', 'nr_prepare_annotated', 'ns_body']:
        if len(re.findall(r'^def ' + name + r'\(', source, re.M)) != 1:
            raise ValueError('missing mature semantic entry ' + name)
    additions, modules, override_files, edits, take_names = compose_modules(args.profile)
    entry = HERE / 'main.bend'
    base, cache = release['assets']['base'], release['assets']['cache']
    verify(base); verify(cache['carrier'])
    old_manifest = OLD / 'controls/manifest.json'
    original = json.loads(old_manifest.read_text())
    reverse = pinned_relative(next(row for row in original['sourceControls'] if row['name'] == 'nt-reverse'))
    derived_manifest = OLD / 'controls/derived/manifest.json'
    derived_record = json.loads(derived_manifest.read_text())['source']
    derived = derived_manifest.parent / derived_record['file']
    if pin(derived)['sha256'] != derived_record['sha256']:
        raise ValueError('frozen derived source changed')
    selectors_manifest = PHASE / 'controls/manifest.json'
    selectors = pinned_relative(json.loads(selectors_manifest.read_text())['sourceFixture'])
    calls_manifest = PHASE / 'controls/calls/manifest.json'
    append = pinned_relative(json.loads(calls_manifest.read_text())['source'])
    contracts = {'reverse': reverse, 'discard': derived, 'duplicate': derived, 'tail': selectors, 'last': selectors, 'append': append}
    values = [('p110_native_base_path', base['file']), ('p110_native_cache_path', cache['carrier']['file']),
              ('p110_native_cache_stamp', cache['stamp']), ('p110_native_reverse_source', reverse.read_text()),
              ('p110_native_derived_source', derived.read_text()), ('p110_native_selectors_source', selectors.read_text()),
              ('p110_native_append_source', append.read_text())]
    config = '\n\n'.join('def ' + name + '() -> String:\n  ' + json.dumps(value, ensure_ascii=False) for name, value in values)
    config += '\n\ndef p110_native_contract_text(+contract: String) -> String:\n  nx_choose(String,String.eq(contract,"reverse"),u => p110_native_reverse_source(),u =>\n  nx_choose(String,String.eq(contract,"tail") || String.eq(contract,"last"),u => p110_native_selectors_source(),u =>\n  nx_choose(String,String.eq(contract,"append"),u => p110_native_append_source(),u => p110_native_derived_source())))\n'
    appended = additions + '\n\n' + entry.read_text() + '\n\n' + config
    existing = set(blocks(source)) - {'main'}
    collision = existing & set(blocks(appended))
    if collision:
        raise ValueError('declaration collision ' + str(sorted(collision)))
    final = retained + '\n\n' + appended + '\n'
    if len(re.findall(r'^def main\(', final, re.M)) != 1:
        raise ValueError('expected one main')
    runtime = ROOT / 'selfhost/build/phase108/portable-source04/runtime.c'
    if pin(runtime)['sha256'] != BASE.RUNTIME:
        raise ValueError('portable v3 runtime changed')
    parts = [Path(str(runtime) + '.part' + str(i)) for i in range(5)]
    if runtime.read_bytes() != b''.join(path.read_bytes() for path in parts):
        raise ValueError('portable runtime parts differ')
    files = [Path(__file__), OLD / 'native/prepare.py', ROOT / 'selfhost/tools/native/launch.py', entry,
             old_manifest, derived_manifest, selectors_manifest, calls_manifest, reverse, derived, selectors, append,
             runtime, *parts, *modules, *override_files]
    if admission_kind:
        files += [PHASE / 'runtime-ir' / (admission_kind + '-admit.py'), args.worker_runtime.resolve() / 'manifest.json']
        if admission_kind == 'wrapper-spare':
            files += [PHASE / 'runtime-ir/stored-field-admit.py']
    inputs = [*map(pin, files), binding['selection'], binding['admission'], release['source'], release['stages']['b2']['binary'], base, cache['carrier']]
    for item in inputs:
        verify(item)
    out.mkdir(parents=True)
    (out / 'compiler.bend').write_text(final)
    (out / 'config.bend').write_text(config)
    (out / 'modules.bend').write_text(additions + '\n')
    core_names = ['KTerm', 'KDef', 'kc', 'kt', 'atom', 'tg', 'nm', 'ix', 'qt', 'ks', 'terms_at', 'kid', 'dn', 'dk', 'da', 'dv']
    core = blocks(source)
    bridge = out / 'bridge'
    bridge.mkdir()
    (bridge / 'source.bend').write_text('import Base\n\n' + '\n\n'.join(core[name] for name in core_names) + '\n\n' + additions + '\n')
    (bridge / 'manifest.json').write_text(json.dumps({'kind': 'phase110-native-module-bridge', 'complete': True, 'targetsRun': False, 'source': pin(bridge / 'source.bend'), 'inputs': inputs}, indent=2) + '\n')
    source_admission = None
    if admission_kind:
        # This helper only authenticates source/runtime components and writes a
        # receipt. It executes no compiler, proof, generated worker or timing.
        admission_out = out / (admission_kind + '-admission')
        subprocess.run([sys.executable, '-B', str(PHASE / 'runtime-ir' / (admission_kind + '-admit.py')),
                        '--runtime', str(args.worker_runtime.resolve()), '--source', str(out / 'compiler.bend'),
                        '--out', str(admission_out)], check=True, capture_output=True, text=True)
        source_admission = pin(admission_out / 'manifest.json')
        admission = json.loads((admission_out / 'manifest.json').read_text())
        if not admission.get('complete'):
            raise ValueError(admission_kind + ' source/runtime admission incomplete')
        inputs.append(source_admission)
    build_root = ROOT / 'selfhost/build/phase108' / ('p110-' + out.name)
    emit_out, image_out = build_root / 'emit', build_root / 'image'
    portable = emit_out / 'portable.c'
    phase108 = PHASE.parent / 'phase108'
    commands = {
        'emit': [sys.executable, '-B', str(phase108 / 'run.py'), 'emit', str(out / 'compiler.bend'), '--runtime', str(runtime), '--out', str(emit_out), '--seconds', '300'],
        'metadata': [sys.executable, '-B', str(phase108 / 'runtime/bridge-metadata.py'), str(emit_out / 'program.1.c'), str(portable), '--receipt', str(emit_out / 'metadata.json')],
        'build': [sys.executable, '-B', str(phase108 / 'run.py'), 'build', str(portable), '--backend', 'qbe', '--out', str(image_out), '--seconds', '180'],
        'requestExample': [str(image_out / 'program'), '--threads', '1', '--gpu', 'off', '--', 'phase110', str(append), 'append', 'qbe', 'pair-take', 'cache']}
    guard = [sys.executable, '-B', str(ROOT / 'selfhost/tools/performance/phase86/guard.py')]
    guarded = {
        'emit': guard + ['--out', str(build_root / 'emit-guard'), '--seconds', '330', '--rss-mib', '3072', '--available-mib', '8192', '--cpu', '3', '--'] + commands['emit'],
        'build': guard + ['--out', str(build_root / 'build-guard'), '--seconds', '200', '--rss-mib', '4096', '--available-mib', '16384', '--cpu', '3', '--'] + commands['build']}
    report = {'kind': 'phase110-native-selected-library-source', 'version': 1, 'complete': True, 'targetsRun': False,
              'runtimeProfile': args.profile,
              'sourceRuntimeAdmission': source_admission,
              'inputs': inputs, 'selection': binding, 'source': pin(out / 'compiler.bend'), 'config': pin(out / 'config.bend'),
              'modules': list(map(pin, modules)), 'selectedTakeDeclarations': take_names, 'exactOverrides': edits,
              'bridge': pin(bridge / 'source.bend'), 'selectedSource': release['source'],
              'assets': {'base': base, 'cache': cache, 'runtime': pin(runtime), 'parts': list(map(pin, parts))},
              'sourceInverseExact': True, 'contracts': {name: pin(path) for name, path in contracts.items()},
              'policies': ['raw', 'trusted', 'fused', 'tagged', 'specialized', 'pair', 'pair-take', 'runtime-ir-single', 'runtime-ir-atomic'],
              'refusedCombinations': [],
              'commands': commands, 'guardedCommands': guarded,
              'semanticChain': ['mature p86_prepare or p88_cache_prepare', 'mature p86_plan and checked erasure', 'ns_body NativeErasedBody',
                                'closed nxc_lower_library or private nx110rt_lower_library', 'ownership/signature/template verification', 'Nx QBE/C or typed-pair emission'],
              'qualificationLimits': ['Prepared only; no checking, acquisition or target execution performed by this tool.',
                'Frozen source bytes and fixed owning-Term entry contracts remain mandatory.',
                'Ordinary non-self recursion can use the native call stack; arbitrary depth is not qualified.',
                'Image acquisition uses mature C/cproc/QBE; admitted ordinary requests run the Bend frontend and direct-IR emission natively.']}
    for item in inputs:
        verify(item)
    (out / 'manifest.json').write_text(json.dumps(report, indent=2) + '\n')
    print(json.dumps({'complete': True, 'targetsRun': False, 'source': report['source'], 'bridge': report['bridge'], 'manifest': str(out / 'manifest.json')}))


if __name__ == '__main__':
    main()

#!/usr/bin/env python3
"""Prepare a selected-library native Bend image source; execute no compiler.
Reuse mature p86_plan/NR_Request directly and preserve the selected source except
its old main name. This is an authenticated research entry, not general ABI admission.
"""
import argparse
import hashlib
import importlib.util
import json
import re
import sys
from pathlib import Path
sys.dont_write_bytecode = True
HERE = Path(__file__).resolve().parent
PHASE = HERE.parent
ROOT = HERE.parents[4]
SPEC = importlib.util.spec_from_file_location('p109_launch', ROOT / 'selfhost/tools/native/launch.py')
N = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(N)
SELECTED_SOURCE = '63ef222c4c6de73bb54c8e51d3b0a0552979b5791ea98e64d1098051a9cda237'
RUNTIME = 'bffb4258ac362a338b18bb7a6ece1c816a46e6f3112a3cb594d65ae79cdde0dc'


def pin(path):
    return N.pin(path)


def verify(row):
    N.verify(row)
    return Path(row['file'])


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--out', type=Path, required=True)
    args = parser.parse_args()
    out = args.out.resolve()
    if not out.is_relative_to(ROOT / 'selfhost/build/phase109') or out.exists():
        raise ValueError('fresh source directory under selfhost/build/phase109 required')
    release, binding = N.load(stage='b2', live=False)
    if release['source']['sha256'] != SELECTED_SOURCE:
        raise ValueError('selected source changed; review integration boundary')
    source = verify(release['source']).read_text()
    old = '@unsafe\ndef main() -> IO(U32):\n  do IO<U32>:\n    args : List<&1,String> <- IO.args()\n    p86_cli(args)'
    if source.count(old) != 1:
        raise ValueError('unexpected selected main')
    renamed = old.replace('def main()', 'def p109_previous_main()')
    retained = source.replace(old, renamed, 1)
    if retained.replace(renamed, old, 1) != source:
        raise ValueError('entry rename inverse mismatch')
    required = ['p86_plan', 'p86_prepare', 'p88_cache_prepare', 'nr_prepare_annotated', 'ns_body']
    for name in required:
        if len(re.findall(r'^def ' + name + r'\(', source, re.M)) != 1:
            raise ValueError('missing mature semantic entry: ' + name)
    common = ROOT / 'selfhost/tools/performance/phase106/ir'
    modules = [common / (name + '.bend') for name in ['model', 'optimize', 'verify', 'json', 'c']]
    modules += [ROOT / 'selfhost/tools/performance/phase107/backends/qbe.bend']
    modules += [PHASE / 'nx' / (name + '.bend') for name in ['library', 'runtime', 'c']]
    modules += [PHASE / 'lower' / (name + '.bend') for name in ['model', 'verify', 'lower', 'admission', 'nx', 'policy']]
    modules += [HERE / 'main.bend']
    base, cache = release['assets']['base'], release['assets']['cache']
    verify(base); verify(cache['carrier'])
    controls = PHASE / 'controls'
    original = json.loads((controls / 'manifest.json').read_text())
    reverse_record = next(row for row in original['sourceControls'] if row['name'] == 'nt-reverse')
    reverse = ROOT / reverse_record['file']
    if pin(reverse)['sha256'] != reverse_record['sha256']:
        raise ValueError('frozen reverse source changed')
    derived_manifest = controls / 'derived/manifest.json'
    derived_record = json.loads(derived_manifest.read_text())['source']
    derived = derived_manifest.parent / derived_record['file']
    if pin(derived)['sha256'] != derived_record['sha256']:
        raise ValueError('frozen derived source changed')
    config = '\n\n'.join('def ' + name + '() -> String:\n  ' + json.dumps(value, ensure_ascii=False) for name, value in [
        ('p109_native_base_path', base['file']), ('p109_native_cache_path', cache['carrier']['file']),
        ('p109_native_cache_stamp', cache['stamp']), ('p109_native_reverse_source', reverse.read_text()),
        ('p109_native_derived_source', derived.read_text())])
    config += '\n\ndef p109_native_contract_text(+contract: String) -> String:\n  nx_choose(String,String.eq(contract,"reverse"),u => p109_native_reverse_source(),u => p109_native_derived_source())\n'
    additions = '\n\n'.join(path.read_text() for path in modules) + '\n\n' + config
    existing = set(re.findall(r'^(?:def|type|law) ([A-Za-z0-9_.]+)\b', source, re.M)) - {'main'}
    added = set(re.findall(r'^(?:def|type|law) ([A-Za-z0-9_.]+)\b', additions, re.M))
    if existing & added:
        raise ValueError('declaration collision: ' + str(sorted(existing & added)))
    final = retained + '\n\n' + additions + '\n'
    if len(re.findall(r'^def main\(', final, re.M)) != 1:
        raise ValueError('expected one entry')
    runtime = ROOT / 'selfhost/build/phase108/portable-source04/runtime.c'
    if pin(runtime)['sha256'] != RUNTIME:
        raise ValueError('portable v3 runtime changed')
    parts = [Path(str(runtime) + '.part' + str(i)) for i in range(5)]
    if runtime.read_bytes() != b''.join(path.read_bytes() for path in parts):
        raise ValueError('portable runtime parts differ')
    inputs = [pin(__file__), pin(ROOT / 'selfhost/tools/native/launch.py'), binding['selection'], binding['admission'], release['source'],
              release['stages']['b2']['binary'], base, cache['carrier'],
              pin(controls / 'manifest.json'), pin(derived_manifest), pin(reverse), pin(derived),
              pin(runtime), *map(pin, parts), *map(pin, modules)]
    for item in inputs:
        verify(item)
    out.mkdir(parents=True)
    (out / 'compiler.bend').write_text(final)
    (out / 'config.bend').write_text(config)
    # Existing Phase108 driver restricts receipt outputs to its own build tree.
    # Commands remain explicit plans; caller guards and executes serially.
    build_root = ROOT / 'selfhost/build/phase108' / ('p109-' + out.name)
    emit_out = build_root / 'emit'
    portable = emit_out / 'portable.c'
    image_out = build_root / 'image'
    phase108 = ROOT / 'selfhost/tools/performance/phase108'
    commands = {
        'emit': [sys.executable, '-B', str(phase108 / 'run.py'), 'emit', str(out / 'compiler.bend'),
                 '--runtime', str(runtime), '--out', str(emit_out), '--seconds', '300'],
        'metadata': [sys.executable, '-B', str(phase108 / 'runtime/bridge-metadata.py'),
                     str(emit_out / 'program.1.c'), str(portable), '--receipt', str(emit_out / 'metadata.json')],
        'build': [sys.executable, '-B', str(phase108 / 'run.py'), 'build', str(portable),
                  '--backend', 'qbe', '--out', str(image_out), '--seconds', '180'],
        'requestExample': [str(image_out / 'program'), '--threads', '1', '--gpu', 'off', '--',
                           'phase109', str(reverse), 'reverse', 'qbe', 'raw', 'cache']}
    guard = [sys.executable, '-B', str(ROOT / 'selfhost/tools/performance/phase86/guard.py')]
    guarded = {
        'emit': guard + ['--out', str(build_root / 'emit-guard'), '--seconds', '330',
                         '--rss-mib', '3072', '--available-mib', '8192', '--cpu', '3', '--'] + commands['emit'],
        'build': guard + ['--out', str(build_root / 'build-guard'), '--seconds', '200',
                          '--rss-mib', '4096', '--available-mib', '16384', '--cpu', '3', '--'] + commands['build']}
    report = {'kind': 'phase109-native-selected-library-source', 'version': 1, 'complete': True,
              'targetsRun': False, 'inputs': inputs, 'selection': binding, 'source': pin(out / 'compiler.bend'),
              'config': pin(out / 'config.bend'), 'selectedSource': release['source'], 'modules': list(map(pin, modules)),
              'assets': {'base': base, 'cache': cache, 'runtime': pin(runtime), 'parts': list(map(pin, parts))},
              'edits': ['rename only old main to p109_previous_main', 'append owned IR/QBE modules and controlled entry'],
              'sourceInverseExact': True, 'semanticChain': ['p86_prepare or p88_cache_prepare', 'p86_plan',
                'nr_prepare_annotated within p86_plan', 'NR_Request.book NativeErasedBody via ns_body',
                'nxo_lower_policy', 'Nxo ownership verifier', 'Nx opaque-library verifier', 'QBE emission'],
              'contracts': {'reverse': pin(reverse), 'discard': pin(derived), 'duplicate': pin(derived)},
              'commands': commands, 'guardedCommands': guarded,
              'qualificationLimits': ['Prepared only; no checking or machine acquisition performed by this tool.',
                'Only frozen exact source texts and fixed List<String>/String runtime harness contracts are admitted.',
                'The mature frontend/erasure run in Bend; no host AST conversion or scalar frontend substitutes them.',
                'Entry contract is not general type/layout or arbitrary-source ABI validation.',
                'Acquisition uses current native seed and portable C/cproc/QBE; ordinary requests output direct IR.']}
    for item in inputs:
        verify(item)
    (out / 'manifest.json').write_text(json.dumps(report, indent=2) + '\n')
    print(json.dumps({'complete': True, 'targetsRun': False, 'source': report['source'], 'manifest': str(out / 'manifest.json')}))


if __name__ == '__main__':
    main()

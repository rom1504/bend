#!/usr/bin/env python3
"""Gate the exact Phase90 combined native B1, then optionally emit its frozen S as C.

This experimental runner never changes public image/cache admission, compiles
C2 with Clang, executes B2, or labels native-produced C as an upstream build.
"""
import argparse
import json
import re
import subprocess
import sys
from pathlib import Path

sys.dont_write_bytecode = True
HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[4]
PERF = ROOT / 'selfhost/tools/performance'
sys.path.insert(0, str(PERF / 'phase88'))
from native_support import authenticate, native_args, DEFAULT_CACHE, pin, verify

SOURCE_SHA = 'd8a94ce9f16e7576d2f4269c858d008e3da2f40f734cdf0983a3a9835f330791'
ANCESTOR_SHA = '4584cf083d9eddad6f1290c9472c3aac2708099caa716a27f5b53fbcbaee1618'
ASSEMBLY = ROOT / 'selfhost/tools/performance/phase90/observation/fork01/compiler-fork.assembly.json'
ASSEMBLY_SHA = '21a6140df89ff3f0757e78652ad234d37fd220fc774ff705fa289b2d2f3179ff'
ASSETS_SHA = '1894cef9f71d674507aa671cd5c24730ce221b23df7ca0f9675949336671ba2b'
DERIVATION = ROOT / 'selfhost/build/phase89/native-self-source01.bend.derivation.json'
EFFECT_NAMES = ['args.c', 'print.c', 'now.c', 'print_err.c', 'file_open.c',
                'file_read.c', 'file_size.c', 'file_write.c', 'file_close.c']
GUARD = PERF / 'phase86/guard.py'


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('image', type=Path, help='New checked upstream-built B1 for exact combined source d8a94ce9…')
    parser.add_argument('out', type=Path, help='Fresh experiment directory')
    parser.add_argument('--check-only', action='store_true', help='Validate all image, acquisition, effect, cache and oracle bindings without launching any target')
    parser.add_argument('--self-source', action='store_true', help='After all gates, emit only frozen S with a 240s/2GiB/64MiB-file guard')
    args = parser.parse_args()
    out = args.out.resolve()
    out.mkdir(parents=True, exist_ok=False)
    report = dict(kind='phase90-combined-native-b1-gates', complete=False, passed=False,
                  method=pin(__file__), checkOnly=args.check_only, executionPerformed=False, requestedSelfEmission=args.self_source, rows=[],
                  scope='Private exact-source experiment. No public cache/image admission or native B2 build/execution.')
    def save():
        (out / 'report.json').write_text(json.dumps(report, indent=2) + '\n')
    save()
    inputs = {}
    def bound(record):
        value = verify(record)
        previous = inputs.setdefault(value['file'], value)
        assert previous == value, 'Conflicting input identities'
        return value
    def bind_file(path):
        return bound(pin(path))
    def bind_tree(value):
        if isinstance(value, dict):
            if 'sha256' in value and 'bytes' in value and ('file' in value or 'path' in value):bound(value)
            else:
                for child in value.values():bind_tree(child)
        elif isinstance(value, list):
            for child in value:bind_tree(child)
    def unchanged():
        for record in inputs.values():verify(record)

    try:
        assets_pin = bind_file(PERF / 'phase89/native-b2/nine-effects.json')
        assert assets_pin['sha256'] == ASSETS_SHA, 'Wrong nine-effect asset manifest'
        assets = json.loads(Path(assets_pin['file']).read_text())
        assert assets['kind'] == 'phase89-private-native-entry-effect-assets'
        assert [r['name'] for r in assets['admittedEffects']] == EFFECT_NAMES
        effects = [bound(r) for r in assets['admittedEffects']]
        for name, record in zip(EFFECT_NAMES, effects):
            assert Path(record['file']) == ROOT / 'selfhost/src/runtime/native/effs' / name
        for key in ['base', 'runtime', 'runtimeTemplate', 'oldEntry', 'oldDefinition', 'newDefinition']:
            bound(assets[key])
        derivation_pin = bind_file(DERIVATION)
        derivation = json.loads(DERIVATION.read_text())
        assert derivation['kind'] == 'phase89-native-nine-effect-entry-derivative'
        assert derivation['complete'] and derivation['remainingBytesExact']
        assert derivation['replacementCount'] == 1 and derivation['definition'] == 'p86_effect_file'
        assert derivation['admittedEffects'] == assets['admittedEffects']
        bind_tree(derivation['inputs'])
        ancestor_source = bound(derivation['output'])
        assert ancestor_source['sha256'] == ANCESTOR_SHA
        # Exact new source is separate from the ancestor's nine-effect entry proof.
        assembly_pin = bind_file(ASSEMBLY)
        assert assembly_pin['sha256'] == ASSEMBLY_SHA
        assembly = json.loads(ASSEMBLY.read_text())
        assert assembly['kind'] == 'phase90-native-source-assembly' and assembly['complete']
        assert assembly['acquisitionComplete'] is False and assembly['exactOutsideDefinitions']
        assert assembly['inputs'][0]['sha256'] == ANCESTOR_SHA
        bind_tree(assembly['inputs'])
        frozen_source = bound(assembly['output'])
        assert frozen_source['sha256'] == SOURCE_SHA
        original = Path(ancestor_source['file']).read_text()
        changes = assembly['replacements']
        assert len(changes) == 13
        current = original
        for change in changes:
            assert change['old'] and change['new'] and current.count(change['old']) == 1
            current = current.replace(change['old'], change['new'], 1)
        assert current == Path(frozen_source['file']).read_text()
        for change in reversed(changes):
            assert current.count(change['new']) == 1
            current = current.replace(change['new'], change['old'], 1)
        assert current == original, 'Combined source inverse differs from frozen ancestor'
        def entry_definitions(text):
            starts = list(re.finditer(r'(?m)^(?:@unsafe\n)?def (p86_[A-Za-z0-9_]+)\(', text))
            result = {}
            for match in starts:
                end = re.search(r'(?m)^(?:@unsafe|def |law |type |import )', text[match.end():])
                stop = match.end() + end.start() if end else len(text)
                assert match[1] not in result
                result[match[1]] = text[match.start():stop].rstrip()
            assert 'p86_effect_file' in result and 'p86_cli' in result
            return result
        original_entry = entry_definitions(original)
        assert entry_definitions(Path(frozen_source['file']).read_text()) == original_entry
        assert 'p86_effect_file' not in assembly['functions'], 'Entry changed unexpectedly'
        report['ancestorNineEffectProof'] = dict(source=ancestor_source, derivation=derivation_pin)
        report['combinedSourceProof'] = dict(source=frozen_source, derivation=assembly_pin,
            inverseRecoversAncestor=True, entryDefinitionUnchanged=True, unchangedEntryDefinitions=sorted(original_entry))

        # authenticate(..., None) verifies checked upstream acquisition and the
        # build/source command chain. The additional six effects are checked
        # independently above, rather than assumed covered by its scalar API.
        auth = authenticate(args.image, None)
        assert auth['source']['sha256'] == SOURCE_SHA, 'Only frozen nine-effect B1 is admitted'
        checked = json.loads(Path(auth['checked']['file']).read_text())
        assert checked['kind'] == 'phase90-checked-upstream-native-source-derivative'
        assert verify(checked['derivation']) == assembly_pin
        assert checked['inputsUnchanged'] and checked['holes'] == 0
        assert checked['sourceDerivation']['inverseRecoversParent']
        assert checked['sourceDerivation']['forwardSha256'] == SOURCE_SHA
        assert checked['sourceDerivation']['inverseSha256'] == ANCESTOR_SHA
        assert checked['parent']['sha256'] == 'eb6d743504b7636fd6dc7fdf176586ca4380d46ea25965f5c1a2b35a5c1a2743'
        assert verify(checked['historicalParent']['source'])['sha256'] == ANCESTOR_SHA
        assert auth['base'] == verify(assets['base'])
        assert auth['runtime']['sha256'] == assets['runtime']['sha256']
        assert auth['template'] == verify(assets['runtimeTemplate'])
        bind_tree(auth)
        build = json.loads(Path(auth['build']['file']).read_text())
        bound(build['guard'])
        bind_tree(build['inputs'])
        bind_tree(checked['inputs'])
        bound(checked['parent'])
        trusted_cache = authenticate(ROOT / 'selfhost/build/phase88/compiler-native02', DEFAULT_CACHE)
        bind_tree(trusted_cache)
        for path in [__file__, GUARD, PERF / 'programs/support.py', PERF / 'phase88/native_support.py', sys.executable]:
            bind_file(path)
        # Keep independent oracle receipt digests even when historical complete
        # C files have been archived; equality compares the full emitted hash.
        screen_pin = bind_file(ROOT / 'selfhost/build/phase88/screen01/report.json')
        screen = json.loads(Path(screen_pin['file']).read_text())
        assert screen['complete'] and screen['allJobsSucceeded']
        cases = []
        for name in ['small', 'map_closed', 'unicode']:
            source = bound(next(p for p in screen['inputs'] if p.get('file', p.get('path')) == screen['cases'][name]))
            oracle = next(r for r in screen['rows'] if r['role'] == 'b2' and r['case'] == name)['outputs'][0]
            cases.append(dict(name=name, source=source, oracle=oracle, oracleReceipt=screen_pin))
        file_gate_pin = bound(assets['testedFileControl'])
        file_gate = json.loads(Path(file_gate_pin['file']).read_text())
        assert file_gate['kind'] == 'phase89-b2-control-emission' and file_gate['complete']
        assert file_gate['case'] == 'file-io' and file_gate['observation']['status'] == 'ok'
        assert file_gate['policy'] and all(x == 0 for x in file_gate['policy'].values())
        io_source = bound(next(p for p in file_gate['inputs'] if p['file'].endswith('/file-io.bend')))
        io_oracle = bound(file_gate['output'])
        cases.append(dict(name='file-io', source=io_source, oracle=io_oracle, oracleReceipt=file_gate_pin))
        report.update(nativeB1=auth, nineEffects=effects, assets=assets_pin, derivation=assembly_pin,
                      source=frozen_source, oracleCases=cases, cacheOrigin=trusted_cache['cache'],
                      inputs=list(inputs.values()), guards=dict(cpu='3', rssMiB=2048, availableMiB=4096,
                          outputFileLimitBytes=64*1024*1024, normalSeconds=90, selfSeconds=240))
        save()

        if args.check_only:
            unchanged()
            assert authenticate(args.image, None) == auth
            assert authenticate(ROOT / 'selfhost/build/phase88/compiler-native02', DEFAULT_CACHE) == trusted_cache
            report.update(complete=True, passed=True,
                scope='Input validation only; no compiler target, live/cache qualification, self-emission or public admission.')
            save()
            return

        def run(name, source, producer, seconds, oracle=None):
            unchanged()
            prefix = out / name
            directory = out / (name + '-guard')
            command = [sys.executable, '-B', str(GUARD), '--out', str(directory),
                       '--seconds', str(seconds), '--rss-mib', '2048', '--available-mib', '4096',
                       '--cpu', '3', '--', *native_args(producer, source['file'], prefix, 1)]
            row = dict(name=name, source=source, mode='cached' if producer['cache'] else 'live',
                       command=command, guard=str(directory), passed=False)
            report['rows'].append(row); report['current']=name; save()
            report['executionPerformed'] = True; save()
            job = subprocess.run(command, capture_output=True, text=True)
            row.update(guardReturncode=job.returncode, guardStdout=job.stdout, guardStderr=job.stderr)
            process_file = directory / 'process.json'
            process = json.loads(process_file.read_text()) if process_file.exists() else {}
            row['process'] = process
            emitted = Path(str(prefix) + '.1.c')
            if emitted.exists():row['output'] = pin(emitted)
            stderr = (directory / 'stderr.log').read_text() if (directory / 'stderr.log').exists() else ''
            row['requestMs'] = list(map(int, re.findall(r'request=\d+ request_ms=(\d+)', stderr)))
            row['inputBindingsUnchanged'] = False
            unchanged(); row['inputBindingsUnchanged'] = True
            success = job.returncode == 0 and process.get('complete') and process.get('returncode') == 0
            success = success and emitted.exists() and 0 < row['output']['bytes'] <= 64*1024*1024 and len(row['requestMs']) == 1
            if oracle is not None:
                row['oracle'] = oracle
                row['exactC'] = bool(emitted.exists() and row['output']['sha256'] == oracle['sha256'] and row['output']['bytes'] == oracle['bytes'])
                success = success and row['exactC']
            row['passed'] = bool(success); save()
            assert success, 'Native emission failed/refused; retained all guard logs and any partial output: ' + name
            return row

        for case in cases:
            run('live-' + case['name'], case['source'], auth, 90, case['oracle'])
        report['liveQualified'] = True; save()
        # Only this exact source/image, after all four live gates, may consume
        # the already authenticated carrier inside this process. Public
        # native_support.CACHED_CONSUMER is deliberately untouched.
        cached = dict(auth, cache=trusted_cache['cache'])
        for case in cases:
            run('cached-' + case['name'], case['source'], cached, 90, case['oracle'])
        report['cacheQualifiedForThisExperiment'] = True; save()
        # Freeze this qualification separately: report.json continues changing
        # during optional self-emission and must not be a hashed parent yet.
        qualification = out / 'gates.json'
        gate_report = dict(report, complete=True, passed=True,
            scope='Eight exact-C live/cache gates for this recorded B1 only; no self-emission or public admission.')
        gate_report.pop('current', None)
        qualification.write_text(json.dumps(gate_report, indent=2) + '\n')
        report['gateQualification'] = bind_file(qualification); save()
        if args.self_source:
            row = run('self-source', frozen_source, cached, 240)
            emission = dict(kind='phase90-native-b1-self-emission', complete=True,
                producer=dict(stage='upstream-built native B1', authentication=auth),
                source=frozen_source, derivation=assembly_pin, ancestorNineEffectProof=report['ancestorNineEffectProof'], base=auth['base'],
                runtime=auth['runtime'], runtimeParts=auth['runtimeParts'], effects=effects,
                cache=trusted_cache['cache'], c=row['output'], guard=row['guard'],
                qualification=pin(qualification), compiled=False, independentlyCompared=False,
                scope='C2 emitted by the recorded native B1 from exact frozen S. No upstream acquisition claim for C2, no Clang build, native B2 execution or fixed point.')
            (out / 'native-emission.json').write_text(json.dumps(emission, indent=2) + '\n')
            report['selfEmission'] = pin(out / 'native-emission.json')
        unchanged()
        assert authenticate(args.image, None) == auth
        assert authenticate(ROOT / 'selfhost/build/phase88/compiler-native02', DEFAULT_CACHE) == trusted_cache
        report.pop('current', None)
        report.update(complete=True, passed=True)
        save()
    except Exception as error:
        report['error'] = str(error)
        report['retainedRefusalOrFailure'] = True
        save()
        raise


if __name__ == '__main__':
    main()

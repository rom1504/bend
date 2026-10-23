"""Bind the checked Phase128 experiment to its native entry; execute no targets."""
import argparse
import hashlib
import importlib.util
import json
from pathlib import Path
import re

ROOT = Path(__file__).resolve().parents[5]
PHASE = ROOT / 'selfhost/tools/performance/phase128'
PARENT = ROOT / 'selfhost/build/phase127/live-bank-source01/compiler.bend'
PARENT_SHA = 'f4eb3c6b8aca8cdfc72c8eb308db83af50c6bee888a93b69415a77aa5101318d'
SOURCE32_SHA = '40c469114c4d1c75dceab456e1979bb5c0278744a02e6dbe4a37e63667740abb'
COMPOSER = ROOT / 'selfhost/tools/performance/phase126/prepare.py'
COMPOSER_SHA = '358fddd4408e263d8e3316f8dbd3efb639331ad50753f520124e06ce983d6207'
OLD_ABI = ROOT / 'selfhost/build/phase126/native32-abi01.json'
OLD_ABI_SHA = 'a464c08f61a59d33f5cb512a25924d89e2e131bb48a76803dbacb9763ac9a7d4'
OLD_RUNTIME = ROOT / 'selfhost/build/phase126/runtime-divmod01/report.json'
OLD_RUNTIME_SHA = '5b5f57ea8d35fc2ad5c03f2bb3f854d0513b2f9d8ea12211505805d544860880'
GUARD = ROOT / 'selfhost/tools/performance/phase118/runtime-scalar-borrow.c'
GUARD_SHA = '85d7f3a6a99f3864bdb7b6fd822d854061c87b59f1d83d9b0fb4650283f29ce3'


def require(ok, message):
    if not ok:
        raise ValueError(message)


def pin(path):
    path = Path(path).resolve()
    data = path.read_bytes()
    return dict(file=str(path), bytes=len(data), sha256=hashlib.sha256(data).hexdigest())


def read(path):
    return json.loads(Path(path).read_text())


def verify(row):
    require(pin(row['file']) == row, 'Changed frozen input: ' + row['file'])
    return Path(row['file'])


def unique(rows):
    result = {}
    for row in rows:
        require(row['file'] not in result or result[row['file']] == row, 'Conflicting input identity')
        result[row['file']] = row
    return list(result.values())


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    for name in ['source-manifest', 'api-report', 'runtime-report', 'out']:
        parser.add_argument('--' + name, type=Path, required=True)
    args = parser.parse_args()
    out = args.out.resolve()
    require(not out.exists() and out.is_relative_to(ROOT / 'selfhost/build/phase128'), 'Fresh Phase128 output required')
    for path, digest in [(PARENT, PARENT_SHA), (COMPOSER, COMPOSER_SHA), (OLD_ABI, OLD_ABI_SHA),
                         (OLD_RUNTIME, OLD_RUNTIME_SHA), (GUARD, GUARD_SHA)]:
        require(pin(path)['sha256'] == digest, 'Changed authority: ' + str(path))
    spec = importlib.util.spec_from_file_location('p128_native_composer', COMPOSER)
    composition = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(composition)
    source, api, runtime = map(read, [args.source_manifest, args.api_report, args.runtime_report])
    require(source.get('complete') and source['parent'] == pin(PARENT), 'Exact Phase127-parent composition required')
    current = verify(source['source'])
    require(current.parent == args.source_manifest.resolve().parent, 'Source must accompany its manifest')
    require(api.get('complete') and api.get('checked') and api.get('status') == 0, 'Checked combined API required')
    verify(api['api'])
    require(source['source'] in api['inputs'], 'Checked API belongs to another source')
    require([str(Path(x).resolve()) for x in api['command'] if x.endswith('.bend')] == [str(current.resolve())], 'API checked another Bend file')
    require('p128raw_emit_admitted' in api['exports'], 'Combined experimental entry must have been checked/exported')

    # Recover ordered module inputs from the existing Phase128 composition format.
    # Reuse its exact declaration composer and check every immutable module copy.
    inputs = unique([pin(__file__), pin(COMPOSER), pin(args.source_manifest), pin(args.api_report),
                     pin(args.runtime_report), *source['inputs'], *api['inputs'], *runtime['inputs']])
    for row in inputs:
        verify(row)
    module_pins = [r for r in source['inputs'] if Path(r['file']).suffix == '.bend'
                   and Path(r['file']).resolve().is_relative_to(PHASE)]
    require(module_pins and len({r['file'] for r in module_pins}) == len(module_pins), 'Unique Phase128 module inventory required')
    for i, row in enumerate(module_pins):
        snapshot = current.parent / ('module%d.bend' % i)
        require(snapshot.read_bytes() == verify(row).read_bytes(), 'Changed module snapshot: ' + str(snapshot))
        inputs.append(pin(snapshot))
    require(len(list(current.parent.glob('module*.bend'))) == len(module_pins), 'Unexpected module snapshot')
    parent_text = PARENT.read_text()
    replay, added, protected = composition.compose(parent_text,
        [Path(r['file']).read_text() for r in module_pins],
        set(source['overrides']), set(source.get('moduleOverrides', [])))
    require(replay.encode() == current.read_bytes(), 'Complete declaration replay differs')
    require(source['added'] == added and source['protectedDeclarations'] == protected, 'Composition inventory differs')

    # Authenticate the Phase127 repair's inverse against the qualified source32.
    parent_receipt = read(PARENT.parent / 'manifest.json')
    require(parent_receipt['source'] == pin(PARENT) and parent_receipt['parent']['sha256'] == SOURCE32_SHA, 'Repair lineage differs')
    for row in parent_receipt['inputs']:
        verify(row)
    transform = parent_receipt['transform']
    require(parent_text.endswith(transform['appended']), 'Repair control suffix differs')
    repaired = parent_text[:-len(transform['appended'])]
    require(repaired.count(transform['new']) == 1, 'Repair replacement is not unique')
    require(repaired.replace(transform['new'], transform['old'], 1).encode() == verify(parent_receipt['parent']).read_bytes(), 'Repair inverse differs')

    before, parent_defs = composition.blocks(replay), composition.blocks(parent_text)
    extra_gates = {'p126bp_complete', 'p118b_verify_functions', 'p114t_verify_done', 'p113d_pass',
                   'p113d_pass_function', 'p113d_passes'}
    for name in set(protected) | extra_gates:
        require(composition.norm(before[name]) == composition.norm(parent_defs[name]), 'Changed original verifier/gate: ' + name)
    require(before['p111_emit_admitted'] == parent_defs['p111_emit_admitted'], 'Entry is not the exact original declaration')
    for name in ['p128raw_emit_admitted', 'p128raw_lowered', 'p128raw_verified', 'p128raw_br_prepare',
                 'p128raw_br_compose', 'p128raw_prepare', 'p128br_scan']:
        require(name in before, 'Required combined request-local path missing: ' + name)

    old_abi, old_runtime = read(OLD_ABI), read(OLD_RUNTIME)
    require(old_abi['source'] == parent_receipt['parent'], 'Inherited runtime contract is not source32')
    require(old_abi['runtime'] == old_runtime['object'] and old_abi['runtimeSource'] == old_runtime['source'], 'Old runtime authority differs')
    require(runtime.get('complete') and runtime.get('status') == 0 and runtime['kind'] == 'phase128-scalar-borrow-additive-runtime', 'Completed scalar-borrow runtime required')
    require(runtime['parent'] == old_runtime['object'] and runtime['extension'] == pin(GUARD), 'Runtime parent/extension differs')
    require(verify(runtime['source']).read_bytes() == verify(old_runtime['source']).read_bytes() + b'\n' + GUARD.read_bytes(), 'Runtime is not the exact additive composition')
    verify(runtime['object'])
    require(runtime['command'] == [old_runtime['command'][0], '-O2', '-std=gnu11', '-ffp-contract=off', '-c', runtime['source']['file'], '-o', runtime['object']['file']], 'Runtime toolchain/flags differ')
    for name in ['runtime.h', 'primitives.h']:
        old = Path(old_runtime['source']['file']).with_name(name)
        new = Path(runtime['source']['file']).with_name(name)
        require(old.read_bytes() == new.read_bytes(), 'Runtime layout/primitive catalogue differs')
        inputs.extend([pin(old), pin(new)])
    for row in old_abi['inputs'] + old_runtime['inputs']:
        verify(row)
    old_defs = composition.blocks(verify(old_abi['source']).read_text())
    inherited = {row['name']: row for row in old_abi['sourceDeclarations']}
    for name, row in inherited.items():
        raw = old_defs[name].encode()
        require(len(raw) == row['bytes'] and hashlib.sha256(raw).hexdigest() == row['sha256'], 'Inherited ABI declaration identity differs')
        require(composition.norm(before[name]) == composition.norm(old_defs[name]), 'Inherited ABI declaration changed: ' + name)
    library_authority = {name for call in old_abi['libraryCalls'] for name in call['authority']}
    for name in library_authority:
        require(composition.norm(before[name]) == composition.norm(old_defs[name]), 'Inherited library-call authority changed: ' + name)
    inherited_symbols = [item['symbol'] for item in old_abi['imports']]
    require(len(set(inherited_symbols)) == len(inherited_symbols)
            and 'p118_rt_borrow_scalar_safe' not in inherited_symbols, 'Runtime import inventory is not additive')
    runtime_names = lambda text: set(re.findall(r'\bp[0-9]+_rt_[A-Za-z0-9_]+\b', text))
    require(runtime_names(replay) == runtime_names(parent_text) | {'p118_rt_borrow_scalar_safe'}, 'Unexpected runtime symbol addition')
    guard_authority = ['p128bs_guard_args', 'p128bs_project_guard', 'p118b_project_call', 'p128bs_functions',
                       'p128bs_eligible', 'p118b_verify_functions', 'p126bp_complete']
    require(all(name in before for name in guard_authority), 'Scalar guard admission declarations missing')

    old = before['p111_emit_admitted']
    require(replay.count(old) == 1, 'Original entry replacement is not unique')
    tail = old[len(old.rstrip('\n')):]
    new = ('@unsafe\ndef p111_emit_admitted(+request: NR_Request, +error: String) -> P111Emission:\n'
           '  p128raw_emit_admitted(request,error)' + tail)
    result = replay.replace(old, new, 1)
    require(result.count(new) == 1 and result.replace(new, old, 1) == replay, 'Entry inverse must recover every input byte')
    final = composition.blocks(result)
    require(set(final) == set(before), 'Entry binding changed declaration inventory')
    require([name for name in before if before[name] != final[name]] == ['p111_emit_admitted'], 'Unexpected declaration byte change')
    for name in (set(protected) | extra_gates) - {'p111_emit_admitted'}:
        require(final[name] == before[name], 'Entry binding changed protected bytes: ' + name)
    inputs = unique([*inputs, pin(PARENT), pin(PARENT.parent / 'manifest.json'), *parent_receipt['inputs'],
                     pin(OLD_ABI), pin(OLD_RUNTIME), pin(GUARD), *old_abi['inputs'], *old_runtime['inputs'],
                     source['source'], api['api'], runtime['source'], runtime['object']])
    for row in inputs:
        verify(row)
    out.mkdir(parents=True)
    (out / 'compiler.bend').write_bytes(result.encode())
    (out / 'prepare.py').write_bytes(Path(__file__).read_bytes())
    declarations = []
    for name in sorted(set(inherited) | set(guard_authority) | library_authority):
        data = final[name].encode()
        declarations.append(dict(name=name, bytes=len(data), sha256=hashlib.sha256(data).hexdigest()))
    imports = [*old_abi['imports'], dict(symbol='p118_rt_borrow_scalar_safe',
        arguments=['Ptr P111State', 'U64 first owned Term', 'U64 second owned Term', 'U32 root count 1..2'],
        result='U64 Boolean', authority=guard_authority, implementation=pin(GUARD),
        contract='Read-only shared-root guard; refuses aliased nontrivial RFC roots and roots without an external reference. No ownership transition or scheduler transition; actual result is not the verifier structural projection.')]
    runtime_contract = dict(kind='phase128-source-bound-runtime-contract-pending-check', complete=False,
        sourceChecked=False, source=pin(out / 'compiler.bend'), runtime=runtime['object'], runtimeSource=runtime['source'],
        inheritedAuthority=pin(OLD_ABI), runtimeReport=pin(args.runtime_report), imports=imports,
        sourceDeclarations=declarations, libraryCalls=old_abi['libraryCalls'],
        scope='Structural source/runtime binding only. The old source32 receipt is inherited authority, not qualification of Phase128. A new checked API of this exact wired source is required before runtime admission/qualification.')
    report = dict(kind='phase128-native-entry-source', complete=True, checked=False, sourceChecked=False,
        targetsRun=False, nativeQualified=False, selected=False, installed=False, source=pin(out / 'compiler.bend'),
        parent=source['source'], sourceManifest=pin(args.source_manifest), checkedParentApi=pin(args.api_report),
        checkedParentExports=api['exports'], runtime=runtime['object'], runtimeReport=pin(args.runtime_report),
        sourceReplay=dict(parent=pin(PARENT), completeByteIdentity=True, modules=module_pins,
                          overrides=source['overrides'], moduleOverrides=source.get('moduleOverrides', [])),
        overrides=['p111_emit_admitted'], added=[], entryTransform=dict(old=old, new=new),
        inverseByteIdentity=True, allOtherBytesUnchanged=True,
        unchangedProtectedDeclarations=sorted((set(protected) | extra_gates) - {'p111_emit_admitted'}),
        runtimeContract=runtime_contract, inputs=inputs,
        requiredNextExports=['p88_cache_prepare', 'p86_prepare', 'p86_plan', 'p111_runtime_admission',
                             'p111_emit_admitted', 'p111_compile_source', 'p128raw_controls', 'p128raw_br_controls'],
        physicalLines=len(result.splitlines()), parentLines=len(replay.splitlines()),
        scope='Exact checked-experiment entry binding only. Output source remains unchecked until a new checked API succeeds. No runtime execution, native build, conformance qualification or installed-selection change.')
    (out / 'manifest.json').write_text(json.dumps(report, indent=2) + '\n')
    print(json.dumps(dict(source=report['source'], manifest=str(out / 'manifest.json'), sourceChecked=False)))


if __name__ == '__main__':
    main()

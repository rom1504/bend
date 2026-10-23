"""Rebind exact layered Phase126 source and one reviewed divmod runtime extension."""
import argparse
import hashlib
import re
from pathlib import Path
import json
import importlib.util

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[4]
spec = importlib.util.spec_from_file_location('p126_layered_contract', HERE/'layered-contract-v5.py')
C = importlib.util.module_from_spec(spec); spec.loader.exec_module(C)
pin, read, verify, blocks, norm = C.pin, C.read, C.verify, C.blocks, C.norm


def runtime_contract(policy, runtime):
    assert runtime == read(verify(policy['runtimeReport'])), 'Unreviewed runtime build'
    old = read(verify(policy['parentRuntimeReport']))
    extension = verify(policy['runtimeExtension']).read_bytes()
    assert runtime['complete'] and runtime['status'] == 0 and runtime['parent'] == old['object']
    assert runtime['extension'] == policy['runtimeExtension']
    assert verify(runtime['source']).read_bytes() == verify(old['source']).read_bytes()+b'\n'+extension
    verify(runtime['object']); verify(old['object']); verify(policy['runtimeBuilder'])
    authority = read(verify(policy['divmodAuthority']))
    assert authority['runtime'] == policy['runtimeExtension'] and authority['header'] == policy['runtimeHeader']
    expected = 'uint64_t p126_rt_nat_divmod(P111State *state, uint64_t a, uint64_t b, uint64_t *out);'
    assert verify(policy['runtimeHeader']).read_text().strip() == expected
    command = runtime['command']
    assert command == [old['command'][0], '-O2', '-std=gnu11', '-ffp-contract=off', '-c',
                       runtime['source']['file'], '-o', runtime['object']['file']], 'Changed runtime toolchain/flags'
    headers = []
    for name in ['runtime.h', 'primitives.h']:
        before = Path(old['source']['file']).with_name(name)
        after = Path(runtime['source']['file']).with_name(name)
        assert before.read_bytes() == after.read_bytes(), 'Changed runtime layout/catalogue'
        headers.extend([pin(before), pin(after)])
    for row in runtime['inputs']+old['inputs']:
        verify(row)
    return old, headers


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    for key in ['source-manifest', 'api-report', 'runtime-report', 'out']:
        parser.add_argument('--'+key, type=Path, required=True)
    args = parser.parse_args(); assert not args.out.exists()
    policy = C.authority()
    old = read(verify(policy['parentAbi']))
    assert old['complete'] and old['kind'] == 'phase125-native-runtime-abi-admission'
    source, api, runtime = map(read, [args.source_manifest, args.api_report, args.runtime_report])
    assert source['complete'] and api['complete'] and api['checked'] and source['source'] in api['inputs']
    assert [str(Path(x).resolve()) for x in api['command'] if x.endswith('.bend')] == [source['source']['file']]
    contract = C.source_contract(Path(source['source']['file']), source)
    previous_runtime, headers = runtime_contract(policy, runtime)
    assert previous_runtime['source'] == old['runtimeSource'] and previous_runtime['object'] == old['runtime']
    previous_text = verify(old['source']).read_text(); current_text = verify(source['source']).read_text()
    previous, current = blocks(previous_text), blocks(current_text)
    rows = {r['name']: r for r in old['sourceDeclarations']}
    assert set(rows) == {n for row in old['imports'] for n in row['authority']}
    declarations = []
    for name, row in rows.items():
        raw = previous[name].encode()
        assert len(raw) == row['bytes'] and hashlib.sha256(raw).hexdigest() == row['sha256']
        assert current[name].encode() == raw, 'Changed prior runtime authority: '+name
        declarations.append(dict(row, byteExact=True))
    preparation = C.load(HERE.parent/'prepare.py', 'p126_base_gates')
    gate_names = (preparation.ENTRY_GATES | set(blocks(preparation.DIRECT_VERIFIER.read_text())) |
                  {n for n in previous if n.startswith('p111v_')}) & set(previous)
    aliases = policy['layers'][0]['aliases']; preserved = []
    for name in sorted(gate_names):
        target = aliases.get(name, name)
        expected = previous[name].replace('def '+name+'(', 'def '+target+'(', 1)
        assert norm(current[target]) == norm(expected), 'Changed original gate: '+name
        if target != name:
            preserved.append(dict(original=name, alias=target, normalizedSha256=hashlib.sha256(norm(expected).encode()).hexdigest()))
    # Exact local projection is inherited through observer26's unchanged source replay.
    # Bind its reviewed definitions again, rather than inferring a C ABI from symbols.
    local_manifest = read(HERE.parent/'local/modules01.json'); local = {}
    for row in local_manifest['modules']:
        path = Path(row['file'])
        if path.name == 'primitives.bend': path = path.with_name('primitives-v02.bend')
        local.update(blocks(path.read_text()))
    local = {n: b for n, b in local.items() if n.startswith('p126l_')}
    for name, body in local.items():
        assert norm(current[name]) == norm(body), 'Changed local projection: '+name
    assert {n for n in current if n.startswith('p126l_')} == set(local)
    runtime_text = Path(runtime['source']['file']).read_text()
    assert 'return f32_rewrap((f32)sqrt(f32_unbox(args[0])));' in runtime_text
    assert 'return v >= 0.0f && v < 4294967296.0f ? (u32)v : 0;' in runtime_text
    added = {n for n in current if n.startswith('p126dp_')}
    divmod_authority = ['p126dp_selected', 'p126dp_value_shape', 'p126dp_code', 'p126dp_import',
                       'p113e_scalar_safe', 'p113e_stmt', 'p126dp_original_scalar_safe', 'p126dp_original_stmt']
    assert set(divmod_authority) <= set(current)
    for name in divmod_authority:
        raw = current[name].encode()
        declarations.append(dict(name=name, bytes=len(raw), sha256=hashlib.sha256(raw).hexdigest(), exactLayerBound=True))
    imports = old['imports']+[dict(symbol='p126_rt_nat_divmod', arguments=['Ptr state', 'U64 Nat dividend',
        'U64 Nat divisor', 'Ptr writable U64[2]'], result='U64 zero status', authority=divmod_authority,
        contract='Full-width quotient/remainder; divisor zero yields (0,dividend). No allocation, ownership or runtime state mutation. The exact import gate checks output capacity/alignment and excludes state buffers.',
        implementation=policy['runtimeExtension'], prototype=policy['runtimeHeader'])]
    runtime_names = lambda text: set(re.findall(r'\bp[0-9]+_rt_[A-Za-z0-9_]+\b', text))
    literal_names = lambda text: set(re.findall(r'\$[A-Za-z][A-Za-z0-9_.]*', text))
    assert runtime_names(current_text) == runtime_names(previous_text) | {'p126_rt_nat_divmod'}
    literals = literal_names(current_text)-literal_names(previous_text)
    assert literals <= {'$sqrt', '$p126.divmod.control', '$product.observe', '$p126scc.', '$p126scc.0'}, 'Unadmitted literal symbol'
    # Non-sqrt additions are exact structural-control or verified SCC private function names, not C imports.
    library = [dict(symbol='sqrt', arguments=['F64'], result='F64', authority=sorted(local),
                    contract='Exact inherited F32→F64→libm sqrt→F32 projection; integer public ABI unchanged.')]
    native = C.load(ROOT/'selfhost/tools/performance/phase125/native/plan.py', 'p126_native_helpers')
    inputs = native.unique([pin(__file__), pin(HERE/'plan-v2.py'), pin(C.__file__), pin(C.AUTHORITY),
        pin(args.source_manifest), pin(args.api_report), pin(args.runtime_report), policy['parentAbi'],
        policy['parentRuntimeReport'], policy['runtimeBuilder'], policy['runtimeExtension'], policy['runtimeHeader'],
        policy['divmodAuthority'], source['source'], api['api'], runtime['source'], runtime['object'],
        *source['inputs'], *api['inputs'], *runtime['inputs'], *old['inputs'], *headers, *contract['snapshots']])
    for row in inputs: verify(row)
    result = dict(kind=old['kind'], complete=True, targetsRun=False, source=source['source'], runtime=runtime['object'],
        runtimeSource=runtime['source'], imports=imports, sourceDeclarations=declarations, libraryCalls=library,
        inputs=inputs, parentAuthority=policy['parentAbi'], transportContract=contract,
        preservedVerifierAliases=preserved, unchangedVerifierDeclarations=sorted(gate_names-set(aliases)),
        runtimeSymbolSpellings=sorted(runtime_names(current_text)), newLiteralSymbols=sorted(literals),
        exactLayerAuthority=pin(C.AUTHORITY),
        scope='Exact closed source replay and checked API; nine prior imports retain their byte-exact authorities, one explicitly reviewed divmod import added. Original verifier preserved directly or by exact dispatch aliases. Exact old runtime prefix plus reviewed suffix, unchanged layout/toolchain. No target execution, native qualification or installation claim.')
    args.out.parent.mkdir(parents=True, exist_ok=True)
    with args.out.open('x') as stream: json.dump(result, stream, indent=2); stream.write('\n')
    print(json.dumps(dict(complete=True, targetsRun=False, imports=len(imports), receipt=pin(args.out))))


if __name__ == '__main__': main()

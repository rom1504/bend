#!/usr/bin/env python3
"""Offline source/runtime binding for the private uniform-ARR emission profile."""
import argparse
import hashlib
import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[5]
HERE = Path(__file__).resolve().parent
RUNTIME_SHA = 'ea10b5d993fed79738817ee14cc52270e4faf5474128cf082b083e3c09cf655a'
OBJECT_SHA = 'c0f6f2ca5b5a58418f326794e97a29cc21a68f32e924ce5974ad4ffccfc9c9f9'
MATURE_SOURCE = ROOT / 'selfhost/build/phase102/projection-cost-source01/compiler.bend'
MATURE_SHA = '63ef222c4c6de73bb54c8e51d3b0a0552979b5791ea98e64d1098051a9cda237'
INVENTORY_SHA = '0ec7316440c6fd0e4769b5ba4215516445809101aea6cfaba55c3cf9344ad0cd'
DECL = re.compile(r'^(?:@unsafe\n)?(def|type|law) ([A-Za-z0-9_.]+)\b', re.M)
MODULES = ['model.bend', 'template.bend', 'transform.bend', 'program.bend', 'entry.bend']


def pin(file):
    file = Path(file).resolve()
    raw = file.read_bytes()
    return dict(file=str(file), bytes=len(raw), sha256=hashlib.sha256(raw).hexdigest())


def code(text):
    return '\n'.join(x.rstrip() for x in text.splitlines()
                     if x.strip() and not x.lstrip().startswith('#'))


def declarations(text):
    hits = list(DECL.finditer(text))
    result = {}
    for i, hit in enumerate(hits):
        key = hit.group(1), hit.group(2)
        if key in result:
            raise ValueError('duplicate declaration: ' + str(key))
        end = hits[i + 1].start() if i + 1 < len(hits) else len(text)
        result[key] = code(text[hit.start():end])
    return result


def expected_declarations():
    result = {}
    inputs = []
    for name in MODULES:
        file = HERE / name
        result.update(declarations(file.read_text()))
        inputs.append(pin(file))
    # Keep the original structural verifier and the entire direct-rendering
    # layer exact. Product overrides are applied in the same declared order.
    for name in ['segment/model.bend', 'segment/verify.bend']:
        file = ROOT / 'selfhost/tools/performance/phase111' / name
        result.update(declarations(file.read_text()))
        inputs.append(pin(file))
    for name in ['model.bend']:
        file = HERE.parent / 'direct' / name
        result.update(declarations(file.read_text()))
        inputs.append(pin(file))
    for name in ['verify.bend', 'emit.bend', 'program.bend', 'products.bend']:
        file = HERE.parent / 'direct-emit' / name
        result.update(declarations(file.read_text()))
        inputs.append(pin(file))
    mature_pin = pin(MATURE_SOURCE)
    if mature_pin['sha256'] != MATURE_SHA:
        raise ValueError('selected mature checked source changed')
    mature = declarations(MATURE_SOURCE.read_text())
    for name in ['ns_scalar', 'ns_array_type', 'ns_generic_array', 'ns_array_pattern',
                 'ns_terms', 'ns_annotated', 'ns_term', 'ns_definitions', 'ns_array_free',
                 'ns_types_free', 'ns_unshared_terms', 'nr_unshared',
                 'p98_tag_eq', 'p88_string_eq']:
        result['def', name] = mature['def', name]
    inputs.append(mature_pin)
    for relative, names in [
        ('selfhost/tools/performance/phase112/static/model.bend', ['p112s_size']),
        ('selfhost/tools/performance/phase113/products/array.bend', ['p113p_array_arity']),
    ]:
        file = ROOT / relative
        source = declarations(file.read_text())
        for name in names:
            result['def', name] = source['def', name]
        inputs.append(pin(file))
    return result, inputs


def buffer_profile(actual, expected, inputs):
    base = HERE.parent / 'products/array.bend'
    original = declarations(base.read_text())['def', 'p113p_array_call']
    if actual.get(('def', 'p113p_array_call')) == original:
        expected['def', 'p113p_array_call'] = original
        inputs.append(pin(base))
        return 'original'
    overlay = HERE.parent / 'direct-opt-products/overrides.bend'
    buffers = HERE.parent / 'direct-opt-products/buffers.bend'
    expected['def', 'p113p_array_call'] = declarations(overlay.read_text())['def', 'p113p_array_call']
    expected.update(declarations(buffers.read_text()))
    inputs.extend([pin(overlay), pin(buffers)])
    return 'hygienic-product-inliner'


def mismatches(actual, expected):
    wrong = [f'{kind} {name}' for (kind, name), body in expected.items()
             if actual.get((kind, name)) != body]
    wrong += [f'extra {kind} {name}' for kind, name in actual
              if name.startswith(('p113a_', 'P113A')) and (kind, name) not in expected]
    return wrong


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--compiler', type=Path, required=True)
    parser.add_argument('--runtime-source', type=Path, required=True)
    parser.add_argument('--runtime-object', type=Path, required=True)
    parser.add_argument('--out', type=Path, required=True)
    args = parser.parse_args()
    if args.out.exists() or not args.out.resolve().is_relative_to(ROOT / 'selfhost/build/phase113'):
        raise ValueError('fresh Phase113 output required')
    runtime, obj, compiler = map(pin, [args.runtime_source, args.runtime_object, args.compiler])
    if runtime['sha256'] != RUNTIME_SHA or obj['sha256'] != OBJECT_SHA:
        raise ValueError('exact runtime-products01 source / runtime-products-build01 object required')
    inventory_file = HERE / 'modules01.json'
    if pin(inventory_file)['sha256'] != INVENTORY_SHA:
        raise ValueError('frozen source inventory changed')
    inventory = json.loads(inventory_file.read_text())
    for row in inventory['modules'] + inventory['dependencies'] + [inventory['controls']]:
        if pin(row['file']) != row:
            raise ValueError('frozen reviewed module changed: ' + row['file'])
    expected, inputs = expected_declarations()
    inputs.append(pin(inventory_file))
    actual = declarations(args.compiler.read_text())
    profile = buffer_profile(actual, expected, inputs)
    wrong = mismatches(actual, expected)
    if wrong:
        raise ValueError('exact final array/certificate/verifier/renderer mismatch: ' + repr(wrong))
    mutants = []
    for name in ['p113a_certificate', 'p113a_enabled', 'p113a_template',
                 'p113a_address', 'p113a_scalar_guard', 'p113a_success',
                 'p113a_verify', 'p113a_registered', 'p113a_heap_min',
                 'p111_emit_admitted', 'p113d_verify', 'ns_definitions',
                 'nr_unshared', 'p113p_array_call']:
        altered = dict(actual)
        original = altered['def', name]
        altered['def', name] = original + '\n  False{}'
        if not mismatches(altered, expected):
            raise AssertionError('mutation accepted: ' + name)
        mutants.append(dict(name=name, rejected=True,
                            declarationSha256=hashlib.sha256(altered['def', name].encode()).hexdigest()))
    altered = dict(actual)
    altered['def', 'p113a_forged_factory'] = 'def p113a_forged_factory() -> Bool:\n  True{}'
    if not mismatches(altered, expected):
        raise AssertionError('extra array declaration accepted')
    mutants.append(dict(name='extra-array-factory', rejected=True))
    args.out.mkdir(parents=True)
    record = dict(kind='phase113-array-fast-source-runtime-admission', complete=True, admitted=True,
                  targetsExecuted=False, compiler=compiler, runtimeSource=runtime, runtimeObject=obj,
                  method=pin(__file__), inputs=inputs, bufferProfile=profile,
                  exactDeclarations=len(expected), mutations=mutants,
                  declarationHashes={kind + ' ' + name: hashlib.sha256(body.encode()).hexdigest()
                                     for (kind, name), body in expected.items()},
                  contract=dict(stateAbi=11101, runtimeProfile=11301, threads=1, gpu='off',
                                uniformArrayWords=64, rawTopByte=6, immediateTopBytes=[0, 1],
                                heapOffset='51413504 + round128(original static_words)',
                                operations=[72, 73, 74, 75],
                                certificate='same checked NR_Request: ns_definitions && nr_unshared',
                                inputGate='original p113d_verify plus private namespace',
                                nativeEntry='p111_emit_admitted -> p113a_lower_request -> verify -> admitted chunks'),
                  limitations=[
                      'Data-only source binding, not a new ownership theorem or native execution.',
                      'Raw reflected P113ACertificate is not an ownership certificate.',
                      'Use conjunctively with checked-source, runtime-layout, product/inliner and native control receipts.',
                      'Runner must bind the exact compiler and runtime object; no alternative runtime/device claim.'])
    (args.out / 'manifest.json').write_text(json.dumps(record, indent=2) + '\n')
    print(json.dumps(dict(admitted=True, compiler=compiler['sha256'], declarations=len(expected),
                          mutations=len(mutants))))


if __name__ == '__main__':
    main()

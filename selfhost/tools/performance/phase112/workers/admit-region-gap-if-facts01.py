#!/usr/bin/env python3
"""Bind one closed pure-gap repeated-fusion frozen-six-rank profile. Executes no target."""
import argparse
import hashlib
import importlib.util
import json
from pathlib import Path
import re
import sys

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[4]
BASE_METHOD_SHA = '8450e9e120574e1dc5a4dca51f4860258516aa1b0c2eef9e6f9313ea98ff93d9'
INVENTORY_SHA = '66e9ae40a4b4fd4770f93e7e6e59eca52193c3fe7099fed027cdfa5923a01dda'
VERIFIER_SHA = 'c2131760ea5e064394368101c12e59ae79142be453da297822ed6904dd3c51c0'
MODEL_SHA = '316c864bf43232de9cf7fa4fe145c3e761e23afa9bf29e498565e3d55814c5a4'
PREFIXES = ('p112t_', 'p112q_', 'p112w_', 'p112e_', 'p112f_', 'p112r_', 'p112c_', 'p112g_', 'p112h_', 'P112PureGap', 'P112MultiCandidate', 'P112Region', 'P112Tail', 'P112Worker', 'P112Fusion')


def checked(path, sha):
    raw = path.read_bytes()
    if hashlib.sha256(raw).hexdigest() != sha:
        raise ValueError('Pinned input changed: ' + str(path))
    return raw


def validate(base, source, expected):
    actual = base.declarations(source)
    wrong = [name for name, body in expected.items() if actual.get(name) != body]
    extras = [name for name in actual if name[1].startswith(PREFIXES) and name not in expected]
    if wrong or extras:
        raise ValueError('Exact conjunctive declaration mismatch: ' + repr(wrong + extras))


def mutate(source, name, before, after):
    pattern = re.compile(r'^(?:@unsafe\n)?(?:def|type|law) ([A-Za-z0-9_.]+)\b', re.M)
    matches = list(pattern.finditer(source))
    selected = [(i, match) for i, match in enumerate(matches) if match.group(1) == name]
    if len(selected) != 1:
        raise ValueError('Missing mutation declaration: ' + name)
    i, match = selected[0]
    end = matches[i + 1].start() if i + 1 < len(matches) else len(source)
    body = source[match.start():end]
    if before not in body:
        raise ValueError('Mutation did not apply: ' + name)
    return source[:match.start()] + body.replace(before, after, 1) + source[end:]


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--runtime-source', type=Path, required=True)
    parser.add_argument('--runtime-object', type=Path, required=True)
    parser.add_argument('--compiler', type=Path, required=True)
    parser.add_argument('--out', type=Path, required=True)
    args = parser.parse_args()
    base_path = HERE / 'admit-failstop.py'
    checked(base_path, BASE_METHOD_SHA)
    sys.dont_write_bytecode = True
    spec = importlib.util.spec_from_file_location('p112_conjunction_base', base_path)
    base = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(base)
    source_pin, object_pin, compiler_pin = map(base.pin, [args.runtime_source, args.runtime_object, args.compiler])
    if source_pin['sha256'] != base.SOURCE_SHA or object_pin['sha256'] != base.OBJECT_SHA:
        raise ValueError('Requires exact selected CPU runtime04 source and object')
    inventory_path = HERE / 'conjunction-region-gap-if01.json'
    inventory = json.loads(checked(inventory_path, INVENTORY_SHA))
    fusion = inventory['fusionInventory']
    checked(ROOT / fusion['file'], fusion['sha256'])
    region = inventory['regionInventory']
    checked(ROOT / region['file'], region['sha256'])
    multi = inventory['multiInventory']
    checked(ROOT / multi['file'], multi['sha256'])
    wide = inventory['wideInventory']
    checked(ROOT / wide['file'], wide['sha256'])
    gap = inventory['gapInventory']
    checked(ROOT / gap['file'], gap['sha256'])
    structured = inventory['structuredGapInventory']
    checked(ROOT / structured['file'], structured['sha256'])
    expected, module_paths = {}, []
    for item in inventory['modules']:
        path = ROOT / item['file']
        raw = checked(path, item['sha256'])
        if len(raw) != item['bytes']:
            raise ValueError('Module byte length mismatch')
        expected.update(base.declarations(raw.decode()))
        module_paths.append(path)
    verifier = ROOT / 'selfhost/tools/performance/phase111/segment/verify.bend'
    model = ROOT / 'selfhost/tools/performance/phase111/segment/model.bend'
    expected.update(base.declarations(checked(verifier, VERIFIER_SHA).decode()))
    expected.update(base.declarations(checked(model, MODEL_SHA).decode()))
    source = args.compiler.read_text()
    validate(base, source, expected)
    changes = [
        ('worker-bound', 'p112w_plan', 'U32.is_le(arity,32)', 'U32.is_le(arity,33)'),
        ('fusion-bound', 'p112f_target', 'U32.is_le(arity,8)', 'U32.is_le(arity,32)'),
        ('failure-admission', 'p112w_scan', 'p112t_failure(body)', 'True{}'),
        ('secondary-pointer', 'p112t_buffer_args', 'String.eq(name,"scratch")', 'String.eq(name,"state")'),
        ('early-scalar-gate', 'p112w_scan_next', 'p112t_scalar_safe(stmt)', 'True{}'),
        ('actual-emission-hook', 'p111q_segment_chunks', 'p112c_segment_chunks', 'p112r_segment_chunks'),
        ('region-arity-bound', 'p112r_plan', 'U32.is_le(arity,8)', 'U32.is_le(arity,9)'),
        ('region-rank-bound', 'p112r_index', ',1,6)', ',1,7)'),
        ('region-frozen-emission', 'p112r_private_chunks', 'p112w_private(segment,ids,plan)', 'p112w_private(segment,ids,p112w_plan(segment,missing()))'),
        ('region-immutable-pass', 'p112r_pass', 'rest,index,old,symbols,rank,', 'rest,index,missing(),symbols,rank,'),
    ]
    changes.extend([
        ('multi-worker-bound', 'p112c_plan', 'U32.is_le(arity,32)', 'U32.is_le(arity,33)'),
        ('multi-candidate-bound', 'p112c_candidate', 'U32.is_le(arity,32)', 'U32.is_le(arity,33)'),
        ('multi-site-budget', 'p112c_try', 'U32.is_lt(site,8)', 'U32.is_lt(site,9)'),
        ('multi-site-freshness', 'p112c_scan_try', 'p112c_scan(fused,index,ready,U32.inc(site))', 'p112c_scan(fused,index,ready,site)'),
        ('multi-branch-freshness', 'p112c_scan_yes', 'p112c_scan(no,index,ready,next)', 'p112c_scan(no,index,ready,0)'),
        ('multi-frozen-emission', 'p112c_private_chunks', 'p112w_private(segment,ids,plan)', 'p112w_private(segment,ids,p112w_plan(segment,missing()))'),
        ('multi-immutable-pass', 'p112c_pass', 'rest,index,old,symbols,rank,', 'rest,index,missing(),symbols,rank,'),
        ('multi-original-hygiene', 'p112c_candidate', 'p112f_clean(body)', 'True{}'),
    ])
    changes.extend([
        ('wide-fused-callee-bound', 'p112c_target', 'U32.is_le(arity,32)', 'U32.is_le(arity,33)'),
        ('wide-capture-bound', 'p112c_frame', 'U32.is_lt(index,32)', 'U32.is_lt(index,33)'),
    ])
    changes.extend([
        ('gap-statement-bound', 'p112g_split', 'U32.is_le(count,32)', 'U32.is_le(count,33)'),
        ('gap-state-protection', 'p112g_name', 'String.eq(name,"state")', 'False{}'),
        ('gap-scalar-only', 'p112g_pure', 'case _: False{}', 'case _: True{}'),
        ('gap-numeric-types', 'p112g_word_type', 'case _: False{}', 'case _: True{}'),
        ('gap-after-frame-zero', 'p112g_found', 'U32.inc(captures)', 'captures'),
        ('gap-before-arguments', 'p112g_splice', 'nt_append(N111Stmt,gap,body)', 'nt_append(N111Stmt,body,gap)'),
        ('gap-short-scaffold-fallback', 'p112g_splice_next', 'case Nil{}: None{}', 'case Nil{}: Some{[]}'),
        ('fusion-scaffold-frame-zero', 'p112f_fused', 'N111Const{0,0}', 'N111Const{1,0}'),
        ('original-verifier-terminal', 'p111v_finish', 'nt_choose(String,terminal,v => "",v => "segment has a nonterminal path")', '""'),
    ])
    changes.extend([
        ('structured-node-cost', 'p112h_stmt', 'U32.sub(left,1)', 'left'),
        ('structured-both-branches', 'p112h_stmt_room', 'p112h_rest(no,p112h_nodes(yes,left))', 'p112h_nodes(no,left)'),
        ('structured-condition-width', 'p112h_condition', 'U32.is_eq(hi,0)', 'True{}'),
        ('structured-budget-carry', 'p112h_accept', 'U32.sub(32,left)', '0'),
    ])
    variants = [(name, mutate(source, declaration, before, after)) for name, declaration, before, after in changes]
    variants.append(('extra-fusion-helper', source + '\n@unsafe\ndef p112f_unadmitted() -> U32:\n  0\n'))
    refusals = []
    for name, variant in variants:
        try:
            validate(base, variant, expected)
        except ValueError as error:
            refusals.append(dict(name=name, refused=True, reason=str(error)))
        else:
            raise ValueError('Mutated composition was admitted: ' + name)
    if args.out.exists():
        raise ValueError('Use a fresh admission output')
    inputs = [base.pin(path) for path in [base_path, inventory_path, ROOT / fusion['file'], ROOT / region['file'], ROOT / multi['file'], ROOT / wide['file'], ROOT / gap['file'], ROOT / structured['file'], verifier, model, *module_paths]]
    companions = []
    if 'def p112fp_expand(' in source:
        companions.append('phase112-float-source-admission')
    if 'def p112s_emit_lowered(' in source:
        companions.append('phase112-static-source-admission')
    if 'def p112m_match_apply(' in source:
        companions.append('phase112-word-selector-source-admission')
    if 'def p112i_expand(' in source:
        companions.append('phase112-immediate-source-admission')
    if 'def p112to_nonowning(' in source:
        companions.append('phase112-typed-ownership-admission')
    record = dict(kind='phase112-cpu-failstop-worker-admission', profile=inventory['profile'],
                  admitted=True, targetsExecuted=False, runtimeSource=source_pin, runtimeObject=object_pin,
                  compiler=compiler_pin, method=base.pin(__file__), inputs=inputs,
                  exactDeclarations=len(expected),
                  declarationHashes={kind + ' ' + name: hashlib.sha256(body.encode()).hexdigest()
                                     for (kind, name), body in expected.items()},
                  contract=dict(abiVersion=11101, capabilities=1, threads=1, gpu='off',
                                privateArityMax=32, fusionArityMax=32, captureMax=32, dependencyPasses=6,
                                fusionSiteMax=8, continuationStatementsMax=128, filteredCandidates=True,
                                pureGapStatementsMax=32, bothGapBranchesCounted=True, gapAfterCaptureAndFrameZero=True,
                                firstAdmissionFrozen=True, publicUsesFinalReady=True, resultWords=1,
                                earlyRefusal=True, failureReturnUnreachable=True,
                                secondaryRuntimePointers='canonical scratch or exact authenticated fusion scratch'),
                  refusals=refusals, requiredCompanionReceiptKinds=companions,
                  limitations=['Runner must require this exact compiler source and runtime object.',
                               'Detected float/static/word-selector/immediate/typed-ownership profiles require their separate receipts on this same source.',
                               'Other source lowering changes and executable semantics remain separate qualification.'])
    for item in [source_pin, object_pin, compiler_pin, *inputs]:
        if base.pin(item['file']) != item:
            raise ValueError('Input changed during admission: ' + item['file'])
    args.out.mkdir(parents=True)
    (args.out / 'manifest.json').write_text(json.dumps(record, indent=2) + '\n')
    print(json.dumps(dict(admitted=True, profile=record['profile'], exactDeclarations=len(expected), refusals=len(refusals))))


if __name__ == '__main__':
    main()

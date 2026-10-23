"""Extend checked acquisition admission with exact late-field ABI evidence."""
import argparse
import importlib.util
import json
from pathlib import Path

from prepare import ROOT, COMPOSER, COMPOSER_SHA, read, require, unique
from qualify import pin, pins, verify

FIELD = ROOT / 'selfhost/tools/performance/phase128/borrow/field-read'
OLD = ROOT / 'selfhost/build/phase128/native-admission01.json'
OLD_SHA = 'be5b2e297f50a5818bb992abdbf36fd8b0ec0cb49c6572eb79620a83ac907800'
SOURCE_SHA = '6bd9de05e251180280a6761fa46be30dc2a22164cdb35c9ca48fd710911d0f4d'
PARENT_SHA = '057ceed778c8d605cbb9e4a1f0f0290183e8707485d620a4b7b055f137bac68a'
MODULES = {'template.bend': '81269437f25e5eecc7a0d0d4b3e2b3aa6ab2295cfcafacbd36e320ec7592e05f',
           'controls-v3.bend': 'cfe40a2101a0f64317ee25726ead098c12174d3ae5eb84773f395f7f9e90d60d',
           'oracle-wrappers-v2.bend': '32d4187a4e1043e8661ab62b7d7fb473799000ea86a2a01ff0d3b19a3f843eb0'}
FIXTURE_SHA = '0f4626b922181d3fb4c32c3fea6ed9c6b78fab4c9cd1322a6556ec5e04214e68'
EXPORT_SHA = 'de4bd1670eb8d4890f28b1cff99022121afe1cf5845a71e5cb62068038ade46c'


def main():
    p = argparse.ArgumentParser(description=__doc__)
    for name in ['base-admission', 'field-finite', 'oracle-report', 'jobs-plan', 'jobs-report', 'out']:
        p.add_argument('--' + name, type=Path, required=True)
    a = p.parse_args()
    require(not a.out.exists() and a.out.resolve().is_relative_to(ROOT / 'selfhost/build/phase128'), 'Fresh Phase128 receipt required')
    base, finite, oracle, plan, jobs = map(read, [a.base_admission, a.field_finite, a.oracle_report, a.jobs_plan, a.jobs_report])
    require(base['kind'] == 'phase128-checked-native-acquisition-admission' and base['complete']
            and base['sourceChecked'] and base['finitePredicates'] == 79 and not base['nativeQualified'], 'Original base acquisition admission required')
    require(pin(Path(__file__).with_name('admit.py')) in base['inputs'], 'Original admission method missing')
    binding = read(verify(base['sourceBinding']))
    require(base['source'] == binding['source'] and base['source']['sha256'] == SOURCE_SHA
            and binding['parent']['sha256'] == PARENT_SHA and binding['inverseByteIdentity']
            and binding['allOtherBytesUnchanged'], 'Exact wired field-source04 lineage required')
    api = read(verify(base['checkedApi']))
    require(api['complete'] and api['checked'] and api['status'] == 0 and api['api'] == base['api']
            and base['source'] in api['inputs'] and {'p128bf_controls', 'p128bf_oracle_module'} <= set(api['exports']), 'Checked exact-source field exports required')
    require([str(Path(x).resolve()) for x in api['command'] if x.endswith('.bend')] == [base['source']['file']], 'API checked another source')
    require(finite['complete'] and finite['source'] == base['source'] and finite['sourceManifest'] == base['sourceBinding']
            and base['checkedApi'] in finite['inputs'] and base['api'] in finite['inputs'], 'Field finite predicates belong to another checked source')
    group = [x for x in finite['groups'] if x['name'] == 'p128bf_controls']
    require(len(group) == 1 and group[0]['complete'] and group[0]['expectedCount'] == 21
            and len(group[0]['rows']) == 21 and all(x.endswith(':pass') for x in group[0]['rows']), 'All 21 field predicates required')

    # All earlier compiler behavior is unchanged except the two selected renderers.
    # Constructor IDs/readers and the original slow renderer remain source-bound.
    require(pin(OLD)['sha256'] == OLD_SHA and pin(COMPOSER)['sha256'] == COMPOSER_SHA, 'Frozen source audit authority changed')
    old = read(OLD)
    require(base['runtime'] == old['runtime'] and base['runtimeContract']['runtimeSource'] == old['runtimeContract']['runtimeSource'], 'Production runtime changed')
    spec = importlib.util.spec_from_file_location('p128_field_decl_audit', COMPOSER)
    comp = importlib.util.module_from_spec(spec); spec.loader.exec_module(comp)
    previous = comp.blocks(verify(old['source']).read_text())
    current = comp.blocks(verify(base['source']).read_text())
    require(set(previous) <= set(current), 'Original declarations disappeared')
    changed = sorted(n for n in previous if comp.norm(previous[n]) != comp.norm(current[n]))
    require(changed == ['p111q_constructor_ids', 'p111q_stmt'], 'Field change exceeded the two reviewed renderers')
    module_names = set()
    for name, digest in MODULES.items():
        file = FIELD / name
        require(pin(file)['sha256'] == digest, 'Reviewed field module changed')
        for symbol, body in comp.blocks(file.read_text()).items():
            require(comp.norm(current[symbol]) == comp.norm(body), 'Actual renderer/control/oracle declaration differs: ' + symbol)
            module_names.add(symbol)
    require(set(current) - set(previous) == module_names - set(previous), 'Unexpected new declaration outside field modules')
    require(comp.norm(current['p128bf_previous'].replace('def p128bf_previous(', 'def p111q_stmt(', 1)) == comp.norm(previous['p111q_stmt']), 'Original slow renderer changed')

    # Fresh exact wired API exported the real renderer. The independent C fixture
    # links only this QBE object and a helper spy, never the production runtime.
    require(pin(FIELD / 'abi-oracle.c')['sha256'] == FIXTURE_SHA and pin(FIELD / 'export-oracle.mjs')['sha256'] == EXPORT_SHA, 'Independent oracle method changed')
    require(oracle['complete'] and oracle['api'] == base['api'] and base['checkedApi'] in oracle['inputs']
            and base['source'] in oracle['inputs'] and pin(FIELD / 'export-oracle.mjs') in oracle['inputs'], 'Oracle was not exported by exact wired API')
    require(plan['complete'] and jobs['complete'] and jobs['kind'] == 'phase113-serial-jobs'
            and pin(a.jobs_plan) in jobs['inputs'] and pin(a.oracle_report) in plan['inputs']
            and oracle['product'] in plan['inputs'], 'Oracle execution/export lineage differs')
    names = ['qbe', 'assemble', 'link-fixture', 'independent-abi']
    require([x['name'] for x in plan['jobs']] == [x['name'] for x in jobs['jobs']] == names, 'Oracle job sequence differs')
    require(all(x['command'] == y['command'] and y['status'] == 0 for x, y in zip(plan['jobs'], jobs['jobs'])), 'Oracle execution failed or changed commands')
    q, asm, link, execute = [x['command'] for x in jobs['jobs']]
    require(len(q) == 6 and q[1:4] == ['-t', 'amd64_sysv', '-o'] and q[-1] == oracle['product']['file'], 'Oracle QBE command differs')
    require(len(asm) == 5 and asm[1:3] == ['-mbranches-within-32B-boundaries', '-o'] and asm[-1] == q[4], 'Oracle assembler command differs')
    require(link[1:] == ['-std=c11', '-O2', '-no-pie', str(FIELD / 'abi-oracle.c'), asm[3], '-o', execute[0]]
            and len(execute) == 1, 'Oracle must link only the fixed independent fixture and QBE object')
    header = ROOT / 'selfhost/tools/performance/phase111/runtime/runtime.h'
    runtime_header = Path(base['runtimeContract']['runtimeSource']['file']).with_name('runtime.h')
    header_suffix = ('\n#ifndef P113_ARRAY_PAIR_H\n#define P113_ARRAY_PAIR_H\n#define P113_ARRAY_PAIR_PROFILE 11301u\n'
        'uint64_t p113_rt_array_pair(P111State *state, uint32_t op,\n'
        '                           const uint64_t *args, uint32_t count,\n'
        '                           uint64_t *out, uint32_t out_count);\n#endif\n')
    require(runtime_header.read_bytes() == header.read_bytes() + header_suffix.encode(), 'Oracle/production ABI header prefix or inherited declaration suffix differs')
    for file in [FIELD / 'abi-oracle.c', header, Path(q[0]), Path(asm[0]), Path(link[0])]:
        require(pin(file) in plan['inputs'], 'Unpinned oracle tool/input: ' + str(file))
    expected = dict(checks=545, failures=0, fixture='phase128-borrow-field-late-abi')
    require(json.loads(verify(jobs['jobs'][-1]['stdout']).read_text()) == expected
            and all(verify(row['stderr']).stat().st_size == 0 for row in jobs['jobs']), 'Independent ABI oracle failed')
    files = [Path(__file__), Path(__file__).with_name('qualify.py'), a.base_admission, a.field_finite,
             a.oracle_report, a.jobs_plan, a.jobs_report, OLD, COMPOSER, header, runtime_header,
             FIELD / 'ABI-ORACLE.md', FIELD / 'abi-oracle.c', FIELD / 'export-oracle.mjs',
             *[FIELD / name for name in MODULES], Path(q[4]), Path(asm[3]), Path(execute[0])]
    inputs = unique([*map(pin, files), *list(pins(base)), *list(pins(finite)), *list(pins(oracle)), *list(pins(plan)), *list(pins(jobs))])
    for row in inputs:
        verify(row)
    result = dict(base, inputs=inputs, finitePredicates=100, nativeQualified=False, targetsRun=False,
        selected=False, installed=False, baseAdmission=pin(a.base_admission),
        fieldAdmission=dict(kind='phase128-late-field-source-bound-abi', source=base['source'], parent=binding['parent'],
            finite=pin(a.field_finite), finitePredicates=21, oracleExport=pin(a.oracle_report), oracleExecution=pin(a.jobs_report),
            abiChecks=545, failures=0, changedOriginalDeclarations=changed, addedDeclarations=sorted(set(current)-set(previous)),
            unchangedRuntime=base['runtime'], unchangedOriginalFallback=True,
            oracleHeaderIsExactRuntimePrefix=True, runtimeHeaderSuffix=header_suffix,
            constraints='Sequential CPU P111State/RFC ABI only. Verified existing borrow-fields import; widths2..8, exact constructor/arity and scratch guards; unchanged original fallback. No concurrent/device permission.'),
        scope='Acquisition-only extension of the exact checked base admission: 79 existing +21 field predicates and 545 independent late-emission ABI/fallback checks. The helper spy does not prove production malformed-term error behavior. No native self-reproduction, ordinary conformance, performance qualification or installed promotion is claimed.')
    a.out.write_text(json.dumps(result, indent=2) + '\n')
    print(json.dumps(dict(complete=True, finitePredicates=100, abiChecks=545, nativeQualified=False, report=pin(a.out))))


if __name__ == '__main__':
    main()

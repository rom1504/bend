"""Read-only consumption of finite final-source helper and diagnostic-C controls."""
import importlib.util
import itertools
import json
from pathlib import Path
import re

ROOT = Path(__file__).resolve().parents[5]
PHASE = ROOT / 'selfhost/tools/performance/phase102'
RAW = ROOT / 'selfhost/build/phase102'


def consume(b, N, load, add, source, api, helper_path, matrix_path, context):
    method = b.bind(__file__)
    source = b.bind(source); api = b.bind(api)
    helper_pin, helper = load(helper_path)
    assert helper_pin['sha256'] == '284df3162e57bb518f227fe400e47c7fcccf4cec3c95b60f1432236313f1f0b7'
    checker = b.bind(PHASE / 'projection-bend/check-admission-v5.mjs')
    helpers = b.bind(PHASE / 'projection-bend/helpers-v5.bend')
    assert checker['sha256'] == '818e4d4a34357906636071265273cb524664a6ea632c1e28418e50e05528d1bf'
    assert helpers['sha256'] == 'e00c26c349eb5f76c124bf372e792830c5edd92bd0ea08dcb2bcdfd81b0b5399'
    assert helper['inputs'] == [api, checker, helpers]
    assert Path(source['file']).read_bytes().count(Path(helpers['file']).read_bytes()) == 1
    names = ['known-outer-projection', 'alpha-renamed', 'arbitrary-constructor',
        'wrong-constructor', 'unknown-root-match', 'reference-effect', 'primitive-consumer',
        'no-fuel', 'discarded-effect-argument', 'discarded-partial-argument',
        'projector-created-effectful-shell', 'wrong-matcher-width', 'fresh-projection-binders',
        'unused-root-binder-collision', 'unused-result-binder-collision', 'reserved-free-Var',
        'injected-root-capture-counterexample', 'identity-arguments', 'permuted-arguments',
        'duplicate-arguments', 'computed-argument', 'full-Term-parameters', 'wrong-parameter-kind']
    values = ([dict(tag='Var', id=4294967293)] * 3 + [dict(tag='Absent', id=0)] * 9
              + [True, False, False, False, False, True, False, False, False, True, False])
    expected = [dict(name=name, actual=value, expected=value) for name, value in zip(names, values)]
    assert len(expected) == 23
    # JSON comparison preserves the distinction between Bool and numeric 0/1.
    assert json.dumps(helper['observations'], sort_keys=True) == json.dumps(expected, sort_keys=True)
    diagnostic = b.bind(helper['diagnostic'])
    original = Path(api['file']).read_bytes()
    exports = ['nfp_reduce', 'nfp_identity', 'nfp_params', 'nfp_capture_free']
    assert all(original.count(('function $' + name + '$(').encode()) == 1 for name in exports)
    suffix = ('\nexport const phase102Projection={' + ','.join(
        name + ':(...a)=>run_loop($' + name + '$(...a))' for name in exports) + '};\n').encode()
    assert helper['diagnostic']['unchangedPrefixBytes'] == len(original)
    assert Path(diagnostic['file']).read_bytes() == original + suffix

    matrix_pin, matrix = load(matrix_path)
    assert matrix_pin['sha256'] == '22c42512f751f59830b1a2fc32d41a47736545826a05d791c3f4d62ab88ae35c'
    runner = b.bind(matrix['method'])
    assert runner['sha256'] == 'dac96df6ee77844d3d12d10b53f41fcb21b66cd59be3e39fd0200a5758faa2ed'
    plan_pin, plan = load(matrix['plan'])
    assert plan['kind'] == 'phase102-trmc-diagnostic-policy-matrix' and plan['targetsRun'] is False
    assert plan['compilerSource'] == source
    prepare = b.bind(plan['method'])
    assert prepare['sha256'] == '0fa5a59d885c43ddfe170f644cb8fcfdb74778434b1e90efbd6b2187b79cd27a'
    acquisition_pin, acquisition = load(plan['apiAcquisition'])
    assert acquisition['source'] == source and acquisition['api'] == api
    assert N.same(acquisition['snapshot'], source)
    recipe_pin, recipe = load(acquisition['recipe'])
    assert recipe['candidate'] == source
    guard_pin, helper_job = load(RAW / 'final-helper-guard03-job.json', complete=False)
    assert guard_pin['sha256'] == 'ce776f0c681b744dc744ca11ac87e5e4ac906e586c71cf818adab3add3a47268'
    node = b.bind(acquisition['node'])
    helper_argv = [node['file'], '--stack-size=16384', '--max-old-space-size=1536',
        str(Path(checker['file']).relative_to(ROOT)), str(Path(api['file']).relative_to(ROOT)),
        str(Path(helper_pin['file']).parent.relative_to(ROOT))]
    N.job_evidence(b, helper_job, helper_argv, 0, b'{"complete":true,"observations":23}\n', b'')
    add('supplemental/projection-helper-controls', [helper_pin, guard_pin, diagnostic, acquisition_pin, method],
        'Twenty-three exact final-API helper observations. Diagnostic API preserves all original bytes and only appends four wrappers; finite syntax/argument controls, not whole-pass or ownership proof.')

    controls_pin, controls = load(plan['controls'])
    matches = [row for row in controls['records'] if row['id'] == 'mixed']
    assert len(matches) == 1
    control = matches[0]
    fixture = b.bind(control['source']); oracle = b.bind(control['stdout'])
    assert fixture['sha256'] == 'fc00ef256b469692940c81750e8e57188e165bf112f5aa0ba7a603bdcb8d6f63'
    assert oracle['sha256'] == 'ba684411b2ef7ffe051c94def9384cbf1051153e224644cec141d8a0f6bf8458'
    assert control['stderr'] == '' and control['exit'] == 0
    emission_pin, emission = load(plan['emission'])
    assert emission['source'] == fixture and emission['api'] == api and emission['output'] == plan['originalC']
    original_c = b.bind(plan['originalC']); c_text = Path(original_c['file']).read_text()
    # This pinned preparation module has a guarded main; only its pure text
    # recognizers are called, never its preparation entry or any target tool.
    spec = importlib.util.spec_from_file_location('phase102_final_policy_text', prepare['file'])
    M = importlib.util.module_from_spec(spec); spec.loader.exec_module(M)
    assert M.audit(c_text) == plan['shape']
    constructors = [M.cid(name) for name in ['MixedShort', 'MixedWide', 'MixedEnd']]
    assert set(re.findall(r'^#define (CID__CTOR_\d[0-9_]*) \d+$', c_text, re.M)) == set(constructors)
    assert re.findall(r'^#define NATIVE_COLD_CTORS (\d+)$', c_text, re.M) == ['1']
    assert not re.search(r'^#undef NATIVE_COLD_CTORS$', c_text, re.M)
    marker = '#if !DEVICE\n#if NATIVE_TYPED_SCALARS\n'
    assert c_text.count(marker) == 1
    offset = c_text.index(marker)
    assert all(match.start() < offset for match in re.finditer(r'^#(?:define|undef) NATIVE_(?:HOT_|COLD_USER_CTORS)', c_text, re.M))
    truth = [dict(device=device, cold=cold, hot=hot, userCold=user_cold,
        seal=0 if not device and cold and not hot else 0 if user_cold else 1)
        for device, cold, hot, user_cold in itertools.product([0, 1], repeat=4)]
    assert plan['userConstructorPolicyTruthTable'] == truth
    configurations = [('all-hot', [1, 1, 1]), ('all-cold', [0, 0, 0]),
        ('short-hot', [1, 0, 0]), ('wide-hot', [0, 1, 0]), ('end-hot', [0, 0, 1])]
    assert [row['id'] for row in plan['variants']] == [name for name, _ in configurations]
    assert [row['id'] for row in matrix['variants']] == [name for name, _ in configurations]
    assert matrix['context']['clang'] == b.bind(context['clang'])
    cc = context['clang']['file']; expected_stdout = Path(oracle['file']).read_bytes()
    for (name, bits), variant, row in zip(configurations, plan['variants'], matrix['variants']):
        assert variant['source'] == fixture and variant['expectedStdout'] == oracle
        assert variant['expectedStderr'] == '' and variant['expectedExit'] == 0 and variant['threads'] == [1, 2, 4]
        assert variant['hot'] == dict(zip(constructors, bits)) and variant['coldUserConstructors'] == 0
        insertion = '/* Diagnostic unique-chain constructor policy matrix. */\n#undef NATIVE_COLD_USER_CTORS\n#define NATIVE_COLD_USER_CTORS 0\n'
        for constructor, bit in zip(constructors, bits):
            insertion += f'#undef NATIVE_HOT_{constructor}\n#define NATIVE_HOT_{constructor} {bit}\n'
        assert variant['insertion'] == dict(offset=offset, text=insertion)
        c = b.bind(variant['c']); changed = Path(c['file']).read_text()
        assert changed == c_text[:offset] + insertion + c_text[offset:]
        assert changed[:offset] + changed[offset + len(insertion):] == c_text
        assert M.audit(changed) == plan['shape'] and row['c'] == c
        common = [cc, '-isystem', str(Path(cc).parents[1] / 'include/clang'), '-std=c11']
        pre_evidence, _ = N.job_evidence(b, row['preprocessor'], [*common, '-E', '-P', c['file']], 0, stderr=b'')
        preprocessed = Path(pre_evidence['captures']['stdout']['file']).read_text()
        inner = M.function(preprocessed.replace('Env e, _Bool seq, Term* nf_out', 'Env e, bool seq, Term* nf_out'), plan['shape']['worker'] + '_trmc')
        assigned = list(map(int, re.findall(r'nf_out\[4\]\s*=\s*([01]);', inner)))
        assert assigned == row['preprocessedPolicies'] == bits[:2]
        N.build_evidence(b, dict(c=c, binary=row['binary'], build=row['build']), context['clang'])
        assert [entry['workers'] for entry in row['executions']] == [1, 2, 4]
        for execution in row['executions']:
            assert execution['passed'] is True
            argv = [row['binary']['file'], '--threads', str(execution['workers']), '--gpu', 'off']
            N.job_evidence(b, execution['job'], argv, 0, expected_stdout, b'')
    add('supplemental/trmc-cold-policy-matrix', [matrix_pin, plan_pin, controls_pin, emission_pin, acquisition_pin, recipe_pin, method],
        'Five diagnostic macro variants of the final checked-API C; exact insertion/inverse and preprocessed slot4 policies, with fifteen full outputs at 1/2/4 workers. These are explicit diagnostic C variants, not natural compiler outputs, native B1/B2 qualification, performance evidence, or a universal ownership proof.')
    return dict(helperControls=helper_pin, coldMatrix=matrix_pin, coldMatrixPlan=plan_pin,
        apiAcquisition=acquisition_pin, method=method,
        counts=dict(helperObservations=23, diagnosticVariants=5, preprocessedPolicies=5, builds=5, fullOutputs=15),
        scope='Supplemental finite mechanism evidence only; all original semantic and native-image gates remain required.')

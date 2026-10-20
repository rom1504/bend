#!/usr/bin/env python3
"""Prepare or authenticate direct hosted products for the unchanged broad45 corpus.

Offline only: this tool never imports a checked API or launches a target.
"""
import argparse
import contextlib
import importlib.util
import io
from pathlib import Path
import re
import sys
import tempfile
from types import SimpleNamespace

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[4]
BROAD = ROOT/'selfhost/tools/performance/phase112/benchmark45'
spec = importlib.util.spec_from_file_location('frozen_broad45', BROAD/'run.py')
m = importlib.util.module_from_spec(spec)
spec.loader.exec_module(m)
DIRECT = ['p88_cache_prepare', 'p86_prepare', 'p86_plan', 'p111_runtime_admission',
          'p113d_lower_request', 'p113d_verify', 'p113d_chunks']
STAGES = ['api-import', 'input-read', 'preparation', 'frontend', 'frontend-counts',
          'runtime-admission', 'lowering', 'program-counts', 'ir-verification',
          'qbe-emission', 'write', 'output-authentication']


def corpus():
    freeze = m.read(BROAD/'freeze01.json')
    pins = {row['file']: row for row in freeze['inputs']}
    for name in ['manifest01.json', 'upstream-50ms-profile01.json', 'run.py']:
        m.verify(pins[str(BROAD/name)])
    manifest = m.read(BROAD/'manifest01.json')
    if len(manifest['cases']) != 45:
        raise ValueError('Original full45 corpus required')
    for case in manifest['cases']:
        m.verify(case['source'])
    return manifest


def authenticate(reports, manifest, api, runtime, emitter, label):
    """Add direct-path evidence to the unchanged binder's structural checks."""
    if not reports or set(reports) - {case['name'] for case in manifest['cases']}:
        raise ValueError('Known nonempty corpus subset required')
    for entry in reports.values():
        if not isinstance(entry, dict) or set(entry) != {'emission', 'build'}:
            raise ValueError('Separate actual emission/build receipt paths required')
        report = m.read(ROOT/entry['emission'])
        if (report.get('kind') != 'phase113-staged-checked-source-qbe-emission' or
                report.get('pipeline') != 'direct' or report.get('mode') != 'cache' or
                not all(report.get(key) is True for key in
                        ['complete', 'sourceChecked', 'runtimeAdmitted', 'irVerified']) or
                report.get('requiredExports') != DIRECT):
            raise ValueError('Complete checked/admitted/verified direct staged receipt required')
        stages = report.get('stages', [])
        if [row['name'] for row in stages] != STAGES or any(row['status'] != 'complete' for row in stages):
            raise ValueError('Every expected direct emission stage must complete')
        inputs = {row['file']: row for row in report['inputs']}
        for expected in [api, emitter]:
            if inputs.get(expected['file']) != expected:
                raise ValueError('Emission differs from planned API/transport')
        for row in report['inputs']:
            m.verify(row)
    with tempfile.TemporaryDirectory(prefix='p113-hosted45-auth-') as tmp:
        mapping, binding = Path(tmp)/'reports.json', Path(tmp)/'binding.json'
        m.save(mapping, reports)
        with contextlib.redirect_stdout(io.StringIO()):
            m.bind(SimpleNamespace(label=label, reports=mapping, out=binding,
                                   names=list(reports)), manifest)
        result = m.read(binding)
    for product in result['products'].values():
        if product.get('api') != api or product['runtime'] != runtime:
            raise ValueError('Every product must use the planned checked API and runtime')
    return result


def prepare(a, manifest):
    if not re.fullmatch(r'p113-[a-zA-Z0-9_-]+', a.tag):
        raise ValueError('Descriptive p113- artifact prefix required')
    api = a.api.resolve()
    if api.is_dir():
        api /= 'api.mjs'
    checked_path = api.parent/'report.json'
    checked = m.read(checked_path)
    if (not checked.get('complete') or not checked.get('checked') or
            not set(DIRECT + ['p111_compile_source']).issubset(checked.get('exports', [])) or
            m.verify(checked['api']) != api):
        raise ValueError('Checked direct exports plus legacy binder compatibility export p111_compile_source required')
    baseline = m.read(HERE/'manifest01.json')['baseline']
    runtime = (a.runtime or Path(baseline['runtime']['file'])).resolve()
    if runtime.is_dir():
        runtime /= 'runtime.o'
    api_pin, runtime_pin = m.pin(api), m.pin(runtime)
    emitter = m.pin(ROOT/'selfhost/tools/performance/phase113/staged-emit.mjs')
    inputs = [m.pin(__file__), m.pin(HERE/'manifest01.json'), m.pin(BROAD/'freeze01.json'),
              m.pin(BROAD/'manifest01.json'), m.pin(BROAD/'upstream-50ms-profile01.json'),
              m.pin(BROAD/'run.py'), m.pin(checked_path), api_pin, runtime_pin, emitter,
              m.pin(ROOT/'selfhost/tools/performance/phase111/build.py'),
              m.pin(ROOT/'selfhost/tools/performance/phase112/run-jobs.py'),
              manifest['base'], manifest['carrier'], *checked['inputs']]
    reports = m.read(a.reuse_reports) if a.reuse_reports else {}
    reused = list(reports)
    if reports:
        bound = authenticate(reports, manifest, api_pin, runtime_pin, emitter, 'p113-direct')
        inputs.append(m.pin(a.reuse_reports))
        for product in bound['products'].values():
            inputs.extend(product[key] for key in
                          ['binary', 'emission', 'build', 'qbe', 'runtime', 'api', 'apiReport', 'compilerSource'])
    jobs = []
    for case in manifest['cases']:
        inputs.append(case['source'])
        name = case['name']
        if name in reports:
            continue
        emit = ROOT/'selfhost/build/phase111'/(a.tag+'-'+name+'-emit')
        build = ROOT/'selfhost/build/phase111'/(a.tag+'-'+name+'-build')
        if emit.exists() or build.exists():
            raise ValueError('Planned artifact path already exists')
        jobs.extend([
            dict(name=name+'-emit', seconds=45, command=[checked['command'][0],
                 emitter['file'], str(api), case['source']['file'], str(emit), 'cache', 'direct']),
            dict(name=name+'-build', seconds=45, command=[sys.executable, '-B',
                 str(ROOT/'selfhost/tools/performance/phase111/build.py'),
                 '--source', str(emit/'program.ssa'), '--runtime', str(runtime),
                 '--out', str(build), '--seconds', '12'])])
        reports[name] = dict(emission=str(emit/'report.json'), build=str(build/'report.json'))
    inputs = list({row['file']: row for row in inputs}.values())
    for row in inputs:
        m.verify(row)
    mapping = a.out.with_name(a.out.stem+'-reports.json')
    if mapping.exists():
        raise ValueError('Fresh reports-map path required')
    m.save(mapping, reports)
    m.save(a.out, dict(kind='phase113-direct-hosted45-plan', targetsRun=False,
        inputs=inputs, api=api_pin, runtime=runtime_pin, emitter=emitter,
        manifest=m.pin(BROAD/'manifest01.json'), profile=m.pin(BROAD/'upstream-50ms-profile01.json'),
        reportsMap=m.pin(mapping), pipeline='direct', requiredExports=DIRECT,
        requestedNames=[case['name'] for case in manifest['cases']],
        reusedNames=reused, jobs=jobs,
        scope='Unchanged original45 sources/outputs/profile. Hosted direct emission/build only; run audit and existing measurement separately. No native image or self-host qualification. scalar-region-0 remains a correctness-only point with undefined timing ratio.'))


def audit(a, manifest):
    plan = m.read(a.plan)
    if plan.get('kind') != 'phase113-direct-hosted45-plan' or plan['manifest'] != m.pin(BROAD/'manifest01.json'):
        raise ValueError('Exact broad45 direct plan required')
    for row in plan['inputs']:
        m.verify(row)
    reports = m.read(m.verify(plan['reportsMap']))
    if set(reports) != {case['name'] for case in manifest['cases']}:
        raise ValueError('All45 product receipts required; no silent partial qualification')
    if a.label in {'phase111', 'upstream', 'facts-n2'}:
        raise ValueError('Use a new candidate label')
    checked = authenticate(reports, manifest, plan['api'], plan['runtime'], plan['emitter'], a.label)
    binding = a.out.with_name(a.out.stem+'-binding.json')
    if binding.exists():
        raise ValueError('Fresh binding path required')
    # Produce the ordinary binding against the real pinned map, not the temporary audit map.
    with contextlib.redirect_stdout(io.StringIO()):
        m.bind(SimpleNamespace(label=a.label, reports=Path(plan['reportsMap']['file']),
                               out=binding, names=None), manifest)
    m.save(a.out, dict(kind='phase113-direct-hosted45-producer-audit', complete=True,
        targetsRun=False, plan=m.pin(a.plan), binding=m.pin(binding),
        inputs=[m.pin(__file__), *plan['inputs'], m.pin(a.plan), plan['reportsMap']],
        api=plan['api'], runtime=plan['runtime'], emitter=plan['emitter'],
        pipeline='direct', requiredExports=DIRECT, qualifiedNames=list(checked['products']),
        scope='All45 real direct receipts authenticate checked frontend, runtime admission, structured IR verification, exact API/transport/runtime and unchanged legacy binder checks. This does not execute products, qualify native compilation or prove all work took direct lowering.'))


def main():
    p = argparse.ArgumentParser(description=__doc__)
    actions = p.add_subparsers(dest='action', required=True)
    prep = actions.add_parser('prepare')
    prep.add_argument('--api', type=Path, required=True)
    prep.add_argument('--runtime', type=Path)
    prep.add_argument('--tag', required=True)
    prep.add_argument('--reuse-reports', type=Path,
                      help='Optional completed subset from the same direct API/runtime/transport')
    check = actions.add_parser('audit')
    check.add_argument('--plan', type=Path, required=True)
    check.add_argument('--label', required=True)
    for sub in [prep, check]:
        sub.add_argument('--out', type=Path, required=True)
    a = p.parse_args()
    if a.out.exists():
        raise ValueError('Fresh output required')
    a.out.parent.mkdir(parents=True, exist_ok=True)
    manifest = corpus()
    (prepare if a.action == 'prepare' else audit)(a, manifest)
    print(str(a.out))


if __name__ == '__main__':
    main()

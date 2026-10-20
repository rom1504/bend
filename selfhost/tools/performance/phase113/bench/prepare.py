#!/usr/bin/env python3
"""Offline authentication and one-time Phase113 screen freeze; no targets."""
import copy
from datetime import datetime, timezone
import importlib.util
import json
import math
from pathlib import Path
import statistics
from types import SimpleNamespace

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[4]
spec = importlib.util.spec_from_file_location('phase113_adapter', HERE/'run.py')
adapter = importlib.util.module_from_spec(spec)
spec.loader.exec_module(adapter)
method = adapter.method
NAMES = ['scalar-region-8192', 'local-pair', 'editdist', 'variation-ray-active-256-2240', 'lexer', 'coverage-closures-256']


def main():
    if (HERE/'manifest01.json').exists():
        raise ValueError('Already frozen; use a new version rather than rewriting')
    broad_path = ROOT/'selfhost/tools/performance/phase112/benchmark45/manifest01.json'
    broad = method.read(broad_path)
    selection_path = ROOT/'selfhost/tools/performance/phase112/selection.json'
    selection = method.read(selection_path)
    binding_path = ROOT/'selfhost/build/phase112/facts-broad-binding01.json'
    baseline = method.read(binding_path)
    hosted = method.read(ROOT/'selfhost/build/phase112/facts-binding01.json')
    if not baseline.get('complete') or baseline['manifest'] != method.pin(broad_path) or selection['profile'] != 'facts':
        raise ValueError('Complete frozen facts/broad lineage required')
    cases = [copy.deepcopy(next(c for c in broad['cases'] if c['name'] == name)) for name in NAMES]
    api_report_path = Path(selection['api']['file']).parent/'report.json'
    api_report = method.read(api_report_path)
    if not api_report.get('complete') or not api_report.get('checked') or api_report['api'] != selection['api']:
        raise ValueError('Complete checked frozen facts API required')
    inputs = [method.pin(__file__), method.pin(HERE/'run.py'), method.pin(adapter.ORIGINAL),
              method.pin(broad_path), method.pin(selection_path), method.pin(binding_path), method.pin(api_report_path),
              *[selection[k] for k in ['source','sourceManifest','recipe','api','n1','n2','runtime']],
              broad['base'], broad['carrier'], *broad['directToolchain'].values()]
    maps, counts, derivation, hosted_map = {}, {}, {}, {}
    for case in cases:
        name, product = case['name'], baseline['products'][case['name']]
        if product['source'] != case['source'] or product['compiler'] != selection['n2'] or product['runtime'] != selection['runtime']:
            raise ValueError('Unmatched frozen native baseline: '+name)
        for key in ['binary','qbe','emission','build','runtime']:
            method.verify(product[key])
        if method.verify(case['expectedStdoutEvidence']).read_text() != case['expectedStdout']:
            raise ValueError('Independent complete expected output differs')
        med = statistics.median(case['historicalSamplesMs']['upstream'])
        reps = max(1, math.ceil(case['repetitions']*15/med))
        counts[name] = dict(repetitions=reps, warmups=1)
        derivation[name] = dict(originalRepetitions=case['repetitions'], historicalUpstreamMedianMs=med,
            historicalUpstreamSamplesMs=case['historicalSamplesMs']['upstream'], targetMs=15,
            estimatedUpstreamMs=med*reps/case['repetitions'])
        maps[name] = product['emission']['file']
        if name in hosted['products']:
            hp = hosted['products'][name]
            if hp['source'] != case['source'] or hp['api'] != selection['api'] or hp['runtime'] != selection['runtime']:
                raise ValueError('Existing hosted product is not frozen facts: '+name)
            hosted_map[name] = dict(emission=hp['emission']['file'], build=hp['build']['file'])
        inputs += [case['source'], case['expectedStdoutEvidence'], case['upstream']['binary'],
                   case['upstream']['clang'], case['upstream']['generatedC']]
    inputs = list({x['file']: x for x in inputs}.values())
    for item in inputs:
        method.verify(item)
    manifest = dict(kind='phase113-frozen-six-program-screen', version=1, targetsRun=False,
        frozenUtc=datetime.now(timezone.utc).isoformat(), cases=cases, inputs=inputs,
        measurementMethod=method.pin(adapter.ORIGINAL), base=broad['base'], carrier=broad['carrier'],
        directToolchain=broad['directToolchain'], phase111Compiler=broad['phase111Compiler'],
        phase111Runtime=broad['phase111Runtime'], baselineSelection=method.pin(selection_path), baseline=selection,
        baselineRole='facts-n2', fullCorpusReference=method.pin(broad_path),
        minimumMs=5, rounds=3, zeroWorkExclusions=broad['zeroWorkExclusions'], clock=broad['clock'],
        scope='Explicit new Phase113 development six, not the old Phase112 six or original45 score. All workload source/arguments/full outputs preserved.',
        executionPolicy='Unchanged old measurement functions, configured with this manifest; diagnostic1 versus paired3 qualification is recorded by the Phase113 adapter. Legacy output directory parent retained.')
    method.save(HERE/'manifest01.json', manifest)
    profile = dict(kind='phase112-frozen-runtime-profile', name='phase113-upstream15ms01', version=1,
        frozenUtc=manifest['frozenUtc'], targetsRun=False, manifest=method.pin(HERE/'manifest01.json'),
        cases=counts, minimumMs=5, derivation=derivation,
        scope='New Phase113 profile: ceil(original repetitions*15/historical upstream median milliseconds), minimum1; warmups1. Only prior upstream times determine counts. Diagnostic1 is not paired evidence. Paired3 retains three rounds, exact full results and identical role counts; 1ms resolution limits small gains.')
    method.save(HERE/'upstream-15ms-profile01.json', profile)
    method.save(HERE/'baseline-native-reports01.json', maps)
    method.save(HERE/'baseline-hosted-existing01.json', hosted_map)
    method.bind(SimpleNamespace(label='facts-n2', reports=HERE/'baseline-native-reports01.json',
                               out=HERE/'baseline-binding01.json', names=None), manifest)
    print(json.dumps(dict(targetsRun=False, names=NAMES, profile=counts,
        manifest=method.pin(HERE/'manifest01.json'), retainedNativeProducts=6, retainedHostedProducts=len(hosted_map))))


if __name__ == '__main__':
    main()

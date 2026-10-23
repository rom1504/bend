#!/usr/bin/env python3
"""Bind experimental Phase131 timing to unchanged Phase130 clocks and oracles.

Metadata only. Focused qualification and actual native acquisition are required;
this planner does not pretend that either is full native qualification.
"""
import argparse
import copy
import filecmp
import importlib.util
import json
from pathlib import Path
import re
import sys

ROOT = Path(__file__).resolve().parents[5]
BASE = ROOT / 'selfhost/build/phase130/n1-n2-timing01.json'
BASE_SHA = '458c7f9a302bdb57b0749ff3a0e44e477fe0a6e01eaf6aa13f254c0e5148cf29'
RUNNER = ROOT / 'selfhost/tools/performance/phase130/timing-run.py'
RUNNER_SHA = '1a81e92ac201fbd9109ab1f7ad677243b4204ed87acb673127faa46f8e5e9987'
sys.dont_write_bytecode = True
sys.path.insert(0, str(ROOT / 'selfhost/tools/performance/phase128/native'))
spec = importlib.util.spec_from_file_location('p131_timing_build', ROOT / 'selfhost/tools/performance/phase128/native/qualify.py')
Q = importlib.util.module_from_spec(spec)
spec.loader.exec_module(Q)
pin, verify, pins = Q.pin, Q.verify, Q.pins


def read(path):
    return json.loads(Path(path).read_text())


def require(condition, message):
    if not condition:
        raise ValueError(message)


def emission(path, admission, image, carrier):
    r = read(path)
    require(r.get('complete') and r.get('kind') == 'phase130-native-source-qbe-request'
            and r.get('exitCode') == 0 and not r.get('changedInputs'), 'Native emission incomplete')
    require(r['image'] == image and r['source'] == admission['source']
            and r['runtime'] == admission['runtime'], 'Native source/image/runtime lineage differs')
    require(carrier in r['inputs'] and r['stderr']['bytes'] == 0
            and r['product']['bytes'] > 0, 'Compact carrier or raw native output mismatch')
    for row in pins(r):
        verify(row)
    return r


def focused(path, image, runtime):
    r = read(path)
    corpus = ROOT / 'selfhost/tools/performance/phase111/coverage/manifest.json'
    fixtures = read(corpus)['fixtures']
    require(r.get('complete') and r.get('passed') and
            r.get('kind') == 'phase125-aligned-native-source-semantic-coverage', 'Focused gate incomplete')
    require(r['names'] == [x['name'] for x in fixtures] and
            [x['name'] for x in r['rows']] == r['names'], 'Focused corpus differs')
    require(image in r['inputs'] and runtime in r['inputs'] and pin(corpus) in r['inputs'], 'Focused identity mismatch')
    require(r['summary']['semanticPasses'] == 16 and r['summary']['expectedRefusals'] == 3
            and r['summary']['pending'] == 0, 'Focused gate counts differ')
    require(all(row['expected'] == case['expect'] for row, case in zip(r['rows'], fixtures)), 'Focused oracle differs')
    for row in pins(r):
        verify(row)
    return r


def main():
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument('--comparison', choices=['parent-n1', 'n1-n2'], default='parent-n1')
    for name in ['admission', 'n1-emission', 'n1-build', 'n1-focused', 'out']:
        ap.add_argument('--' + name, type=Path, required=True)
    for name in ['n2-emission', 'n2-build', 'n2-focused']:
        ap.add_argument('--' + name, type=Path)
    ap.add_argument('--tag', required=True)
    a = ap.parse_args()
    out = a.out.resolve()
    require(not out.exists() and out.is_relative_to(ROOT / 'selfhost/build/phase131'), 'Fresh Phase131 manifest required')
    require(re.fullmatch(r'p131-[a-z0-9_-]+', a.tag), 'Use a p131- result tag')
    require(pin(BASE)['sha256'] == BASE_SHA and pin(RUNNER)['sha256'] == RUNNER_SHA, 'Frozen timing policy changed')
    base, ad = read(BASE), read(a.admission)
    parent_file = ROOT / 'implementation/phase130/candidate.json'
    parent = read(parent_file)
    require(parent['complete'] and parent['nativeQualified'], 'Qualified parent required')
    require(ad['kind'] == 'phase131-native-acquisition-admission' and ad['complete'] and ad['sourceChecked'], 'Checked Phase131 admission required')
    require(ad['runtime'] == parent['runtime'] == base['runtime'] and
            ad['permittedProducer'] == parent['n1'] and ad['producerSelection'] == pin(parent_file), 'Admission/producer/runtime mismatch')
    for row in pins(ad):
        verify(row)
    for row in pins(parent):
        verify(row)
    carrier = parent['preferredCarrierReceipt']
    require(base['roles']['phase111']['carrierReceipt'] == carrier == base['roles']['phase112']['carrierReceipt'], 'Both native roles must use identical compact Base')
    n0 = emission(a.n1_emission, ad, parent['n1'], carrier)
    n1 = Q.build(read(a.n1_build), n0['product'], ad['runtime'], base['tools'])
    focused(a.n1_focused, n1, ad['runtime'])
    evidence = [a.admission, a.n1_emission, a.n1_build, a.n1_focused]
    left = dict(binary=parent['n1'], source=parent['source'], generation='Qualified Phase130 N1; compact Base', nativeQualified=True, carrierReceipt=carrier)
    right = dict(binary=n1, source=ad['source'], generation='Experimental Phase131 N1; focused19 passed; compact Base', nativeQualified=False, carrierReceipt=carrier)
    if a.comparison == 'n1-n2':
        require(all([a.n2_emission, a.n2_build, a.n2_focused]), 'N2 emission/build/focused receipts required')
        se = emission(a.n2_emission, ad, n1, carrier)
        require(se.get('byteExact') and se.get('expectedQbe') == n0['product'] and
                filecmp.cmp(se['product']['file'], n0['product']['file'], shallow=False), 'Exact same-source native reproduction required')
        n2 = Q.build(read(a.n2_build), se['product'], ad['runtime'], base['tools'])
        focused(a.n2_focused, n2, ad['runtime'])
        left = right
        right = dict(binary=n2, source=ad['source'], generation='Experimental Phase131 N2; exact QBE and focused19 passed; compact Base', nativeQualified=False, carrierReceipt=carrier)
        evidence += [a.n2_emission, a.n2_build, a.n2_focused]
    else:
        require(not any([a.n2_emission, a.n2_build, a.n2_focused]), 'N2 receipts only apply to n1-n2 comparison')
    manifest = copy.deepcopy(base)
    manifest.update(preparedOnly=True, targetsRun=False, researchOnly=True, nativeQualified=False, unqualified=True)
    manifest['roles'].update(phase111=left, phase112=right)
    manifest['inputs'] = [pin(__file__), pin(Q.__file__), pin(BASE), pin(RUNNER), pin(parent_file), *map(pin, evidence)]
    manifest['lineage'] = dict(comparison=a.comparison, roleKeys=dict(phase111=left['generation'], phase112=right['generation'], upstream='Unchanged pinned TypeScript/Bun C compiler'),
        qualificationScope='Source/runtime-admitted experimental compiler with actual native acquisition and focused19. Full qualification and installed selection are separate.',
        sameCompilerSource=a.comparison == 'n1-n2', compactCarrierBothNative=True,
        unchanged='Phase130 cases, independent full outputs, upstream, tools, machine flags, limits, wait4 clocks and rotated three-round schedule.',
        costScope='Request and machine-build child sums separate. Native prepared Base/cached runtime; upstream source Base/full C-Clang runtime build. Program execution is correctness-only.',
        installed=False)
    manifest['derivation'] = dict(kind='phase131-experimental-native-request-comparison', original=pin(BASE), runner=pin(RUNNER), targetsRun=False)
    for row in pins(manifest):
        verify(row)
    target = ROOT / 'selfhost/build/phase112' / a.tag
    jobs_path = out.with_name(out.stem + '-jobs.json')
    require(not target.exists() and not jobs_path.exists(), 'Fresh target/job paths required')
    command = [sys.executable, '-B', str(RUNNER), '--manifest', str(out), '--out', str(target), '--rounds', '3', '--modes', 'cache']
    out.parent.mkdir(parents=True, exist_ok=True)
    with out.open('x') as f:
        json.dump(manifest, f, indent=2); f.write('\n')
    jobs = dict(kind='phase131-native-timing-jobs', complete=True, targetsRun=False, inputs=[pin(out), pin(__file__), pin(RUNNER)],
                jobs=[dict(name='phase131-' + a.comparison + '-upstream-three-source', seconds=240, command=command)])
    with jobs_path.open('x') as f:
        json.dump(jobs, f, indent=2); f.write('\n')
    print(json.dumps(dict(complete=True, targetsRun=False, manifest=pin(out), jobs=pin(jobs_path), command=command)))


if __name__ == '__main__':
    main()

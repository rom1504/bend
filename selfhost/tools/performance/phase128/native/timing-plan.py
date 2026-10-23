"""Prepare two Phase128 manifests for the unchanged Phase125 timing runner."""
import argparse
import copy
import json
from pathlib import Path
import re
import sys

from qualify import ROOT, BASE, BASE_SHA, NATIVE, pin, pins, read, verify, require, build

RUNNER = NATIVE / 'timing-run.py'
RUNNER_SHA = 'd11362384088effd695e2872e7a55cb8e2c4cf943fdc8eeace10bca4780e9e6f'
REPAIR_BUILD = ROOT / 'selfhost/build/phase111/p127-live-bank-same-source01-n1/report.json'
REPAIR_EMIT = ROOT / 'selfhost/build/phase111/p127-live-bank-same-source01-emit/report.json'
REPAIR_COMPARISON = ROOT / 'selfhost/build/phase127/live-bank-full-comparison01.json'
REPAIR_BINARY_SHA = '7d74f5254509970f53ceda6f5305dc195afbb38bf8486005ffab8f1c62c61734'


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--qualification', type=Path)
    for name in ['research-admission', 'hosted', 'n1-build', 'n1-focused']:
        p.add_argument('--' + name, type=Path)
    p.add_argument('--out', type=Path, required=True)
    p.add_argument('--tag', required=True)
    a = p.parse_args()
    out = a.out.resolve()
    require(not out.exists() and out.is_relative_to(ROOT / 'selfhost/build/phase128'), 'Fresh Phase128 directory required')
    require(re.fullmatch(r'p128-[a-z0-9_-]+', a.tag), 'Fresh p128- tag required')
    require(pin(BASE)['sha256'] == BASE_SHA and pin(RUNNER)['sha256'] == RUNNER_SHA, 'Frozen timing inputs changed')
    base = read(BASE)
    research = [a.research_admission, a.hosted, a.n1_build, a.n1_focused]
    require(bool(a.qualification) != all(research) and (not a.qualification or not any(research)), 'Use qualification OR all four research receipt arguments')
    if a.qualification:
        q = read(a.qualification)
        require(q['kind'] == 'phase128-native-qualification' and q['complete'] and q['nativeQualified'] and q['byteExact'], 'Completed Phase128 native qualification required')
        for row in q['inputs']:
            verify(row)
        require(pin(Path(__file__).with_name('qualify.py')) in q['inputs'], 'Qualification method differs')
        authority = pin(a.qualification)
    else:
        admission, h, b, focused = map(read, research)
        require(admission['kind'] == 'phase128-checked-native-acquisition-admission' and admission['complete'] and admission['sourceChecked'], 'Checked research admission required')
        require(h['complete'] and h['kind'] == 'phase118-integrated-checked-source-qbe-emission'
                and h['entry'] == 'p111_emit_admitted' and all(h.get(k) for k in ['sourceChecked', 'runtimeAdmitted', 'irVerified'])
                and all(admission[k] in h['inputs'] for k in ['source', 'api', 'checkedApi']), 'Research hosted source lineage differs')
        image = build(b, h['product'], admission['runtime'], base['tools'])
        corpus = ROOT / 'selfhost/tools/performance/phase111/coverage/manifest.json'
        require(focused['complete'] and focused['passed'] and focused['kind'] == 'phase125-aligned-native-source-semantic-coverage'
                and focused['names'] == [r['name'] for r in read(corpus)['fixtures']], 'Original focused19 required')
        require(focused['summary']['semanticPasses'] == 16 and focused['summary']['expectedRefusals'] == 3
                and focused['summary']['pending'] == 0 and image in focused['inputs']
                and admission['runtime'] in focused['inputs'] and pin(corpus) in focused['inputs']
                and pin(NATIVE / 'coverage.py') in focused['inputs'], 'Research focused19 identity/scope differs')
        for report in [admission, h, b, focused]:
            for row in pins(report):
                verify(row)
        q = dict(source=admission['source'], api=admission['api'], runtime=admission['runtime'],
                 n1=image, admission=pin(a.research_admission), sourceBinding=admission['sourceBinding'],
                 checkedApi=admission['checkedApi'], reports={name: pin(path) for name, path in
                    [('hosted', a.hosted), ('n1_build', a.n1_build), ('n1_focused', a.n1_focused)]})
        authority = pin(a.research_admission)
    keys = ['kind', 'upstreamRevision', 'cases', 'nativeAssets', 'tools', 'scope', 'timer', 'buildPolicy', 'limits']
    template = {k: copy.deepcopy(base[k]) for k in keys}
    template.update(preparedOnly=True, targetsRun=False, assemblerOption='-mbranches-within-32B-boundaries', runtime=q['runtime'])
    template['buildPolicy']['native'] = 'Pinned QBE amd64_sysv, GNU as -mbranches-within-32B-boundaries, gcc -no-pie objects -pthread -lm'
    template['inputs'] = [pin(__file__), pin(Path(__file__).with_name('qualify.py')), pin(RUNNER), pin(BASE),
                          authority, q['admission'], q['sourceBinding'], q['checkedApi'], *q['reports'].values()]
    template.update(unqualified=not bool(a.qualification), researchOnly=not bool(a.qualification), nativeQualified=bool(a.qualification))
    template['derivation'] = dict(kind=('phase128-qualified-native-transport' if a.qualification else 'phase128-unqualified-research-native-transport'), unchanged='Frozen three sources/outputs, upstream, Base/cache, toolchain, schedule, timing clocks and limits; unchanged Phase125 timing runner and Phase123 aligned machine-build policy.')
    current_role = dict(binary=q['n1'], source=q['source'], generation='Phase128 N1')
    manifests = []
    if a.qualification:
        first = copy.deepcopy(template)
        first['roles'] = dict(phase111=current_role, phase112=dict(binary=q['n2'], source=q['source'], generation='Phase128 N2'), upstream=base['roles']['upstream'])
        first['lineage'] = dict(comparison='Same qualified Phase128 compiler source: actual N1/N2 versus pinned TypeScript/Bun upstream.',
                               roleKeys=dict(phase111='Phase128 N1', phase112='Phase128 N2'), qbeByteExact=True,
                               qualification=authority, sameCompilerSource=q['source'])
        manifests.append(('n1-n2', first))
    old_build, old_emit, comparison = map(read, [REPAIR_BUILD, REPAIR_EMIT, REPAIR_COMPARISON])
    admission = read(q['admission']['file'])
    old_abi = read(admission['runtimeContract']['inheritedAuthority']['file'])
    old_image = build(old_build, old_emit['product'], old_abi['runtime'], base['tools'])
    require(old_image['sha256'] == REPAIR_BINARY_SHA, 'Wrong historical repair image')
    require(old_emit['complete'] and old_emit['sourceChecked'] and old_emit['runtimeAdmitted'] and old_emit['irVerified']
            and old_abi['source'] in old_emit['inputs'], 'Repair image source lineage differs')
    require(comparison['complete'] and comparison['changedLines'] == [dict(line=2446194, before=1, after=5)]
            and old_emit['product'] in comparison['inputs'], 'Exact descriptor-only repair evidence differs')
    second = copy.deepcopy(template)
    second['roles'] = dict(phase111=dict(binary=old_image, source=old_abi['source'], generation='Phase127 descriptor-repaired build of unchanged Phase126 source32'),
                          phase112=current_role, upstream=base['roles']['upstream'])
    second['inputs'] += [pin(REPAIR_BUILD), pin(REPAIR_EMIT), pin(REPAIR_COMPARISON), old_abi['source'], old_abi['runtime']]
    second['lineage'] = dict(comparison='Historical repaired source32 image versus Phase128 N1. Different compiler sources; not a same-source N1/N2 comparison.',
        roleKeys=dict(phase111='Phase127 same-source repair image (source32)', phase112='Phase128 N1'),
        repairReceipt=pin(REPAIR_COMPARISON), authority=authority, nativeQualified=bool(a.qualification),
        qualificationScope=('Actual N1/N2 and ordinary qualification complete.' if a.qualification else 'Research-only N1: checked source/runtime admission, actual hosted build and focused19. No self-reproduction or full45 qualification yet.'),
        runtimePolicy='Both newly emitted program products link the same Phase128 additive runtime. The historical compiler executable retains its original Phase126 linked runtime; this is disclosed, not rebuilt.',
        historicalQualification='Phase126 source32 was qualified. Phase127 descriptor-only image repair has the exact one-line comparison; it is not relabeled as a Phase127 full self-host qualification.')
    manifests.append(('repair-n1', second))
    jobs = []
    for label, manifest in manifests:
        for row in pins(manifest):
            verify(row)
        destination = ROOT / 'selfhost/build/phase112' / (a.tag + '-' + label)
        require(not destination.exists(), 'Timing output already exists')
        jobs.append(dict(name=label + '-upstream', seconds=240, command=[sys.executable, '-B', str(RUNNER),
            '--manifest', str(out / (label + '.json')), '--out', str(destination), '--rounds', '3', '--modes', 'cache']))
    out.mkdir(parents=True)
    for label, manifest in manifests:
        (out / (label + '.json')).write_text(json.dumps(manifest, indent=2) + '\n')
    plan = dict(kind='phase128-native-timing-jobs', complete=True, targetsRun=False,
                inputs=[*[pin(out / (label + '.json')) for label, _ in manifests], pin(RUNNER)], jobs=jobs,
                unqualified=not bool(a.qualification), researchOnly=not bool(a.qualification),
                scope='Research mode: one preliminary N1 comparison; qualified mode: two separate sequential three-round timing blocks. Compare roles within each block; report block drift. Request and ready-executable clocks remain distinct. Native prepared Base/cached runtime versus upstream source Base/runtime build remain disclosed.')
    (out / 'jobs.json').write_text(json.dumps(plan, indent=2) + '\n')
    print(json.dumps(dict(complete=True, targetsRun=False, plan=pin(out / 'jobs.json'), jobs=jobs)))


if __name__ == '__main__':
    main()

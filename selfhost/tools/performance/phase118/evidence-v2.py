#!/usr/bin/env python3
"""Offline selected-result replay with an optional exact45 native-source bridge.

Reuses frozen evidence.py gates. No compiler, program, or subprocess execution.
"""
import argparse
import importlib.util
import json
from pathlib import Path

HERE = Path(__file__).resolve().parent
spec = importlib.util.spec_from_file_location('p118_frozen_evidence_v1', HERE / 'evidence.py')
old = importlib.util.module_from_spec(spec)
spec.loader.exec_module(old)
ROOT, BASE, BENCH = old.ROOT, old.BASE, old.BENCH
require, read, save = old.require, old.read, old.save
V1_SHA256 = '94031d4eb931e461a50ba711e33b10ea4e9c638e90bd559cbaedce4b4ae64437'


def same_bytes(left, right):
    with Path(left).open('rb') as a, Path(right).open('rb') as b:
        while True:
            x, y = a.read(1024 * 1024), b.read(1024 * 1024)
            if x != y:
                return False
            if not x:
                return True


def equivalence(a, report_path, broad):
    new, lineage = old.producer(a, report_path)
    previous = a.receipt(a.verify(broad['emission']))
    require(new['runtime'] == broad['lineage']['runtime'], 'Exact45 bridge changed the linked runtime')
    catalogue = read(BENCH / 'manifest01.json')
    names = [c['name'] for c in catalogue['cases']]
    before = {r['name']: r for r in previous['cases']}
    after = {r['name']: r for r in new['cases']}
    require(len(names) == len(before) == len(after) == len(new['cases']) == 45 and
            set(names) == set(before) == set(after), 'Exact45 bridge missing/duplicate fixture')
    require(old.pin_in(a.pin(HERE / 'emit-integrated.mjs'), new['inputs']), 'Unexpected bridge emitter method')
    rows = []
    for case in catalogue['cases']:
        name = case['name']; left, right = before[name], after[name]
        require(left['source'] == right['source'] == case['source'], 'Bridge fixture identity changed: ' + name)
        require(right.get('verified') and right.get('parentVerified'), 'Bridge checked-emission gate incomplete: ' + name)
        require(right.get('exactDiagnosticMatch') == left['qbe'], 'Bridge lacks exact original-emission binding: ' + name)
        for pin in [case['source'], case['expectedStdoutEvidence'], left['qbe'], right['qbe']]:
            a.verify(pin)
        require(all(left['qbe'][k] == right['qbe'][k] for k in ['bytes', 'sha256']), 'Bridge QBE hash/size mismatch: ' + name)
        require(same_bytes(left['qbe']['file'], right['qbe']['file']), 'Bridge raw QBE byte mismatch: ' + name)
        rows.append(dict(name=name, fixture=case['source'], timedQbe=left['qbe'], nativeSourceHostedQbe=right['qbe'], byteExact=True))
    return dict(complete=True, targetsRun=False, cases=rows, exactCases=45, report=a.pin(report_path),
                originalEmission=broad['emission'], timedProducer=broad['lineage'], nativeProducer=lineage,
                runtimeIdentical=True, normalization=False,
                scope='Original45 checked hosted emissions are byte-identical under the same runtime. Timings remain hosted float-source01 measurements. This connects that finite corpus to the separate native-source producer; it does not establish native self-reproduction, native-generated timings, or arbitrary compiler equivalence.')


def native_status(a, plan_path, lineage):
    if plan_path is None:
        return dict(state='not-requested', independentlyReplayed=False)
    plan = a.receipt(plan_path)
    require(plan['kind'] == 'phase118-request-bound-native-qualification-plan', 'Unexpected native plan kind')
    require(all(plan[k] == lineage[k] for k in ['source', 'api', 'runtime']), 'Native plan differs from the authenticated bridge producer')
    rows, parsed = [], {}
    for key, path in plan['artifacts'].items():
        p = Path(path) if key == 'comparison' else Path(path) / ('process.json' if key == 'guard' else 'report.json')
        if not p.exists():
            rows.append(dict(stage=key, file=str(p), state='pending'))
            continue
        receipt = a.pin(p); j = read(p); a.pin(p)
        parsed[key] = j
        rows.append(dict(stage=key, receipt=receipt, state='reported-complete' if j.get('complete') else 'incomplete',
                         reportedComplete=j.get('complete'), reportedError=j.get('error'),
                         returncode=j.get('returncode'), finished=j.get('finished'), byteExact=j.get('byteExact')))
    guard = parsed.get('guard', {})
    terminal_failure = (isinstance(guard.get('finished'), (int, float)) and
                        isinstance(guard.get('returncode'), int) and guard['returncode'] != 0)
    if terminal_failure:
        state = 'terminal-failed'
        for row in rows:
            if row['state'] == 'pending':
                row['state'] = 'not-reached-after-terminal-failure'
    elif all(x['state'] == 'reported-complete' for x in rows):
        state = 'all-receipts-reported-complete'
    else:
        state = 'pending-or-incomplete'
    return dict(plan=a.pin(plan_path), state=state, stages=rows, independentlyReplayed=False,
                scope='Native qualification receipt inventory, distinct from hosted405/control19 replay. A finished nonzero outer guard is terminal failure and may be archived honestly; missing successor stages then remain unqualified. Native suite/lineage claims require their separate pinned qualification receipts.')


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--out', type=Path, required=True)
    p.add_argument('--broad', type=Path, default=BASE / 'broad-screen01/report.json')
    p.add_argument('--broad-emission', type=Path, default=BASE / 'broad-emit01/report.json')
    p.add_argument('--broad-summary', type=Path, default=BASE / 'broad-summary01.json')
    p.add_argument('--controls', type=Path, default=BASE / 'all-controls-run01/report.json')
    p.add_argument('--control-emission', type=Path, default=BASE / 'all-controls-emit01/report.json')
    p.add_argument('--control-manifest', type=Path, default=HERE / 'all-controls03.json')
    p.add_argument('--native-plan', type=Path)
    p.add_argument('--native-equivalence-report', type=Path)
    p.add_argument('--capsule', action='store_true')
    p.add_argument('--max-capsule-mib', type=int, default=16)
    args = p.parse_args(); out = args.out.resolve()
    require(not out.exists() and out.is_relative_to(ROOT), 'Fresh repository-local output required')
    out.mkdir(parents=True)
    a = old.Audit(); a.pin(__file__)
    require(a.pin(HERE / 'evidence.py')['sha256'] == V1_SHA256, 'Frozen v1 replay gates changed')
    result = dict(kind='phase118-independent-selected-evidence-replay-v2', complete=False, targetsRun=False)
    try:
        broad = old.replay_broad(a, args.broad, args.broad_emission, args.broad_summary)
        controls = old.replay_controls(a, args.controls, args.control_emission, args.control_manifest,
                                       broad['lineage'], read(BENCH / 'manifest01.json')['directToolchain'])
        bridge = equivalence(a, args.native_equivalence_report, broad) if args.native_equivalence_report else None
        native_lineage = bridge['nativeProducer'] if bridge else broad['lineage']
        native = native_status(a, args.native_plan, native_lineage)
        result.update(complete=True, broad=broad, controls=controls, nativeEquivalence=bridge, native=native,
                      inputs=list(a.pins.values()),
                      scope='Offline original hosted float405/control19 replay; optional separately authenticated exact45 producer bridge. Native qualification remains separately labeled. No target execution or new timing.')
        save(out / 'replay.json', result)
        producers = [broad['lineage']] + ([native_lineage] if bridge else [])
        mandatory = [x[k]['file'] for x in producers for k in ['source', 'api', 'parent']]
        inv = old.inventory(a, out, mandatory, native)
        inv.update(method=a.pin(__file__), replayDependency=a.pin(HERE / 'evidence.py'),
                   timedProducer=broad['lineage'], nativeProducer=native_lineage,
                   nativeEquivalenceReport=bridge['report'] if bridge else None)
        save(out / 'capsule-manifest.json', inv)
        summary = dict(complete=True, targetsRun=False, replay=a.pin(out / 'replay.json'), inventory=a.pin(out / 'capsule-manifest.json'),
                       observations=broad['observations'], controls=controls['observations'], timedCases=broad['timedCases'],
                       candidateVsUpstream=broad['candidateVsUpstream'], speedup=broad['speedup'],
                       timingProducer=broad['lineage']['source'], nativeProducer=native_lineage['source'],
                       nativeBridgeCases=bridge['exactCases'] if bridge else 0,
                       nativeState=native['state'], capsuleCreated=False)
        if args.capsule:
            require(native['state'] != 'pending-or-incomplete', 'Native campaign is not terminal; inventory retained, capsule deferred')
            summary.update(old.archive(a, out, inv, args.max_capsule_mib), capsuleCreated=True)
        save(out / 'summary.json', summary)
        print(json.dumps(summary))
    except Exception as error:
        result.update(complete=False, error=str(error))
        save(out / 'failure.json', result)
        raise


if __name__ == '__main__':
    main()

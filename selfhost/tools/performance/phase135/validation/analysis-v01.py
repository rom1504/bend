#!/usr/bin/env python3
"""Summarize completed Phase135 JSON receipts; no targets or generated-code reads."""
import argparse
import hashlib
import json
import math
from pathlib import Path

ROOT = Path(__file__).resolve().parents[5]
READS = {}


def require(ok, message):
    if not ok:
        raise ValueError(message)


def pin_metadata(path):
    path = Path(path).resolve()
    require(path.is_file() and path.stat().st_size <= 16 * 1024**2,
            'Bounded metadata file required: ' + str(path))
    data = path.read_bytes()
    return dict(file=str(path), bytes=len(data), sha256=hashlib.sha256(data).hexdigest()), data


def read(path, expected=None, completed=True):
    item, data = pin_metadata(path)
    require(expected is None or item == expected, 'Linked receipt identity changed')
    if item['file'] in READS:
        require(READS[item['file']] == item, 'Receipt changed during analysis')
    READS[item['file']] = item
    value = json.loads(data)
    require(not completed or value.get('complete') is True, 'Incomplete evidence: ' + item['file'])
    return value, item


def linked(item):
    return read(item['file'], item)


def identity(item):
    return {k: item[k] for k in ('bytes', 'sha256')}


def gm(values):
    require(bool(values) and all(v > 0 for v in values), 'Positive observations required')
    return math.exp(sum(map(math.log, values)) / len(values))


def requests(stats):
    return stats.get('requests', {k: stats[k] for k in ('A', 'B') if k in stats})


def machine(item):
    report, receipt = linked(item)
    require(report['kind'] == 'phase135-framed-machine-build' and report['expectedPayloadExact'],
            'Independent complete machine payload required')
    units = report['units']
    require([u['index'] for u in units] == list(range(len(units))), 'Ordered current unit inventory required')
    hits = sum(bool(u['reused']) for u in units)
    require(hits == report['reusedUnits'] and len(units) - hits == report['builtUnits'], 'Unit counters differ')
    return report, dict(receipt=receipt, source=report['source'], payload=report['payloadDigest'],
        binary=report['binary'], units=len(units), hits=hits, misses=len(units)-hits,
        hitFraction=hits/len(units), maximumUnitBytes=report['maximumUnitBytes'],
        childSeconds=report['childSeconds'], consumerWallSeconds=report['seconds'],
        clockScope='Consumer wall includes waiting for its input; child seconds are nested tool wall times, not CPU usage.')


def replay(path, expected_kind, native_b_item):
    report, receipt = read(path)
    require(report['kind'] == expected_kind and report['exitCodes'] == [0, 0]
            and report['currentBuild'] == native_b_item, 'Successful current B replay required')
    built, summary = machine(report['machineReport'])
    summary.update(replayReceipt=receipt, replaySeconds=report['seconds'],
        preflightSeconds=report['preflightSeconds'], totalSeconds=report['totalSeconds'],
        clockScope='Matched backend-only replay. Total includes authenticated preflight; excludes compiler, frontend and Bend rendering.')
    return report, receipt, built, summary


def main():
    ap = argparse.ArgumentParser(description=__doc__)
    for name in ('ordinary-baseline', 'semantic-session', 'native-session', 'cached-replay',
                 'cold-replay', 'cache-snapshot', 'cache-membership', 'gates-summary'):
        ap.add_argument('--'+name, type=Path, required=True)
    ap.add_argument('--guard', action='append', default=[], metavar='LABEL=PROCESS_JSON')
    ap.add_argument('--out', type=Path, required=True)
    a = ap.parse_args()
    out = a.out.resolve()
    require(not out.exists() and (out.is_relative_to(ROOT/'selfhost/build/phase135')
        or out.is_relative_to(ROOT/'implementation/phase135')), 'Fresh Phase135 metrics destination required')
    baseline, baseline_pin = read(a.ordinary_baseline)
    semantic, semantic_pin = read(a.semantic_session)
    require(baseline['kind'] == 'phase130-native-source-qbe-request' and baseline['byteExact']
        and baseline['exitCode'] == 0 and semantic['kind'] == 'phase135-real-compiler-edit-session-result'
        and semantic['exitCode'] == 0 and baseline['image'] == semantic['image'], 'Same-image ordinary/session evidence required')
    semantic_plan, _ = linked(semantic['plan'])
    require(baseline['source'] == semantic_plan['revisions'][1]['source'], 'Ordinary and warm B source differs')
    sb = next(p for p in semantic['products'] if p['role'] == 'B')
    require(sb['byteExact'] and identity(sb['actual']) == identity(baseline['product']), 'Ordinary/warm B product differs')
    warm_b = requests(semantic['stats'])['B']['milliseconds']/1000
    ordinary = baseline['nativeSeconds']
    baseline_comparison = dict(ordinaryReceipt=baseline_pin, sessionReceipt=semantic_pin,
        sameImage=baseline['image'], source=baseline['source'], byteExact=True,
        ordinaryWholeProcessSeconds=ordinary, warmBRequestSeconds=warm_b,
        observedWarmOverOrdinary=warm_b/ordinary, observedDifferenceSeconds=warm_b-ordinary,
        ordinaryCpuSeconds=baseline['cpuSeconds'], ordinaryPeakRssKiB=baseline['peakRssKiB'],
        sessionNativeWallSeconds=semantic['nativeWallSeconds'], sessionSupervisorSeconds=semantic['totalSeconds'],
        scope='Single same-image comparison with unequal clocks: ordinary includes startup/Base/teardown; warm B excludes shared preparation. No balanced causal cache-effect estimate or upstream comparison.',
        demonstratedNetCacheSpeedWin=False)

    native, native_pin = read(a.native_session)
    require(native['kind'] == 'phase135-native-framed-machine-session' and native['producerExitCode'] == 0
        and len(native['machineReports']) == 2, 'Successful complete A/B producer join required')
    machine_a, summary_a = machine(native['machineReports'][0])
    machine_b, summary_b = machine(native['machineReports'][1])
    for i, report in enumerate((machine_a, machine_b)):
        require(report['source'] == native['sources'][i] and report['context']['producer'] == native['producer']
            and report['context']['runtime'] == native['runtime'], 'Joined machine source/context differs')
    require(machine_a['context'] == machine_b['context'], 'Native A/B machine contexts differ')
    stages = native['stats']['stages']
    require(set(stages) == {'A', 'B'}, 'Both native stage partitions required')
    stage_rows = {}
    for side, request in requests(native['stats']).items():
        values = stages[side]
        require(set(values) == {'frontend', 'lowering', 'optimize', 'render'} and
            sum(values.values()) == request['milliseconds'] and request['milliseconds'] > 0,
            'Stage intervals do not partition the request')
        stage_rows[side] = dict(requestSeconds=request['milliseconds']/1000, semanticCacheCounts=request['counts'],
            seconds={k:v/1000 for k,v in values.items()}, fractions={k:v/request['milliseconds'] for k,v in values.items()})
    native_summary = dict(receipt=native_pin, producer=native['producer'], sources=native['sources'],
        preparationSeconds=native['stats']['preparationMilliseconds']/1000, stages=stage_rows,
        pipelineSeconds=native['seconds'], preflightSeconds=native['preflightSeconds'],
        pipelinePlusPreflightSeconds=native['seconds']+native['preflightSeconds'],
        machineA=summary_a, machineB=summary_b,
        scope='Whole native producer plus serial machine consumers. Render includes FIFO backpressure and close. Consumer, stage and child wall intervals overlap; do not sum them. This newer image is not the equal-image ordinary baseline.',
        stageDefinitions=dict(frontend='Parse/check, ownership, annotation, reachability and erasure before runtime admission.',
            lowering='Runtime admission, certificate and common raw native lowering.',
            optimize='Remaining private preparation/optimization/cache checks, verification and emission-plan construction.',
            render='Render/framing/output/close including machine-consumer backpressure.'))

    cached, cached_pin, cached_build, cached_summary = replay(a.cached_replay,
        'phase135-supervised-cached-replay', native['machineReports'][1])
    cold, cold_pin, cold_build, cold_summary = replay(a.cold_replay,
        'phase135-supervised-cold-replay', native['machineReports'][1])
    require(cold_build['cold'] and cold_build['reusedUnits'] == 0 and not cached_build['cold']
        and cold_build['cache'] != cached_build['cache'], 'Independent empty cold versus existing cache required')
    for report in (cached_build, cold_build):
        require(report['context'] == machine_b['context'] and report['source'] == machine_b['source']
            and report['payloadDigest'] == machine_b['payloadDigest'], 'Matched replay payload/context differs')
    snapshot, snapshot_pin = read(a.cache_snapshot)
    membership, membership_pin = read(a.cache_membership)
    require(snapshot['kind'] == 'phase135-revision-a-cache-view' and snapshot['producerJoin'] == native_pin
        and snapshot['aReport'] == native['machineReports'][0] and snapshot['bReport'] == native['machineReports'][1],
        'A-only snapshot not bound to current native session')
    require(membership['kind'] == 'phase135-a-to-b-replay-membership' and membership['exactAOnlyHitMask']
        and membership['snapshot'] == snapshot_pin and membership['replay'] == cached_pin
        and membership['machineReport'] == cached['machineReport'], 'Actual A-only replay admission check required')
    a_keys = {u['key'] for u in machine_a['units']}
    require(a_keys == {u['key'] for u in snapshot['entries']}, 'Snapshot membership differs from A')
    unit_rows = []
    require(len(machine_b['units']) == len(cached_build['units']) == len(cold_build['units']), 'Replay unit counts differ')
    for original, reused, fresh in zip(machine_b['units'], cached_build['units'], cold_build['units']):
        for k in ('index', 'key', 'kind', 'payload'):
            require(original[k] == reused[k] == fresh[k], 'Matched ordered replay unit differs')
        expected = original['key'] in a_keys
        require(bool(reused['reused']) == expected and bool(original['reused']) == expected and not fresh['reused'],
            'Native and replay B hit masks differ from A-only membership')
        unit_rows.append(dict(index=original['index'], key=original['key'], kind=original['kind'],
            bytes=original['payload']['bytes'], inA=expected, nativeBHit=bool(original['reused']), replayHit=bool(reused['reused'])))
    replay_comparison = dict(cached=cached_summary, cold=cold_summary, snapshot=snapshot_pin,
        membership=membership_pin, snapshotPreparationSeconds=snapshot['seconds'],
        cachedOverColdTotal=cached['totalSeconds']/cold['totalSeconds'],
        cachedOverColdExecution=cached['seconds']/cold['seconds'],
        cachedOverColdChild=cached_build['childSeconds']/cold_build['childSeconds'],
        totalSecondsSaved=cold['totalSeconds']-cached['totalSeconds'],
        exactNativeAndReplayHitMask=True, units=unit_rows,
        scope='One matched replay pair of current B against A-only entries versus an empty cache. Includes each replay preflight; snapshot acquisition separately reported. This is backend-only savings, not full edit-loop savings.')

    gates, gates_pin = read(a.gates_summary)
    plan, plan_pin = linked(gates['plan'])
    require(plan['kind'] == 'phase135-small-machine-semantic-gates' and gates['exitCode'] == 0
        and len(gates['requests']) == 18 and len(gates['ordinary']) == 6
        and plan['producerJoin'] == native_pin and plan['replayJoin'] == cold_pin
        and plan['roles']['warm'] == machine_b['binary'] and plan['roles']['cold'] == cold_build['binary'],
        'Completed matching compiler/ordinary gates required')
    cases = sorted({r['case'] for r in gates['requests']})
    require(len(cases) == 3, 'Three frozen request cases required')
    comparisons = []
    ratios_by_role = {role: [] for role in ('cold','warm')}
    for case in cases:
        for role in ratios_by_role:
            ratios = []
            for round_index in range(2):
                rows = [r for r in gates['requests'] if r['case'] == case and r['round'] == round_index]
                require(len(rows) == 3 and {r['role'] for r in rows} == {'monolithic','cold','warm'}, 'Paired gate schedule differs')
                values = {r['role']:r['nativeSeconds'] for r in rows}
                ratios.append(values[role]/values['monolithic'])
            comparisons.append(dict(case=case, role=role, pairedRatios=ratios, geomean=gm(ratios)))
            ratios_by_role[role].extend(ratios)
    gate_summary = dict(receipt=gates_pin, plan=plan_pin, fullQbeGates=18, ordinaryOutputs=6,
        perCase= comparisons, aggregatePairedGeomeans={role:gm(values) for role,values in ratios_by_role.items()},
        summedNativeRequestSeconds=sum(r['nativeSeconds'] for r in gates['requests']),
        scope='Three cases, two reversed-order rounds. Ratios measure edited compiler image request speed versus the same-source monolithic image. Exact generated QBE preserves program code quality; ordinary executions are not runtime benchmarks or full N2 qualification.')

    guards=[]
    for value in a.guard:
        label, sep, path = value.partition('=')
        require(sep and label and path, 'Use --guard LABEL=PROCESS_JSON')
        guard, item = read(path, completed=False)
        require('returncode' in guard and 'wallSeconds' in guard and 'finished' in guard, 'Closed resource guard required')
        guards.append(dict(label=label, receipt=item, complete=guard['complete'], returncode=guard['returncode'], wallSeconds=guard['wallSeconds'],
            peakTreeRssBytes=guard['peakTreeRssBytes'], minimumAvailableBytes=guard['minimumAvailableBytes'],
            rssLimitBytes=guard['rssLimitBytes'], availableFloorBytes=guard['availableFloorBytes'],
            started=guard['started'], finished=guard['finished']))
    method, _ = pin_metadata(__file__)
    for item in READS.values():
        require(pin_metadata(item['file'])[0] == item, 'Receipt changed during analysis')
    result=dict(kind='phase135-final-metrics', complete=True, targetsRun=False, generatedCodeRead=False,
        method=method, inputs=list(READS.values()), sameImageSemanticCache=baseline_comparison,
        nativeFramedSession=native_summary, matchedMachineReplay=replay_comparison,
        compilerMachineGates=gate_summary, resourceGuards=guards,
        accounting='Guard/process/stage/tool clocks have different and sometimes nested boundaries. No grand sum is made. Acquisition, cache preparation, failed attempts and agent effort must remain separately accounted; unprovided costs are unmeasured.',
        claimsExcluded=['upstream performance ratio','new full N2 qualification','generated-program runtime speedup',
            'net end-to-end edit gain from backend-only replay','recursive acceleration'])
    out.parent.mkdir(parents=True,exist_ok=True)
    out.write_text(json.dumps(result,indent=2)+'\n')
    print(json.dumps(dict(complete=True, targetsRun=False, metrics=pin_metadata(out)[0],
        semanticWarmOverOrdinary=warm_b/ordinary, matchedBackendCachedOverCold=replay_comparison['cachedOverColdTotal'],
        compilerRequestRatios=gate_summary['aggregatePairedGeomeans'])))


if __name__ == '__main__':
    main()

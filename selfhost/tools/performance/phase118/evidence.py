#!/usr/bin/env python3
"""Offline Phase118 oracle/lineage replay and bounded, content-addressed capsule.

No compiler or target subprocess is launched. A fresh output directory is required.
The default writes a replay and capsule inventory; --capsule also writes exact
deduplicated payloads. Native qualification status is reported separately.
"""
import argparse
import gzip
import hashlib
import importlib.util
import io
import json
import math
from pathlib import Path
import re
import statistics
import tarfile

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[3]
BASE = ROOT / 'selfhost/build/phase118'
BENCH = ROOT / 'selfhost/tools/performance/phase112/benchmark45'


def require(ok, message):
    if not ok:
        raise ValueError(message)


def read(path):
    return json.loads(Path(path).read_text())


def save(path, data):
    with Path(path).open('x') as f:
        json.dump(data, f, indent=2, ensure_ascii=False)
        f.write('\n')


def module(path, name):
    spec = importlib.util.spec_from_file_location(name, path)
    obj = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(obj)
    return obj


class Audit:
    def __init__(self):
        self.pins = {}
        self.stamps = {}

    def pin(self, path):
        p = (ROOT / path).resolve(strict=True)
        stamp = (p.stat().st_size, p.stat().st_mtime_ns)
        if str(p) in self.pins:
            require(self.stamps[str(p)] == stamp, 'Input changed during replay: ' + str(p))
            return self.pins[str(p)]
        h = hashlib.sha256()
        with p.open('rb') as f:
            for b in iter(lambda: f.read(1024 * 1024), b''):
                h.update(b)
        require(stamp == (p.stat().st_size, p.stat().st_mtime_ns), 'Unstable input: ' + str(p))
        row = dict(file=str(p), bytes=stamp[0], sha256=h.hexdigest())
        self.pins[str(p)], self.stamps[str(p)] = row, stamp
        return row

    def verify(self, row):
        actual = self.pin(row['file'])
        require(all(actual[k] == row[k] for k in ['bytes', 'sha256']), 'Changed pinned input: ' + row['file'])
        return Path(actual['file'])

    def inputs(self, obj):
        for row in obj.get('inputs', []):
            self.verify(row)

    def receipt(self, path, complete=True):
        self.pin(path)
        obj = read(path)
        require(not complete or obj.get('complete'), 'Incomplete receipt: ' + str(path))
        self.inputs(obj)
        return obj


def pin_in(row, rows):
    return any(all(x.get(k) == row.get(k) for k in ['file', 'bytes', 'sha256']) for x in rows)


def producer(a, emission_path):
    e = a.receipt(emission_path)
    require(e.get('kind') == 'phase118-request-bound-integrated-emission', 'Unexpected selected entry contract')
    require(all(e.get(k) for k in ['derived', 'borrowed', 'cold']), 'Selected ownership stages missing')
    for key in ['api', 'source', 'runtime']:
        a.verify(e[key])
        require(pin_in(e[key], e['inputs']), 'Emission lacks producer pin: ' + key)
    ar = a.receipt(Path(e['api']['file']).parent / 'report.json')
    require(ar.get('checked') and ar.get('status') == 0 and ar['api'] == e['api'], 'Unchecked API')
    require('p111_emit_admitted' in ar['exports'] and pin_in(e['source'], ar['inputs']), 'API/source entry mismatch')
    require([str(Path(x).resolve()) for x in ar['command'] if x.endswith('.bend')] == [e['source']['file']], 'Checked another source')
    rp = Path(e['runtime']['file']).parent / 'report.json'
    rr = a.receipt(rp)
    require(rr.get('object') == e['runtime'] and rr.get('status') == 0, 'Runtime object mismatch')
    a.verify(rr['source'])
    sp = Path(e['source']['file']).parent / 'manifest.json'
    sm = a.receipt(sp)
    contract_tool = module(HERE / 'native-plan.py', 'p118_evidence_contract')
    a.pin(HERE / 'native-plan.py')
    contract = contract_tool.source_contract(Path(e['source']['file']), sm)
    for row in contract['snapshots']:
        a.verify(row)
    return e, dict(source=e['source'], api=e['api'], apiReport=a.pin(Path(e['api']['file']).parent / 'report.json'),
                   runtime=e['runtime'], runtimeSource=rr['source'], runtimeReport=a.pin(rp),
                   sourceManifest=a.pin(sp), parent=sm['parent'], contract=contract)


def build(a, path, qbe, runtime, toolchain):
    b = a.receipt(path)
    require(b.get('kind') == 'phase111-direct-qbe-build' and b.get('cachedRuntime') and
            b.get('perProgramC') is False and b.get('cproc') is False, 'Unexpected machine-build contract')
    require(pin_in(qbe, b['inputs']) and pin_in(runtime, b['inputs']), 'Machine build input mismatch')
    jobs = b['jobs']
    require([x['label'] for x in jobs] == ['qbe', 'assemble', 'link'] and all(x['exitCode'] == 0 for x in jobs), 'Machine stages failed')
    q, ass, link = [x['command'] for x in jobs]
    require(len(q) == 6 and q[1:4] == ['-t', 'amd64_sysv', '-o'] and q[-1] == qbe['file'], 'QBE command changed')
    require(len(ass) == 4 and ass[1] == '-o' and ass[3] == q[4], 'Assembler command changed')
    require(len(link) == 8 and link[1:4] == ['-no-pie', ass[2], runtime['file']] and
            link[4:7] == ['-pthread', '-lm', '-o'] and link[7] == b['binary']['file'], 'Link command changed')
    for label, command in [('qbe', q), ('assembler', ass), ('linker', link)]:
        require(a.pin(command[0]) == toolchain[label], 'Toolchain mismatch: ' + label)
    for job in jobs:
        a.verify(job['stdout']); a.verify(job['stderr'])
    a.verify(b['binary']); a.verify(b['object'])
    return b


def replay_broad(a, report_path, emission_path, summary_path):
    manifest_path, profile_path = BENCH / 'manifest01.json', BENCH / 'upstream-50ms-profile01.json'
    manifest, profile = read(manifest_path), read(profile_path)
    a.pin(manifest_path); a.pin(profile_path); a.verify(profile['manifest'])
    original = module(BENCH / 'run.py', 'p118_original_oracle')
    a.pin(BENCH / 'run.py')
    cases = {x['name']: x for x in manifest['cases']}
    require(len(cases) == len(manifest['cases']) == 45, 'Original45 catalogue changed')
    e, lineage = producer(a, emission_path)
    emissions = {x['name']: x for x in e['cases']}
    require(len(e['cases']) == 45 and set(emissions) == set(cases), 'Incomplete emission coverage')
    report = a.receipt(report_path)
    require(pin_in(a.pin(emission_path), report['inputs']), 'Timing report/emission mismatch')
    selection = a.receipt(ROOT / 'implementation/phase117/selection.json', complete=False)
    old = a.receipt(a.verify(selection['broad']))
    baseline = {r['name']: r['binary'] for r in old['rows'] if r['role'] == 'candidate'}
    built = {}
    require(len(report['builds']) == 45, 'Incomplete machine-build coverage')
    for row in report['builds']:
        name = row['name']
        require(name in cases and name not in built and row['status'] == 0, 'Duplicate/failed machine build')
        ec = emissions[name]
        require(ec['source'] == cases[name]['source'] and ec.get('verified') and ec.get('parentVerified'), 'Source/IR admission mismatch')
        a.verify(ec['qbe'])
        built[name] = build(a, a.verify(row['report']), ec['qbe'], e['runtime'], manifest['directToolchain'])['binary']
    seen, samples = set(), {name: {role: [] for role in ['candidate', 'baseline', 'upstream']} for name in cases}
    for row in report['rows']:
        name, role, rnd = row['name'], row['role'], row['round']
        require(name in cases and role in samples[name] and rnd in [0, 1, 2], 'Unknown observation')
        require((name, role, rnd) not in seen, 'Duplicate observation')
        seen.add((name, role, rnd))
        c = dict(cases[name], **profile['cases'][name])
        expected_binary = {'candidate': built[name], 'baseline': baseline[name], 'upstream': c['upstream']['binary']}[role]
        require(row['binary'] == expected_binary, 'Observation binary lineage mismatch')
        for x in [row['binary'], c['source'], c['expectedStdoutEvidence'], row['stdout'], row['stderr']]:
            a.verify(x)
        require(Path(c['expectedStdoutEvidence']['file']).read_bytes() == c['expectedStdout'].encode(), 'Original oracle evidence mismatch')
        command = [row['binary']['file'], '--threads', '1', '--gpu', 'off', '--', str(c['repetitions']), str(c['warmups']), *map(str, c['runtimeArgs'])]
        require(row['command'] == command, 'Workload count/argument/worker mismatch')
        stdout, stderr = [Path(row[k]['file']).read_bytes() for k in ['stdout', 'stderr']]
        prefix = (c['expectedStdout'] + str(c['warmups']) + '\n' + str(c['repetitions']) + '\n').encode()
        require(not stderr and stdout.startswith(prefix) and re.fullmatch(rb'[0-9]+\n', stdout[len(prefix):]), 'Full original output/count mismatch')
        elapsed = int(stdout[len(prefix):])
        require(elapsed == original.observation(stdout, stderr, 0, c, row['wallSeconds']) == row['elapsedMs'], 'Elapsed receipt/oracle mismatch')
        require(not c['ratioEligible'] or elapsed >= profile['minimumMs'], 'Timed interval below frozen floor')
        # screen.py persists rows only after checking returncode=0; it does not
        # retain a per-row exit code. Do not imply independent exit-status evidence.
        samples[name][role].append(elapsed)
    require(len(seen) == 405 and all(len(xs) == 3 for roles in samples.values() for xs in roles.values()), 'Missing original45 observations')
    rows = []
    for name, roles in samples.items():
        med = {k: statistics.median(v) for k, v in roles.items()}
        timed = cases[name]['ratioEligible']
        rows.append(dict(name=name, samplesMs=roles, medianMs=med, timed=timed,
                         candidateVsUpstream=med['candidate'] / med['upstream'] if timed else None,
                         speedup=med['baseline'] / med['candidate'] if timed else None))
    timed = [r for r in rows if r['timed']]
    gm = lambda key: math.exp(sum(math.log(r[key]) for r in timed) / len(timed))
    result = dict(observations=len(seen), timedCases=len(timed), candidateVsUpstream=gm('candidateVsUpstream'), speedup=gm('speedup'), cases=rows)
    require(len(timed) == 44, 'Zero-work exclusion changed')
    recorded = read(summary_path); a.pin(summary_path)
    require(recorded.get('complete'), 'Incomplete recorded broad summary')
    for key in ['observations', 'timedCases']:
        require(result[key] == recorded[key], 'Recorded aggregate count mismatch')
    for key in ['candidateVsUpstream', 'speedup']:
        require(math.isclose(result[key], recorded[key], rel_tol=1e-13), 'Recorded geomean mismatch')
    require(result['cases'] == recorded['cases'], 'Recorded per-case sample/median/ratio mismatch')
    result.update(complete=True, report=a.pin(report_path), emission=a.pin(emission_path), recordedSummary=a.pin(summary_path),
                  oracle=a.pin(manifest_path), profile=a.pin(profile_path), lineage=lineage,
                  elapsedReductionFraction=1 - 1 / result['speedup'],
                  exitStatusEvidence='Frozen screen method accepts only status 0 before storing each row; raw per-observation exit status is not recorded.',
                  scope='Hosted-emitted programs, 45 full-output cases, three roles x three rounds. 44 nonzero-work medians; geometric mean of per-case ratios. No compiler throughput or native-image claim.')
    return result


def replay_controls(a, report_path, emission_path, manifest_path, lineage, toolchain):
    m = a.receipt(manifest_path)
    cases = {c['name']: c for c in m['cases']}
    require(len(cases) == len(m['cases']) == 19, 'Selected control catalogue changed')
    e = a.receipt(emission_path)
    require(all(e[k] == lineage[k] for k in ['source', 'api', 'runtime']), 'Control producer differs from broad producer')
    emissions = {c['name']: c for c in e['cases']}
    r = a.receipt(report_path)
    require(pin_in(a.pin(manifest_path), r['inputs']) and pin_in(a.pin(emission_path), r['inputs']), 'Control provenance mismatch')
    require(len(r['rows']) == len(e['cases']) == 19 and set(emissions) == set(cases), 'Control emission coverage mismatch')
    old_method = ROOT / 'selfhost/tools/performance/phase102/trmc-cold/controls/prepare.py'
    original = module(old_method, 'p118_old_flat_oracle'); a.pin(old_method)
    rows, seen = [], set()
    for row in r['rows']:
        name = row['name']; require(name in cases and name not in seen, 'Unknown/duplicate control')
        seen.add(name); c, ec = cases[name], emissions[name]
        require(ec['source'] == c['source'] and ec.get('verified') and ec.get('parentVerified'), 'Control source/IR mismatch')
        for key in ['source', 'expected', 'expectedStdoutEvidence']:
            a.verify(c[key])
        if 'originalSource' in c:
            a.verify(c['originalSource'])
        expected = read(c['expected']['file'])
        evidence = read(c['expectedStdoutEvidence']['file'])
        if 'exitCode' in evidence:
            require(evidence.get('stage') == 'execute', 'Unknown original oracle schema')
            evidence = dict(status=evidence['exitCode'], stdout=evidence['stdout'], stderr=evidence['stderr'])
        require(evidence == expected, 'Original oracle/status wrapper differs')
        literal = ''.join(x[2:] + '\n' for x in Path(c['source']['file']).read_text().splitlines() if x.startswith('#|'))
        if name in ['mixed', 'shared']:
            values = ([original.value(0, False), original.value(1, False), original.value(1, True), original.value(5, False), original.value(6, True), 'λleft', '🙂right']
                      if name == 'mixed' else [original.value(6, True), original.value(6, True), 'λleft', '🙂right'])
            oracle = '\n'.join(values) + '\n'
            kind = 'retained Phase102 independent flat-description oracle'
        else:
            require(literal, 'Missing source literal oracle: ' + name)
            oracle, kind = literal, 'independent source #| literal'
        require(expected == dict(status=0, stdout=oracle, stderr=''), 'Frozen control oracle differs from independent expectation')
        a.verify(ec['qbe'])
        b = build(a, a.verify(row['build']), ec['qbe'], e['runtime'], toolchain)
        obpath = a.verify(row['observation']); ob = a.receipt(obpath)
        require(row['status'] == 0 and pin_in(b['binary'], ob['inputs']) and pin_in(c['expected'], ob['inputs']), 'Control observation lineage mismatch')
        actual = dict(status=ob['actual']['status'], stdout=(obpath.parent / 'stdout').read_text(), stderr=(obpath.parent / 'stderr').read_text())
        require(actual == ob['actual'] == ob['expected'] == expected, 'Raw control stdout/stderr/status mismatch')
        a.pin(obpath.parent / 'stdout'); a.pin(obpath.parent / 'stderr')
        rows.append(dict(name=name, source=c['source'], expected=c['expected'], oracleKind=kind, observation=a.pin(obpath)))
    return dict(complete=True, observations=len(rows), literalOracles=17, retainedFlatOracles=2,
                report=a.pin(report_path), emission=a.pin(emission_path), manifest=a.pin(manifest_path), cases=rows,
                scope='19 ordinary complete status/stdout/stderr observations; no abstract ownership-proof claim.')


def native_status(a, plan_path, lineage):
    if plan_path is None:
        return dict(state='not-requested', independentlyReplayed=False)
    plan = a.receipt(plan_path)
    require(plan['kind'] == 'phase118-request-bound-native-qualification-plan', 'Unexpected native qualification plan')
    require(all(plan[k] == lineage[k] for k in ['source', 'api', 'runtime']), 'Native plan differs from selected hosted producer')
    rows = []
    for key, path in plan['artifacts'].items():
        p = Path(path) if key == 'comparison' else Path(path) / ('process.json' if key == 'guard' else 'report.json')
        if not p.exists():
            rows.append(dict(stage=key, file=str(p), state='pending'))
            continue
        j = read(p)
        rows.append(dict(stage=key, receipt=a.pin(p), state='reported-complete' if j.get('complete') else 'incomplete',
                         reportedComplete=j.get('complete'), reportedError=j.get('error'),
                         byteExact=j.get('byteExact')))
    complete = all(x['state'] == 'reported-complete' for x in rows)
    return dict(plan=a.pin(plan_path), state='all-receipts-reported-complete' if complete else 'pending-or-incomplete', stages=rows,
                independentlyReplayed=False,
                scope='Receipt inventory only. Native lineage/raw-QBE equality and native semantic-suite oracles use their separately pinned qualification tools; not added to the hosted 405/19 counts.')


def inventory(a, out, mandatory, native):
    roots = [BASE, HERE, ROOT / 'implementation/phase118', ROOT / 'design/phase118', ROOT / 'experiments/phase118']
    roots += sorted((ROOT / 'selfhost/build/phase111').glob('p118-*'))
    roots += sorted((ROOT / 'selfhost/build/phase113').glob('p118-*'))
    paths = {p for d in roots if d.is_dir() for p in d.rglob('*') if p.is_file() and not p.is_symlink() and not p.is_relative_to(out)
             and not (p.is_relative_to(BASE) and p.relative_to(BASE).parts[0].startswith('evidence-') and p.name != 'failure.json')}
    paths |= {Path(r['file']) for r in a.pins.values() if Path(r['file']).is_relative_to(ROOT)}
    paths.add(out / 'replay.json')
    mandatory = {str(Path(p).resolve()) for p in mandatory}
    keep, excluded, states = [], [], []
    extensions = {'.json', '.md', '.py', '.mjs', '.bend', '.c', '.h', '.txt', '.log', '.stdout', '.stderr', '.p88'}
    for p in sorted(paths):
        size = p.stat().st_size
        rel = str(p.relative_to(ROOT))
        selected = str(p.resolve()) in mandatory
        reason = None
        if not selected:
            if p.name in {'compiler.bend', 'api.mjs'}:
                reason = 'Only selected full compiler/API snapshots are included; other exact identities remain in receipts and module inventories.'
            elif p.suffix in {'.ssa', '.s', '.o', '.program'} or p.name == 'program':
                reason = 'Generated QBE/assembly/objects/images stay local and externally pinned.'
            elif p.suffix not in extensions and p.name not in {'stdout', 'stderr'}:
                reason = 'Outside compact source/receipt/log inventory.'
            elif size > 4 * 1024 * 1024:
                reason = 'Large generated payload stays local and externally pinned.'
        if reason:
            known = a.pins.get(str(p.resolve()))
            excluded.append(dict(file=rel, bytes=size, sha256=known['sha256'] if known else None, reason=reason,
                                 hashScope='replayed local pin' if known else 'not rehashed; consult retained producer receipt'))
            continue
        row = a.pin(p)
        keep.append(dict(file=rel, bytes=row['bytes'], sha256=row['sha256'], blob='sha256/' + row['sha256']))
        if p.name in {'report.json', 'process.json'}:
            j = read(p)
            states.append(dict(file=rel, complete=j.get('complete'), kind=j.get('kind'), status=j.get('status', j.get('exitCode')),
                               seconds=j.get('seconds', j.get('buildSeconds')), error=j.get('error')))
    unique = {r['sha256']: r['bytes'] for r in keep}
    require(sum(unique.values()) <= 64 * 1024 * 1024, 'Unique capsule payload exceeds 64 MiB bound')
    return dict(kind='phase118-content-addressed-evidence-capsule', complete=True, targetsRun=False,
                method=a.pin(__file__), files=keep, omitted=excluded, receiptStates=states,
                paths=len(keep), uniquePayloads=len(unique), rawPathBytes=sum(r['bytes'] for r in keep), uniqueRawBytes=sum(unique.values()),
                nativeState=native['state'],
                scope='Exact source/methods, reports, raw small observations and guards, including rejected and incomplete attempts. Membership is not qualification. Selected compiler/API and parent source included; machine artifacts stay local. Reconstruct each file from its sha256 blob; repository-relative paths preserve provenance.')


def archive(a, out, inv, maximum):
    manifest = json.dumps(inv, indent=2, ensure_ascii=False).encode() + b'\n'
    path = out / 'capsule.tar.gz'
    with path.open('xb') as raw, gzip.GzipFile(filename='', mode='wb', fileobj=raw, mtime=0, compresslevel=6) as gz, tarfile.open(fileobj=gz, mode='w|') as tar:
        def add(name, data):
            info = tarfile.TarInfo(name); info.size = len(data); info.mtime = 0; info.mode = 0o644
            tar.addfile(info, io.BytesIO(data))
        add('manifest.json', manifest)
        done = set()
        for row in inv['files']:
            if row['sha256'] in done:
                continue
            data = (ROOT / row['file']).read_bytes()
            require(len(data) == row['bytes'] and hashlib.sha256(data).hexdigest() == row['sha256'], 'Capsule source changed')
            add(row['blob'], data); done.add(row['sha256'])
    require(path.stat().st_size <= maximum * 1024 * 1024, 'Compressed capsule exceeds requested bound')
    with tarfile.open(path, 'r:gz') as tar:
        require(tar.extractfile('manifest.json').read() == manifest, 'Capsule manifest mismatch')
        blobs = {r['blob']: r for r in inv['files']}
        require(set(tar.getnames()) == {'manifest.json', *blobs}, 'Unexpected capsule members')
        for name, row in blobs.items():
            data = tar.extractfile(name).read()
            require(len(data) == row['bytes'] and hashlib.sha256(data).hexdigest() == row['sha256'], 'Capsule payload mismatch')
    return dict(complete=True, archive=a.pin(path), allPayloadsVerified=True)


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
    p.add_argument('--capsule', action='store_true')
    p.add_argument('--max-capsule-mib', type=int, default=16)
    args = p.parse_args(); out = args.out.resolve()
    require(not out.exists() and out.is_relative_to(ROOT), 'Fresh repository-local output directory required')
    out.mkdir(parents=True)
    a = Audit(); a.pin(__file__)
    result = dict(kind='phase118-independent-selected-evidence-replay', complete=False, targetsRun=False)
    try:
        broad = replay_broad(a, args.broad, args.broad_emission, args.broad_summary)
        controls = replay_controls(a, args.controls, args.control_emission, args.control_manifest, broad['lineage'], read(BENCH / 'manifest01.json')['directToolchain'])
        native = native_status(a, args.native_plan, broad['lineage'])
        result.update(complete=True, broad=broad, controls=controls, native=native,
                      scope='Offline local byte/hash/oracle/lineage replay only. No target execution, no new measurement, no ownership proof, and no installed selection change.')
        result['inputs'] = list(a.pins.values())
        save(out / 'replay.json', result)
        mandatory = [broad['lineage'][k]['file'] for k in ['source', 'api', 'parent']]
        inv = inventory(a, out, mandatory, native)
        save(out / 'capsule-manifest.json', inv)
        summary = dict(complete=True, targetsRun=False, replay=a.pin(out / 'replay.json'), inventory=a.pin(out / 'capsule-manifest.json'),
                       observations=broad['observations'], controls=controls['observations'], timedCases=broad['timedCases'],
                       candidateVsUpstream=broad['candidateVsUpstream'], speedup=broad['speedup'],
                       nativeState=native['state'], capsuleCreated=False)
        if args.capsule:
            require(native['state'] != 'pending-or-incomplete', 'Native receipts are still pending; retain inventory and seal in a fresh run after completion')
            summary.update(archive(a, out, inv, args.max_capsule_mib), capsuleCreated=True)
        save(out / 'summary.json', summary)
        print(json.dumps(summary))
    except Exception as error:
        result.update(complete=False, error=str(error))
        save(out / 'failure.json', result)
        raise


if __name__ == '__main__':
    main()

#!/usr/bin/env python3
"""Bounded metadata-only Phase140 cost accounting; never invokes a target."""
from __future__ import annotations
import argparse
import datetime as dt
import hashlib
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[5]
SCOPES = [('selfhost/build/phase111', 'p140-*/process.json'),
          ('selfhost/build/phase140', '*/process.json')]
IMAGES = [('03', 'p140-n1', '01'), ('15', 'p140-n1b', '02'),
          ('17', 'p140-n1c', '03'), ('18', 'p140-n1d', '04')]
LOOPS = ['full-product01', 'full-batch01', 'batch-smoke01', 'batch-smoke02',
         'full-product02', 'batch-smoke03', 'full-product03']


def utc(value: str) -> float:
    parsed = dt.datetime.fromisoformat(value.replace('Z', '+00:00'))
    if parsed.tzinfo is None:
        raise ValueError('timestamps must include UTC offset')
    return parsed.timestamp()


def iso(value: float) -> str:
    return dt.datetime.fromtimestamp(value, dt.timezone.utc).isoformat()


def path(value: str | Path) -> Path:
    p = Path(value)
    p = p.resolve() if p.is_absolute() else (ROOT / p).resolve()
    p.relative_to(ROOT)
    return p


def payload(value: str | Path, limit: int = 8 << 20) -> bytes:
    p = path(value)
    if p.stat().st_size > limit:
        raise ValueError(f'bounded metadata/source read exceeded: {p}')
    return p.read_bytes()


def pin(value: str | Path, raw: bytes | None = None) -> dict:
    p = path(value)
    raw = payload(p) if raw is None else raw
    return {'file': str(p.relative_to(ROOT)), 'bytes': len(raw),
            'sha256': hashlib.sha256(raw).hexdigest()}


def read(value: str | Path) -> tuple[dict, dict]:
    raw = payload(value)
    return json.loads(raw), pin(value, raw)


def interval_union(rows: list[dict]) -> float:
    end = 0.0
    total = 0.0
    for start, finish in sorted((r['started'], r['finished']) for r in rows):
        if finish > end:
            total += finish - max(start, end)
            end = finish
    return total


def category(name: str, command: list[str]) -> str:
    text = ' '.join(command)
    if 'check-api.py' in text:
        return 'Checked API acquisition'
    if name.startswith('p140-acquire'):
        return 'Native compiler acquisition'
    if name in {f'{image}-guard' for _, image, _ in IMAGES}:
        return 'Native compiler machine build'
    if 'profile' in name:
        return 'Profiling campaign'
    if name.startswith('p140-full-'):
        return 'Complete native compiler-edit loops'
    if 'p140-reference-product' in name:
        return 'Independent full-product oracle'
    if 'build-aligned.py' in text:
        return 'Generated-product machine build'
    if any(t in name for t in ['batch-smoke', 'native-lexer', 'product-compiler-smoke']):
        return 'Native smoke/request checks'
    return 'Hosted finite/semantic/product checks'


def guard_inventory(start: float, cutoff: float) -> tuple[list, list]:
    found = sorted(p for base, pattern in SCOPES for p in (ROOT / base).glob(pattern))
    if len(found) > 512:
        raise ValueError('bounded guard count exceeded512')
    rows, excluded = [], []
    for p in found:
        data, receipt = read(p)
        row = {k: data.get(k) for k in ['started', 'finished', 'wallSeconds',
               'returncode', 'complete', 'command', 'peakTreeRssBytes']}
        row.update(name=p.parent.name, receipt=receipt)
        if not row['started'] or row['started'] < start:
            row['exclusion'] = 'before campaign or missing start'
        elif row['started'] > cutoff:
            row['exclusion'] = 'after cutoff'
        elif row['finished'] is None or row['returncode'] is None or row['wallSeconds'] is None:
            row['exclusion'] = 'unfinished; no completed cost/result'
        elif row['finished'] > cutoff:
            row['exclusion'] = 'finished after cutoff'
        else:
            if row['finished'] < row['started'] or row['wallSeconds'] < 0:
                raise ValueError(f'invalid interval: {p}')
            row['category'] = category(row['name'], row['command'])
            rows.append(row)
            continue
        excluded.append(row)
    return rows, excluded


def image_inventory(rows: list[dict]) -> tuple[list, list]:
    by_name = {r['name']: r for r in rows}
    images, pending = [], []
    for version, image, acquisition in IMAGES:
        mp = path(f'selfhost/build/phase140/native-source{version}/manifest.json')
        bp = path(f'selfhost/build/phase111/{image}/report.json')
        ap = path(f'selfhost/build/phase111/p140-native-api{version}/report.json')
        acq = by_name.get(f'p140-acquire{acquisition}-guard')
        built = by_name.get(f'{image}-guard')
        if not all(p.exists() for p in [mp, bp, ap]) or not acq or not built:
            pending.append({'sourceVersion': version, 'reason': 'acquisition/build/API not all closed by cutoff'})
            continue
        manifest, manifest_pin = read(mp)
        build, build_pin = read(bp)
        api, api_pin = read(ap)
        if not build.get('complete') or not api.get('complete') or not api.get('checked') or acq['returncode'] or built['returncode']:
            pending.append({'sourceVersion': version, 'reason': 'acquisition/build/API did not all succeed'})
            continue
        raw = payload(manifest['source']['file'])
        actual = pin(manifest['source']['file'], raw)
        if any(actual[k] != manifest['source'][k] for k in ['sha256', 'bytes']):
            raise ValueError(f'candidate source identity drift: {version}')
        lines = raw.decode().splitlines()
        modules = []
        if len(manifest['modules']) > 128:
            raise ValueError('bounded module count exceeded')
        for item in manifest['modules']:
            raw_module = payload(item['file'])
            actual_module = pin(item['file'], raw_module)
            if any(actual_module[k] != item[k] for k in ['sha256', 'bytes']):
                raise ValueError(f'module identity drift: {item["file"]}')
            ml = raw_module.decode().splitlines()
            modules.append(dict(actual_module, physicalLines=len(ml),
                nonblankNoncommentLines=sum(bool(l.strip()) and not l.lstrip().startswith('#') for l in ml),
                controlOrReference=any(t in Path(item['file']).name for t in ['control', 'reference'])))
        images.append(dict(sourceVersion=version, source=actual, manifest=manifest_pin,
            checkedApi=api_pin, imageBuild=build_pin, image=build['binary'],
            buildSeconds=build['buildSeconds'], nativeAcquisitionSeconds=acq['wallSeconds'],
            physicalLines=len(lines), nonblankNoncommentLines=sum(bool(l.strip()) and not l.lstrip().startswith('#') for l in lines),
            addedDeclarations=len(manifest['added']), modules=modules))
    return images, pending


def loop_inventory(rows: list[dict]) -> tuple[list, list]:
    observations, pending = [], []
    for name in LOOPS:
        p = path(f'selfhost/build/phase140/{name}/report.json')
        if not p.exists():
            continue
        report, receipt = read(p)
        closed = any(any(str(p.parent) == str(path(arg)) for arg in r['command']
                        if arg.startswith('selfhost/build/phase140/') or arg.startswith(str(ROOT / 'selfhost/build/phase140/')))
                     for r in rows if r['returncode'] == 0)
        if not report.get('complete') or not closed:
            pending.append(dict(name=name, receipt=receipt, reason='report or enclosing guard not complete by cutoff'))
            continue
        observations.append(dict(name=name, receipt=receipt, nativeSeconds=report.get('nativeSeconds'),
            totalSeconds=report.get('totalSeconds'), independentProductsExact=report.get('independentProductsExact'),
            stages=report.get('stages'), jobs=[dict(name=j['name'], stages=j.get('stages'), ioMs=j.get('ioMs'),
                transportSeconds=j.get('transportSeconds'), exactOracle=j.get('exactOracle')) for j in report.get('jobs', [])]))
    return observations, pending


def markdown(data: dict, json_name: str) -> str:
    lines = ['# Phase140 final cost inventory', '',
        f"Snapshot **{data['campaignStartUtc']}–{data['cutoffUtc']}**; elapsed **{data['elapsedSeconds']/60:.2f}min**.",
        f'Numerical inputs and exact pins: [{json_name}]({json_name}). Earlier20:34 cost-review files remain unchanged.', '',
        'Only terminal guards are charged, including failures (`complete:false` with a terminal exit). Pending work is listed separately.', '',
        '| Completed workflow | Runs | Success / failure | Guard seconds |', '|---|---:|---:|---:|']
    for c in data['categories']:
        lines.append(f"|{c['category']}|{c['count']}|{c['successes']} /{c['failures']}|{c['wallSumSeconds']:.2f}|")
    lines += ['', f"Completed guards: **{data['terminalGuardCount']}**. Summed workflow wall: **{data['guardWallSumSeconds']/60:.2f}min**; interval union: **{data['guardIntervalUnionSeconds']/60:.2f}min**.",
        f"Failed guards: **{data['failedGuardCount']}**, **{data['failedGuardSeconds']:.2f}s** target time. Outside completed intervals: **{data['outsideCompletedGuardIntervalsSeconds']/60:.2f}min**, not an idle-time measurement.", '',
        '## Candidate acquisition and size', '', '| Source | SHA prefix | Lines | Code-line approximation | Source bytes | Emission guard | Machine build |', '|---|---|---:|---:|---:|---:|---:|']
    for i in data['images']:
        lines.append(f"|{i['sourceVersion']}|{i['source']['sha256'][:12]}|{i['physicalLines']:,}|{i['nonblankNoncommentLines']:,}|{i['source']['bytes']:,}|{i['nativeAcquisitionSeconds']:.2f}s|{i['buildSeconds']:.2f}s|")
    lines += ['', 'Machine-build and stage timers below are nested explanations; do not add them again to guard totals. Acquisition is not compiler throughput or qualification.', '',
        '## Completed native loop stage observations', '', '| Receipt / revision | Frontend | Raw | Backend | Registry | Render/close | Total |', '|---|---:|---:|---:|---:|---:|---:|']
    notes = []
    for o in data['measuredLoops']:
        stages = list((o.get('stages') or {}).items()) + [(j['name'], j['stages']) for j in o['jobs'] if j['stages']]
        for label, stage in stages:
            values = [stage[k]/1000 for k in ['frontendMs', 'rawMs', 'backendMs', 'registryMs', 'renderCloseMs', 'totalMs']]
            lines.append(f"|{o['name']} /{label}|" + '|'.join(f'{v:.3f}s' for v in values) + '|')
        notes.append(f"{o['name']}: independentProductsExact={o['independentProductsExact']}; native={o['nativeSeconds']:.3f}s, enclosing runner={o['totalSeconds']:.3f}s.")
    lines += ['', *notes, '', '## Scope and pending work', '']
    lines += [f'- {x}' for x in data['limitations']]
    lines += [f"- Excluded guard: {r['name']} — {r['exclusion']}." for r in data['excluded']]
    lines += [f"- Pending image{r['sourceVersion']}: {r['reason']}." for r in data['pendingImages']]
    lines += [f"- Pending loop {r['name']}: {r['reason']}." for r in data['pendingLoops']]
    lines += ['', 'For interpretation and efficiency lessons, see [the earlier cost review](cost-review.md). Source03/15/17/18 and differently sequenced edit batches are not interchangeable controlled ablations. Confirm exact oracle status and matching source/checkpoint inputs before attributing a gain.', '']
    return '\n'.join(lines)


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--out-prefix', required=True, help='Fresh repo-relative prefix; emits .json and .md')
    parser.add_argument('--start', default='2026-10-25T18:12:15Z')
    parser.add_argument('--cutoff', help='Optional fixed UTC snapshot; default current UTC')
    args = parser.parse_args()
    start = utc(args.start)
    cutoff = utc(args.cutoff) if args.cutoff else dt.datetime.now(dt.timezone.utc).timestamp()
    if not start < cutoff:
        raise ValueError('cutoff must follow campaign start')
    output = path(args.out_prefix)
    if not any(output.is_relative_to(ROOT / allowed) for allowed in ['implementation/phase140', 'selfhost/build/phase140']):
        raise ValueError('output must be in Phase140 evidence locations')
    json_path, md_path = Path(str(output)+'.json'), Path(str(output)+'.md')
    if json_path.exists() or md_path.exists():
        raise FileExistsError('refuse to overwrite an earlier snapshot')
    rows, excluded = guard_inventory(start, cutoff)
    categories = []
    for label in sorted({r['category'] for r in rows}):
        group = [r for r in rows if r['category'] == label]
        categories.append(dict(category=label, count=len(group), successes=sum(r['returncode']==0 for r in group),
            failures=sum(r['returncode']!=0 for r in group), wallSumSeconds=sum(r['wallSeconds'] for r in group), intervalUnionSeconds=interval_union(group)))
    images, pending_images = image_inventory(rows)
    loops, pending_loops = loop_inventory(rows)
    failed = [r for r in rows if r['returncode'] != 0]
    union = interval_union(rows)
    data = dict(kind='phase140-bounded-cost-inventory', complete=True, method=pin(__file__),
        campaignStartUtc=iso(start), cutoffUtc=iso(cutoff), elapsedSeconds=cutoff-start,
        receiptScopes=[f'{base}/{pattern}' for base, pattern in SCOPES], terminalGuardCount=len(rows),
        guardWallSumSeconds=sum(r['wallSeconds'] for r in rows), guardIntervalUnionSeconds=union,
        outsideCompletedGuardIntervalsSeconds=cutoff-start-union, failedGuardCount=len(failed),
        failedGuardSeconds=sum(r['wallSeconds'] for r in failed), categories=categories,
        guards=rows, excluded=excluded, images=images, pendingImages=pending_images,
        measuredLoops=loops, pendingLoops=pending_loops, limitations=[
            'Guard wall is workflow time, not aggregate CPU time, agent effort, token use or quota consumption.',
            'Interval union accounts for overlapping guards. Nested native, build, stage and transport timers are never added again.',
            'Intervals outside completed guards include implementation, coordination, unguarded work and pending runs; they are not measured idle time.',
            'Historical acquisition and qualification outside the campaign are excluded. Prior Phase140 attempts and failures remain charged.',
            'Scope is the two bounded guard globs; unguarded metadata/finite work is not comprehensively metered.',
            'Source/module bytes are rehashed. ELF bytes are reported from the completed build receipt; executable contents are not rescanned.',
            'Completed loop status does not establish independent semantic qualification; each exact-oracle flag is retained.',
            'Stage observations are single exploratory runs; matching inputs/checkpoints and repeated timing are needed for causal performance claims.'])
    output.parent.mkdir(parents=True, exist_ok=True)
    with json_path.open('x') as f:
        json.dump(data, f, indent=2)
        f.write('\n')
    with md_path.open('x') as f:
        f.write(markdown(data, json_path.name))
    print(json.dumps(dict(json=str(json_path.relative_to(ROOT)), markdown=str(md_path.relative_to(ROOT)),
        guards=len(rows), failures=len(failed), excluded=len(excluded), guardWallSeconds=data['guardWallSumSeconds'], intervalUnionSeconds=union)))


if __name__ == '__main__':
    main()

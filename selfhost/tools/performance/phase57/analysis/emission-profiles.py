#!/usr/bin/env python3
"""Validate and summarize completed one-shot compiler-emission CPU stage captures."""
import argparse
import ast
import bisect
from collections import defaultdict
import hashlib
import json
import math
from pathlib import Path
from urllib.parse import unquote, urlsplit

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[4]
STAGES = ['load-own-source', 'remaining-todos', 'specialize-loaded-book', 'owned-layout-identity',
          'context', 'native-stops', 'source-reachability', 'annotate-selected',
          'emitted-reachability', 'layout-proof', 'unsplit-library', 'foreign-modules']
inputs = {}


def pin(item):
    file = Path(item['file'] if isinstance(item, dict) else item).resolve(strict=True)
    digest = hashlib.sha256()
    with file.open('rb') as stream:
        for chunk in iter(lambda: stream.read(1024 * 1024), b''):
            digest.update(chunk)
    row = dict(file=str(file), bytes=file.stat().st_size, sha256=digest.hexdigest())
    if isinstance(item, dict):
        assert row['sha256'] == item['sha256'], str(file)
        assert 'bytes' not in item or row['bytes'] == item['bytes'], str(file)
    if str(file) in inputs:
        assert inputs[str(file)] == row, str(file)
    inputs[str(file)] = row
    return row


def read(item):
    row = pin(item)
    assert row['bytes'] <= 128 * 1024 * 1024, 'Bounded JSON input'
    return row, json.loads(Path(row['file']).read_text())


def finite(value):
    return isinstance(value, (int, float)) and math.isfinite(value) and value >= 0


def approx(left, right):
    assert math.isclose(left, right, rel_tol=1e-10, abs_tol=.001), (left, right)


def urlpath(url):
    value = urlsplit(url)
    return str(Path(unquote(value.path)).resolve()) if value.scheme == 'file' else url if url.startswith('/') else None


def framekey(frame):
    return tuple(frame.get(k) for k in ('functionName', 'url', 'lineNumber', 'columnNumber'))


def check_self(raw, summary, use_time):
    """Independent self-only accounting; inclusive ancestry remains the pinned method's view."""
    nodes = {node['id']: node for node in raw['nodes']}
    assert len(nodes) == len(raw['nodes'])
    weights, counts = defaultdict(int), defaultdict(int)
    for node, delta in zip(raw['samples'], raw['timeDeltas']):
        key = framekey(nodes[node]['callFrame'])
        weights[key] += max(0, delta) if use_time else 1
        counts[key] += 1
    seen = set()
    for frame in summary['frames']:
        key = framekey(frame['frame'])
        assert key not in seen
        seen.add(key)
        approx(frame['selfWeight'], weights[key])
        assert frame['selfSamples'] == counts[key]
    assert set(weights) <= seen
    approx(sum(weights.values()), summary['totalWeight'])


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--report', type=Path, required=True)
    parser.add_argument('--supervisor', type=Path, required=True)
    parser.add_argument('--inventory', type=Path, default=HERE.parent / 'static/code-shapes.json')
    parser.add_argument('--out', type=Path, required=True)
    parser.add_argument('--allow-partial', action='store_true', help='Extract finalized captures from a failed bounded run; never infer whole-workload success')
    args = parser.parse_args()
    out = args.out.resolve()
    assert out.is_relative_to(ROOT / 'selfhost/build/phase57') and not out.exists()
    producer = pin(__file__)
    method = pin(HERE / 'profiles-v2.py')
    assert method['sha256'] == 'ab678fb32d51d497009d5e1ffbae3ffbba4fdae27973b47546d2b5859d7c0d19'
    # Extract only the reviewed validator, never the parent's argument parser/CLI.
    node = next(n for n in ast.parse(Path(method['file']).read_text()).body
                if isinstance(n, ast.FunctionDef) and n.name == 'cpu_views')
    namespace = dict(read=read, finite=finite, approx=approx)
    exec(compile(ast.Module(body=[node], type_ignores=[]), method['file'], 'exec'), namespace)
    cpu_views = namespace['cpu_views']
    report_id, report = read(args.report)
    variant = {'phase57-b2-own-source-emission-profile': (1000, 'd2c240b45d130732a99c8310605b7e5cce66ee88edcf1813911ecaa3b030e4df', 'f472c5e565827e7a8cfc4181e19dffe61f4485c63a3d137c1315c82e388064f6'),
               'phase57-b2-own-source-emission-profile-v2': (25000, 'a7d6ae0d980146a327ecda9c6e22d3f6181fe79ff8ff79f5c2ec0f8634370fa4', 'd5044de9f3e056fb300b7fbdc93afe9820164fe87830efd366d72b6a8ed39a69')}[report['kind']]
    interval, worker_hash, profiler_hash = variant
    full = bool(report['complete'] and report['pass'])
    assert (full or args.allow_partial) and not report['cleanTiming']
    if full:
        assert report['byteEquality']
    assert report['checking'] == dict(lane='inherited-exact-bootstrap', freshSelfCheck=False,
                                     sourceSha256=report['subject']['source']['sha256'])
    assert report['producer']['sha256'] == worker_hash
    pin(report['producer']); pin(report['node'])
    progress_id = pin(report.get('progress', args.report.resolve().parent / 'progress.jsonl'))
    progress = [json.loads(line) for line in Path(progress_id['file']).read_text().splitlines()]
    assert [p['sequence'] for p in progress] == list(range(len(progress)))
    for item in report['inputs']:
        pin(item)
    for item in report['copies']:
        pin(item['before']); pin(item['after'])
    if full:
        assert report['verification']['inputsUnchanged'] and report['verification']['copiesUnchanged']
    assert len(report['roots']) == len(set(report['roots'])) == 77
    image = report['image']
    assert image['role'] == 'direct' and image['kind'] == 'direct-self-emitted-image'
    for field in ('api', 'source', 'driver', 'runtime', 'directRuntime', 'base'):
        pin(image[field])
    _, binding = read(image['pins'])
    _, emission = read(image['emission'])
    assert binding['b2']['sha256'] == image['api']['sha256'] == report['b2']['sha256']
    assert binding['source'] == report['subject']['source'] == image['source']
    assert emission['complete'] and emission['pass'] and emission['roots'] == report['roots'] == binding['roots']
    assert emission['subject'] == report['subject']
    b2, b3 = pin(report['b2']), None
    assert b2['sha256'] == '3f652f7d3e26e06fe74da18bf8709195c54e4620906ffb7c1d0643c96ecbd57e' and b2['bytes'] == 3896951
    if full:
        assert emission['selected'] == report['selected'] and report['emitted'] == emission['emitted']
        b3 = pin(report['b3'])
        assert b2['sha256'] == b3['sha256'] and b2['bytes'] == b3['bytes']
        assert Path(b2['file']).read_bytes() == Path(b3['file']).read_bytes()
    supervisor_id, supervisor = read(args.supervisor)
    if full:
        assert supervisor['complete'] and supervisor['returncode'] == 0 and 'stoppedFor' not in supervisor
    else:
        assert not supervisor['complete'] and supervisor['returncode'] != 0 and 'finished' in supervisor
    assert supervisor['secondsLimit'] <= 420 and supervisor['rssLimitBytes'] <= 2048 * 1024 * 1024
    assert supervisor['availableFloorBytes'] >= 4096 * 1024 * 1024
    pin(supervisor['producer']); pin(supervisor['stdout']); pin(supervisor['stderr'])
    command = supervisor['command']; cwd = Path(supervisor['cwd'])
    resolve = lambda text: str((cwd / text).resolve())
    assert list(map(resolve, command[-3:])) == [report['producer']['file'], image['pins']['file'], str(args.report.resolve().parent)]
    assert command[:3] == ['taskset', '-c', '3'] and '--max-old-space-size=1024' in command and '--stack-size=4096' in command
    assert resolve(command[3]) == report['node']['file']

    inventory_id, inventory = read(args.inventory)
    assert inventory['complete'] and inventory['kind'] == 'phase57-static-compiler-code-shapes'
    inv = next(r for r in inventory['roles'] if r['role'] == 'directB2')
    assert pin(inv['identity'])['sha256'] == image['api']['sha256']
    source = Path(image['api']['file']).read_bytes()
    lines = source.splitlines(keepends=True); starts = [0]
    for line in lines:
        starts.append(starts[-1] + len(line))
    spans = []
    for name, fn in inv['functions'].items():
        line = fn['line'] - 1
        start = starts[line] + lines[line].index(('function ' + fn['identifier'] + '(').encode())
        end = start + fn['bytes']
        assert hashlib.sha256(source[start:end]).hexdigest() == fn['sha256']
        spans.append(dict(name=name, identifier=fn['identifier'], line=fn['line'], start=start, end=end, sha256=fn['sha256']))
    spans.sort(key=lambda x: x['start']); span_starts = [s['start'] for s in spans]
    assert all(a['end'] <= b['start'] for a, b in zip(spans, spans[1:]))

    def enrich(frame):
        frame = dict(frame); loc = frame['frame']; file = urlpath(loc.get('url', ''))
        line, column = loc.get('lineNumber', -1), loc.get('columnNumber', -1)
        if file == image['api']['file'] and 0 <= line < len(lines) and column >= 0:
            encoded = lines[line].decode().encode('utf-16-le')
            if column * 2 <= len(encoded):
                try:
                    offset = starts[line] + len(encoded[:column * 2].decode('utf-16-le').encode())
                    at = bisect.bisect_right(span_starts, offset) - 1
                    if at >= 0 and offset < spans[at]['end']:
                        frame['containingBendDefinition'] = spans[at]
                except UnicodeError:
                    pass
        return frame

    stages = []
    finished = [stage for stage in report['phases'] if stage.get('complete') is not False]
    assert [stage['name'] for stage in finished] == STAGES[:len(finished)]
    captured = [stage for stage in finished if stage.get('profile')]
    expected_captures = STAGES if interval == 1000 else ['emitted-reachability', 'unsplit-library']
    assert [stage['name'] for stage in captured] == [name for name in expected_captures if name in {s['name'] for s in finished}]
    if full:
        assert len(finished) == len(STAGES) and len(captured) == len(expected_captures)
    for stage in captured:
        inline = stage['profile']; profile_id, profile = read(inline['receipt'])
        assert profile == {k: v for k, v in inline.items() if k != 'receipt'}
        assert profile['complete'] and profile['pass'] and profile['mode'] == 'cpu' and profile['diagnosticOnly']
        assert profile['schemaVersion'] == 2 and profile['calls'] == profile['maxRequests'] == 1
        assert len(profile['requestMs']) == 1 and profile['sampling'] == dict(intervalMicroseconds=interval)
        assert profile['moduleUrl'] == Path(image['api']['file']).as_uri()
        assert profile['producer']['sha256'] == profiler_hash
        if interval == 25000:
            assert profile['derivedFrom']['sha256'] == 'f472c5e565827e7a8cfc4181e19dffe61f4485c63a3d137c1315c82e388064f6'
            pin(profile['derivedFrom'])
        assert profile['node']['sha256'] == report['node']['sha256']
        for field in ('producer', 'predecessor', 'summaryMethod', 'node'):
            pin(profile[field])
        raw_id, raw = read(profile['raw']); summary_id, summary = read(profile['summary'])
        count_id, count = cpu_views(raw, summary, profile)
        assert count is not None
        check_self(raw, count, False)
        check_self(raw, summary, profile['weightedStatus'] == 'admitted')
        views = []
        for name, identity, value in [('primary', summary_id, summary), ('sample-count', count_id, count)]:
            frames = [enrich(frame) for frame in value['frames']]
            views.append(dict(view=name, summary=identity, unit=value['unit'], totalWeight=value['totalWeight'],
                              sampleCount=value['sampleCount'], accounting=value.get('accounting'), warnings=value['warnings'],
                              topSelf=sorted(frames, key=lambda f: -f['selfWeight'])[:25],
                              topInclusive=sorted(frames, key=lambda f: -f['inclusiveWeight'])[:25]))
        stages.append(dict(name=stage['name'], seconds=stage['seconds'], captureSeconds=stage['captureSeconds'],
                           book={k: stage[k] for k in ('entries', 'definitions', 'characters', 'bytes') if k in stage},
                           profile=profile_id, raw=raw_id, weightedStatus=profile['weightedStatus'], views=views))
        del raw, summary, count
    for item in list(inputs.values()):
        pin(item)
    result = dict(kind='phase57-emission-stage-cpu-analysis', complete=True, passGate=True, dataOnly=True, targetExecuted=False,
                  analysisComplete=True, workloadPassed=full, partial=not full,
                  producer=producer, viewValidator=method, inventory=inventory_id, report=report_id, supervisor=supervisor_id,
                  progress=progress_id, lastProgress=progress[-1], unfinalizedCapturesOrUnreachedStages=STAGES[len(finished):],
                  samplingIntervalMicroseconds=interval,
                  stageTimings=[{k: stage[k] for k in ('name', 'seconds', 'captureSeconds', 'cpuCaptured') if k in stage} for stage in finished],
                  supervisorOutcome={k: supervisor[k] for k in ('complete', 'returncode', 'stoppedFor', 'wallSeconds', 'peakTreeRssBytes', 'minimumAvailableBytes') if k in supervisor},
                  byteEquality=True if full else None, b2=b2, b3=b3, selected=report.get('selected'), roots=report['roots'],
                  checking=report['checking'], seconds=report.get('seconds'), stages=stages, inputs=list(inputs.values()), inputsUnchanged=True,
                  scope='One instrumented full emission, not steady throughput. Phase CPU captures include marker IO and async overhead. Raw self weights and counts are independently recomputed; inclusive stacks use the pinned method and overlap. Source spans identify containing definitions, not a proved optimization cause. No stage or overall timing ratios.')
    outcome = (f"Complete B2/B3 equality: **{b3['bytes']:,} bytes**, SHA256 `{b3['sha256']}`." if full else
               f"**Workload failed**: `{supervisor.get('stoppedFor', 'process failure')}`, return code {supervisor['returncode']}, {supervisor['wallSeconds']:.3f}s. Only {len(stages)} finalized captures are analyzed. B3 and final byte equality are unavailable; absent profiles imply no zero-cost claim.")
    md = ['# B2 full-emission CPU stages', '', outcome, '', result['scope'], '',
          'Inherited checked-source proof; no fresh self-check in this run.', '',
          '| Stage | Function wall s | Capture s | CPU samples | Weighted view |', '|---|---:|---:|---:|---|']
    for stage in finished:
        sample = next((s for s in stages if s['name'] == stage['name']), None)
        count, status = (sample['views'][0]['sampleCount'], sample['weightedStatus']) if sample else ('—', 'not sampled')
        md.append(f"| {stage['name']} | {stage['seconds']:.3f} | {stage['captureSeconds']:.3f} | {count} | {status} |")
    for stage in stages:
        md += ['', '## ' + stage['name'], '']
        for view in stage['views']:
            md += [f"### {view['view']} ({view['unit']})", '', '| Self % | Inclusive % | Frame | Containing Bend definition |', '|---:|---:|---|---|']
            for frame in view['topSelf'][:12]:
                name = frame['functionName'].replace('`', '').replace('|', '/')
                bend = frame.get('containingBendDefinition', {}).get('name', '—')
                md.append(f"| {frame['selfPercent']:.2f} | {frame['inclusivePercent']:.2f} | `{name}` | {bend} |")
            md += [''] + ['- ' + warning for warning in view['warnings']]
    md += ['', 'The emitted-reachability stage renders definitions to collect JD_REF markers. The unsplit-library stage rebuilds call facts, emits definitions and builds host exports. Their stage names do not isolate internal algorithms; inspect the sampled functions before proposing a change.', '']
    out.mkdir(parents=True)
    (out / 'report.json').write_text(json.dumps(result, indent=2) + '\n')
    (out / 'report.md').write_text('\n'.join(md))
    print(json.dumps(dict(analysisComplete=True, workloadPassed=full, stages=len(stages), byteEquality=result['byteEquality'], out=str(out))))


if __name__ == '__main__':
    main()

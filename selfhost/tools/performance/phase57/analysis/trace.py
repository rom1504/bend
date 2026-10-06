#!/usr/bin/env python3
"""Data-only Phase57 trace accounting. Never imports or executes a target."""
import argparse
from collections import Counter
from datetime import datetime
import hashlib
import json
from pathlib import Path
import re

HERE = Path(__file__).resolve()
ROOT = HERE.parents[5]
PREFIX = 'BEND_PHASE57_TRACE '
TYPED = re.compile(r'^\[typed ([^]]+)\] (.*)$')
ABI = re.compile(r'^ABI (\S+) (encode|invoke|decode|return) (.*)$')
FUNCTION = re.compile(r'<JSFunction\s*(.*?)\s*\(sfi = |<SharedFunctionInfo\s+([^>]+)>')
SFI = re.compile(r'sfi = (0x[0-9a-f]+)')
GC = re.compile(r'\]\s+([0-9.]+) ms:\s+(.*\bpause=[0-9.]+.*)')
FIELDS = re.compile(r'(?:^|\s)([\w.]+)=([^\s]+)')
STAGES = ('discover ', 'load and elaborate graph', 'check book', 'specialize book',
          'prune reachable definitions', 'annotate book', 'prune direct runtime dependencies',
          'validate runtime layouts', 'emit library', 'emitted direct ', 'compiler exception:')
NOTES = [
    'Diagnostic trace durations are not clean speed samples; no speed ratios are calculated.',
    'cold means fresh-process import/API load/first request with an already primed private Base disk cache; it does not mean cold filesystem or absent Base cache.',
    'V8 attribution is stdout emission order between synchronous worker markers. Concurrent optimization can have started earlier; this is not exclusive CPU attribution.',
    'GC clockMs is V8 isolate-relative time. It is not equated with performance.now; marker order supplies request attribution.',
    'BEND_TYPED_TRACE uses millisecond wall-clock timestamps. Request ordinal joins are checked against worker windows; sub-millisecond durations can round to zero.',
    'wallWindowContainsEvents is a recorded consistency diagnostic, not an acceptance condition. Clock-backwards events or false containment require investigating clock/log behavior before interpreting stage durations.',
    'discover includes cache reads, source discovery, parsing and completed graph elaboration. The later load-and-elaborate marker is after discoverSources returns.',
    'check book is composite: checker-result ABI 2 includes specialization; its interval also contains subsequent ownership/context/root preparation before the next marker.',
    'prune direct runtime dependencies calls jd_reach_selected, which renders definitions to discover emitted references. It is not just a graph traversal.',
    'emit library includes foreign modules, whole-library rendering, runtime read and final source assembly.',
    'ABI encode/invoke/decode durations are adapter-boundary intervals, not disjoint from enclosing driver stages. Do not add nested totals.',
    'Deoptimization counts indicate logged events, not execution hotness or lost time. Names can collide across lexical functions; raw SFI addresses distinguish only this process.',
    'Unmarked v1 V8 events remain phase-unattributed. Missing named-ABI events (including the direct image) do not mean zero adapter or compiler work.',
]


def require(condition, message):
    if not condition:
        raise ValueError(message)


def epoch(value):
    return datetime.fromisoformat(value.replace('Z', '+00:00')).timestamp() * 1000


def label(window):
    if window is None:
        return 'unattributed'
    suffix = '' if window['index'] is None else ':' + str(window['index'])
    return window['phase'] + suffix


def temperature(name):
    if name.startswith(('host-import', 'api-load', 'first-request')):
        return 'cold'
    if name.startswith('warm-request'):
        return 'warm'
    if name.startswith('trace-request'):
        return 'diagnostic-after-warmup'
    return 'unattributed'


class Inputs:
    def __init__(self):
        self.pins = {}

    @staticmethod
    def identity(file):
        file = Path(file).resolve(strict=True)
        h = hashlib.sha256()
        with file.open('rb') as stream:
            for chunk in iter(lambda: stream.read(1024 * 1024), b''):
                h.update(chunk)
        return dict(file=str(file), bytes=file.stat().st_size, sha256=h.hexdigest())

    def pin(self, item):
        file = item['file'] if isinstance(item, dict) else item
        key = str(Path(file).resolve(strict=True))
        if key not in self.pins:
            self.pins[key] = self.identity(key)
        actual = self.pins[key]
        if isinstance(item, dict):
            require(actual['sha256'] == item['sha256'], 'Input hash mismatch: ' + key)
            require('bytes' not in item or actual['bytes'] == item['bytes'], 'Input size mismatch: ' + key)
        return actual

    def read(self, item):
        pin = self.pin(item)
        require(pin['bytes'] <= 32 * 1024 * 1024, 'JSON exceeds 32 MiB')
        return json.loads(Path(pin['file']).read_text())

    def finish(self):
        for pin in self.pins.values():
            require(self.identity(pin['file']) == pin, 'Input changed during analysis: ' + pin['file'])


def lines(file, inputs, limits):
    require(file.stat().st_size <= limits.max_log_mib * 1024 * 1024, 'Log byte bound: ' + str(file))
    inputs.pin(file)
    with file.open('rb') as stream:
        number = 0
        while True:
            raw = stream.readline(65537)
            if not raw:
                break
            number += 1
            require(len(raw) <= 65536, 'Log line exceeds 64 KiB: ' + str(file))
            require(number <= limits.max_lines, 'Log line-count bound: ' + str(file))
            yield number, raw.decode('utf8', errors='replace').rstrip('\r\n')


def v8(file, observed, inputs, limits):
    active = None
    windows, counts, groups, gc_groups = [], Counter(), {}, {}
    deopts, gc_events = [], []
    total = unmatched = 0
    for number, line in lines(file, inputs, limits):
        total = number
        if line.startswith(PREFIX):
            marker = json.loads(line[len(PREFIX):])
            require(marker['role'] == observed['role'], 'Marker role differs from worker')
            require(marker['phase'] in ('host-import', 'api-load', 'first-request', 'warm-request', 'trace-request'), 'Unknown trace phase')
            if marker['event'] == 'begin':
                require(active is None, 'Nested trace window')
                active = dict(phase=marker['phase'], index=marker['index'], begin=marker, beginLine=number)
            else:
                require(marker['event'] == 'end' and active is not None, 'Unpaired trace marker')
                require((marker['phase'], marker['index']) == (active['phase'], active['index']), 'Mismatched trace marker')
                require(marker['monotonicMs'] >= active['begin']['monotonicMs'], 'Negative window duration')
                active.update(end=marker, endLine=number)
                windows.append(active)
                active = None
            continue
        phase = label(active)
        match = GC.search(line)
        if match:
            fields = dict(FIELDS.findall(match[2]))
            event = dict(line=number, window=phase, temperature=temperature(phase),
                         clockMs=float(match[1]), collector=fields.get('gc', 'unknown'), pauseMs=float(fields['pause']))
            gc_events.append(event)
            require(len(deopts) + len(gc_events) <= 100000, 'V8 retained-event bound')
            key = (phase, event['collector'])
            group = gc_groups.setdefault(key, dict(window=phase, temperature=temperature(phase), collector=key[1], count=0, pauseMs=0, maxPauseMs=0))
            group['count'] += 1
            group['pauseMs'] += event['pauseMs']
            group['maxPauseMs'] = max(group['maxPauseMs'], event['pauseMs'])
            counts[(phase, 'gc')] += 1
            continue
        kind = ('deopt' if '[bailout ' in line else 'invalidate' if 'marking dependent code' in line else
                'compile-complete' if '[completed ' in line and ('compiling' in line or 'optimizing' in line) else
                'compile-start' if '[compiling method' in line or '[optimizing ' in line else
                'mark-optimize' if '[marking ' in line and 'for optimization' in line else None)
        if kind is None:
            if any(s in line for s in ('optimizing', 'compiling method', 'bailout', 'pause=')):
                unmatched += 1
            continue
        name_match = FUNCTION.search(line)
        name = (name_match[1] or name_match[2] or '<anonymous>') if name_match else '<unparsed>'
        reason_match = re.search(r'reason: (.*?)\): begin', line) if kind == 'deopt' else None
        reason = reason_match[1] if reason_match else None
        tier_match = re.search(r'\b(MAGLEV|TURBOFAN(?:_JS)?|TURBOSHAFT)\b', line)
        tier = tier_match[1] if tier_match else None
        key = (phase, kind, name, reason, tier)
        require(len(groups) < 100000 or key in groups, 'V8 unique-event group bound')
        group = groups.setdefault(key, dict(window=phase, temperature=temperature(phase), kind=kind,
                                            name=name, reason=reason, tier=tier, count=0, sfi=[], firstLine=number))
        group['count'] += 1
        group['lastLine'] = number
        sfi = SFI.search(line)
        if sfi and sfi[1] not in group['sfi']:
            group['sfi'].append(sfi[1])
        counts[(phase, kind)] += 1
        if kind == 'deopt':
            deopts.append(dict(line=number, window=phase, temperature=temperature(phase), name=name,
                               reason=reason, tier=tier, sfi=sfi[1] if sfi else None, text=line))
        require(len(deopts) + len(gc_events) <= 100000, 'V8 retained-event bound')
    require(active is None, 'Unfinished stdout window')
    expected = observed.get('traceWindows', [])
    actual = [{k: w[k] for k in ('phase', 'index', 'begin', 'end')} for w in windows]
    require(actual == expected, 'Stdout windows differ from worker receipt')
    if windows:
        require(len(windows) == 3 + len(observed['warmRequests']) + len(observed.get('traceRequests', [])), 'Unexpected window count')
    return dict(lines=total, markerWindows=windows, phaseBinding='ordered-stdout-markers' if windows else 'none',
                counts=[dict(window=k[0], temperature=temperature(k[0]), kind=k[1], count=v) for k, v in sorted(counts.items())],
                groups=sorted(groups.values(), key=lambda g: (-g['count'], g['name'], g['window'])),
                deoptimizations=deopts, gc=gc_events, gcGroups=list(gc_groups.values()), unparsedDiagnosticLines=unmatched)


def typed(file, windows, observed, inputs, limits):
    request_windows = [w for w in windows if w['phase'].endswith('request')]
    requests, events, abi_groups, open_abi = [], [], {}, None
    current, last_time, backwards = None, None, 0
    for number, line in lines(file, inputs, limits):
        match = TYPED.match(line)
        if not match:
            continue
        time, message = epoch(match[1]), match[2]
        backwards += int(last_time is not None and time < last_time)
        last_time = time
        if message.startswith('discover '):
            ordinal = len(requests)
            w = request_windows[ordinal] if ordinal < len(request_windows) else None
            inferred = 'first-request' if ordinal == 0 else 'warm-request:' + str(ordinal - 1) if ordinal <= len(observed['warmRequests']) else 'trace-request:' + str(ordinal - len(observed['warmRequests']) - 1)
            current = dict(ordinal=ordinal, window=label(w) if w else inferred, attribution='request-order',
                           discoverTime=match[1], events=[], intervals=[], complete=False)
            requests.append(current)
        phase = current['window'] if current and not current['complete'] else 'outside-request'
        event = dict(line=number, wallTime=match[1], epochMs=time, message=message, window=phase)
        events.append(event)
        require(len(events) <= 100000, 'Typed trace event bound')
        abi = ABI.match(message)
        if abi:
            name, boundary = abi[1], abi[2]
            if boundary == 'encode':
                require(open_abi is None, 'Nested/incomplete ABI trace')
                open_abi = dict(name=name, window=phase, times={'encode': time})
            else:
                require(open_abi is not None and open_abi['name'] == name, 'Unpaired ABI trace')
                open_abi['times'][boundary] = time
                if boundary == 'return':
                    times = open_abi['times']
                    require(set(times) == {'encode', 'invoke', 'decode', 'return'}, 'Missing ABI boundary')
                    key = (open_abi['window'], name)
                    g = abi_groups.setdefault(key, dict(window=key[0], name=name, calls=0, encodeMs=0, invokeMs=0, decodeMs=0))
                    g['calls'] += 1
                    for left, right in [('encode', 'invoke'), ('invoke', 'decode'), ('decode', 'return')]:
                        g[left + 'Ms'] += times[right] - times[left]
                    open_abi = None
        elif current and message.startswith(STAGES):
            current['events'].append(event)
            if message.startswith('emitted direct '):
                current['complete'] = True
    require(open_abi is None, 'Unfinished ABI call')
    expected = 1 + len(observed['warmRequests']) + len(observed.get('traceRequests', []))
    require(observed['role'] == 'typescript' or len(requests) == expected, 'Unexpected typed request count')
    require(all(r['complete'] for r in requests), 'Incomplete typed request')
    for r in requests:
        for a, b in zip(r['events'], r['events'][1:]):
            r['intervals'].append(dict(start=a['message'], end=b['message'], durationMs=b['epochMs'] - a['epochMs']))
        if request_windows:
            w = request_windows[r['ordinal']]
            lo, hi = epoch(w['begin']['wallTime']), epoch(w['end']['wallTime'])
            r['wallWindowContainsEvents'] = all(lo <= e['epochMs'] <= hi for e in r['events'])
    return dict(requests=requests, abiGroups=list(abi_groups.values()), eventCount=len(events),
                clockBackwardsEvents=backwards, events=events)


def analyze(row, inputs, args):
    observation = inputs.read(row['result'])
    require(observation == row['observation'], 'Worker observation differs from result file')
    require(observation['complete'] and observation['pass'] and observation['mode'] == 'trace', 'Worker did not pass in trace mode')
    require(observation['role'] == row['role'] and observation['sample'] == row['sample'], 'Row identity mismatch')
    require(observation['node'] == 'v24.18.0', 'Unexpected Node version')
    request = inputs.read(observation['request'])
    config = inputs.read(observation['config'])
    require(request['config'] == observation['config'] and request['case'] == row['case'], 'Request/config join mismatch')
    require(next(c for c in config['cases'] if c['id'] == row['case'])['source'] == observation['source'], 'Source differs from planned case')
    inputs.pin(config['node'])
    for item in config['inputs']:
        inputs.pin(item)
    for item in (observation['source'], observation['expected'], observation['output']):
        inputs.pin(item)
    prep = inputs.read(observation['preparation'])
    require(prep['complete'] and prep['pass'] and prep['role'] == row['role'], 'Preparation failed')
    require(prep.get('image') == observation.get('image'), 'Image changed from preparation')
    prepared = next(c for c in prep['outputs'] if c['id'] == row['case'])
    require(prepared['oracle']['pass'] and prepared['output'] == observation['expected'], 'Prepared output/oracle mismatch')
    require(observation['output']['sha256'] == observation['expected']['sha256'], 'Sample output differs from prepared bytes')
    if observation.get('image'):
        for field in ('api', 'driver', 'runtime', 'directRuntime', 'base'):
            inputs.pin(observation['image'][field])
        driver = Path(observation['image']['driver']['file'])
        inputs.pin(driver.with_name('compiler-abi.mjs'))
    result = Path(row['result']['file'])
    require(result.name.endswith('.result.json'), 'Unexpected worker result filename')
    directory = result.with_name(result.name.removesuffix('.result.json') + '-process')
    process = inputs.read(directory / 'process.json')
    require(process == row['execution'] and process['complete'] and process['returncode'] == 0, 'Process receipt mismatch/failure')
    for flag in ('--trace-opt', '--trace-deopt', '--trace-gc-nvp'):
        require(flag in process['command'], 'Missing trace flag ' + flag)
    require(config['node']['file'] in process['command'], 'Node binary differs from plan')
    require(process['command'][-2:] == [observation['request']['file'], row['result']['file']], 'Worker command mismatch')
    inputs.pin(process['command'][-3])
    stdout = v8(directory / 'stdout.log', observation, inputs, args)
    stderr = typed(directory / 'stderr.log', stdout['markerWindows'], observation, inputs, args)
    return dict(case=row['case'], role=row['role'], sample=row['sample'], worker=row['result'],
                api=observation.get('image', {}).get('api'), stdout=stdout, typed=stderr)


def markdown(report):
    text = ['# Phase57 compiler trace diagnostics', '', 'These are trace observations, not clean timing ratios.', '',
            '| Case | Role | V8 windows | Deoptimizations | GC events | GC pause ms | Typed requests |',
            '|---|---|---:|---:|---:|---:|---:|']
    for row in report['rows']:
        v = row['stdout']
        text.append(f"| {row['case']} | {row['role']} | {len(v['markerWindows'])} | {len(v['deoptimizations'])} | {len(v['gc'])} | {sum(e['pauseMs'] for e in v['gc']):.3f} | {len(row['typed']['requests'])} |")
    for row in report['rows']:
        text += ['', f"## {row['case']} / {row['role']}", '', '| Window | Function | Reason | Count |', '|---|---|---|---:|']
        groups = [g for g in row['stdout']['groups'] if g['kind'] == 'deopt'][:15]
        for g in groups:
            cells = [str(g[k]).replace('|', '\\|').replace('\n', ' ') for k in ('window', 'name', 'reason', 'count')]
            text.append('| ' + ' | '.join(cells) + ' |')
        if not groups:
            text.append('| — | No logged deoptimizations | — | 0 |')
    text += ['', '## Interpretation limits', ''] + ['- ' + note for note in NOTES]
    text += ['', 'Exact input hashes, per-request stages, ABI intervals, GC timestamps and all grouped events are in `report.json`.', '']
    return '\n'.join(text)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--report', type=Path, action='append', required=True)
    parser.add_argument('--out', type=Path, required=True)
    parser.add_argument('--max-log-mib', type=int, default=128)
    parser.add_argument('--max-lines', type=int, default=500000)
    args = parser.parse_args()
    require(1 <= args.max_log_mib <= 512 and 1 <= args.max_lines <= 2000000, 'Invalid read bounds')
    out = args.out.resolve()
    require(out.is_relative_to(ROOT / 'selfhost/build/phase57') and not out.exists(), 'Use a fresh Phase57 raw output directory')
    out.mkdir(parents=True)
    inputs = Inputs()
    report = dict(kind='phase57-compiler-trace-analysis', complete=False, passGate=False, diagnosticOnly=True,
                  producer=inputs.pin(HERE), limits=dict(maxLogMiB=args.max_log_mib, maxLines=args.max_lines, maxLineBytes=65536),
                  notes=NOTES, rows=[])
    try:
        for file in args.report:
            source = inputs.read(file)
            require(source['kind'] == 'phase57-four-image-library-latency' and source['mode'] == 'trace', 'Not a trace campaign')
            require(source['complete'] and source['pass'], 'Trace campaign did not pass')
            require(source['rows'], 'Empty trace campaign')
            inputs.read(source['config'])
            for row in source['rows']:
                report['rows'].append(analyze(row, inputs, args))
        inputs.finish()
        report['complete'] = report['passGate'] = True
    except Exception as error:
        report['error'] = str(error)
    report['inputs'] = list(inputs.pins.values())
    (out / 'report.json').write_text(json.dumps(report, indent=2) + '\n')
    if report['complete']:
        (out / 'report.md').write_text(markdown(report))
    print(json.dumps(dict(complete=report['complete'], rows=len(report['rows']), error=report.get('error'))))
    return 0 if report['complete'] else 1


if __name__ == '__main__':
    raise SystemExit(main())

#!/usr/bin/env python3
"""Publish a finished baseline report and a human-readable measurement summary."""
import json, pathlib, sys
root=pathlib.Path(__file__).resolve().parents[2]
source=pathlib.Path(sys.argv[1])
r=json.loads(source.read_text())
assert r.get('finished') and r.get('archiveUnchanged')
assert len(r['samples'])==45 and all(s['status']=='ok' for s in r['samples'])
assert len(r['summary'])==15 and all(s['successful']==3 for s in r['summary'])
out=root/'benchmarks'/('baseline-'+r['started'][:10]+'.json')
out.parent.mkdir(exist_ok=True)
out.write_text(source.read_text())
get=lambda case,impl:next(s for s in r['summary'] if s['workload']==case and s['implementation']==impl)
fmt=lambda s:f"{s['compileMs']['median']/1000:.3f}"
names={'no-base':'Tiny datatype (check)','declarations-256':'256 declarations (check)','base-u32':'Base + U32 (JS)','tree-io':'Tree + IO (JS)','list-sort':'List sort (JS)'}
lines=['# Performance baseline before compiler changes','',
    f"Measured {r['started'][:10]} against upstream `{r['upstreamRevision']}`. All 45 samples passed their checks; all 27 emitted JavaScript programs produced the expected output. The distribution manifest was verified before and after measurement: no existing source or shipped artifact changed.",'',
    f"[Raw measurements and provenance](../benchmarks/{out.name}) · [Harness and reproduction instructions](../tools/performance/README.md)",'',
    '## Controlled conditions','',
    f"Node {r['environment']['node']}, Intel Xeon E3-1245 V2, Linux x86-64. Each implementation used a fresh Node process, logical CPU {r['methodology']['cpuAffinity']}, a 4 MB JavaScript stack and a 4 GB old-space ceiling. Three samples per workload and implementation ran serially in balanced rotating order. There were no JIT warmups or persistent Base/check-prefix caches; every Base sample parsed and checked the same complete Base file. Filesystem caches were not flushed. This is a cold compiler-process comparison of full work, not cached CLI or steady-state JIT performance.",'',
    '## Compiler pipeline time','',
    'Seconds, median of three. Imports, Node startup, output-file persistence and execution of generated programs are excluded. Ratios divide each port median by the corresponding upstream median. “Bootstrap” is the supplied upstream-emitted typed Bend API; “self-emitted” is the verified self-hosting seed. The legacy prototype is not measured.','',
    '| Workload | Upstream TS | Bootstrap | Self-emitted | Bootstrap / TS | Self-emitted / TS |',
    '|---|---:|---:|---:|---:|---:|']
for case,name in names.items():
    u,b,s=(get(case,i) for i in ['upstream','bootstrap','selfhost'])
    lines.append(f"| {name} | {fmt(u)} | {fmt(b)} | {fmt(s)} | {b['compileRatioToUpstream']:.1f}× | {s['compileRatioToUpstream']:.1f}× |")
lines += ['','Check-only cases omit declaration-report formatting on both sides. JS cases load, fully check and emit a program, then independently validate its execution outside timing. Upstream output runs as CommonJS and port output as ESM, without rewriting emitted bytes.','',
    '## Range and process overhead','',
    'Measured minimum–maximum pipeline seconds; these are observed ranges, not confidence intervals.','',
    '| Workload | Upstream TS | Bootstrap | Self-emitted |','|---|---:|---:|---:|']
for case,name in names.items():
    cells=[]
    for impl in ['upstream','bootstrap','selfhost']:
        d=get(case,impl)['compileMs'];cells.append(f"{d['min']/1000:.3f}–{d['max']/1000:.3f}")
    lines.append('| '+name+' | '+' | '.join(cells)+' |')
lines += ['','Total process time includes Node startup, module imports, output persistence and exit. It matters for small inputs:','',
    '| Workload | Upstream TS process (s) | Bootstrap process (s) | Self-emitted process (s) |','|---|---:|---:|---:|']
for case in ['no-base','tree-io']:
    cells=[f"{get(case,i)['processMs']['median']/1000:.3f}" for i in ['upstream','bootstrap','selfhost']]
    lines.append('| '+names[case]+' | '+' | '.join(cells)+' |')
lines += ['','## Memory and phase attribution','',
    'Median process peak RSS in MiB, including module imports. This is neither minimum heap requirement nor phase-specific allocation.','',
    '| Workload | Upstream TS | Bootstrap | Self-emitted |','|---|---:|---:|---:|']
for case in ['base-u32','tree-io','list-sort']:
    cells=[f"{get(case,i)['maxRssKiB']['median']/1024:.1f}" for i in ['upstream','bootstrap','selfhost']]
    lines.append('| '+names[case]+' | '+' | '.join(cells)+' |')
lines += ['','Largest measured public API costs in the self-emitted tree compilation (median seconds). Upstream and port phase boundaries differ, so these are attribution, not like-for-like phase speed ratios.','',
    '| Entry point | Seconds |','|---|---:|']
phases=get('tree-io','selfhost')['phases']
for key,d in sorted(phases.items(),key=lambda kv:-kv[1]['median'])[:6]:
    lines.append(f"| `{key}` | {d['median']/1000:.3f} |")
lines += ['','The source-discovery pass calls `f_parse`, and graph loading parses sources again. Together with `check_book`, these are concrete profiling targets. The bootstrap/self-emitted gap also warrants separating generated-code/runtime overhead from algorithmic cost. Phase timings alone do not establish a specific optimization or its safety.','',
    'The adapter also rejects the supplied invalid-type fixture for all three implementations, with no output emitted. See [the negative validation record](../benchmarks/harness-negative-validation.json).','',
    '## Limits and next step','',
    'This selected five-workload baseline does not establish full-corpus performance, a self-rebuild time, interpreter speed, native/GPU performance, cached CLI latency or steady-state throughput. Three samples support a preliminary local baseline; no statistical confidence interval or cross-machine claim is made. The host was shared and CPU affinity does not isolate its SMT sibling. No compiler optimization has been applied.','',
    'Use the recorded artifacts as the control for the next change. Profile frontend discovery/loading and checking first, then compare a separately identified candidate with the same inputs, flags, cache policy and output checks. Preserve checking and conformance gates when evaluating any speedup.','']
(root/'docs/PERFORMANCE-BASELINE.md').write_text('\n'.join(lines))
print(out)
print(root/'docs/PERFORMANCE-BASELINE.md')

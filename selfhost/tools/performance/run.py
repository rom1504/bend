#!/usr/bin/env python3
"""Serial cold-process benchmark against the exact pinned Bend TypeScript compiler."""
import datetime, hashlib, json, os, pathlib, platform, resource, shutil, statistics, subprocess, sys, time
ROOT = pathlib.Path(__file__).resolve().parents[2]
UP = pathlib.Path(os.environ.get('BEND_UPSTREAM', ROOT / '.bootstrap/upstream')).resolve()
OUT = pathlib.Path(sys.argv[1] if len(sys.argv) > 1 else ROOT / 'build/performance/controlled-baseline-v2').resolve()
NODE = os.environ.get('BEND_BENCH_NODE') or shutil.which('node')
if not NODE:
    raise SystemExit('Set BEND_BENCH_NODE to a Node >=24 executable')
NODE = str(pathlib.Path(NODE).resolve())
PIN = '6018e28ecc67cf1fffc0c20c64b11023474c2df8'
CPU = os.environ.get('BEND_BENCH_CPU', '2')
FLAGS = ['--stack-size=4096', '--max-old-space-size=4096']
ENV = dict(os.environ)
for key in ['NODE_OPTIONS', 'NODE_COMPILE_CACHE', 'BEND_TYPED_TRACE']:
    ENV.pop(key, None)
ENV['NODE_DISABLE_COMPILE_CACHE'] = '1'
def now(): return datetime.datetime.now(datetime.timezone.utc).isoformat()
def run(cmd, timeout=180): return subprocess.run(list(map(str, cmd)), cwd=ROOT, env=ENV, capture_output=True, text=True, timeout=timeout)
def git(*args):
    r = run(['git', '-C', UP, *args]); r.check_returncode(); return r.stdout.strip()
def digest(p): return hashlib.sha256(pathlib.Path(p).read_bytes()).hexdigest()
def info(p): return dict(path=str(p), bytes=pathlib.Path(p).stat().st_size, sha256=digest(p))
archive = json.loads((ROOT / 'ARCHIVE-MANIFEST.json').read_text())
def verify_archive():
    changed = [f['path'] for f in archive['files'] if digest(ROOT / f['path']) != f['sha256']]
    if changed: raise RuntimeError(f'Archived files changed: {changed}')
verify_archive()
assert git('rev-parse', 'HEAD') == PIN and not git('status', '--porcelain'), 'Upstream must be clean and pinned'
assert digest(ROOT / 'dist/base.bend') == digest(UP / 'bend2/base.bend'), 'Base mismatch'
assert not (ROOT / 'build/performance/STOP').exists(), 'Preliminary run still stopping'
version = run([NODE, '--version']).stdout.strip()
assert int(version.split('.')[0][1:]) >= 24
OUT.mkdir(parents=True, exist_ok=False)
scale = OUT / 'declarations-256.bend'
scale.write_text('type Bit is Data:\n  Off{}\n  On{}\n\n' + ''.join(f'def value{i}() -> Bit:\n  On{{}}\n\n' for i in range(256)) + 'def main() -> Bit:\n  value255()\n#|On{}\n')
cases = [
    dict(id='no-base', file=ROOT/'tests/conformance/typed-smoke/bool.bend', mode='check', expected='checked'),
    dict(id='declarations-256', file=scale, mode='check', expected='checked'),
    dict(id='base-u32', file=ROOT/'tests/conformance/typed-smoke/base-u32.bend', mode='compile', expected='42'),
    dict(id='tree-io', file=ROOT/'tests/fixtures/tree.bend', mode='compile', expected='42'),
    dict(id='list-sort', file=UP/'tests/base/list_sort.bend', mode='compile', expected='6'),
]
implementations = ['upstream', 'bootstrap', 'selfhost']
def read(p):
    try: return pathlib.Path(p).read_text().strip()
    except OSError: return None
cgroup = read('/proc/self/cgroup')
cgpath = cgroup.split('0::')[-1] if cgroup and '0::' in cgroup else ''
report = dict(schema=1, started=now(), upstreamRevision=PIN,
    methodology=dict(operation='full check for no-Base workloads; load, fully check, and emit executable JavaScript for Base workloads', repetitions=3,
        warmups=0, processPolicy='fresh Node process per sample; first compilation; no JIT warmup',
        cachePolicy='no persistent Base cache or check-prefix reuse; OS filesystem caches uncontrolled/warm; Node module compile cache disabled',
        order='three balanced cyclic orders per workload; serial execution', cpuAffinity=CPU, nodeFlags=FLAGS, timeoutSeconds=180,
        timed='imports and compiler pipeline separately; process wall includes startup and output persistence; output execution excluded',
        phaseCaveat='Upstream and port phase boundaries differ; attribution only, not equivalent-work phase ratios',
        scope='five selected positive workloads; no full-corpus, native/GPU, interpreter, warm-JIT, cached CLI or full-self-rebuild performance claim'),
    environment=dict(node=version, nodeBinary=info(NODE), versions=json.loads(run([NODE,'-p','JSON.stringify(process.versions)']).stdout),
        platform=platform.platform(), cpuInfo=read('/proc/cpuinfo'), memInfoAtStart=read('/proc/meminfo'),
        loadAtStart=os.getloadavg(), nativeStackLimitBytes=resource.getrlimit(resource.RLIMIT_STACK), cgroup=cgroup,
        cgroupCpuMax=read('/sys/fs/cgroup'+cgpath+'/cpu.max'), cgroupMemoryMax=read('/sys/fs/cgroup'+cgpath+'/memory.max'),
        cpuGovernor=read(f'/sys/devices/system/cpu/cpu{CPU}/cpufreq/scaling_governor')),
    artifacts=[info(ROOT/f) for f in ['dist/typed-api.mjs','dist/selfhost/seed-verification/seed.mjs','src/runtime.mjs','tools/typed-driver.mjs','tools/compiler-abi.mjs','tools/performance/run.py','tools/performance/worker.mjs','ARCHIVE-MANIFEST.json']],
    upstreamArtifacts=[info(UP/f) for f in ['bend2/bend.ts','bend2/comp.ts','bend2/base.bend']],
    workloads=[dict(c, file=str(c['file']), **info(c['file'])) for c in cases], samples=[], summary=[])
def save(): (OUT/'report.json').write_text(json.dumps(report, indent=2)+'\n')
save()
for c in cases:
    for rnd in range(3):
        for j in range(3):
            impl = implementations[(rnd+j)%3]
            stem = f"{c['id']}-{rnd}-{impl}"
            output = OUT/(stem+(('.cjs' if impl=='upstream' else '.mjs') if c['mode']=='compile' else '.txt'))
            cmd = ['taskset','-c',CPU,NODE,*FLAGS,ROOT/'tools/performance/worker.mjs',impl,c['file'],output,UP,c['mode']]
            sample = dict(workload=c['id'], mode=c['mode'], round=rnd, implementation=impl, started=now(), command=list(map(str,cmd)), status='failed')
            t = time.perf_counter()
            try:
                result = run(cmd)
                sample.update(processMs=(time.perf_counter()-t)*1000, exitCode=result.returncode)
                (OUT/(stem+'.stderr')).write_text(result.stderr)
                (OUT/(stem+'.stdout')).write_text(result.stdout)
                result.check_returncode()
                sample.update(json.loads(result.stdout))
                if c['mode']=='compile':
                    validation = run(['taskset','-c',CPU,NODE,*FLAGS,output],timeout=10)
                    sample['validation'] = dict(exitCode=validation.returncode, actual=validation.stdout.strip(), expected=c['expected'], stderr=validation.stderr)
                    sample['status'] = 'ok' if validation.returncode==0 and validation.stdout.strip()==c['expected'] else 'wrong-output'
                else:
                    actual = output.read_text()
                    sample['validation'] = dict(actual=actual, expected='checked')
                    sample['status'] = 'ok' if actual=='checked' else 'wrong-output'
                sample['outputSha256'] = digest(output)
            except (subprocess.SubprocessError, ValueError, OSError) as e:
                sample.update(error=str(e), processMs=(time.perf_counter()-t)*1000)
                if isinstance(e,subprocess.TimeoutExpired): sample['status']='timeout'
            report['samples'].append(sample); save()
            print(json.dumps({k:sample.get(k) for k in ['workload','round','implementation','status','compileMs','processMs']}),flush=True)
def stats(values): return dict(n=len(values),median=statistics.median(values),min=min(values),max=max(values))
for c in cases:
    for impl in implementations:
        rows = [s for s in report['samples'] if s['workload']==c['id'] and s['implementation']==impl and s['status']=='ok']
        summary = dict(workload=c['id'], mode=c['mode'], implementation=impl, successful=len(rows), attempted=3)
        if rows:
            for field in ['compileMs','importMs','importAndCompileMs','processMs','cpuMs','maxRssKiB']:
                summary[field] = stats([r[field] for r in rows])
            summary['phases'] = {key:stats([r['phases'].get(key,0) for r in rows]) for key in rows[0]['phases']}
        report['summary'].append(summary)
for row in report['summary']:
    base = next(s for s in report['summary'] if s['workload']==row['workload'] and s['implementation']=='upstream')
    if row['successful']==3 and base['successful']==3:
        row['compileRatioToUpstream'] = row['compileMs']['median']/base['compileMs']['median']
verify_archive()
assert not git('status','--porcelain'), 'Upstream changed during run'
report.update(finished=now(), archiveUnchanged=True)
report['environment']['loadAtEnd'] = os.getloadavg()
save()
print('Report: '+str(OUT/'report.json'),flush=True)
sys.exit(int(any(s['status']!='ok' for s in report['samples'])))

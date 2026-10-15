#!/usr/bin/env python3
"""Freeze exact-image full-self sampler commands; data only, no targets."""
import hashlib
import json
from pathlib import Path
import shlex
import shutil

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[4]
BUILD = ROOT / 'selfhost/build/phase98'
OWN = ROOT / 'selfhost/tools/performance/phase88/ownership'


def pin(path):
    path = Path(path).resolve(); data = path.read_bytes()
    return dict(file=str(path), bytes=len(data), sha256=hashlib.sha256(data).hexdigest())


def main():
    manifest_path = HERE / 'ownership-origin-b1-preparation01.json'
    guide_path = manifest_path.with_suffix('.md')
    assert not manifest_path.exists() and not guide_path.exists()
    oracle_path = BUILD / 'origin-b1-self01/report.json'
    oracle = json.loads(oracle_path.read_text())
    assert oracle['complete'] and oracle['passed'] and oracle['inputsUnchanged']
    image = oracle['producer']['binary']; source = oracle['source']; generated_c = oracle['producer']['c']
    assert image['sha256'] == '099df960c418c9caef6977f011074fcc2aa43e2fbbd3daee32fe80824b54e1e9'
    assert source['sha256'] == '2a72bbdc3d757982d7dd4804d8a1312f9427e3b2822ed9d187424c2d9f4de051'
    table_dir = BUILD / 'ownership-origin-b1-table01'
    table_path = table_dir / 'table.json'; header_path = table_dir / 'unwind-table.h'
    table = json.loads(table_path.read_text())
    assert table['binary_sha256'] == image['sha256'] and table['binary'] == image['file']
    assert table['header_sha256'] == pin(header_path)['sha256'] and len(table['rows']) == 55
    assert table['generator_sha256'] == pin(OWN / 'make-table.py')['sha256']
    sampler = BUILD / 'ownership-origin-b1-sample01.so'
    build_guard = BUILD / 'ownership-origin-b1-build01'
    capture = BUILD / 'ownership-origin-b1-self01'
    binding = BUILD / 'ownership-origin-b1-binding01.json'
    assert all(not x.exists() for x in [sampler, build_guard, capture, binding])
    python = '/usr/bin/python3'; guard = ROOT / 'selfhost/tools/performance/phase86/guard.py'
    clang = Path('/home/ai/.elan/toolchains/leanprover--lean4---v4.32.0/bin/clang')
    checker = HERE / 'ownership-origin-b1-check.py'
    native = list(oracle['row']['command']); native = native[native.index(image['file']):]
    old_prefix = str(BUILD / 'origin-b1-self01/execution/output')
    assert native.count(old_prefix) == 1 and 'phase90-native' not in native
    assert oracle['producer']['argvSentinel'] is False
    assert native[native.index('--') + 1] == source['file']
    native[native.index(old_prefix)] = str(capture / 'program')
    def guarded(out, seconds, rss, argv):
        return [python, '-B', str(guard), '--out', str(out), '--seconds', str(seconds),
                '--rss-mib', str(rss), '--available-mib', '4096', '--cpu', '3', '--', *map(str, argv)]
    commands = dict(
        buildSampler=guarded(build_guard, 60, 512, [clang, '-isystem', clang.parent.parent / 'include/clang',
            '-std=c11', '-O2', '-Wall', '-Wextra', '-Werror', '-fPIC', '-shared', '-I', table_dir,
            OWN / 'sample-ownership.c', '-o', sampler, '-pthread', '-ldl', '-lrt']),
        bindSampler=[python, '-B', str(checker), '--preparation', str(manifest_path), '--bind-sampler', '--out', str(binding)],
        capture=guarded(capture / 'guard', 300, 2048, ['env', 'LD_PRELOAD=' + str(sampler),
            'BEND_SAMPLE_OUT=' + str(capture / 'samples.txt'), 'BEND_SAMPLE_PERIOD_US=16000', *native]),
        analyzeOffline=['taskset', '-c', '0', python, '-B', str(OWN / 'analyze.py'), '--samples', str(capture / 'samples.txt'),
            '--binary', image['file'], '--table', str(table_path), '--stderr', str(capture / 'guard/stderr.log'),
            '--out', str(capture / 'analysis.json')],
        verifyAndWindowsOffline=['taskset', '-c', '0', python, '-B', str(checker), '--preparation', str(manifest_path),
            '--binding', str(binding), '--analysis', str(capture / 'analysis.json'), '--out', str(capture / 'windows.json')])
    files = [__file__, HERE / 'prepare-origin-b2-profile.py', HERE / 'ownership-origin-b2-check.py', checker, oracle_path, oracle['producer']['build']['file'], image['file'], source['file'], generated_c['file'],
             oracle['row']['output']['file'], oracle['row']['diagnosticFile']['file'], table_path, header_path,
             OWN / 'make-table.py', OWN / 'sample-ownership.c', OWN / 'analyze.py',
             ROOT / 'selfhost/tools/performance/phase68/parity-survey/sample-analysis-v2.py',
             ROOT / 'selfhost/tools/performance/phase90/profiling/windows.py',
             ROOT / 'selfhost/tools/performance/phase98/qualification/support.py',
             guard, ROOT / 'selfhost/tools/performance/programs/support.py', python, clang,
             *[shutil.which(name) for name in ['nm', 'readelf', 'addr2line', 'taskset']]]
    for item in native:
        if Path(item).is_file(): files.append(item)
    transport = ROOT / 'selfhost/build/phase90/runtime-accessor-transport02'
    files += list(transport.glob('runtime.c.part*')) + list((transport / 'effs').glob('*.c'))
    inputs = list({row['file']: row for row in map(pin, files)}.values())
    for row in [image, source, generated_c, oracle['row']['output'], oracle['row']['diagnosticFile']]: assert pin(row['file']) == row
    result = dict(kind='phase98-origin-b1-full-ownership-preparation', complete=True, targetsRun=False,
        method=pin(__file__), image=image, source=source, c=generated_c, table=pin(table_path), header=pin(header_path),
        inputs=inputs, commands=commands, cwd=str(ROOT), samplerPath=str(sampler), samplerBuildGuard=str(build_guard),
        samplerBindingPath=str(binding), captureDirectory=str(capture), samplerBuildPerformed=False, capturePerformed=False,
        periodUs=16000, threadCapacity=25000, nominalPerThreadCpuCapacitySeconds=400,
        deadlineSeconds=300, rssMiB=2048, availableMiB=4096, watchdog=False,
        oracle=dict(report=pin(oracle_path), c=oracle['row']['output'], diagnostic=oracle['row']['diagnosticFile']),
        qualityRequirements=[
            'Build only the small exact-table preload under the root serial guard; bind its successful build and hash before capture.',
            'Require normal successful full-target exit, exact same-image same-source complete C and clock-stripped diagnostic, and empty stdout.',
            'Use unchanged Phase88 analyze.py; require END, main-thread destructor, exact six IO.now marks and phase clock agreement, matching image/table, accepted process CPU coverage.',
            'Also require zero overruns, dropped samples, thread overflow, thread-clock failures and timer-disarm failures; analyzer acceptance alone does not require zero overruns.',
            'Keep incomplete, failed or lossy runs as failures/exploratory evidence; do not label a prefix a full profile or silently rerun for a favorable capture.'],
        limitations=[
            'One worker on CPU3, 16 ms sampling, at most three physical ownership return frames; no compiler binary changes.',
            'Sampler compatibility established offline by exact ELF symbols and 55 accepted rsp-relative CFI rows, not yet by an executed capture.',
            'Windows adapt Phase90 aggregation to the validated full request only; Base, runtime transport and output writing remain separate.',
            'No new sampling framework or unwind rules. B1 upstream-generated and B2 own-generated physical symbols/runtime paths differ.',
            'This capture is a matched same-source companion to the successful B2 profile. Physical symbols/runtime paths differ; a sampled difference alone is not a controlled causal speedup.',
            'Keep 512 MiB free for C/raw artifacts; existing guard enforces the 64 MiB per-file cap and 160 MiB disk floor.'])
    manifest_path.write_text(json.dumps(result, indent=2) + '\n')
    lines = ['# Exact origin B1 full-self ownership capture', '',
        'Prepared data only. The unchanged Phase88 ELF generator accepted 55 unwind rows for',
        '`099df960…` (the actual origin B1 image). No sampler build or capture has run.', '',
        'Root executes these commands serially, in order. This upstream-generated B1 image',
        'does not use the B2 argv sentinel. Capture uses 300 s / 2 GiB, a 4 GiB floor, CPU 3,',
        'one worker and 16 ms samples, with no watchdog. Reserve 512 MiB disk space.', '']
    for name, command in commands.items(): lines += ['## ' + name, '', '```sh', shlex.join(command), '```', '']
    lines += ['The oracle is the successful unsampled **same-image, same-source** request in',
        '`origin-b1-self01`, including complete C and the exact diagnostic after removing only',
        'the existing clock lines. Binding and final checking are offline data operations.', '',
        'The unchanged Phase88 analyzer must accept complete clocks and coverage. The final',
        'postprocessor separately requires zero loss, successful target exit, exact C/diagnostic',
        'and unchanged inputs. It produces 30 s windows measured from request start, clipping',
        'the final window to completion. They are wall-time windows, not compiler stages.', '',
        'Physical ownership callers do not reconstruct eliminated Bend ancestors or inline RC',
        'operations. Sampled times include profiler overhead and are not speed comparisons.',
        'A failed or partial capture stays failed/partial; no full-profile claim is permitted.', '']
    guide_path.write_text('\n'.join(lines))
    print(json.dumps(dict(complete=True, targetsRun=False, manifest=pin(manifest_path), guide=pin(guide_path), inputs=len(inputs))))


if __name__ == '__main__': main()

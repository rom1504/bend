#!/usr/bin/env python3
"""Freeze metadata and commands for the actual-path native FIFO smoke; no targets."""
import argparse
import hashlib
import json
from pathlib import Path
import shlex

ROOT = Path(__file__).resolve().parents[5]


def pin(path):
    p = Path(path).resolve()
    data = p.read_bytes()
    return dict(file=str(p), bytes=len(data), sha256=hashlib.sha256(data).hexdigest())


def main():
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument('--out', type=Path, required=True)
    args = ap.parse_args()
    out = args.out.resolve()
    assert not out.exists() and out.is_relative_to(ROOT / 'selfhost/build/phase135')
    reference_path = ROOT / 'selfhost/build/phase134/reference03.json'
    reference = json.loads(reference_path.read_text())
    assert reference['complete']
    lexer = next(c for c in reference['cases'] if c['name'] == 'lexer')
    for item in [lexer['source'], lexer['expectedQbe'], reference['runtime'], reference['carrierReceipt']]:
        assert pin(item['file']) == item
    source = pin(ROOT / 'selfhost/build/phase135/machine-source02/compiler.bend')
    assert source['sha256'] == '391a6f2dde2ef960a2d8b33a3100a0d9ba53ff68848a2279d502f7858019091c'
    image = ROOT / 'selfhost/build/phase134/p135-machine-native01/program'
    build = image.parent / 'report.json'
    runout = ROOT / 'selfhost/build/phase135/machine-native-smoke01'
    cache = ROOT / 'selfhost/build/phase135/machine-native-smoke-cache01'
    guardout = ROOT / 'selfhost/build/phase135/machine-native-smoke-guard01'
    assert all(not p.exists() for p in [runout, cache, guardout])
    supervisor = ROOT / 'selfhost/tools/performance/phase135/machine/session-build-v01.py'
    command = ['python3', '-B', str(supervisor), '--image', str(image), '--image-report', str(build),
        '--a', lexer['source']['file'], '--b', lexer['source']['file'],
        '--runtime', reference['runtime']['file'], '--carrier-receipt', reference['carrierReceipt']['file'],
        '--out', str(runout), '--cache', str(cache), '--expected-a', lexer['expectedQbe']['file'],
        '--expected-b', lexer['expectedQbe']['file'], '--mode', 'warm', '--retain-b', '--seconds', '100']
    guard = ['python3', str(ROOT / 'selfhost/tools/performance/phase111/guard.py'),
        '--out', str(guardout), '--seconds', '120', '--rss-mib', '3072', '--available-mib', '16384',
        '--file-mib', '128', '--cpu', '3', '--', *command]
    metadata = dict(kind='phase135-native-framed-smoke-plan', complete=True, targetsRun=False,
        imageReadiness='Pending; execution supervisor must authenticate the completed exact image/build receipt. This plan is not acquisition evidence.',
        expectedCompilerSource=source, pendingImage=str(image), pendingImageReport=str(build),
        source=lexer['source'], expectedPayload=lexer['expectedQbe'], runtime=reference['runtime'],
        carrierReceipt=reference['carrierReceipt'], inputs=[pin(__file__), pin(reference_path), pin(supervisor),
            pin(ROOT / 'selfhost/tools/performance/phase111/guard.py'), source,
            lexer['source'], lexer['expectedQbe'], reference['runtime'], reference['carrierReceipt']],
        command=command, guardedCommand=guard,
        requiredResult='Joined producer exit zero plus both complete machine reports and exact independent full Lexer QBE payloads. Native FIFO ABI/ownership smoke only; same-source A=B is not a real-edit incrementality result.',
        nextGate='Independent retained-B cold replay and ELF comparison, then the separately frozen actual full compiler edit. Preserve original actual source paths and independent full QBE identities.',
        clocks='Whole pipeline wall is critical-path time. Native render intervals include FIFO backpressure. Do not sum overlapping producer/consumer wall clocks.')
    out.mkdir(parents=True)
    (out / 'plan.json').write_text(json.dumps(metadata, indent=2) + '\n')
    (out / 'command.sh').write_text('# Pending completed image acquisition; coordinator-controlled execution only.\n' + shlex.join(guard) + '\n')
    print(json.dumps(dict(complete=True, targetsRun=False, plan=pin(out / 'plan.json'))))


if __name__ == '__main__':
    main()

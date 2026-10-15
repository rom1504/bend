#!/usr/bin/env python3
"""Root-run complete native control pairs; all targets serial and bounded."""
import argparse
import json
from pathlib import Path
import sys
sys.dont_write_bytecode = True
ROOT = Path(__file__).resolve().parents[4]
sys.path.insert(0, str(ROOT/'selfhost/tools/laws/phase98'))
from common import BUILD, CLANG, pin, read, save, verify, run, passed


def verify_nested(value):
    if isinstance(value, dict):
        if {'file', 'sha256', 'bytes'} <= value.keys():
            verify({key:value[key] for key in ['file','sha256','bytes']})
        else:
            for child in value.values(): verify_nested(child)
    elif isinstance(value, list):
        for child in value: verify_nested(child)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--receipt', type=Path, required=True)
    parser.add_argument('--out', type=Path, required=True)
    parser.add_argument('--record', choices=['P98TagCase','P98ScalarCase'], required=True)
    args = parser.parse_args()
    receipt = read(args.receipt); verify_nested(receipt)
    assert receipt['complete'] and not receipt['targetsRun']
    sources = {Path(p['file']).stem:p for p in receipt['outputs']}
    assert set(sources) == {'baseline','candidate'}
    out = args.out.resolve(); assert out.is_relative_to(BUILD) and not out.exists()
    out.mkdir()
    inputs = [pin(__file__), pin(ROOT/'selfhost/tools/laws/phase98/common.py'),
              pin(args.receipt), pin(ROOT/'selfhost/tools/performance/phase98/acquire.mjs')]
    report = dict(complete=False, inputs=inputs, recipe=receipt, roles={},
                  scope='Upstream checked C for complete-value control pairs; no own-backend or whole-compiler correctness claim.')
    def write(): save(out/'report.json', report)
    write()
    try:
        for role in ['baseline','candidate']:
            folder = out/role; row = dict(source=sources[role]); report['roles'][role] = row
            job = run(out/(role+'-acquire-guard'),
                      [ROOT/'selfhost/build/phase66/bun-toolchain01/bun',
                       ROOT/'selfhost/tools/performance/phase98/acquire.mjs',sources[role]['file'],folder],60)
            row['acquire'] = job; write(); assert passed(job)
            checked = read(folder/'report.json'); assert checked['complete'] and checked['holes'] == 0
            row['checked'] = pin(folder/'report.json')
            job = run(out/(role+'-build-guard'),
                      [CLANG,'-isystem',CLANG.parent.parent/'include/clang','-O2',folder/'program.c',
                       '-o',folder/'program','-lm','-pthread'],60)
            row['build'] = job; write(); assert passed(job)
            row['binary'] = pin(folder/'program')
            job = run(out/(role+'-run-guard'),[folder/'program','--threads','1','--gpu','off'],30)
            row['run'] = job; write(); assert passed(job) and not job['stderr']
            assert job['stdout'].count(args.record+'{') == receipt['cases']
            row['observedRecords'] = receipt['cases']; write()
        assert report['roles']['baseline']['run']['stdout'] == report['roles']['candidate']['run']['stdout']
        verify_nested(receipt)
        for item in inputs: verify(item)
        report.update(complete=True, fullStdoutExact=True, inputsUnchanged=True,
                      completeRecords=receipt['cases'])
    except BaseException as error:
        report['error'] = repr(error); raise
    finally: write()
    print(json.dumps({key:report[key] for key in ['complete','fullStdoutExact','completeRecords']}))


if __name__ == '__main__': main()

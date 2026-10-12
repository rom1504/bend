#!/usr/bin/env python3
"""Prepare exact Phase70 successors of sealed Phase69 methods; no targets."""
import argparse
import ast
import hashlib
import json
import os
from pathlib import Path

ROOT = Path(__file__).resolve().parents[5]
RAW = ROOT / 'selfhost/build/phase70'
P69 = 'selfhost/build/phase69/methods01/'
T69 = 'selfhost/tools/performance/phase69/methods/'


def pin(path):
    path = Path(path).resolve(strict=True)
    data = path.read_bytes()
    return dict(file=str(path), sha256=hashlib.sha256(data).hexdigest(), bytes=len(data))


def write(path, value):
    with path.open('x') as stream:
        stream.write(value if isinstance(value, str) else json.dumps(value, indent=2) + '\n')


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--out', type=Path, required=True)
    args = parser.parse_args()
    assert os.sched_getaffinity(0) == {0}, 'Data preparation belongs on CPU0'
    out = args.out.resolve()
    assert out.is_relative_to(RAW) and not out.exists()
    out.mkdir(parents=True)
    methods = []

    def derive(name, parent_name, expected, edits):
        parent = ROOT / parent_name
        parent_pin = pin(parent)
        assert parent_pin['sha256'] == expected, parent
        text = parent.read_text()
        recorded = []
        for old, new, count in edits:
            assert text.count(old) == count, (name, old, text.count(old), count)
            text = text.replace(old, new)
            recorded.append(dict(before=old, after=new, count=count))
        ast.parse(text, filename=name, feature_version=9)
        target = out / name
        write(target, text)
        receipt = dict(kind='phase70-exact-method-derivation', parent=parent_pin,
                       output=pin(target), edits=recorded, producer=pin(__file__),
                       targetsExecuted=False,
                       scope='Only explicitly recorded boundary, baseline identity and provenance-label changes. Parent bytes preserved; target guards and semantic oracles unchanged.')
        write(target.with_suffix('.derivation.json'), receipt)
        methods.append(dict(name=name, **receipt, receipt=pin(target.with_suffix('.derivation.json'))))

    boundary = ('selfhost/build/phase69', 'selfhost/build/phase70', 1)
    derive('prepare-integration.py', P69+'prepare-integration.py',
           '03e81d418678300c6c1145987829bb1589ea1c806be6caab89797eacfa28608b', [boundary])
    derive('prepare-raw.py', P69+'prepare-raw.py',
           '66feb12fde9418c6461570f163d888fb2d0de549bc6ec3f47e3e74d46ec9dd1c', [boundary])
    derive('prepare-threads.py', P69+'prepare-threads.py',
           '4eb171eb3bf0a1e382b48a069fad8d20dfbaa363f45f2801882103b69b079e5f',
           [('selfhost/build/phase69', 'selfhost/build/phase70', 2)])
    derive('prepare-custom.py', T69+'prepare-custom.py',
           '8284c6133a2de0996fa6f8bf6f8ec6d09a92c89979a2b54d238e40bbb719b03e', [boundary])
    derive('prepare-custom-raw.py', T69+'prepare-custom-raw-v2.py',
           '783c0c5e97b58199148e827bddbcf7caca1a8eaabe1be0adc0bd831e4534e146', [boundary])
    derive('compare-native.py', P69+'compare-native-v2.py',
           'b09b38af16ecf4cce59c6893ef4e5123014566d740194da175dbcf11c11ecdd5', [
        ('baseline23', 'baseline69', 8),
        ('Baseline23', 'Baseline69', 1),
        ("paths=[('baseline69',ROOT/'selfhost/build/phase68'/n/'report.json') for n in ['native-facts23-lexer','native-facts23-rest']]",
         "paths=[('baseline69',ROOT/'selfhost/build/phase69/typed10-native/report.json')]", 1),
        ("out.is_relative_to(ROOT/'selfhost/build/phase69')", "out.is_relative_to(ROOT/'selfhost/build/phase70')", 1),
        ('Compare saved compiler23/candidate/upstream', 'Compare saved Phase69 typed10/candidate/upstream', 1)])
    derive('verify-js.py', P69+'verify-js.py',
           '54c4cdecacb963f3d5182878107cc440b23fe9a70874e6962001209c3a61537e', [
        ('out.mkdir(exist_ok=False)',
         "out = out.resolve(); assert out.is_relative_to(Path("+repr(str(RAW))+"))\nout.mkdir(exist_ok=False)", 1)])
    derive('prepare-compilation.py', P69+'prepare-compilation.py',
           'bbc5070005f541a599cc4e546e8ba054497aeb7769c25f9a9b85020d085111f6', [boundary])
    derive('prepare-bootstrap.py', P69+'prepare-bootstrap-v2.py',
           '1f2ea9723e934b6fdddc1bf3e377d90b73de415d999795b98e53f984b70a3d99', [boundary])
    derive('prepare-release-qualification.py', T69+'prepare-release-qualification.py',
           '8bc6fcbedcaeace75a566acf6afd741ca0ba332bf9ff0627573da005a4575355', [
        ('ROOT = Path(__file__).resolve().parents[5]', 'ROOT = Path('+repr(str(ROOT))+')', 1),
        ('selfhost/build/phase69', 'selfhost/build/phase70', 2),
        ('inside Phase69', 'inside Phase70', 1)])

    development = dict(project=str(ROOT/'selfhost'), upstream=str(ROOT/'selfhost/.bootstrap/upstream-phase66'),
                       profile='equality', strictExact=True, jobs=1, cpu='3', heapMb=1024)
    write(out/'development.json', development)
    baseline_api = pin(ROOT/'selfhost/build/phase69/typed-build10/equality/api.mjs')
    assert baseline_api['sha256'] == '674e7960c7e8957452ffb0bdc6cb1f69ddaf8c03814617277886d1551fe16553'
    baseline_report = pin(ROOT/'selfhost/build/phase69/typed10-native/report.json')
    assert baseline_report['sha256'] == 'b0756f8d444248231e3ccf0d2ae6c694e74545e36fd52d95eca332703f826324'
    b2 = pin(ROOT/'selfhost/build/phase69/typed10-b2-v2/full/compiler.mjs')
    assert b2['sha256'] == 'c858dfa5424c534444a2b733c0336a7009fc260da272d64c52f33a188d3f066e'
    result = dict(kind='phase70-method-derivations', dataOnly=True, targetsExecuted=False,
        producer=pin(__file__), methods=methods, development=pin(out/'development.json'),
        baselineApi=baseline_api, baselineNativeAcquisition=baseline_report, baselineB2=b2,
        baselineImagePins=pin(ROOT/'selfhost/build/phase69/typed10-b2-v2/image-pins.json'),
        scope='Phase69 sealed bytes remain immutable. New output boundaries are Phase70 only. Native comparison baseline is actual checked69 typed10. Upstream sources, C toolchain, runtime controls, independent checksums, fixed work, guards and B2 trust boundaries remain inherited. Node target execution requires approved escalation for the diagnosed managed-sandbox PIPE/EPERM issue. Preparation does not run or qualify targets.')
    write(out/'methods.json', result)
    print(json.dumps(dict(manifest=pin(out/'methods.json'), derivatives=len(methods), targetsExecuted=False)))


if __name__ == '__main__':
    main()

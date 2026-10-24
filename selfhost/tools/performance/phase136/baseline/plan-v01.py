#!/usr/bin/env python3
"""Freeze the existing ordinary native-to-monolithic pipeline; metadata only."""
import argparse
import hashlib
import importlib.util
import json
from pathlib import Path
import shlex
import sys

sys.dont_write_bytecode = True
ROOT = Path(__file__).resolve().parents[5]


def pin(path):
    path = Path(path).resolve()
    h = hashlib.sha256(); size = 0
    with path.open('rb') as f:
        while data := f.read(65536):
            size += len(data); h.update(data)
    return dict(file=str(path), bytes=size, sha256=h.hexdigest())


def read(path):
    return json.loads(Path(path).read_text())


def main():
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument('--out', type=Path, required=True)
    a = ap.parse_args(); out = a.out.resolve()
    assert not out.exists() and out.is_relative_to(ROOT/'selfhost/build/phase136')
    capsule_path = ROOT/'implementation/phase134/final/candidate.json'
    capsule = read(capsule_path)
    assert capsule['complete'] and capsule['nativeQualified']
    qualification = read(capsule['qualification']['file'])
    assert qualification['complete'] and qualification['nativeQualified']
    assert qualification['finalImage'] == capsule['finalImage'] == capsule['n2']
    assert qualification['source'] == capsule['source'] and qualification['runtime'] == capsule['runtime']
    expected_path = ROOT/'selfhost/build/phase130/p131-final-self01/report.json'
    expected = read(expected_path)
    assert expected['complete'] and expected['exitCode'] == 0
    assert expected['source']['sha256'] == '1bc5930edcf80cda6c3572645df3c846fa631a83c2b936f20c83b05e0a6728f9'
    assert expected['product']['sha256'] == 'f3ff63b04b58e5a5b92be781d0d1cba8cc574a37765cbf66d817c3d38f4b576e'
    assert expected['runtime'] == capsule['runtime']
    native_path = ROOT/'selfhost/tools/performance/phase130/native-request.py'
    spec = importlib.util.spec_from_file_location('native_metadata', native_path)
    native = importlib.util.module_from_spec(spec); spec.loader.exec_module(native)
    carrier, base, carrier_inputs = native.carrier_inputs(Path(capsule['preferredCarrierReceipt']['file']))
    assert carrier['carrier'] == capsule['preferredCarrier'] and carrier['stamp'] == capsule['preferredStamp']
    assert base == expected['base']
    pipe = ROOT/'selfhost/tools/performance/phase134/pipe/build-v02.py'
    guard = ROOT/'selfhost/tools/performance/phase111/guard.py'
    destination = ROOT/'selfhost/build/phase134/p136-cold-baseline01'
    guardout = ROOT/'selfhost/build/phase136/cold-baseline-guard01'
    command = ['python3','-B',str(pipe),'--image',capsule['finalImage']['file'],
        '--source',expected['source']['file'],'--carrier-receipt',capsule['preferredCarrierReceipt']['file'],
        '--runtime',capsule['runtime']['file'],'--expected-qbe',expected['product']['file'],
        '--out',str(destination),'--seconds','700']
    guarded = ['python3',str(guard),'--out',str(guardout),'--seconds','750','--rss-mib','4096',
        '--available-mib','16384','--file-mib','256','--cpu','3','--',*command]
    inputs = [pin(__file__),pin(capsule_path),capsule['qualification'],capsule['source'],capsule['sourceManifest'],
        capsule['finalImage'],pin(Path(capsule['finalImage']['file']).parent/'report.json'),capsule['runtime'],
        capsule['runtimeReport'],pin(expected_path),expected['source'],expected['product'],
        pin(pipe),pin(guard),pin(native_path),pin(ROOT/'selfhost/tools/performance/programs/support.py'),*carrier_inputs]
    inputs = list({(p['file'],p['sha256']):p for p in inputs}.values())
    for item in inputs:
        assert pin(item['file']) == item, 'Changed pinned input: '+item['file']
    plan = dict(kind='phase136-qualified-cold-source-to-executable-plan',complete=True,targetsRun=False,
        inputs=inputs,qualifiedProducerSource=capsule['source'],qualifiedProducer=capsule['finalImage'],
        qualification=capsule['qualification'],source=expected['source'],expectedQbe=expected['product'],
        runtime=capsule['runtime'],base=base,carrier=carrier['carrier'],carrierReceipt=capsule['preferredCarrierReceipt'],
        carrierStamp=carrier['stamp'],command=command,guardedCommand=guarded,
        result=str(destination/'report.json'),resourceGuard=str(guardout/'process.json'),
        coldPolicy='Fresh ordinary source request and fresh monolithic QBE/as/link. No retained source/edit/optimizer/object session state. OS caches are not flushed. Explicit immutable compact prepared Base, prebuilt runtime and producer executable are allowed, with acquisition outside this baseline.',
        clockPolicy='Primary clock is complete outer resource-guard wall, including pipe preflight/authentication and full source-to-executable pipeline. Inner wall excludes preflight. Emission and QBE overlap on one CPU; their combined interval includes backpressure. Assembly/link are subsequent nested intervals. Never add nested/overlapping clocks or call this cold Base/runtime/toolchain acquisition.',
        validation='Require compiler/QBE/assembler/link success, independent entire107059385-byte digest, unchanged inputs and resource guard success. Then validate the new executable on the frozen three-request oracle subset if the coordinator selects a smoke; no repeated full self-host or broad45 campaign is implied.',
        scope='Controlled cold ordinary compiler workload, not an edit-loop result, upstream comparison, whole-language proof, new N2 qualification or installed selection change.')
    out.mkdir(parents=True);(out/'plan.json').write_text(json.dumps(plan,indent=2)+'\n')
    (out/'command.sh').write_text('# Coordinator-controlled execution; do not run concurrently with controlled timing.\n'+shlex.join(guarded)+'\n')
    print(json.dumps(dict(complete=True,targetsRun=False,plan=pin(out/'plan.json'))))


if __name__ == '__main__':
    main()

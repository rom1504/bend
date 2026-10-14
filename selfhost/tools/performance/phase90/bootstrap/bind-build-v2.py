#!/usr/bin/env python3
"""Bind a guarded Clang result to actual JS-hosted Bend C emission; no targets."""
import argparse
import json
import sys
from pathlib import Path

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[4]
sys.dont_write_bytecode = True
sys.path.insert(0, str(ROOT/'selfhost/tools/performance/phase88'))
from native_support import pin, verify, require

parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument('emission', type=Path, help='Completed emit-self report.json')
parser.add_argument('guard', type=Path, help='Completed guarded Clang directory')
parser.add_argument('binary', type=Path)
parser.add_argument('receipt', type=Path, help='Fresh provenance file; does not grant launcher/cache admission')
args = parser.parse_args()
emission_pin = pin(args.emission)
emission = json.loads(args.emission.read_text())
require(emission['kind'] == 'phase90-js-b1-native-self-source-emission'
        and emission['complete'] and emission['inputsUnchanged'], 'Incomplete C emission')
require(emission['producer']['stage'] == 'checked equality-derived JS-hosted Bend B1'
        and emission['subject']['sha256'] == '4584cf083d9eddad6f1290c9472c3aac2708099caa716a27f5b53fbcbaee1618',
        'Wrong producer/source')
require(emission['observation']['status'] == 'ok' and emission['observation']['checked']
        and len(emission['policy']) == 4 and all(v == 0 for v in emission['policy'].values()),
        'Unchecked emission or unexpected representation permission')
# This method binds a real checked B1 producer, never the old installed B2 name.
for record in emission['inputs']:
    verify(record)
producer = emission['producer']
attempt = json.loads(Path(verify(producer['attempt'])['file']).read_text())
validation = json.loads(Path(verify(producer['validation'])['file']).read_text())
require(attempt['checked'] and attempt['artifactKind'] == 'derived-b1'
        and validation['complete'] and validation['pass'] and validation['strictExact'], 'Incomplete checked producer')
require(verify(producer['api'])['sha256'] == attempt['api']['sha256']
        and verify(producer['checkedApi'])['sha256'] == attempt['checkedApi']['sha256']
        and verify(producer['bootstrap'])['sha256'] == attempt['bootstrapReport']['sha256']
        and verify(producer['derivation'])['sha256'] == attempt['derivationReport']['sha256'], 'Producer lineage differs')
source, c, binary = verify(emission['subject']), verify(emission['output']), pin(args.binary)
guard_pin = pin(args.guard/'process.json')
guard = json.loads(Path(guard_pin['file']).read_text())
inputs_pin = pin(args.guard/'inputs.json')
inputs = json.loads(Path(inputs_pin['file']).read_text())
require(guard['complete'] and guard['returncode'] == 0 and not guard.get('stoppedFor'), 'Incomplete Clang build')
require(c['file'] in guard['command'] and binary['file'] in guard['command'], 'Build command/source mismatch')
verified_inputs = [verify(p) for p in inputs]
require(c in verified_inputs, 'Emitted C absent from build inputs')
result = dict(kind='phase90-bend-produced-native-build', complete=True, method=pin(__file__),
    producer=emission['producer'], source=source, c=c, binary=binary, emission=emission_pin,
    buildGuard=guard_pin, buildInputs=inputs_pin, inputs=verified_inputs, command=guard['command'],
    nativeSelfEmission=False, nativeB2Qualified=False, cacheAdmitted=False,
    argvConvention='retained runtime omits argv0: entry needs explicit program sentinel after --',
    scope='Compiler C emitted by recorded checked equality-derived JS-hosted Bend B1, then compiled by recorded Clang. No upstream acquisition, native-B1 self-emission, execution qualification or public admission.')
with args.receipt.open('x') as stream:
    json.dump(result, stream, indent=2); stream.write('\n')
print(json.dumps(dict(receipt=pin(args.receipt), admitted=False, targetJobsRun=0)))

#!/usr/bin/env python3
"""Tiny synthetic receipt tests; never execute a compiler or native image."""
import argparse
import copy
import importlib.util
import json
from pathlib import Path
import tempfile

HERE = Path(__file__).resolve().parent
spec = importlib.util.spec_from_file_location('comparison', HERE/'compare-native-v02.py')
C = importlib.util.module_from_spec(spec)
spec.loader.exec_module(C)


def main():
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument('--out', type=Path, required=True)
    args = ap.parse_args()
    C.require(not args.out.exists(), 'Fresh test receipt required')
    results = []
    with tempfile.TemporaryDirectory(prefix='p142-comparator-metadata-') as temporary:
        root = Path(temporary)

        def artifact(name, data):
            path = root/name
            path.write_bytes(data)
            return C.pin(path)

        def receipt(name, data):
            return artifact(name, (json.dumps(data, indent=2)+'\n').encode())

        producer = artifact('image', b'not executed: producer')
        other = artifact('other-image', b'not executed: different producer')
        runtime = artifact('runtime.o', b'not executed: runtime')
        base = artifact('base.bend', b'base')
        carrier = artifact('base.carrier', b'carrier')
        source = artifact('source.bend', b'source')
        expected = artifact('expected.ssa', b'exact output\n')
        payload = artifact('payload.bin', b'exact output\n')
        wrong_payload = artifact('wrong-payload.bin', b'different output\n')
        wire = artifact('000.frames', b'wire frame placeholder')
        jobs = artifact('jobs.txt', b'jobs placeholder')
        stdout = artifact('stdout.log', b'')
        stderr = artifact('stderr.log', b'')
        method = C.pin(HERE.parent/'phase140/session/run-batch-v02.py')
        inputs = [method, producer, other, runtime, base, carrier, source, expected, jobs]
        context = dict(kind='phase140-transport-context', protocol=2, session=str(root),
                       producer=producer, runtime=runtime, source=source,
                       policy=dict(kind='phase140-exact-output-v1', logicalSourcePath=source['file']), inputs=inputs)
        cp = receipt('context.json', context)
        transport = dict(kind='phase140-byte-transport', protocol=2, complete=True,
                         producerSuccessAttested=False, context=context, contextManifest=cp,
                         priorManifest=None, payload=payload,
                         wire={k:wire[k] for k in ('bytes','sha256')})
        tp = receipt('transport.json', transport)
        command = [producer['file'],'--threads','1','--gpu','off','--','phase140-batch',
                   source['file'],base['file'],carrier['file'],'stamp',jobs['file'],'v1']
        job = dict(name='edit',source=source['file'],hint=0,owner='main',mode='warm',
                   expected=expected['file'],frames=wire,transport=tp,product=payload,
                   exactOracle=True,stages={**{key:1 for key in C.STAGES},'totalMs':5},
                   ioMs=1,transportSeconds=.002,stats=[])
        valid = dict(kind='phase140-native-batch',complete=True,independentProductsExact=True,
                     exitCode=0,changedInputs=[],inputs=inputs,command=command,
                     logicalSourcePath=source['file'],jobs=[job],stdout=stdout,stderr=stderr,
                     nativeSeconds=.010,totalSeconds=.013,prepareMs=1)

        def run(name, data, expected_error=None):
            report = receipt('report.json', data)
            try:
                C.batch(report['file'])
            except ValueError as error:
                C.require(expected_error and str(error) == expected_error, 'Unexpected rejection: '+str(error))
                results.append(dict(name=name, passed=True, refused=True, error=str(error)))
            else:
                C.require(expected_error is None, 'Expected refusal: '+name)
                results.append(dict(name=name, passed=True, refused=False))

        run('valid actual-schema wire lacks file member',valid)
        changed = copy.deepcopy(valid)
        changed['command'][0] = other['file']
        run('different native image despite valid pinned artifact',changed,'Wrong native producer')
        changed = copy.deepcopy(valid)
        changed['jobs'][0]['product'] = wrong_payload
        run('different pinned product despite complete flags',changed,'Output/transport product mismatch')
        changed_transport = copy.deepcopy(transport)
        changed_transport['wire']['sha256'] = '0'*64
        changed = copy.deepcopy(valid)
        changed['jobs'][0]['transport'] = receipt('wrong-wire-transport.json',changed_transport)
        run('wire/frame digest mismatch despite complete flags',changed,'Frame/wire identity mismatch')
    output = dict(kind='phase142-comparator-metadata-controls',complete=True,synthetic=True,
                  compilerExecutions=0,inputs=[C.pin(__file__),C.pin(HERE/'compare-native-v02.py')],rows=results)
    args.out.parent.mkdir(parents=True,exist_ok=True)
    with args.out.open('x') as handle:
        json.dump(output,handle,indent=2);handle.write('\n')
    print(json.dumps(dict(complete=True,controls=len(results),output=str(args.out))))


if __name__ == '__main__':
    main()

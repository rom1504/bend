#!/usr/bin/env python3
"""Data-only comparison of two exact-oracle run-batch-v02 native receipts."""
import argparse
import hashlib
import json
import math
from pathlib import Path

STAGES = ('frontendMs', 'rawMs', 'backendMs', 'registryMs', 'renderCloseMs')
_verified = {}


def require(condition, message):
    if not condition:
        raise ValueError(message)


def pin(path):
    path = Path(path).resolve()
    stat = path.stat()
    key = (str(path), stat.st_size, stat.st_mtime_ns)
    if key not in _verified:
        digest = hashlib.sha256()
        with path.open('rb') as handle:
            for block in iter(lambda: handle.read(1 << 20), b''):
                digest.update(block)
        _verified[key] = dict(file=str(path), bytes=stat.st_size, sha256=digest.hexdigest())
    return _verified[key]


def verify(item):
    require(isinstance(item, dict) and set(item) == {'file', 'bytes', 'sha256'}, 'Malformed artifact pin')
    require(pin(item['file']) == item, 'Artifact changed: ' + item['file'])
    return item


def identity(item):
    return item['bytes'], item['sha256']


def read(path):
    path = Path(path)
    if path.is_dir():
        path = path / 'report.json'
    before = pin(path)
    data = json.loads(path.read_text())
    require(pin(path) == before, 'Receipt changed while reading')
    return data, before


def number(value, label):
    require(isinstance(value, (int, float)) and not isinstance(value, bool)
            and math.isfinite(value) and value >= 0, 'Invalid timing: ' + label)
    return value


def batch(path):
    report, receipt = read(path)
    require(report.get('kind') == 'phase140-native-batch' and report.get('complete') is True,
            'Complete native batch receipt required')
    require(report.get('independentProductsExact') is True and report.get('exitCode') == 0
            and report.get('changedInputs') == [], 'Successful exact-oracle batch required')
    require(not report.get('diagnostic') and not report.get('sampler') and not report.get('samples'),
            'Diagnostic sampling cannot supply clean speed ratios')
    for item in report['inputs']:
        verify(item)
    inputs = {item['file']: item for item in report['inputs']}
    for field in ('stdout', 'stderr'):
        verify(report[field])
    require(report['stderr']['bytes'] == 0, 'Native diagnostics present')
    command = report['command']
    require(len(command) == 13 and command[1:7] == ['--threads', '1', '--gpu', 'off', '--', 'phase140-batch']
            and command[-1] == 'v1', 'Unknown native invocation or resource policy')
    require(command[7] == report['logicalSourcePath'], 'Logical path mismatch')
    method = [item for item in report['inputs'] if Path(item['file']).name == 'run-batch-v02.py']
    require(len(method) == 1, 'Exact run-batch-v02 method required')
    producer = verify(inputs[str(Path(command[0]).resolve())])
    require(report['jobs'] and len(report['jobs']) <= 64, 'Bounded nonempty batch required')
    require(len({j['name'] for j in report['jobs']}) == len(report['jobs']), 'Duplicate job names')
    contexts = []
    previous = None
    for job in report['jobs']:
        require(job.get('exactOracle') is True and job.get('expected'), 'Missing independent output oracle')
        require(job['mode'] in ('cold', 'warm') and isinstance(job['hint'], int) and job['owner'], 'Bad edit identity')
        for field in ('frames', 'transport', 'product'):
            verify(job[field])
        transport, transport_pin = read(job['transport']['file'])
        require(transport_pin == job['transport'] and transport.get('complete') is True
                and transport.get('kind') == 'phase140-byte-transport'
                and transport.get('producerSuccessAttested') is False, 'Unknown or incomplete transport')
        require(transport['payload'] == job['product'], 'Output/transport product mismatch')
        require(set(transport['wire']) == {'bytes', 'sha256'}
                and identity(transport['wire']) == identity(job['frames']), 'Frame/wire identity mismatch')
        require(transport['priorManifest'] == previous, 'Transport chain changed')
        previous = job['transport']
        context, cp = read(verify(transport['contextManifest'])['file'])
        require(cp == transport['contextManifest'] and context == transport['context'], 'Context mismatch')
        require(context.get('kind') == 'phase140-transport-context' and context.get('protocol') == 2,
                'Unknown transport context schema')
        require(context['producer'] == producer, 'Wrong native producer')
        require(context['session'] == str(Path(receipt['file']).parent), 'Wrong native session')
        require(context['policy'] == dict(kind='phase140-exact-output-v1', logicalSourcePath=command[7]),
                'Output policy changed')
        require(context['source'] == inputs[str(Path(job['source']).resolve())], 'Source identity mismatch')
        verify(context['runtime'])
        expected = inputs[str(Path(job['expected']).resolve())]
        require(identity(job['product']) == identity(expected), 'Product is not byte-identical to independent oracle')
        for field in STAGES + ('totalMs',):
            number(job['stages'][field], field)
        require(sum(job['stages'][field] for field in STAGES) == job['stages']['totalMs'], 'Stage boundaries do not partition total')
        for field in ('ioMs', 'transportSeconds'):
            number(job[field], field)
        contexts.append(context)
    require(all(c['runtime'] == contexts[0]['runtime'] for c in contexts), 'Runtime changed inside session')
    for field in ('nativeSeconds', 'totalSeconds', 'prepareMs'):
        number(report[field], field)
    job_native = sum((j['stages']['totalMs'] + j['ioMs']) / 1000 for j in report['jobs'])
    transport = sum(j['transportSeconds'] for j in report['jobs'])
    shared = report['nativeSeconds'] - job_native
    residual = report['totalSeconds'] - report['nativeSeconds'] - transport
    require(shared >= -0.02 and residual >= -0.02, 'Inconsistent native/host timing scope')
    meta = dict(receipt=receipt, producer=producer, runtime=contexts[0]['runtime'], method=method[0],
                base=inputs[str(Path(command[8]).resolve())], carrier=inputs[str(Path(command[9]).resolve())],
                stamp=command[10], logicalSourcePath=command[7], contexts=contexts,
                nativeProcessSeconds=report['nativeSeconds'], hostMaterializationSeconds=transport,
                sharedNativeSeconds=shared, sharedPreparationSeconds=report['prepareMs']/1000,
                sharedNativeExcludingPreparationSeconds=shared-report['prepareMs']/1000,
                hostOrchestrationResidualSeconds=residual, reportedBatchSeconds=report['totalSeconds'])
    return report, meta


def comparison(old, new):
    return dict(baseline=old, candidate=new, candidateMinusBaseline=new-old,
                candidateOverBaseline=new/old if old else None)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    for name in ('baseline', 'candidate', 'out'):
        parser.add_argument('--'+name, type=Path, required=True)
    parser.add_argument('--machine-report', type=Path)
    parser.add_argument('--machine-job', help='Exact job name built once from the shared byte-identical product')
    args = parser.parse_args()
    require(not args.out.exists(), 'Fresh JSON output required')
    require(bool(args.machine_report) == bool(args.machine_job), 'Machine report and job must be supplied together')
    baseline, bm = batch(args.baseline)
    candidate, cm = batch(args.candidate)
    for field in ('runtime', 'method', 'base', 'carrier', 'stamp', 'logicalSourcePath'):
        require(bm[field] == cm[field], 'Comparison context differs: ' + field)
    require(len(baseline['jobs']) == len(candidate['jobs']), 'Different batch lengths')
    rows = []
    for i, (old, new) in enumerate(zip(baseline['jobs'], candidate['jobs'])):
        for field in ('name', 'source', 'hint', 'owner', 'mode', 'expected'):
            require(old[field] == new[field], 'Different ordered source/edit/oracle: ' + field)
        require(bm['contexts'][i]['source'] == cm['contexts'][i]['source'], 'Different source bytes')
        require(identity(old['product']) == identity(new['product']), 'Output changed between compilers')
        timings = {field.removesuffix('Ms')+'Seconds': comparison(old['stages'][field]/1000, new['stages'][field]/1000)
                   for field in STAGES + ('totalMs',)}
        timings['sourceIOSeconds'] = comparison(old['ioMs']/1000, new['ioMs']/1000)
        timings['hostMaterializationSeconds'] = comparison(old['transportSeconds'], new['transportSeconds'])
        subtotals = [(j['stages']['totalMs']+j['ioMs'])/1000+j['transportSeconds'] for j in (old,new)]
        timings['requestPlusMaterializationSeconds'] = comparison(*subtotals)
        rows.append(dict(name=old['name'], mode=old['mode'], source=bm['contexts'][i]['source'],
                         hint=old['hint'], owner=old['owner'], productIdentity=dict(bytes=old['product']['bytes'],sha256=old['product']['sha256']),
                         timings=timings, baselineStats=old['stats'], candidateStats=new['stats']))
    machine = None
    if args.machine_report:
        build, receipt = read(args.machine_report)
        require(build.get('kind') == 'phase123-branch-aligned-qbe-build' and build.get('complete') is True,
                'Complete aligned machine build required')
        for item in build['inputs']:
            verify(item)
        verify(build['binary'])
        matches = [r for r in rows if r['name'] == args.machine_job]
        require(len(matches) == 1, 'Machine job not found')
        row = matches[0]
        qbe = [j for j in build['jobs'] if j['label'] == 'qbe']
        require(len(qbe) == 1 and all(j['exitCode'] == 0 for j in build['jobs']), 'Machine tools failed')
        qbe_pin = pin(qbe[0]['command'][-1])
        require(identity(qbe_pin) == identity(row['productIdentity']) and qbe_pin in build['inputs'], 'Machine build used a different QBE product')
        require(bm['runtime'] in build['inputs'], 'Machine runtime differs')
        seconds = number(build['buildSeconds'], 'buildSeconds')
        subtotal = row['timings']['requestPlusMaterializationSeconds']
        row['timings']['requestMaterializationAndSharedMachineBuildSeconds'] = comparison(subtotal['baseline']+seconds,subtotal['candidate']+seconds)
        machine = dict(receipt=receipt, product=qbe_pin, binary=build['binary'], seconds=seconds,
                       job=args.machine_job, scope='One explicitly supplied measured machine build of the identical product, added equally to both request subtotals; not two new builds and not a measurement of compiler acquisition.')
    summary = dict(kind='phase142-native-batch-comparison', complete=True, inputs=[pin(__file__),bm['receipt'],cm['receipt']],
                   baseline=bm,candidate=cm,jobs=rows,machine=machine,
                   batchTimings={field:comparison(bm[field],cm[field]) for field in ('nativeProcessSeconds','hostMaterializationSeconds','sharedNativeSeconds','sharedPreparationSeconds','sharedNativeExcludingPreparationSeconds','hostOrchestrationResidualSeconds','reportedBatchSeconds')},
                   limits=['Single ordered native sessions, descriptive ratios; no confidence interval or native qualification claim.',
                           'Request subtotal includes native stages, source IO and host materialization. Shared process preparation/teardown and host receipt/hash overhead are reported separately, not silently charged to one warm request.',
                           'Cold acquisition and warm requests remain distinct; do not interpret a warm/cold ratio as speedup of a standalone cold compilation.',
                           'Compiler build provenance, guard affinity and concurrent load must be joined from acquisition/build and outer-guard receipts; this adapter authenticates actual image/runtime/source/output and existing timings only.'])
    if machine:
        summary['inputs'].append(machine['receipt'])
    args.out.parent.mkdir(parents=True,exist_ok=True)
    with args.out.open('x') as handle:
        json.dump(summary,handle,indent=2);handle.write('\n')
    print(json.dumps(dict(complete=True,output=str(args.out.resolve()),jobs=len(rows))))


if __name__ == '__main__':
    main()

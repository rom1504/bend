#!/usr/bin/env python3
"""Frozen full-output controls for a generated-C intervention, never Bend emission."""
import argparse
import hashlib
import importlib.util
from pathlib import Path
import sys
import time

sys.dont_write_bytecode = True
HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[3]
spec = importlib.util.spec_from_file_location('p102_transformed_evidence', HERE/'native-inherit-v2.py')
H = importlib.util.module_from_spec(spec); spec.loader.exec_module(H)
S, R, G = H.S, H.R, H.G


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--controls', type=Path, required=True)
    parser.add_argument('--transform', type=Path, required=True)
    parser.add_argument('--transform-input', type=Path, nargs='*', default=[])
    parser.add_argument('--prepare-only', action='store_true')
    parser.add_argument('--out', type=Path, required=True)
    args = parser.parse_args()
    out = args.out.resolve(); assert out.is_relative_to(ROOT/'selfhost/build/phase102')
    out.mkdir(parents=True, exist_ok=False)
    bindings = S.Bindings()
    report = dict(kind='phase102-generated-C-intervention-controls', complete=False, passed=False,
        prepared=False, executionPerformed=False, imageQualified=False, bendEmission=False,
        started=time.time(), method=bindings.bind(__file__), inputs=[], products=[], observations=[],
        scope='Original Bend producer C plus separately pinned C transform. '
              'Only changed C is built/executed; unchanged C inherits authenticated exact prior full outputs. '
              'No new Bend emission, compiler source, native-chain or speed claim.')

    def save():
        report['inputs'] = list(bindings.rows.values()); R.save(out/'report.json', report)

    def load(pin):
        item = bindings.bind(pin); value = S.read(item['file'])
        assert value['complete'] and not value.get('error')
        bindings.tree(value)
        return item, value

    def oracle(data):
        path = out/'oracles'/hashlib.sha256(data).hexdigest()
        path.parent.mkdir(exist_ok=True)
        if not path.exists(): path.write_bytes(data)
        assert path.read_bytes() == data
        return bindings.bind(path)

    save()
    try:
        report['controls'], controls = load(args.controls)
        report['manifest'], manifest = load(controls['manifest'])
        report['producerEmission'], emission = load(controls['emission'])
        clang = bindings.bind(controls['context']['clang'])
        report['clang'] = clang
        transform_path = args.transform.resolve()
        report['transform'] = bindings.bind(transform_path)
        transform = S.module('p102_saved_C_transform', transform_path)
        # Small method siblings include structural patterns and their provenance.
        method_files = {Path(__file__).resolve(), transform_path, HERE/'native-inherit-v2.py',
            HERE/'check-emitted-v2.py', HERE/'guarded.py', HERE/'guard-long-args.py',
            HERE.parent/'phase100/run.py', HERE.parent/'phase46/execute.py',
            HERE.parent/'programs/support.py', Path(S.__file__).resolve()}
        method_files.update(p.resolve() for p in args.transform_input)
        method_files.update(p.resolve() for p in transform_path.parent.iterdir()
                            if p.is_file() and p.suffix in ('.py', '.json', '.md'))
        report['methodInputs'] = []
        for index, path in enumerate(sorted(method_files)):
            item = bindings.bind(path)
            dest = out/'methods'/f'{index:02d}-{path.name}'; dest.parent.mkdir(exist_ok=True)
            dest.write_bytes(path.read_bytes())
            report['methodInputs'].append(dict(original=item, snapshot=bindings.bind(dest)))
        cases_by_source = {}
        for case in manifest['records']:
            cases_by_source.setdefault(case['source'], []).append(case)
        assert set(cases_by_source) == set(controls['products'])
        manifest_files = {str(Path(p.get('file', p.get('path'))).resolve()):p for p in manifest.get('pins', [])}
        for index, (source, cases) in enumerate(cases_by_source.items()):
            old = controls['products'][source]
            source_pin = bindings.bind(old['source'])
            assert source_pin['file'] == str(Path(source).resolve())
            producer = old['variants']['candidate']
            producer_c = bindings.bind(producer['c'])
            receipt_pin, receipt = load(old['emissionReceipt'])
            assert receipt['source'] == source_pin and receipt['output'] == producer_c
            emitted = [p for p in emission['programs'] if p['source']['file'] == source_pin['file']]
            assert len(emitted) == 1 and emitted[0]['c'] == producer_c and emitted[0]['receipt'] == receipt_pin
            row = dict(id=f'source-{index:02d}', source=source_pin, producerC=producer_c,
                producerReceipt=receipt_pin, producerBuild=H.build_evidence(bindings, producer, clang),
                producerBinary=bindings.bind(producer['binary']), obligations=[])
            report['products'].append(row)
            original = Path(producer_c['file']).read_text()
            candidate, detail = transform.transform(original)
            assert isinstance(candidate, str) and isinstance(detail, dict)
            bindings.tree(detail)
            folder = out/row['id']; folder.mkdir()
            target = folder/'intervention.c'; target.write_text(candidate)
            row.update(candidateC=bindings.bind(target), intervention=detail, changed=candidate != original)
            for case in cases:
                if case.get('requireBaselineCIdentity'):
                    baseline = bindings.bind(old['variants']['baseline']['c'])
                    assert H.same(baseline, producer_c) and not row['changed']
                for name in case.get('requireTRMC', []):
                    symbol = 'NF_FID_' + ''.join(str(ord(c))+'_' for c in name) + '_trmc'
                    assert symbol in candidate, ('TRMC must remain active', name)
                for name in case.get('forbidTRMC', []):
                    symbol = 'NF_FID_' + ''.join(str(ord(c))+'_' for c in name) + '_trmc'
                    assert symbol not in candidate, ('TRMC must remain refused', name)
                for argument in case.get('argv', []):
                    try: file_argument = Path(argument).is_file()
                    except OSError as error:
                        if error.errno != 36: raise
                        file_argument = False
                    if file_argument:
                        key = str(Path(argument).resolve())
                        assert key in manifest_files, ('Unpinned file argument', argument)
                        bindings.bind(manifest_files[key])
                expected = Path(bindings.bind(case['expected'])['file']).read_bytes() if 'expected' in case else case.get('stdout','').encode()
                stderr = case.get('stderr','').encode(); status = case.get('returncode',0)
                for workers in case.get('workers', [1]):
                    prior = [r for r in controls['executions'] if r['case']==case['id'] and r['workers']==workers and r['role']=='candidate']
                    assert len(prior)==1 and prior[0]['passed']
                    argv = [producer['binary']['file'], '--threads', str(workers), '--gpu', 'off', '--', *case.get('argv', [])]
                    evidence, _ = H.job_evidence(bindings, prior[0]['job'], argv, status, expected, stderr)
                    obligation = dict(case=case['id'], workers=workers, argv=case.get('argv', []), expectedExit=status,
                        stdout=oracle(expected), stderr=oracle(stderr), priorEvidence=evidence,
                        priorObservation=prior[0], executionKind='pending' if row['changed'] else 'inherited',
                        passed=not row['changed'])
                    row['obligations'].append(obligation)
                    report['observations'].append(obligation)
            save()
        report['prepared'] = True
        report['changedSources'] = sum(p['changed'] for p in report['products'])
        report['inheritedObservations'] = sum(o['executionKind']=='inherited' for o in report['observations'])
        if args.prepare_only:
            bindings.unchanged(); report.update(complete=True, inputsUnchanged=True, prepareOnly=True)
            return
        for row in report['products']:
            if not row['changed']: continue
            folder = out/row['id']; binary = folder/'intervention.program'
            command = [clang['file'], '-isystem', str(Path(clang['file']).parents[1]/'include/clang'),
                       '-std=c11','-O3',row['candidateC']['file'],'-o',str(binary),'-lpthread','-lm']
            report['executionPerformed'] = True; save()
            row['build'], _ = G.guarded(folder/'build', command)
            row['binary'] = bindings.bind(binary)
            row['buildEvidence'] = H.build_evidence(bindings, dict(c=row['candidateC'],binary=row['binary'],build=row['build']), clang)
            save()
            for index, obligation in enumerate(row['obligations']):
                job_folder = folder/f'run-{index:03d}'
                command = [row['binary']['file'],'--threads',str(obligation['workers']),'--gpu','off','--',*obligation['argv']]
                obligation['executionKind'] = 'fresh'; save()
                obligation['job'], child = H.CHECK.execute(job_folder, command,
                    {1:'3',2:'2,3',4:'0,1,2,3'}[obligation['workers']], obligation['expectedExit'])
                obligation['evidence'], _ = H.job_evidence(bindings, obligation['job'], command, obligation['expectedExit'],
                    Path(obligation['stdout']['file']).read_bytes(), Path(obligation['stderr']['file']).read_bytes())
                obligation['passed'] = True; save()
        bindings.unchanged()
        assert all(o['passed'] for o in report['observations'])
        report.update(complete=True, passed=True, inputsUnchanged=True)
    except BaseException as error:
        report['error'] = repr(error); raise
    finally:
        report['finished'] = time.time(); save()
    print(R.json.dumps(dict(complete=report['complete'], passed=report['passed'], changedSources=report['changedSources'],
        observations=len(report['observations']), inherited=report['inheritedObservations'])))


if __name__ == '__main__': main()

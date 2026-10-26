#!/usr/bin/env python3
"""Offline receipt joins and compact publication of the serial full request."""
import argparse
import hashlib
import json
from pathlib import Path
import shutil

ROOT = Path(__file__).resolve().parents[5]


def pin(p):
    b = p.read_bytes()
    return dict(file=str(p), bytes=len(b), sha256=hashlib.sha256(b).hexdigest())


def same(a, b):
    return all(a[k] == b[k] for k in ('bytes', 'sha256')) and Path(a['file']).resolve() == Path(b['file']).resolve()


def main():
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument('--out', type=Path, required=True, help='fresh published evidence directory')
    args = ap.parse_args(); out = args.out.resolve()
    if out.exists(): raise ValueError('fresh output required')
    source_paths = {}
    reports = {}
    guards = {}
    for role in ['parent', 'integrated', 'integrated-serial']:
        p = ROOT / f'selfhost/build/phase130/p144-{role}-fixed-cold01/report.json'
        g = ROOT / f'selfhost/build/phase144/{role}-fixed-cold01-guard/process.json'
        d = json.loads(p.read_text()); guard = json.loads(g.read_text())
        assert d['complete'] and d['byteExact'] and d['exitCode'] == 0 and not d['changedInputs']
        assert guard['complete'] and guard['returncode'] == 0 and d['inheritedAffinity'] == [3]
        assert d['stderr']['bytes'] == 0 and d['product']['bytes'] == 115909112
        source_paths[role+'-request.json'] = p; source_paths[role+'-guard.json'] = g
        reports[role] = d; guards[role] = guard
    reference = reports['parent']
    for d in reports.values():
        for k in ['source', 'base', 'carrier', 'expectedQbe']:
            assert same(reference[k], d[k])
        assert d['stamp'] == reference['stamp']
        assert all(d['product'][k] == reference['expectedQbe'][k] for k in ('bytes', 'sha256'))
        for item in [d['image'], d['source'], d['carrier']]:
            assert same(pin(Path(item['file'])), item)
    relink_path = ROOT / 'selfhost/build/phase144/integrated-serial-n1-01/report.json'
    relink = json.loads(relink_path.read_text())
    assert relink['complete'] and relink['sameCompilerObject'] and not relink['nativeQualified'] and not relink['selected']
    assert same(relink['binary'], reports['integrated-serial']['image'])
    assert same(relink['originalBinary'], reports['integrated']['image'])
    acquisition_path = Path(relink['acquisitionBuild']['file'])
    assert same(pin(acquisition_path), relink['acquisitionBuild'])
    acquisition = json.loads(acquisition_path.read_text())
    assert same(acquisition['object'], relink['object']) and same(acquisition['source'], relink['source'])
    assert same(pin(Path(relink['runtime']['file'])), relink['runtime'])
    source_paths['integrated-relink.json'] = relink_path
    source_paths['integrated-relink-plan.json'] = Path(relink['plan']['file'])
    source_paths['integrated-acquisition.json'] = acquisition_path
    atomic = reports['integrated']['nativeSeconds']; serial = reports['integrated-serial']['nativeSeconds']; parent = reference['nativeSeconds']
    result = dict(kind='phase144-serial-rfc-full-results-v01', complete=True,
        method=pin(Path(__file__).resolve()), fixedSource=reference['source'], expectedQbe=reference['expectedQbe'],
        compilerSource=relink['source'], compilerObject=relink['object'], serialRuntime=relink['runtime'],
        actualRuntimeAuthority='Integrated relink receipt. The native-request runtime field is future-build context only.',
        observations={role: dict(image=d['image'], nativeSeconds=d['nativeSeconds'], cpuSeconds=d['cpuSeconds'],
            childPeakRssKiB=d['peakRssKiB'], guardWallSeconds=guards[role]['wallSeconds'],
            guardPeakTreeRssBytes=guards[role]['peakTreeRssBytes'], exactOutput=True,
            sourceReceipt=pin(source_paths[role+'-request.json'])) for role,d in reports.items()},
        ratios=dict(serialOverSameObjectAtomic=serial/atomic, runtimeReductionFraction=1-serial/atomic,
                    integratedAtomicOverParent=atomic/parent, sourceReductionFraction=1-atomic/parent,
                    combinedOverParent=serial/parent, combinedReductionFraction=1-serial/parent),
        qualification=dict(fullSourceRequestPass=True, n2Reproduction=False, selected=False,
            runtimeProgramRelinks=61, runtimeCliRefusals=3, fixedBatchPrograms=4, fixedBatchPairsPerProgram=6,
            heldOutParallelOrArbitraryForeignAbi=False),
        limitations=['One clean full-source observation per role, no confidence interval or statistically bounded regression claim.',
                     'Fresh processes and fixed CPU3, but OS caches are not flushed.',
                     'Full compiler request exercises current compiler effects including NativeHost.read; not every provider/failure path.',
                     'No N2 qualification, installation or claim of large general generated-program speedup.'])
    out.mkdir(parents=True)
    evidence = []
    for name,p in source_paths.items():
        shutil.copyfile(p, out/name)
        evidence.append(dict(original=pin(p), published=pin(out/name)))
    result['evidence'] = evidence
    (out/'summary.json').write_text(json.dumps(result, indent=2)+'\n')
    print(json.dumps(result['ratios']))


if __name__ == '__main__':
    main()

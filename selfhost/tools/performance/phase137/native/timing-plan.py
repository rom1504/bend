#!/usr/bin/env python3
"""Metadata-only role binding for the frozen three-request native/upstream screen."""
import argparse
import copy
import importlib.util
from pathlib import Path
import re
import sys

sys.dont_write_bytecode = True
HERE = Path(__file__).resolve().parent
spec = importlib.util.spec_from_file_location('p137_qualification', HERE / 'qualify.py')
P = importlib.util.module_from_spec(spec); spec.loader.exec_module(P)
V, Q, ROOT, TOOLS = P.V, P.Q, P.ROOT, P.TOOLS


def main():
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument('--qualification', required=True, type=Path)
    ap.add_argument('--out', required=True, type=Path)
    ap.add_argument('--tag', required=True)
    a = ap.parse_args()
    P.require(re.fullmatch(r'p137-[a-z0-9_-]+', a.tag), 'Fresh p137 timing tag required')
    parent, _, base = P.authorities()
    qualified = P.json_read(a.qualification)
    V.retain([Q.pin(a.qualification), Q.pin(P.__file__)])
    P.require(qualified.get('kind') == 'phase137-native-research-qualification' and
              qualified.get('complete') and qualified.get('nativeQualified') and
              Q.pin(P.__file__) in qualified['inputs'] and qualified['producer'] == parent['n2'] and
              qualified['source']['sha256'] == P.SOURCE_SHA and qualified['runtime'] == parent['runtime'],
              'Completed exact Phase137 qualification required')
    for row in [qualified['source'], qualified['finalImage']]: V.retain(row)
    P.require(qualified['finalImage'] in [gate['image'] for gate in qualified['semanticGates']],
              'Final image lacks semantic gate')
    # Corpus, upstream, toolchain, clocks, limits and rotation remain unchanged.
    manifest = copy.deepcopy(base)
    manifest.update(preparedOnly=True, targetsRun=False, researchOnly=True, nativeQualified=True, unqualified=False)
    manifest['roles']['phase111'] = dict(binary=parent['n2'], source=parent['source'],
        generation='Qualified Phase134 N2; fresh process and compact Base', nativeQualified=True,
        carrierReceipt=parent['preferredCarrierReceipt'])
    manifest['roles']['phase112'] = dict(binary=qualified['finalImage'], source=qualified['source'],
        generation='Qualified Phase137 final native image; fresh process and compact Base', nativeQualified=True,
        carrierReceipt=parent['preferredCarrierReceipt'])
    manifest['inputs'] = [Q.pin(__file__), Q.pin(P.__file__), Q.pin(HERE / 'authority.json'),
        Q.pin(a.qualification), Q.pin(P.SELECTION), Q.pin(ROOT / 'selfhost/build/phase130/n1-n2-timing01.json'),
        Q.pin(TOOLS / 'phase130/timing-run.py'), parent['n2'], parent['source'],
        qualified['finalImage'], qualified['source'], parent['runtime'], parent['preferredCarrierReceipt']]
    manifest['lineage'] = dict(parent='Phase134 N2', candidateQualification=Q.pin(a.qualification),
        sameCompilerSource=False, allObservationsFresh=True, semanticEditCache=False,
        scope='Unchanged27 observations:3 sources ×3 roles ×3 rotating rounds. Request time is primary. Native emits QBE with prepared Base and cached runtime; upstream emits C from source Base and builds full runtime. Ready sums and generated-program execution have different meanings.')
    for row in Q.pins(manifest): Q.verify(row)
    target = ROOT / 'selfhost/build/phase112' / a.tag
    P.require(not target.exists(), 'Fresh timing target required')
    P.save(a.out, manifest)
    command = [sys.executable, '-B', str(TOOLS / 'phase130/timing-run.py'),
               '--manifest', str(a.out.resolve()), '--out', str(target), '--rounds', '3', '--modes', 'cache']
    P.save(a.out.with_name(a.out.stem + '-jobs.json'), dict(complete=True, targetsRun=False,
        inputs=[Q.pin(__file__), Q.pin(a.out)],
        jobs=[dict(name='phase137-final-parent-upstream-three-source', seconds=300, command=command)],
        guardRequirement='Root-owned serial CPU3 guard; no concurrent target work during measurement'))
    print('Timing manifest prepared; no targets run')


if __name__ == '__main__': main()

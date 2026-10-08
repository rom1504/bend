#!/usr/bin/env python3
"""Compact one closed conformance join; no target execution or new qualification."""
import argparse
import hashlib
import json
import os
from pathlib import Path

ROOT = Path(__file__).resolve().parents[5]


def pin(file):
    data = file.read_bytes()
    return dict(file=str(file.relative_to(ROOT)), bytes=len(data),
                sha256=hashlib.sha256(data).hexdigest())


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--input', required=True, type=Path)
    parser.add_argument('--output', required=True, type=Path)
    args = parser.parse_args()
    assert os.sched_getaffinity(0) == {0}
    source, destination = args.input.resolve(), args.output.resolve()
    source.relative_to(ROOT / 'selfhost/build/phase66')
    destination.relative_to(ROOT / 'implementation/phase66/evidence')
    assert not destination.exists()
    source_pin = pin(source)
    joined = json.loads(source.read_text())
    assert joined['kind'] == 'phase66-selected07-conformance-lanes'
    assert joined['complete'] is True and joined['dataOnly'] is True
    assert joined['selectedApi']['sha256'] == 'bb6c6e2ad6f18bf54d2b5c7e4e7a8d0fe3f0f80658a260ad52256fa4351d81a6'
    primary = {}
    for role, value in joined['primaryJavaScript'].items():
        assert value['observations'] == 1170 == sum(value['statuses'].values())
        primary[role] = {key: value[key] for key in
                         ('report', 'observations', 'statuses', 'allFixtureOraclesPass')}
    coverage = joined['mixedRuntimeCoverage']
    for role, ids in coverage['passingIds'].items():
        assert len(ids) == len(set(ids)) == coverage['counts'][role]
    assert coverage['counts']['bend-candidate-new-base-js'] == 1045
    assert coverage['counts']['typescript-new-js'] == 1044
    assert joined['supplementalBun']['summary'] == {'pass': 54, 'deferred-environment': 1, 'fail': 1}
    assert joined['referencePassingCandidateFailures'] == []
    assert joined['noUnexplainedCandidateOnlyGaps'] is True
    assert joined['exactFrontendObservations'] == 3174
    result = dict(kind='phase66-selected07-conformance-summary', complete=True,
                  dataOnly=True, targetExecuted=False, summaryVerified=True,
                  producer=pin(Path(__file__).resolve()), sourceJoin=source_pin,
                  selectedAttempt=joined['selectedAttempt'], selectedApi=joined['selectedApi'],
                  frontend=dict(fixtures=1587, exactObservations=3174, reuse=joined['frontendReuse']),
                  primaryNode=primary, supplementalBun=joined['supplementalBun'],
                  mixedRuntimeCoverage=dict(eligibleFixtures=1170, distinctGoldenPasses=coverage['counts'],
                      remaining=dict(unprintableMainNotApplicable=123,
                                     sharedProcessRunGoldenFailure=1,
                                     graphicsEnvironmentDeferral=1), scope=coverage['scope']),
                  exactPrimaryObservationAgreements=joined['exactObservationAgreements'],
                  referencePassingCandidateFailures=[], noUnexplainedCandidateOnlyGaps=True,
                  candidatePassingReferenceFailures=joined['candidatePassingReferenceFailures'],
                  priorGapsPreserved=joined['priorGapsPreserved'],
                  sourceScope=joined['scope'],
                  summaryScope='Counts and exact join identity only. Full observations and outputs '
                              'remain in the raw join and its pinned reports. No new input-closure '
                              'qualification, target run, native/legacy/GPU result, universal '
                              'conformance or all-fixture-pass claim is made by this summary.')
    assert sum(result['mixedRuntimeCoverage']['remaining'].values()) + 1045 == 1170
    assert pin(source) == source_pin
    destination.parent.mkdir(parents=True, exist_ok=True)
    with destination.open('x') as stream:
        stream.write(json.dumps(result, indent=2) + '\n')
    print(json.dumps(dict(output=pin(destination), source=source_pin, counts=coverage['counts'])))


if __name__ == '__main__':
    main()

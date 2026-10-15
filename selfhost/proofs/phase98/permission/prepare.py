#!/usr/bin/env python3
"""Bind frozen foreign-admission laws to the actual successor source; no targets."""
import argparse
import hashlib
import importlib.util
import json
from pathlib import Path
import subprocess
import sys

HERE=Path(__file__).resolve().parent
ROOT=HERE.parents[3]
EXTRACTOR=HERE.parent/'prepare-current.py'


def pin(path):
    path=Path(path).resolve();data=path.read_bytes()
    return dict(file=str(path),bytes=len(data),sha256=hashlib.sha256(data).hexdigest())


def main():
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument('--receipt',type=Path,required=True)
    p.add_argument('--out',type=Path,required=True)
    a=p.parse_args();out=a.out.resolve()
    assert out.is_relative_to(ROOT)and not out.exists()
    receipt=json.loads(a.receipt.read_text());assert receipt['complete']
    for key in ['source','candidate']:assert pin(receipt[key]['file'])==receipt[key]
    source=Path(receipt['source']['file']).read_text();candidate=Path(receipt['candidate']['file']).read_text();replay=source
    for change in receipt['changes']:
        start=change['offset'];end=start+len(change['old'])
        assert replay[start:end]==change['old']
        replay=replay[:start]+change['new']+replay[end:]
    assert replay==candidate
    helper=(HERE/'helper.d04.bend').read_text();assert candidate.count(helper)==1
    assert candidate.count('no_effect_foreign_allowed(')==2,'Definition and actual classifier call required'
    subprocess.run([sys.executable,'-B',str(EXTRACTOR),'--candidate',receipt['candidate']['file'],
                    '--kind','permission','--out',str(out)],check=True,cwd=ROOT)
    prepared=json.loads((out/'manifest.json').read_text())
    manifest=dict(kind='phase98-actual-foreign-admission-proof-bridge',targetsRun=False,
                  method=pin(__file__),extractor=pin(EXTRACTOR),recipe=pin(a.receipt),
                  source=receipt['source'],candidate=receipt['candidate'],helper=pin(HERE/'helper.d04.bend'),
                  canonicalHelper=pin(HERE/'helper.canonical.bend'),prepared=pin(out/'manifest.json'),
                  forwardReplayExact=True,helperBytesExact=True,actualClassifierUsesHelper=True,
                  entry=prepared['entry'],publicLaws=['foreign_permission_exact','foreign_permission_requires_trust',
                  'foreign_permission_requires_body','foreign_permission_rejects_unlisted'],
                  supportLemmas=['provider_membership_exact'],
                  inheritedLaws=['consuming_equal_specification','consuming_equal_invariant'],
                  boundary='Universal safe Bool contract over the actual predicate and exact closed provider list. The trusted/filled flags are inputs; host authentication, unsafe classifier traversal, checked-program closure, native ownership and scoped backend routing are not proved.')
    (out/'permission-bridge.json').write_text(json.dumps(manifest,indent=2)+'\n')
    (out/'permission-prepare.py').write_bytes(Path(__file__).read_bytes())
    print(json.dumps(dict(entry=prepared['entry'],targetsRun=False,newPublicLaws=4,newSupportLemmas=1)))


if __name__=='__main__':main()

#!/usr/bin/env python3
"""Add exact current nb_contains to the real safe-permission proof closure."""
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
    p.add_argument('--candidate',type=Path,required=True)
    p.add_argument('--out',type=Path,required=True)
    a=p.parse_args();out=a.out.resolve();candidate=a.candidate.resolve()
    assert out.is_relative_to(ROOT)and not out.exists()and candidate.is_relative_to(ROOT)
    spec=importlib.util.spec_from_file_location('phase98_current_extractor',EXTRACTOR)
    extractor=importlib.util.module_from_spec(spec);spec.loader.exec_module(extractor)
    declarations=extractor.declarations(candidate.read_text())
    original=extractor.unique(declarations,'nb_contains');safe=original.removeprefix('@unsafe\n')
    assert '@unsafe'not in safe and 'def nb_contains('in safe
    subprocess.run([sys.executable,'-B',str(EXTRACTOR),'--candidate',str(candidate),
                    '--kind','permission','--out',str(out)],check=True,cwd=ROOT)
    (out/'membership-source-manifest.json').write_bytes((out/'manifest.json').read_bytes())
    proof_candidate=out/'candidate.bend'
    proof_candidate.write_text(proof_candidate.read_text()+safe)
    (out/'bridge.bend').write_bytes((HERE/'bridge.bend').read_bytes())
    (out/'prepare-bridge.py').write_bytes(Path(__file__).read_bytes())
    manifest=dict(kind='phase98-actual-existing-membership-bridge',targetsRun=False,
                  method=pin(__file__),extractor=pin(EXTRACTOR),candidate=pin(candidate),
                  originalExtraction=pin(out/'membership-source-manifest.json'),
                  definition=dict(name='nb_contains',original=original,extracted=safe,removedUnsafe=original!=safe),
                  outputs=[pin(path)for path in sorted(out.iterdir())if path.name!='manifest.json'],
                  entry=str(out/'bridge.bend'),publicLaws=['foreign_permission_preserves_existing_membership'],
                  supportLemmas=['provider_membership_existing'],
                  transformation='Exact current compiler nb_contains declaration, same name and recursive calls; only leading unsafe annotation removed. Existing permission law/reference files unchanged.',
                  boundary='Actual old membership expression and actual new safe helper for every list/key and guard combination. Does not establish correctness of unsafe callers, provider authentication or native ownership.')
    (out/'manifest.json').write_text(json.dumps(manifest,indent=2)+'\n')
    print(json.dumps(dict(entry=manifest['entry'],targetsRun=False,newPublicLaws=1,newSupportLemmas=1)))


if __name__=='__main__':main()

#!/usr/bin/env python3
"""Authenticate the bridge from an accepted tag proof to a full compiler source."""
import argparse
import hashlib
import json
from pathlib import Path


def pin(path):
    path=Path(path).resolve(); data=path.read_bytes()
    return dict(file=str(path),bytes=len(data),sha256=hashlib.sha256(data).hexdigest())


def main():
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument('--proof-report',required=True,type=Path)
    p.add_argument('--proof-manifest',required=True,type=Path)
    p.add_argument('--recipe',required=True,type=Path)
    p.add_argument('--out',required=True,type=Path)
    a=p.parse_args(); assert not a.out.exists()
    proof=json.loads(a.proof_report.read_text()); manifest=json.loads(a.proof_manifest.read_text())
    recipe=json.loads(a.recipe.read_text())
    assert proof['complete'] and proof['independentlyChecked'] and not proof['opaqueDefinitions']
    assert 'tag_comparison_preserves' in proof['lawNames']
    closure={Path(row['origin']['file']).name:row for row in proof['sourceClosure']}
    for row in closure.values(): assert pin(row['snapshot']['file'])==row['snapshot']
    for item in manifest['outputs']: assert pin(item['file'])==item
    assert pin(recipe['candidate']['file'])==recipe['candidate']
    assert pin(recipe['source']['file'])==recipe['source']
    assert pin(recipe['helper']['file'])==recipe['helper']==manifest['helpers']
    assert pin(recipe['parentSource']['file'])==recipe['parentSource']==manifest['heldSource']
    candidate=Path(recipe['candidate']['file']).read_text()
    replay=Path(recipe['source']['file']).read_text()
    for change in recipe['changes']:
        start=change['offset']; stop=start+len(change['old'])
        assert replay[start:stop]==change['old']
        replay=replay[:start]+change['new']+replay[stop:]
    assert replay==candidate
    proof_candidate=Path(closure['candidate.bend']['snapshot']['file']).read_text()
    declared_candidate=next(row for row in manifest['outputs'] if Path(row['file']).name=='candidate.bend')
    assert closure['candidate.bend']['origin']==declared_candidate
    helpers=Path(recipe['helper']['file']).read_text()
    assert proof_candidate.count(helpers)==candidate.count(helpers)==1
    for row in manifest['definitions']:
        assert proof_candidate.count(row['extracted'])==1
        assert candidate.count(row['original'])==1
    old_cmp=next(row for row in manifest['comparisonSourceClosure'] if Path(row['origin']['file']).name=='candidate.bend')
    assert pin(old_cmp['snapshot']['file'])==old_cmp['snapshot']
    comparison=Path(old_cmp['snapshot']['file']).read_text().removeprefix('import Base\n\n')
    assert candidate.count(comparison)==proof_candidate.count(comparison)==1
    report=dict(kind='phase98-full-compiler-tag-proof-identity-bridge',complete=True,targetsRun=False,
                method=pin(__file__),proofReport=pin(a.proof_report),proofManifest=pin(a.proof_manifest),recipe=pin(a.recipe),
                compiler=recipe['candidate'],helper=recipe['helper'],proofCandidate=closure['candidate.bend']['snapshot'],
                exactTagHelpers=True,exactInheritedComparison=True,exactTermAndObserverBodies=True,
                sourceReplayExact=True,selectedCallSites=recipe['selectedSites'],
                scope='The accepted safe helper law applies to these exact full-compiler helper bodies. Source replay authenticates call substitutions; unsafe callers and native C ownership are not proved by this audit.')
    a.out.parent.mkdir(parents=True,exist_ok=True)
    a.out.write_text(json.dumps(report,indent=2)+'\n')
    print(json.dumps(dict(complete=True,targetsRun=False,selectedCallSites=recipe['selectedSites'])))


if __name__=='__main__': main()

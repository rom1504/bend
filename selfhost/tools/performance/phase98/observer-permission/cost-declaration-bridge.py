#!/usr/bin/env python3
"""Offline source02 -> 59b36 -> a025 bridge; no whole-image proof transfer."""
import argparse
import hashlib
import importlib.util
from pathlib import Path

HERE=Path(__file__).resolve().parent
spec=importlib.util.spec_from_file_location('permission_bridge',HERE/'declaration-bridge-v2.py')
B=importlib.util.module_from_spec(spec);spec.loader.exec_module(B)
ROOT=B.ROOT;BUILD=ROOT/'selfhost/build/phase98'


def main():
    p=argparse.ArgumentParser(description=__doc__);p.add_argument('--out',type=Path,required=True)
    args=p.parse_args();out=args.out.resolve();assert out.is_relative_to(BUILD) and not out.exists();out.mkdir(parents=True)
    inputs={};report=dict(kind='phase98-observer-cost-declaration-bridge',complete=False,targetsRun=False,
                         imageQualified=False,wholeCompilerProved=False)
    def bind(path):
        row=B.pin(path);assert inputs.setdefault(row['file'],row)==row;return row
    def verify(v):
        if isinstance(v,dict):
            if {'file','bytes','sha256'}<=v.keys():assert bind(v['file'])==v
            else:
                for child in v.values():verify(child)
        elif isinstance(v,list):
            for child in v:verify(child)
    def read(path):
        bind(path);value=B.read(path);verify(value);return value
    try:
        bind(__file__);bind(HERE/'declaration-bridge-v2.py')
        prior_path=BUILD/'permission-declaration-bridge02/report.json';prior=read(prior_path)
        assert prior['complete'] and not prior['imageQualified']
        recipe_path=BUILD/'observer-cost-sources01/both/changes.json';recipe=read(recipe_path)
        assert recipe['parentSource']==prior['source']
        assert recipe['candidate']['sha256']=='a0254c279cab150aeb5c5e9084e1520ae2c1f8ec4ef9bdd96189eb3364e7d5a5'
        old=Path(recipe['parentSource']['file']).read_text();new=Path(recipe['candidate']['file']).read_text()
        replay=Path(recipe['source']['file']).read_text()
        for edit in recipe['changes']:
            at=edit['offset'];assert replay[at:at+len(edit['old'])]==edit['old']
            replay=replay[:at]+edit['new']+replay[at+len(edit['old']):]
        assert replay==new
        before,after=B.declarations(old),B.declarations(new)
        changed=sorted(k for k in before if before[k]!=after.get(k))
        added=sorted(set(after)-set(before))
        assert changed==['no_route','no_scalar_redirect']
        assert added==sorted(n+'_cached' for n in ['no_schema','nol_params','nol_param_head','nol_param_type','nol_result','nol_finish','no_route_schema','no_route_one','no_route_names'])
        exact=[]
        for record in prior['exactPermissionDeclarations']:
            name=record['name'];assert before[name]==after[name]
            assert hashlib.sha256(after[name].encode()).hexdigest()==record['sha256'];exact.append(record)
        for path in [prior['finalPermissionProofManifest']['file'],prior['finalTagProofManifest']['file']]:
            manifest=read(path)
            for row in manifest['candidateDefinitions']:assert new.count(row['original'])==1
        controls_path=BUILD/'observer-cost-controls02/report.json';controls=read(controls_path)
        values=read(controls['controls']['file']);plan=read(controls['plan']['file'])
        assert controls['complete'] and values['complete']
        assert plan['sources']=={'baseline':recipe['parentSource'],'candidate':recipe['candidate']}
        assert values['workerCases']==105 and values['schemaCases']==60
        c_rows=[r for r in values['rows'] if r['kind']=='complete-C-and-diagnostic']
        assert len(c_rows)==3 and all(r['passed'] and r['diagnostic']=='' for r in c_rows)
        audit_path=ROOT/'selfhost/proofs/phase98/final-cost-data01/source-audit.json';audit=read(audit_path)
        assert audit['source']==recipe['candidate'] and audit['redirectClosureByteIdentical']
        assert len(audit['scalarCloneNormalizations'])==9 and all(r['codeEqual'] for r in audit['scalarCloneNormalizations'])
        proof=read(audit['acceptedRedirectProof']['file'])
        assert proof['complete'] and proof['independentlyChecked'] and proof['opaqueDefinitions']==[]
        prepared=[]
        for directory in ['cost-tag-proof-source01','cost-membership-proof-source01','cost-redirect-proof-source01']:
            manifest_path=BUILD/directory/'manifest.json';manifest=read(manifest_path)
            assert manifest['candidate']==recipe['candidate'];prepared.append(bind(manifest_path))
        report.update(complete=True,source=recipe['candidate'],parentSource=recipe['parentSource'],
            qualifiedSource=prior['qualifiedSource'],candidateRecipe=bind(recipe_path),priorDeclarationBridge=bind(prior_path),
            backendQualification=prior['backendQualification'],corpusQualification=prior['corpusQualification'],
            exactPermissionDeclarations=exact,unchangedParentDeclarations=len(before)-len(changed),
            changedDeclarations=[dict(name=n,beforeSha256=hashlib.sha256(before[n].encode()).hexdigest(),afterSha256=hashlib.sha256(after[n].encode()).hexdigest()) for n in changed],
            addedCacheDeclarations=added,cacheCloneSourceAudit=bind(audit_path),
            exactCAndFullValueControls=bind(controls_path),controlCounts=dict(workers=105,schemas=60,completeC=3),
            acceptedRedirectProof=audit['acceptedRedirectProof'],redirectLaws=proof['lawNames'],
            unchangedPermissionAndTagProofClosures=True,
            inheritedPermissionProof=prior['finalPermissionProof'],inheritedTagProof=prior['finalTagProof'],
            finalPreparedProofManifests=prepared,
            finalPreparedProofStatus='Source rebinding only here; any new independent final-source checks require their own receipts.',
            scope='Exact permission declarations and old accepted safe helper proof closures survive the two planning-only changes. Complete finite workers/schemas and three tiny complete C/diagnostic comparisons pass; redirect has an exact independently checked whole-list law and identical final closure. Cached unsafe resolver correspondence is source-audited, not universally proved. No native ownership, performance, full-program C identity or image qualification is transferred.')
        for row in inputs.values():assert B.pin(row['file'])==row
        report['inputsUnchanged']=True
    except BaseException as error:
        report['error']=repr(error);raise
    finally:
        import json
        report['inputs']=list(inputs.values());(out/'report.json').write_text(json.dumps(report,indent=2)+'\n')
    print({'complete':True,'permissionDeclarations':len(exact),'changed':changed,'added':len(added)})


if __name__=='__main__':main()

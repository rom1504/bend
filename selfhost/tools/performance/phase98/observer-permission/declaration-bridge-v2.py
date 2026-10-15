#!/usr/bin/env python3
"""Offline exact-declaration bridge; does not transfer whole-image qualification."""
import argparse
import hashlib
import json
from pathlib import Path
import re
HERE=Path(__file__).resolve().parent
ROOT=HERE.parents[4]
def pin(path):
    path=Path(path).resolve();data=path.read_bytes()
    return dict(file=str(path),bytes=len(data),sha256=hashlib.sha256(data).hexdigest())
def read(path):return json.loads(Path(path).read_text())
def declarations(source):
    result={}
    for match in re.finditer(r'(?m)^(?:@unsafe\n)?def ([A-Za-z_][\w.]*)\b[^\n]*\n',source):
        end=source.find('\n\n',match.end());text=source[match.start():len(source) if end<0 else end+1]
        assert match[1] not in result,match[1];result[match[1]]=text
    return result

def main():
    p=argparse.ArgumentParser(description=__doc__)
    for name in ['qualified-recipe','candidate-recipe','qualification','corpus','proof','proof-manifest','tag-proof','tag-proof-manifest','out']:p.add_argument('--'+name,type=Path,required=True)
    args=p.parse_args();out=args.out.resolve();assert out.is_relative_to(ROOT/'selfhost/build/phase98') and not out.exists();out.mkdir(parents=True)
    inputs={}
    def bind(path):
        row=pin(path);assert inputs.setdefault(row['file'],row)==row;return row
    def verify(x):
        if isinstance(x,list):
            for y in x:verify(y)
        elif isinstance(x,dict):
            if {'file','bytes','sha256'}<=x.keys():assert bind(x['file'])==x
            else:
                for y in x.values():verify(y)
    def recipe(path):
        row=read(path);bind(path);verify(row);assert row['complete'];text=Path(row['source']['file']).read_text()
        for edit in row['changes']:
            at,old,new=edit['offset'],edit['old'],edit['new'];assert text[at:at+len(old)]==old
            text=text[:at]+new+text[at+len(old):]
        assert text==Path(row['candidate']['file']).read_text();return row,text
    report=dict(complete=False,kind='phase98-observer-declaration-bridge',targetsRun=False,imageQualified=False,wholeCompilerProved=False,inputs=[])
    try:
        qualified,old=recipe(args.qualified_recipe);candidate,new=recipe(args.candidate_recipe)
        assert candidate['source']==qualified['source']
        methods=read(args.qualification);corpus=read(args.corpus);proof=read(args.proof);manifest=read(args.proof_manifest)
        for file,row in [(args.qualification,methods),(args.corpus,corpus),(args.proof,proof),(args.proof_manifest,manifest)]:bind(file);verify(row)
        assert methods['complete'] and methods['fullPrograms']==7
        plan=read(methods['plan']['file']);assert plan['recipe']==pin(args.qualified_recipe)
        assert corpus['complete'] and corpus['pairs']==1444 and corpus['observedFields']==14
        assert proof['complete'] and proof['independentlyChecked'] and proof['opaqueDefinitions']==[]
        assert manifest['candidate']==candidate['candidate'] and manifest['package']=='permission'
        assert proof['source']==pin(manifest['entry'])
        proof_origins={x['origin']['file']:x['origin'] for x in proof['sourceClosure']}
        for row in manifest['outputs']:
            if Path(row['file']).suffix=='.bend':assert proof_origins[row['file']]==row
        before,after=declarations(old),declarations(new)
        names=sorted({name for change in qualified['changes'] for name in declarations(change['new'])})
        exact=[]
        for name in names:
            assert before[name]==after[name],name
            exact.append(dict(name=name,bytes=len(before[name].encode()),sha256=hashlib.sha256(before[name].encode()).hexdigest(),exact=True))
        dependencies=sorted({name for owner in names for name in re.findall(r'\b([A-Za-z_][\w.]*)\s*\(',before[owner]) if name not in names and name in before})
        changed=[]
        for name in dependencies:
            if before[name]!=after.get(name):changed.append(dict(name=name,beforeSha256=hashlib.sha256(before[name].encode()).hexdigest(),afterSha256=hashlib.sha256(after[name].encode()).hexdigest() if name in after else None))
        for row in manifest['candidateDefinitions']:
            assert new.count(row['original'])==1 and not row['removedUnsafe']
        tag_proof=read(args.tag_proof);tag_manifest=read(args.tag_proof_manifest)
        for file,row in [(args.tag_proof,tag_proof),(args.tag_proof_manifest,tag_manifest)]:bind(file);verify(row)
        assert tag_proof['complete'] and tag_proof['independentlyChecked'] and tag_proof['opaqueDefinitions']==[]
        assert tag_manifest['candidate']==candidate['candidate'] and tag_manifest['package']=='tag'
        assert tag_proof['source']==pin(tag_manifest['entry'])
        tag_origins={x['origin']['file']:x['origin'] for x in tag_proof['sourceClosure']}
        for row in tag_manifest['outputs']:
            if Path(row['file']).suffix=='.bend':assert tag_origins[row['file']]==row
        for row in tag_manifest['candidateDefinitions']:
            assert new.count(row['original'])==1
            expected=row['original'].removeprefix('@unsafe\n') if row['removedUnsafe'] else row['original']
            assert row['extracted']==expected
        for row in changed:
            name=row['name']
            if name=='p88_string_eq':
                assert any(x['name']==name for x in manifest['candidateDefinitions'])
                row['classification']='Exact final held comparator in permission/tag proof closures; qualified-source comparator differs.'
            else:
                replay=before[name];applied=[]
                for edit in candidate['changes']:
                    if edit['old'].startswith('p88_string_eq(tg(') and edit['new'].startswith('p98_tag_eq(') and edit['old'] in replay:
                        applied.append(dict(old=edit['old'],new=edit['new']));replay=replay.replace(edit['old'],edit['new'])
                assert replay==after[name] and applied,name
                row['classification']='Only exact authenticated tag-comparison substitutions; final safe tag law connected.'
                row['changes']=applied
        report.update(finalTagProof=pin(args.tag_proof),finalTagProofManifest=pin(args.tag_proof_manifest),finalTagProofLaws=tag_proof['lawNames'])
        report.update(complete=True,source=candidate['candidate'],qualifiedSource=qualified['candidate'],
            candidateRecipe=pin(args.candidate_recipe),qualifiedRecipe=pin(args.qualified_recipe),
            backendQualification=pin(args.qualification),corpusQualification=pin(args.corpus),
            exactPermissionDeclarations=exact,directChangedDependencies=changed,
            finalPermissionProof=pin(args.proof),finalPermissionProofManifest=pin(args.proof_manifest),
            finalProofLaws=proof['lawNames'],method=bind(__file__),
            scope='Exact permission declarations and recipes are connected to qualified source02; final safe permission/comparator proof closure is independently checked. Changed callees are explicitly listed. This does not transfer native ownership, generated-C identity, performance or whole final-image qualification; final B1/B2 and original semantic gates remain required.')
        for row in inputs.values():assert pin(row['file'])==row
        report['inputsUnchanged']=True
    except BaseException as error:report['error']=repr(error);raise
    finally:
        report['inputs']=list(inputs.values());(out/'report.json').write_text(json.dumps(report,indent=2)+'\n')
    print(json.dumps(dict(complete=report['complete'],exactDeclarations=len(report['exactPermissionDeclarations']),changedDependencies=len(report['directChangedDependencies']))))
if __name__=='__main__':main()

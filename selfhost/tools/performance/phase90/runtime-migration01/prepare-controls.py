#!/usr/bin/env python3
"""Four explicit runtime-only C oracle derivatives plus two negative source controls; no targets."""
import argparse,json,sys
from pathlib import Path
sys.dont_write_bytecode=True
from support import ROOT,P,transition,historical,transport,read,pin,verify

def main():
    p=argparse.ArgumentParser(description=__doc__);p.add_argument('transport',type=Path);p.add_argument('out',type=Path);a=p.parse_args()
    assets,transport_pin,seal,seal_pin=transport(a.transport)
    proof_pin=pin(ROOT/'selfhost/build/phase90/whitespace02/report.json');proof=read(proof_pin['file'])
    admission=read(seal['admission']['file']);assert admission['cpuPreprocessingProof']==proof_pin
    assert proof['complete'] and proof['pass'] and proof['inputBindingsUnchanged'] and len(proof['rows'])==4
    plan=read(assets['plan']['file']);assert len(plan['edits'])==2
    out=a.out.resolve();assert out.is_relative_to(ROOT/'selfhost/build/phase90');out.mkdir(parents=True,exist_ok=False)
    rows=[]
    for row in proof['rows']:
        assert row['passed'] and row['exactPreprocessed']
        before=verify(row['current']);source=verify(row['source']);text=Path(before['file']).read_bytes();original=text
        for edit in plan['edits']:
            old,new=edit['before'].encode(),edit['after'].encode();assert text.count(old)==1;text=text.replace(old,new,1)
        target=out/(row['name']+'.expected.c');target.write_bytes(text)
        for edit in reversed(plan['edits']):
            old,new=edit['before'].encode(),edit['after'].encode();assert text.count(new)==1;text=text.replace(new,old,1)
        assert text==original
        rows.append(dict(name=row['name'],source=source,parentC=before,oracle=pin(target),exactInverse=True))
    catalog_pin=pin(P/'phase37/catalog.json');catalog=read(catalog_pin['file'])
    entry=next(c for c in catalog['cases'] if c['id']=='coverage-map-churn-128')
    original_map=pin(P/'phase37'/entry['source']['path']);assert original_map['sha256']==entry['source']['sha256']
    map_source=next(r['source'] for r in rows if r['name']=='map_closed')
    assert Path(map_source['file']).read_text().split('# Phase86:')[0].strip()==Path(original_map['file']).read_text().strip()
    assert entry['point']==dict(exportName='bench',args=[128,123],expected=3714872484)
    expected={'small':'42\n','map_closed':'3714872484\n','unicode':'😀🦋猫\n'}
    for row in rows:
        if row['name'] in expected:row['execute']=dict(stdout=expected[row['name']],stderr='',exitCode=0)
    file_manifest_pin=pin(ROOT/'selfhost/build/phase89/native-b2-controls02/manifest.json');file_manifest=read(file_manifest_pin['file'])
    file_case=next(x for x in file_manifest['fileCases'] if x['id']=='unicode')
    input_pin=pin(file_case['input']);assert input_pin['sha256']==file_case['expect']['outputSha256']
    file_row=next(r for r in rows if r['name']=='file-io')
    file_row['execute']=dict(stdout='copy-ok\n',stderr='file-control-ok\n',exitCode=0,input=input_pin,
        payload=['phase90-program','copy',input_pin['file'],'OUTPUT_COPY'],outputSha256=input_pin['sha256'])
    controls=Path(__file__).parent/'controls'
    negatives=[dict(name=name,source=pin(controls/file),expectedError=phase,exitCode=1,outputAbsent=True)
        for name,file,phase in [('invalid-syntax','invalid-syntax.bend','parse'),('type-error','type-error.bend','check')]]
    result=dict(kind='phase90-runtime-migrated-semantic-control-plan',complete=True,executionPerformed=False,
        method=pin(__file__),transition=seal_pin,transport=transport_pin,parentCProof=proof_pin,runtimePlan=assets['plan'],edits=plan['edits'],
        cases=rows,negatives=negatives,catalog=catalog_pin,mapOriginal=original_map,fileManifest=file_manifest_pin,
        scope='Expected user C is explicitly derived from independent checked old-C outputs by only the two new-runtime edits. Actual native07 compiler, negative, Clang and program execution gates remain required.')
    f=out/'controls.json';f.write_text(json.dumps(result,indent=2,ensure_ascii=False)+'\n');print(json.dumps(dict(controls=pin(f),targetsExecuted=False)))

if __name__=='__main__':main()

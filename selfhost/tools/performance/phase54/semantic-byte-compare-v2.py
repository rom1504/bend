#!/usr/bin/env python3
"""Exact emitted module comparison; never normalize output or infer allowed changes."""
import argparse,hashlib,json,importlib.util,sys
from pathlib import Path

def identity(file):
    file=Path(file).resolve(strict=True)
    return dict(file=str(file),sha256=hashlib.sha256(file.read_bytes()).hexdigest(),bytes=file.stat().st_size)

def main():
    p=argparse.ArgumentParser(description=__doc__)
    for name in ['baseline','candidate','out']:p.add_argument('--'+name,type=Path,required=True)
    p.add_argument('--format',choices=['semantic','production'],required=True)
    p.add_argument('--profile',choices=['core','core8','full45'],default='full45')
    p.add_argument('--set',choices=['core','full'])
    a=p.parse_args();
    if a.set:a.profile='core' if a.set=='core' else 'full45'
    if a.profile!='full45':assert a.format=='production'
    assert not a.out.exists();inputs=[identity(__file__),identity(Path(__file__).with_name('semantic-byte-compare-v1.py')),identity(a.baseline),identity(a.candidate)]
    before=json.loads(a.baseline.read_text());after=json.loads(a.candidate.read_text());assert before['complete'] and after['complete']
    planFile=Path(__file__).with_name('semantic-plan-v2.json');plan=json.loads(planFile.read_text());inputs.append(identity(planFile))
    expected=[plan['baselineJS45']] if a.format=='production' else list(plan['baselineSemantic'].values())
    assert any(identity(a.baseline)['sha256']==r['sha256'] for r in expected),'Must compare with the frozen installed-Phase53 acquisition'
    if a.format=='semantic':
        attemptRow=after['roles']['direct']['attempt']
    else:
        prepRow=after['preparation'];prepFile=a.candidate.resolve().parent/prepRow['path'];assert identity(prepFile)['sha256']==prepRow['sha256'];inputs.append(identity(prepFile));prep=json.loads(prepFile.read_text());assert prep['complete'] and len(prep['sources'])==(plan['helperCatalogCore']['uniqueSourceReceipts'] if a.profile=='core' else 8 if a.profile=='core8' else 23)
        first=prep['sources'][0]['emission'];firstFile=a.candidate.resolve().parent/first['path'];assert identity(firstFile)['sha256']==first['sha256'];attemptRow=json.loads(firstFile.read_text())['attempt']
    attemptFile=Path(attemptRow.get('file',attemptRow.get('path')));selected=json.loads(attemptFile.read_text());assert selected['checked'] and identity(attemptFile)['sha256']==attemptRow['sha256'];inputs.append(identity(attemptFile))
    def checkedCandidate(receipt):
        assert receipt['kind']=='bend-program-checked-emission' and receipt['complete'] and receipt['observation']['checked'] and receipt['observation']['status']=='ok' and receipt['observation']['exitCode']==0
        assert receipt['attempt']['sha256']==attemptRow['sha256'] and receipt['compiler']['backend']=='direct'
        for key in ['api','runtime','base']:assert receipt['compiler'][key]['sha256']==selected[key]['sha256']
        frozen={Path(row['frozen']['file']).resolve():row['frozen']['sha256'] for row in selected['snapshot']['sources']}
        for key in ['driver','directRuntime']:assert frozen[Path(receipt['compiler'][key]['file']).resolve()]==receipt['compiler'][key]['sha256']
    rawBySource={}
    if a.format=='production':
        for row in prep['sources']:
            file=a.candidate.resolve().parent/row['emission']['path'];assert identity(file)['sha256']==row['emission']['sha256'];inputs.append(identity(file));receipt=json.loads(file.read_text());checkedCandidate(receipt)
            output=Path(receipt['output']['file']);assert identity(output)['sha256']==receipt['output']['sha256'];inputs.append(identity(output))
            assert receipt['compiler']==after['roles']['candidate']['compiler']
            rawBySource[receipt['input']['sha256']]=dict(file=output,sha256=receipt['output']['sha256'])
    report=dict(kind='phase54-exact-emitted-module-comparison',complete=False,executed=False,format=a.format,inputs=inputs,rows=[],scope='Data-only exact full-file comparison. Every selected source/module must match; no normalization, changed-case exception, semantic substitute or benchmark claim.')
    report['pass']=False
    def module(file,expected):
        row=identity(file);assert row['sha256']==expected['sha256'];inputs.append(row);return row
    if a.format=='semantic':
        assert before['passed'] and after['passed'] and before['catalog']==after['catalog']
        b=before['roles']['direct']['modules'];c=after['roles']['direct']['modules'];assert set(b)==set(c)
        for key in b:
            roles=[]
            for f in [b[key],c[key]]:
                receiptFile=Path(str(f)+'.json');r=json.loads(receiptFile.read_text());assert r['complete'] and r['observation']['checked'] and r['observation']['status']=='ok';inputs.append(identity(receiptFile));roles.append((module(f,r['output']),r))
            checkedCandidate(roles[1][1])
            assert roles[0][1]['compiler']['api']['sha256']==plan['installedAPI']
            assert roles[0][1]['input']['sha256']==roles[1][1]['input']['sha256']
            report['rows'].append(dict(id=key,baseline=roles[0][0],candidate=roles[1][0],equal=roles[0][0]['sha256']==roles[1][0]['sha256']))
    else:
        assert before['catalogSha256']==after['catalogSha256'] and before['upstreamCommit']==after['upstreamCommit']
        b={c['id']:c for c in before['cases']};c={c['id']:c for c in after['cases']}
        if a.profile=='core8':b={key:b[key]for key in plan['helperOnlyCore8']}
        elif a.profile=='core':b={key:b[key]for key in plan['helperCatalogCore']['caseIDs']}
        assert set(b)==set(c) and len(b)==(8 if a.profile in ['core','core8'] else 45)
        assert before['roles']['candidate']['compiler']['api']['sha256']==plan['installedAPI']
        for key in b:
            assert b[key]['point']==c[key]['point'] and b[key]['sourceSha256']==c[key]['sourceSha256']
        programs=Path(__file__).resolve().parent.parent/'programs';sys.path.insert(0,str(programs))
        loaderFile=programs/'run.py';supportFile=programs/'support.py'
        for file in [loaderFile,supportFile]:
            expected=next(r for r in plan['immutableInputs'] if Path(r['file'])==file);assert identity(file)['sha256']==expected['sha256'];inputs.append(identity(file))
        spec=importlib.util.spec_from_file_location('phase54_verified_bundle_reader',loaderFile);reader=importlib.util.module_from_spec(spec);spec.loader.exec_module(reader)
        catalogFile=programs.parent/'phase37/catalog.json';catalog=json.loads(catalogFile.read_text());catalogRow=identity(catalogFile);assert catalogRow['sha256']==before['catalogSha256'];inputs.append(catalogRow)
        selected=[row for row in catalog['cases']if row['id']in b];assert len(selected)==len(b)
        observerFile=programs.parent/'phase52/prepare-v2.py';expected=next(r for r in plan['immutableInputs'] if Path(r['file'])==observerFile);assert identity(observerFile)['sha256']==expected['sha256'];inputs.append(identity(observerFile))
        observerSpec=importlib.util.spec_from_file_location('phase54_frozen_row_observer',observerFile);observer=importlib.util.module_from_spec(observerSpec);observerSpec.loader.exec_module(observer)
        for case in selected:
            raw=rawBySource[case['source']['sha256']];row=c[case['id']]['modules']['candidate']
            if case.get('adapter'):
                assert case['adapter']=='generic-row';adapters=[x for x in prep['adapters']if x['raw']['sha256']==raw['sha256']];assert len(adapters)==1
                adapted=adapters[0];assert adapted['producer']['sha256']==expected['sha256'];assert row['sha256']==adapted['adapted']['sha256']
                exact=observer.observe_row(raw['file'].read_text(),typescript=True).encode();assert hashlib.sha256(exact).hexdigest()==row['sha256']
            else:assert row['sha256']==raw['sha256']
            assert (a.candidate.resolve().parent/row['path']).read_bytes()==(exact if case.get('adapter') else raw['file'].read_bytes())
        verified=[]
        for file in [a.baseline,a.candidate]:verified.append(reader.load_bundle(file,catalog,catalogRow['sha256'],selected,['candidate'],inputs,out=None))
        for key in b:
            old=verified[0]['points'][key]['candidate'];new=verified[1]['points'][key]['candidate']
            left=dict(archive=before.get('archive'),modulePath=old['path'],sha256=old['sha256'],bytes=old['bytes']);right=dict(file=str(a.candidate.resolve().parent/new['path']),sha256=new['sha256'],bytes=new['bytes'])
            report['rows'].append(dict(id=key,baseline=left,candidate=right,equal=left['sha256']==right['sha256'] and left['bytes']==right['bytes']))
    report['complete']=True;report['counts']=dict(equal=sum(r['equal']for r in report['rows']),total=len(report['rows']),uniqueBaselineModules=len({r['baseline']['sha256']for r in report['rows']}));report['pass']=all(r['equal']for r in report['rows'])
    report['inputs']=[dict(file=str(Path(r.get('file',r.get('path'))).resolve()),sha256=r['sha256'],bytes=r['bytes'])for r in inputs];report['changedInputs']=[r for r in report['inputs'] if identity(r['file'])!=r];assert not report['changedInputs'];a.out.parent.mkdir(parents=True,exist_ok=True)
    with a.out.open('x')as f:f.write(json.dumps(report,indent=2)+'\n')
    print(json.dumps(dict(complete=True,pass_=report['pass'],counts=report['counts'])))
    return 0 if report['pass'] else 1
if __name__=='__main__':raise SystemExit(main())

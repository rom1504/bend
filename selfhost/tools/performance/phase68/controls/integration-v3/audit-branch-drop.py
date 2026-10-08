#!/usr/bin/env python3
"""Join the retained branch-drop golden with its boxed-entry admission fact."""
import argparse
import hashlib
import json
import re
from pathlib import Path

def pin(value):
    item = value if isinstance(value,dict) else None
    p = Path(item.get('file',item.get('path')) if item else value).resolve(strict=True)
    data = p.read_bytes(); result = dict(file=str(p),sha256=hashlib.sha256(data).hexdigest(),bytes=len(data))
    if item:
        assert result['sha256'] == item['sha256'], p
        if 'bytes' in item: assert result['bytes'] == item['bytes'], p
    return result

def c_without_literals(source):
    # Preserve offsets/newlines; erase comments and C string/character literals.
    chars = list(source); i = 0
    while i < len(source):
        start = i
        if source.startswith('//',i):
            i = source.find('\n',i)
            if i < 0: i = len(source)
        elif source.startswith('/*',i):
            end = source.find('*/',i+2); assert end >= 0; i = end+2
        elif source[i] in "\"'":
            quote = source[i]; i += 1
            while i < len(source) and source[i] != quote:
                i += 2 if source[i] == '\\' else 1
            assert i < len(source); i += 1
        else:
            i += 1; continue
        for j in range(start,i):
            if chars[j] != '\n': chars[j] = ' '
    return ''.join(chars)

def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--plan',type=Path,required=True); p.add_argument('--out',type=Path,required=True)
    a = p.parse_args(); plan = json.loads(a.plan.read_text())
    inputs = [pin(a.plan),pin(__file__),*[pin(x) for x in plan['inputs']]]
    report_path = Path(plan['report']); report = json.loads(report_path.read_text()); inputs.append(pin(report_path))
    assert report['complete'] and report['pass'] and report['strictExact']
    assert pin(report['api']) == pin(plan['selectedApi']) and pin(report['attempt']) == pin(plan['attempt'])
    pair_path = report_path.parent/'selected/paired.json'; paired = json.loads(pair_path.read_text()); inputs.append(pin(pair_path))
    assert paired['selectedComplete'] and len(paired['rows']) == 1
    wanted = {(r['id'],'native') for r in json.loads(Path(plan['selection']['file']).read_text())['cases']}
    assert {(r['id'],r['lane']) for r in paired['rows']} == wanted
    assert all(r['exactAgreement'] and r['referenceVerdict']==r['candidateVerdict']=='pass' for r in paired['rows'])
    candidate_path = pair_path.parent/'candidate.json'; candidate = json.loads(candidate_path.read_text()); inputs.append(pin(candidate_path))
    assert candidate['finished'] and candidate['selectedComplete'] and not candidate['changedInputs']
    assert candidate['identity']['changedArtifacts'] == [] and candidate['identity']['adapterChangedDuringRun'] is False
    rows = [r for r in candidate['results'] if r['id']=='phase68/flat-product-branch-drop-v1.bend' and r['lane']=='native']
    assert len(rows)==1; row=rows[0]; assert row['status']=='pass'
    assert row['result']['phase']=='runtime' and row['result']['output']=='1831\n' and row['result']['exitCode']==0
    artifact = Path(row['artifacts']); request_path=artifact/'request.json'; request=json.loads(request_path.read_text()); inputs.append(pin(request_path))
    assert request['test']['id']==row['id'] and request['lane']=='native'
    fixture=pin(dict(file=request['test']['file'],sha256=request['test']['sha256'],bytes=request['test']['bytes']));inputs.append(fixture)
    assert fixture in inputs and fixture['file'] in {x['file'] for x in plan['inputs']}
    source=artifact/(Path(request['test']['file']).stem+'.c'); inputs.append(pin(source))
    code=c_without_literals(source.read_text())
    fid=lambda name:'FID_'+''.join(str(ord(c))+'_' for c in name)
    worker=lambda name:'NF_'+fid(name)
    original='drop_product_branch68'
    assert re.search(r'^#define '+re.escape(fid(original))+r' \d+$',code,re.M), 'Dropping definition must be retained'
    forbidden=worker('$product.'+original)
    assert not re.search(r'\b'+re.escape(forbidden)+r'\b',code), 'Dropping product entry must be absent, including declarations/calls'
    for item in inputs: pin(item)
    result=dict(kind='phase68-product-branch-drop-controls',complete=True,targetExecuted=False,
        inputs=inputs,sourceCount=1,independentGolden=1831,
        boxedDefinition=dict(name=original,symbol=fid(original)),
        forbiddenProductEntry=dict(name='$product.'+original,symbol=forbidden),
        scope='One exact paired runtime observation plus retained-C exclusion of the dropping product entry. Does not prove general ownership or qualify another compiler image.')
    result['pass']=True
    assert not a.out.exists();a.out.parent.mkdir(parents=True,exist_ok=True)
    a.out.write_text(json.dumps(result,indent=2)+'\n');print(json.dumps(pin(a.out)))

if __name__=='__main__': main()

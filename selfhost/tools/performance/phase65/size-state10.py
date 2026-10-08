#!/usr/bin/env python3
"""State10 successor; preserve consumed State09 audit. Data only, no compiler."""
from pathlib import Path
import hashlib,json,re,sys

ROOT=Path(__file__).resolve().parents[4]
OUT=Path(sys.argv[1]).resolve() if len(sys.argv)==2 else ROOT/'implementation/phase65/evidence/state10-size.json'
INPUTS={}
FIELDS=['physicalLines','codeLines','definitions','laws','types','utf8Bytes']

def identify(file,expected=None):
    file=Path(file);data=file.read_bytes()
    row={'file':str(file),'sha256':hashlib.sha256(data).hexdigest(),'bytes':len(data)}
    if expected:
        assert row['sha256']==expected['sha256'],file
        if 'bytes' in expected:assert row['bytes']==expected['bytes'],file
        if 'canonicalPath' in expected:assert str(file.resolve())==expected['canonicalPath'],file
    if str(file.resolve()) in INPUTS:assert INPUTS[str(file.resolve())]==row,file
    INPUTS[str(file.resolve())]=row
    return row

def read(file,expected=None):
    identity=identify(file,expected)
    return json.loads(Path(file).read_text()),identity

def counts(file,bend=True):
    data=Path(file).read_bytes();text=data.decode('utf-8');assert text.encode('utf-8')==data
    lines=text.splitlines();result={'physicalLines':len(lines),'utf8Bytes':len(data)}
    if bend:result.update(codeLines=sum(bool(x.strip()) and not x.lstrip().startswith('#') for x in lines),
        definitions=sum(bool(re.match(r'^def\s',x)) for x in lines),
        laws=sum(bool(re.match(r'^law\s',x)) for x in lines),types=sum(bool(re.match(r'^type\s',x)) for x in lines))
    return result

def state(phase,number='09'):
    attempt,attempt_id=read(ROOT/f'selfhost/build/phase{phase}/checked-state{number}/attempt.json')
    assert attempt['checked'] and attempt['config']['strictExact']
    snapshot=Path(attempt['snapshot']['root']);frozen={str(Path(x['frozen']['file']).relative_to(snapshot)):x['frozen'] for x in attempt['snapshot']['sources']}
    manifest,manifest_id=read(snapshot/'src/compiler.json',frozen['src/compiler.json'])
    names=manifest['modules'];assert len(names)==len(set(names)) and all(x.endswith('.bend') for x in names)
    modules={}
    for name in names:
        file=snapshot/name;assert file.resolve().is_relative_to(snapshot.resolve())
        modules[name]={'sha256':identify(file,frozen[name])['sha256'],'metrics':counts(file)}
    totals={k:sum(x['metrics'][k] for x in modules.values()) for k in FIELDS};totals['modules']=len(modules)
    host={name:{'identity':identify(snapshot/name,frozen[name]),'metrics':counts(snapshot/name,False)}
          for name in ['tools/typed-driver.mjs','tools/base-cache-graph.mjs','tools/development/workflow.mjs','tools/development/release.mjs']}
    runtimes={name:identify(snapshot/name,frozen[name]) for name in ['src/runtime.mjs','src/runtime/js/direct.mjs']}
    b2,b2_id=read(ROOT/f'selfhost/build/phase{phase}/bootstrap-state{number}/full/report.json')
    assert b2['complete'] and b2['pass'];assert b2['subject']['attempt']['sha256']==attempt_id['sha256']
    identify(b2['subject']['attempt']['file'],b2['subject']['attempt']);identify(b2['subject']['bootstrap']['file'],b2['subject']['bootstrap'])
    source=identify(b2['subject']['source']['file'],b2['subject']['source'])
    artifacts={x['file']:x for x in attempt['artifacts']};identify(source['file'],artifacts[source['file']])
    backups=[identify(snapshot/name,frozen[name]) for name in sorted(frozen) if name.endswith('.bend.orig')]
    images={'checkedB1Raw':identify(attempt['checkedApi']['file'],attempt['checkedApi']),
            'checkedB1EqualityDerived':identify(attempt['api']['file'],attempt['api']),
            'genuineB2':identify(b2['module']['file'],b2['module'])}
    return {'phase':phase,'state':number,'snapshotRoot':str(snapshot),'attempt':attempt_id,'manifest':manifest_id,'metrics':totals,
            'moduleOrder':names,'hostSupport':host,'runtimes':runtimes,'assembledSource':source,'images':images,
            'b2Receipt':b2_id,'exports':b2['roots'],'excludedNonmanifestBackups':backups},modules

identify(__file__)
parent=identify(ROOT/'selfhost/tools/performance/phase64/typed-plan/size.py')
before,old=state(64);after,new=state(65,'10')
assert before['metrics']=={'physicalLines':28279,'codeLines':23199,'definitions':3254,'laws':642,'types':118,'utf8Bytes':1289580,'modules':114}
assert [n for n in after['moduleOrder'] if n in old]==before['moduleOrder'],'Original module order changed'
unchanged=[];changed=[]
for name in sorted(set(old)|set(new)):
    a,b=old.get(name),new.get(name)
    if a and b and a['sha256']==b['sha256']:
        assert a['metrics']==b['metrics'];unchanged.append([name,a['sha256']]+[a['metrics'][k] for k in FIELDS])
    else:
        zero={k:0 for k in FIELDS}
        changed.append({'module':name,'before':a,'after':b,'delta':{k:(b['metrics'] if b else zero)[k]-(a['metrics'] if a else zero)[k] for k in FIELDS}})
host_changes=[{'file':name,'before':before['hostSupport'][name]['metrics'],'after':after['hostSupport'][name]['metrics'],
               'delta':{k:after['hostSupport'][name]['metrics'][k]-before['hostSupport'][name]['metrics'][k] for k in before['hostSupport'][name]['metrics']}}
              for name in before['hostSupport']]
report={'kind':'phase65-frozen-state10-size-comparison','complete':True,'pass':True,'dataOnly':True,'targetExecuted':False,
        'producer':identify(__file__),'methodParent':parent,
        'method':{'boundary':'Exactly each frozen src/compiler.json module list; exclude generated assembly, backups, fixtures, tools, docs, runtime and host source from Bend totals.',
                  'physicalLines':'UTF-8 decoded Python splitlines per module, same Phase64 rule.',
                  'codeLines':'Nonempty lines excluding lines whose first nonspace character is #.',
                  'declarations':'Line-start def/law/type followed by whitespace; textual proxies, not concept complexity.',
                  'verification':'Every manifest/module/host/runtime/image is checked against its frozen receipt SHA256; optional bytes/canonicalPath checked; all inputs rehashed after counting.',
                  'compactModuleTable':'Each unchanged row was independently checked in both snapshot roots; order and column schema are explicit.'},
        'baseline':before,'candidate':after,'delta':{k:after['metrics'][k]-before['metrics'][k] for k in before['metrics']},
        'unchangedModuleColumns':['module','sha256']+FIELDS,'unchangedModules':unchanged,'changedModules':changed,
        'hostChanges':host_changes,'imageByteDeltas':{k:after['images'][k]['bytes']-before['images'][k]['bytes'] for k in before['images']},
        'exportsAdded':[x for x in after['exports'] if x not in before['exports']],
        'exportsRemoved':[x for x in before['exports'] if x not in after['exports']],
        'runtimeUnchanged':all(before['runtimes'][k]['sha256']==after['runtimes'][k]['sha256'] for k in before['runtimes']),
        'limitations':['These are reproducible source/image size proxies, not a speed, semantic concept-count, correctness, release or soundness claim.',
                       'Actual selected image export scopes differ; image bytes are not an equal-export microcomparison.',
                       'Repository-wide experiments/reports and nonmanifest backup files do not enter the compiler source denominator.']}
for row in list(INPUTS.values()):identify(row['file'],row)
report['verifiedInputCount']=len(INPUTS);report['verifiedAllInputsUnchanged']=True
OUT.parent.mkdir(parents=True,exist_ok=True)
with OUT.open('x') as stream:json.dump(report,stream,indent=2);stream.write('\n')
print(json.dumps({'output':str(OUT),'bytes':OUT.stat().st_size,'verifiedInputs':len(INPUTS),'baseline':before['metrics'],'candidate':after['metrics'],'delta':report['delta'],'changedModules':changed,'hostChanges':host_changes,'imageByteDeltas':report['imageByteDeltas'],'exportsAdded':report['exportsAdded'],'runtimeUnchanged':report['runtimeUnchanged']}))

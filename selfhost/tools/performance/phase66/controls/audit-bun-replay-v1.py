#!/usr/bin/env python3
"""CPU0 data-only audit; no target execution or mutation of campaign artifacts."""
import collections, hashlib, json, sys
from pathlib import Path
root=Path(__file__).resolve().parents[5]
def read(p): return json.loads(Path(p).read_text())
def identity(p):
    p=Path(p).resolve()
    h=hashlib.sha256()
    with p.open('rb') as f:
        for chunk in iter(lambda:f.read(1048576),b''): h.update(chunk)
    digest=h.hexdigest()
    return dict(file=str(p),sha256=digest,bytes=p.stat().st_size)
verified={}
def pin(v):
    p=Path(v['file']).resolve()
    if str(p) not in verified: verified[str(p)]=identity(p)
    got=verified[str(p)]
    assert got['sha256']==v['sha256'],str(p)
    if 'bytes' in v: assert got['bytes']==v['bytes'],str(p)
    return got
rpath=root/'selfhost/build/phase66/bun-replay01/report.json'
recipepath=root/'selfhost/build/phase66/bun-replay01-recipe.json'
processpath=root/'selfhost/build/phase66/bun-replay01-exec/process.json'
r,recipe,process=map(read,[rpath,recipepath,processpath])
assert r['complete'] and not r['pass'] and r['inputsUnchanged']
assert not r['compilersExecuted'] and not r['nodeResultsRewritten']
assert process['command']==['taskset','-c','3',*recipe['command']]
assert process['returncode']==1 and not process['complete']
assert 'stoppedFor' not in process and 'error' not in process
assert process['peakTreeRssBytes']<process['rssLimitBytes']
assert process['minimumAvailableBytes']>process['availableFloorBytes']
for row in r['inputs']: pin(row)
def pins(v):
    if isinstance(v,dict):
        if isinstance(v.get('file'),str) and isinstance(v.get('sha256'),str): pin(v)
        for value in v.values(): pins(value)
    elif isinstance(v,list):
        for value in v: pins(value)
pins(recipe)
counts=collections.Counter(c['status'] for c in r['cases'])
assert counts=={'pass':54,'fail':1,'deferred-environment':1}
assert len(r['cases'])==56 and [c['id'] for c in r['cases']]==r['selection']['ids']
rows=[]; actions=0; original_dirs=set()
for c in r['cases']:
    assert set(c['roles'])=={'typescript','bend'}
    for role,v in c['roles'].items():
        pin(v['source']); pin(v['module'])
        original=Path(v['module']['file']).parent
        expected={x['relative'] for x in v['artifactFiles']}
        actual={str(p.relative_to(original)) for p in original.rglob('*') if p.is_file()}
        assert expected==actual,(c['id'],role,'original inventory')
        original_dirs.add(str(original))
        for x in v['artifactFiles']: pin(x)
    ts,bend=c['roles']['typescript'],c['roles']['bend']
    assert ts['source']==bend['source'] and ts['expected']==bend['expected']
    if c['status']=='deferred-environment':
        assert c['id']=='gfx/app_linear.bend'
        assert all('execution' not in v for v in c['roles'].values())
        rows.append(dict(id=c['id'],status=c['status'],actions=0)); continue
    for role,v in c['roles'].items():
        e=v['execution']; actions+=1
        assert not e['timedOut'] and not e['overflow'] and not e['spawnError'] and not e['signal']
        assert isinstance(e['exitCode'],int) and e['observation']['checked']
        pin(e['output'])
        assert Path(e['output']['file']).read_text()==e['observation']['output']
        assert v['judgment']['status']==c['status']
        pin(dict(file=e['command'][1],sha256=v['module']['sha256'],bytes=v['module']['bytes']))
    assert ts['execution']['exitCode']==bend['execution']['exitCode'],c['id']
    assert ts['execution']['output']['sha256']==bend['execution']['output']['sha256'],c['id']
    assert ts['rendered']==bend['rendered']
    rows.append(dict(id=c['id'],status=c['status'],actions=2,identicalOutput=True,
        outputSha256=ts['execution']['output']['sha256']))
assert actions==110
failure=next(c for c in r['cases'] if c['status']=='fail')
assert failure['id']=='io/process_run.bend'
v=failure['roles']['typescript']
expected=v['expected'].splitlines(); actual=v['rendered'].splitlines()
assert len(actual)==len(expected)==16 and actual[:14]==expected[:14]
assert actual[14:]==['inherited pipe: unexpected failure','descendant output: unexpected failure']
provider=root/'selfhost/src/runtime/js/effs/process_run.js'
upstream=root/'selfhost/.bootstrap/upstream-phase66/bend2/effs/process_run.js'
assert provider.read_bytes()==upstream.read_bytes()
result=dict(kind='phase66-paired-bun-runtime-audit',complete=True,auditPass=True,
    replayPass=False,producer=identity(__file__),raw=identity(rpath),recipe=identity(recipepath),
    supervisor=identity(processpath),runtime=r['runtime'],judge=r['judge'],
    nodeReports={k:v['identity'] for k,v in r['nodeReports'].items()},
    identitiesRehashed=len(verified),originalArtifactDirectoriesRechecked=len(original_dirs),
    summary=dict(selected=56,executedPairs=55,actions=actions,pairedPass=54,sharedFailure=1,
        deferred=1,identicalOutputPairs=55,candidateOnlyRuntimeDifferences=0),
    resources=dict(wallSeconds=process['wallSeconds'],peakTreeRssBytes=process['peakTreeRssBytes'],
        minimumAvailableBytes=process['minimumAvailableBytes'],returncode=1,resourceStop=False),
    sharedFailure=dict(id=failure['id'],source=v['source'],provider=identity(provider),
        upstreamProvider=identity(upstream),matchedChecks=14,totalChecks=16,
        differences=[dict(expected=a,actual=b) for a,b in zip(expected,actual) if a!=b],
        outputs={k:x['execution']['output'] for k,x in failure['roles'].items()},
        interpretation='Both generated programs fail the same background-descendant cases in the unchanged upstream Bun.spawnSync provider. Actual provider error codes are hidden by this fixture; timeout versus maxBuffer versus another failure is not established.'),
    cases=rows,scope='Finite Bun replay of retained State04 Bend and pinned upstream TS emitted programs, not a new compile or a rewrite of Node observations. Deferred gfx is not passed. Complete audit does not turn the shared oracle failure into conformance success.')
out=Path(sys.argv[1]); out.parent.mkdir(parents=True,exist_ok=True)
with out.open('x') as f: json.dump(result,f,indent=2); f.write('\n')
print(json.dumps(dict(output=identity(out),summary=result['summary'],identitiesRehashed=len(verified))))

"""Index completed Phase120 evidence; never selects an installed compiler."""
import argparse
import hashlib
import json
import statistics
from pathlib import Path

ROOT = Path(__file__).resolve().parents[4]
def read(file): return json.loads((ROOT / file).read_text())
def pin(file):
    file = (ROOT / file).resolve(); data = file.read_bytes()
    return dict(file=str(file), bytes=len(data), sha256=hashlib.sha256(data).hexdigest())
def checked(file):
    r = read(file); assert r['complete'], file
    return r
def save(file, data):
    assert not file.exists(), file
    file.write_text(json.dumps(data, indent=2)+'\n')
p = argparse.ArgumentParser(description=__doc__)
p.add_argument('--out', type=Path, default=ROOT / 'implementation/phase120')
a = p.parse_args(); a.out.mkdir(parents=True, exist_ok=True)
sm = 'selfhost/build/phase120/combined-source03/manifest.json'
ar = 'selfhost/build/phase111/p120-combined-api03/report.json'
source, api = checked(sm), checked(ar)
primary_sm = 'selfhost/build/phase120/combined-source01/manifest.json'
primary_ar = 'selfhost/build/phase111/p120-combined-api01/report.json'
primary_source, primary_api = checked(primary_sm), checked(primary_ar)
assert primary_api['checked'] and primary_source['source'] in primary_api['inputs']
assert api['checked'] and source['source'] in api['inputs']
for item in [source['source'],api['api'],*source['inputs'],primary_source['source'],primary_api['api'],*primary_source['inputs']]: assert pin(item['file']) == item
bridges = []
for kind, count in [('broad',45),('controls',6)]:
    newfile = f'selfhost/build/phase118/p120-combined-{kind}-emit03/report.json'
    oldfile = f'selfhost/build/phase118/p120-combined-{kind}-emit01/report.json'
    new, old = checked(newfile), checked(oldfile)
    assert new['source'] == source['source'] and new['runtime'] == old['runtime']
    assert len(new['cases']) == len(old['cases']) == count
    for row in new['cases']:
        previous = next(x for x in old['cases'] if x['name'] == row['name'])
        assert row['verified'] and row['source'] == previous['source']
        assert row['exactDiagnosticMatch'] == previous['qbe']
        assert pin(row['qbe']['file']) == row['qbe'] and pin(previous['qbe']['file']) == previous['qbe']
        assert Path(row['qbe']['file']).read_bytes() == Path(previous['qbe']['file']).read_bytes()
    bridges.append(dict(kind=kind,cases=count,new=pin(newfile),timedProducer=pin(oldfile)))
runtime = new['runtime']; assert pin(runtime['file']) == runtime
costs = {}
for version in ['01','03']:
    file = f'selfhost/build/phase118/p120-combined-cost{version}/report.json'
    r = checked(file); assert len(r['rows']) == 32
    costs[version] = dict(receipt=pin(file), summaries=r['summaries'],
                         geometricCandidateOverParent=r['geometricCandidateOverParent'],
                         geometricAdmittedCandidateOverParent=r['geometricAdmittedCandidateOverParent'])
controls = []
for file in ['selfhost/build/phase120/combined-finite03.json',
             'selfhost/build/phase120/combined-word03/report.json',
             'selfhost/build/phase120/combined-shortcut03.json',
             'selfhost/build/phase118/p120-combined-controls-run01/report.json']:
    checked(file); controls.append(pin(file))
primary_controls = []
for file in ['selfhost/build/phase120/combined-finite01.json',
             'selfhost/build/phase120/combined-word01/report.json',
             'selfhost/build/phase120/combined-shortcut01.json',
             'selfhost/build/phase118/p120-combined-controls-run01/report.json']:
    checked(file); primary_controls.append(pin(file))
stages = []
for name in ['word-stage13','word-stage18','word-ray-stage13','word-ray-stage18']:
    file = 'selfhost/build/phase120/'+name+'.json'; r = checked(file)
    rows = [x for x in r['rows'] if not x['warmup']]; assert len(rows)==3 and all(x['accepted'] for x in rows)
    stages.append(dict(name=name,receipt=pin(file), medians={k:statistics.median(x[k] for x in rows) for k in ['analysisSeconds','verifySeconds']}))
broadfile = 'selfhost/build/phase120/broad-analysis01.json'; broad = checked(broadfile)
focusedfile = 'selfhost/build/phase120/focused-summary01.json'; focused = checked(focusedfile)
candidate = dict(complete=True,experimental=True,installed=False,nativeQualified=False,
                 source=primary_source['source'],api=primary_api['api'],runtime=runtime,
                 sourceManifest=pin(primary_sm),checkedApi=pin(primary_ar),bridges=bridges,
                 controls=primary_controls,timing=pin(broadfile),compilerCost=costs['01']['receipt'],
                 recipe=pin('selfhost/tools/performance/phase120/candidate-recipe.json'),
                 unselectedPrefilter=dict(source=source['source'],api=api['api'],cost=costs['03']['receipt'],controls=controls,
                                          reason='Lower isolated analysis cost but no whole four-case cost win; preserve as an unselected experiment.'),
                 scope='Timed checked-hosted combined01 retained. Combined03 has exact45+6 QBE and runtime identity but remains unselected after the whole-cost screen. No native compiler image or installed promotion.')
save(a.out/'candidate.json',candidate)
save(a.out/'results.json',dict(complete=True,method=pin(__file__),candidate=candidate,
                              broad=broad,focused=focused,costs=costs,stages=stages,
                              sourceLines=dict(parent=primary_source['parentLines'],candidate=primary_source['physicalLines'],unselectedPrefilter=source['physicalLines']),
                              addedDeclarations=len(primary_source['added'])))
print(json.dumps(dict(complete=True,source=candidate['source']['sha256'],
                     runtimeRatio=broad['equalPoint']['candidateOverUpstream'],
                     finalHostedCostRatio=costs['01']['geometricCandidateOverParent'])))

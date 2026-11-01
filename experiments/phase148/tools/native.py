#!/usr/bin/env python3
"""Prepare one current/compact native unit harness from authenticated controls."""
import argparse,json
from pathlib import Path
from shared import ROOT,assembly,extract,guard,pin,require,verify,write_json,fresh_output,current_capture,literal,fields,sources

def main():
    p=argparse.ArgumentParser(description=__doc__)
    for name in ['preparation','controls','capture','out']:p.add_argument('--'+name,type=Path,required=True)
    p.add_argument('--family',required=True);a=p.parse_args()
    prepared=json.loads(a.preparation.read_text());controls=json.loads(a.controls.read_text());capture=current_capture(a.capture)
    require(prepared['kind']=='phase148-unit-api-preparation'and prepared['complete'],'Checked preparation required')
    require(controls['kind']=='phase148-unit-controls'and controls['complete']and controls['passed'],'Complete independent controls required')
    require(controls['source']==prepared['source'],'Controls/preparation source mismatch')
    source=verify(prepared['source']);api_report=json.loads(Path(prepared['acquisition']).read_text())
    require(api_report['complete']and api_report['checked']and api_report['api']==controls['api']and api_report['source']==prepared['source'],'Actual checked image/source mismatch')
    for row in controls['inputs']:verify(row)
    datum=next(row for row in capture['rows']if row['name']==a.family);packet=json.loads(verify(datum['data']).read_text())
    rows=[r for r in controls['rows']if r['kind']=='actual-scalar-render'and r['family']==a.family]
    require([r['index']for r in rows]==[r['index']for r in packet['direct']],'Complete selected direct family required')
    for row in rows:verify(row['old']);verify(row['candidate']);require(row['structureExact']and row['textExact']and row['passed'],'Failed function oracle')
    harness=Path(__file__).with_name('native-harness.bend');schema=fields(source.read_bytes()+harness.read_bytes())
    definitions=[('headers','List<&2,N111Segment>',packet['segments']),('constructors','List<&2,N_Constructor>',packet['constructors']),
       ('direct_headers','List<&2,P113DFunction>',packet['directHeaders']),
       ('selected','List<&2,P148HSelected>',[{'$':'P148HSelected','index':r['index'],'function':r['function']}for r in packet['direct']])]
    fixture='\n'.join('def p148h_'+name+'() -> '+typ+':\n  '+literal(value,schema)+'\n'for name,typ,value in definitions).encode()
    canonical_parts,canonical_inputs,canonical_identity=sources([]);canonical=canonical_parts[0][1]
    require(canonical_identity==prepared['canonicalSourceIdentity'],'Current canonical moved from checked preparation')
    _,have=assembly.blocks(source.read_bytes());names={r['name']for r in have};_,original=assembly.blocks(canonical)
    extra=b''.join(r['data']for r in original if r['name']not in names and r['name']!='main')
    body,declarations=extract([('checked-api',source.read_bytes()),('canonical-extra',extra),('fixture',fixture),('harness',harness.read_bytes())],['main'],1_500_000)
    out=fresh_output(a.out,ROOT);(out/'compiler.bend').write_bytes(body);(out/'fixture.bend').write_bytes(fixture)
    (out/'expected.stdout').write_bytes(b''.join(verify(row['old']).read_bytes()for row in rows))
    write_json(out/'exports.json',dict(kind='bend-hosted-api-exports',version=1,exports=['p148h_text'],protocol='hosted-api-v1',targets=['qbe'],
        preparationModes=['live'],scope='Check complete harness book including IO main; private text helper export only.'))
    checked=out/'checked-api'
    check=guard('phase148-harness-check-'+a.family,checked,[ROOT/'selfhost/.assets/bin/bun',ROOT/'selfhost/tools/build/hosted.mjs','acquire',
        '--source',out/'compiler.bend','--exports',out/'exports.json','--upstream',ROOT/'selfhost/.bootstrap/upstream-phase66',
        '--engine',ROOT/'selfhost/.assets/bin/bun','--out',checked],90,3072,128)
    native=out/'native';command=['python3','-B',ROOT/'selfhost/tools/build/native.py','--assets',ROOT/'selfhost/manifests/assets-native.json',
       '--host','native','--stage','N2','--target','qbe','--mode','cache','--image',ROOT/'selfhost/build/phase147/integrated-sequel02/n2/program',
       '--image-receipt',ROOT/'implementation/phase147/candidate.json','--source',out/'compiler.bend','--out',native,'--retain-ir','--seconds','150']
    jobs=[check,guard('phase148-dual-mode-'+a.family,native,command,180,2048,256)]
    timing=guard('phase148-unit-timing-'+a.family,out/'timing',['python3','-B',Path(__file__).with_name('time-native.py'),
        '--manifest',out/'manifest.json','--out',out/'timing','--budget-seconds','45'],60,2048,64)
    result=dict(kind='phase148-native-unit-preparation',version=1,complete=True,targetsRun=False,
       inputs=[pin(__file__),pin(Path(__file__).with_name('shared.py')),pin(harness),pin(a.preparation),pin(a.controls),pin(a.capture),datum['data'],prepared['source'],controls['api'],*canonical_inputs],
       source=pin(out/'compiler.bend'),fixture=pin(out/'fixture.bend'),oracle=pin(out/'expected.stdout'),family=a.family,
       functions=len(rows),declarations=declarations,binary=str(native/'program'),buildReport=str(native/'report.json'),harnessCheckReport=str(checked/'report.json'),jobs=jobs,
       contextLifetime='All original headers/IDs/ordered ready contexts prepared once per process before repetitions; startup and final cleanup remain in headline time.',
       region='Old:scalar+admission+independent final check+render+write+cleanup. New:pack+compact scalar+compact admission+unpack+same final check+render+write+cleanup. No decoded handoff between compact consumers.',
       argv=['--threads','1','--gpu','off','--','compact-unit','old|new|transport|old-analysis|new-analysis','oracle|bench','COUNT'],
       ablationModes=dict(analysis='Skip rendering only; both checks, cleanup and empty File.write remain. Analysis modes reject oracle requests.',
           transport='Fresh pack/unpack followed by original scalar/admission/final-check/render; full output must equal the original oracle.'))
    write_json(out/'manifest.json',result);write_json(out/'jobs.json',jobs)
    write_json(out/'timing-job.json',timing)
    print(json.dumps(dict(source=result['source'],family=a.family,functions=len(rows),jobs=str(out/'jobs.json'))))

if __name__=='__main__':main()

#!/usr/bin/env python3
"""Root-run narrow API controls for observer planning only; serial guards, no Clang."""
import argparse
import importlib.util
import json
from pathlib import Path
import subprocess
import sys

HERE = Path(__file__).resolve().parent
spec = importlib.util.spec_from_file_location('permission_qualifier_v5', HERE / 'qualify-v5.py')
Q = importlib.util.module_from_spec(spec)
spec.loader.exec_module(Q)
ROOT, BUILD, pin = Q.ROOT, Q.BUILD, Q.pin


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--out', type=Path, required=True)
    p.add_argument('--candidate', type=Path, default=BUILD / 'observer-cost-sources01/both/changes.json')
    p.add_argument('--prepare-only', action='store_true')
    args = p.parse_args()
    out = args.out.resolve()
    assert out.is_relative_to(BUILD) and not out.exists()
    out.mkdir(parents=True)
    inputs = {}
    report = dict(kind='phase98-observer-cost-controls', complete=False, targetsRun=False, rows=[])
    def bind(path):
        row = pin(path)
        assert inputs.setdefault(row['file'], row) == row
        return row
    def verify(value):
        if isinstance(value, dict):
            if {'file', 'bytes', 'sha256'} <= value.keys():
                assert bind(value['file']) == value
            else:
                for child in value.values(): verify(child)
        elif isinstance(value, list):
            for child in value: verify(child)
    def save():
        report['inputs'] = list(inputs.values())
        Q.save(out / 'report.json', report)
    try:
        recipe = Q.read(args.candidate)
        verify(recipe)
        assert recipe['parentSource']['sha256'] == '59b36a1ca3f7843ff7a03628cd39ed0f530ed137c4825d508a274a8e1ede2714'
        assert recipe['candidate']['sha256'] == 'a0254c279cab150aeb5c5e9084e1520ae2c1f8ec4ef9bdd96189eb3364e7d5a5'
        replay = Path(recipe['source']['file']).read_text()
        for change in recipe['changes']:
            at = change['offset']
            assert replay[at:at + len(change['old'])] == change['old']
            replay = replay[:at] + change['new'] + replay[at + len(change['old']):]
        assert replay == Path(recipe['candidate']['file']).read_text()
        node = Path('/home/ai/.nvm/versions/node/v24.18.0/bin/node')
        for path in [__file__, HERE/'qualify-v5.py', HERE/'cost-controls.mjs', HERE/'source-audit.json',
                     Q.STAGE0, Q.GUARD, node, ROOT/'selfhost/tools/typed-driver.mjs', ROOT/'selfhost/dist/typed-api.mjs']:
            bind(path)
        audit = Q.read(HERE/'source-audit.json'); verify(audit)
        upstream = Q.read(ROOT/'selfhost/build/phase86/upstream.json'); verify(upstream)
        assert upstream['revision'] == '059266225b77c8ca256ac6b25ee5c21449bab151'
        bind(ROOT/'selfhost/build/phase86/upstream.json')
        plan = dict(kind='phase98-observer-cost-inputs', recipe=bind(args.candidate), audit=bind(HERE/'source-audit.json'),
                    sources={'baseline':recipe['parentSource'], 'candidate':recipe['candidate']},
                    apis={role:str(out/(role+'.mjs')) for role in ['baseline','candidate']},
                    controls=[
                        dict(id='real-io',source=bind(HERE.parent/'comparison/held-io-smoke01.bend'),
                             schemaNames=['p98_eq_walk','p98_eq_finish','p98_string_eq','p98_io_probe','main']),
                        dict(id='generic-array',source=bind(HERE/'generic-array-string-v2.bend'),
                             schemaNames=['p98_array_string_walk','p98_array_string_observe','p98_array_string_read','main']),
                        dict(id='schema-refusals',source=bind(HERE/'schema-refusals.bend'),
                             schemaNames=['p98_array_probe','p98_word_view','p98_array_answer','p98_word_answer','main'])],
                    scope='Planning only: full worker/schema data and complete C/diagnostics on identical inputs. No native execution, timing claim or whole-compiler proof.')
        Q.save(out/'plan.json',plan); bind(out/'plan.json')
        exports=['nc_compile_checked','no_scalar_redirect','no_schema','nol_scalar_specs','lookup','kt','dk']
        commands=[]
        for role in ['baseline','candidate']:
            commands.append(dict(name='api-'+role, seconds=120, rss=4096, available=16384,
                argv=['env','BEND_UPSTREAM='+str(Q.UPSTREAM), str(node),'--stack-size=65536','--max-old-space-size=3072',
                      str(Q.STAGE0),plan['sources'][role]['file'],plan['apis'][role],*exports,
                      *(['no_schema_cached'] if role=='candidate' else [])]))
        commands.append(dict(name='controls',seconds=180,rss=4096,available=16384,
            argv=[str(node),'--stack-size=16384','--max-old-space-size=3072',str(HERE/'cost-controls.mjs'),str(out/'plan.json'),str(out/'values')]))
        Q.save(out/'commands.json',commands)
        report.update(plan=bind(out/'plan.json'),commands=commands,scope=plan['scope']);save()
        if args.prepare_only:
            report.update(complete=True,preparedOnly=True);save();return
        for command in commands:
            folder=out/(command['name']+'-guard')
            argv=[sys.executable,'-B',str(Q.GUARD),'--out',str(folder),'--seconds',str(command['seconds']),
                  '--rss-mib',str(command['rss']),'--available-mib',str(command['available']),'--cpu','3','--',*command['argv']]
            report['targetsRun']=True;save()
            job=subprocess.run(argv,cwd=ROOT,capture_output=True,text=True)
            (out/(command['name']+'.stdout')).write_text(job.stdout)
            (out/(command['name']+'.stderr')).write_text(job.stderr)
            row=dict(name=command['name'],launcherExit=job.returncode,guard=bind(folder/'process.json'))
            process=Q.read(folder/'process.json');row['process']=process;report['rows'].append(row);save()
            assert job.returncode==0 and process['complete'] and process['returncode']==0 and not process.get('stoppedFor'),command['name']
        controls=Q.read(out/'values/report.json');assert controls['complete']
        verify(controls);report['controls']=bind(out/'values/report.json')
        for row in inputs.values():assert pin(row['file'])==row
        report.update(complete=True,inputsUnchanged=True)
    except BaseException as error:
        report['error']=repr(error);raise
    finally:save()


if __name__=='__main__':main()

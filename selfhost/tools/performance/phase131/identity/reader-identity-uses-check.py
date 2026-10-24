"""Independent nq_uses output/count screen; no timing conclusion or promotion."""
import argparse
import importlib.util
import json
import os
from pathlib import Path
import subprocess

ROOT=Path(__file__).resolve().parents[5]
spec=importlib.util.spec_from_file_location('probe',Path(__file__).with_name('reader-identity-probe.py'))
probe=importlib.util.module_from_spec(spec);spec.loader.exec_module(probe)
pin=probe.pin

def main():
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument('--probe',type=Path,required=True);p.add_argument('--out',type=Path,required=True)
    a=p.parse_args();assert sorted(os.sched_getaffinity(0))==[5]
    out=a.out.resolve();assert not out.exists() and out.is_relative_to(ROOT/'selfhost/build/phase131')
    config=json.loads(a.probe.read_text());assert config['complete'] and config['exactN2ReaderMatch']
    builder=ROOT/'selfhost/build/phase111/p131-read-lookup01-identity-candidate-build/method.py'
    runtime=ROOT/'selfhost/build/phase128/runtime-borrow01/runtime.o'
    original=ROOT/'selfhost/build/phase111/p131-regions-uses01-candidate-build/program'
    expected=ROOT/'selfhost/tools/performance/phase131/regions/compiler-uses.expected.stdout'
    source=ROOT/'selfhost/tools/performance/phase131/regions/compiler-uses.bend'
    inputs=[pin(Path(__file__)),pin(a.probe),pin(builder),pin(runtime),pin(original),pin(expected),pin(source)]
    inputs+=config['inputs']+[config['diagnostic'],config['ceiling']]
    for row in inputs:assert pin(Path(row['file']))==row
    assert expected.read_text()=='2\n0\n1\n2\n1\n0\n1\n1\n0\n0\n'
    out.mkdir();r=dict(complete=False,inputs=inputs,builds=[],observations=[],productionChange=False,
        scope='QBE-only hypothesis with independent nq_uses controls; no runtime timings reported.')
    def save():(out/'report.json').write_text(json.dumps(r,indent=2)+'\n')
    save()
    try:
        binaries={'original':original}
        for variant in ['diagnostic','ceiling']:
            build=ROOT/'selfhost/build/phase111'/('p131-reader-identity-uses-'+variant+'01')
            cmd=['python3',str(builder),'--source',config[variant]['file'],'--runtime',str(runtime),'--out',str(build),'--seconds','20']
            child=subprocess.run(cmd,capture_output=True,timeout=30)
            (out/(variant+'-build.stdout')).write_bytes(child.stdout);(out/(variant+'-build.stderr')).write_bytes(child.stderr)
            assert child.returncode==0,child.stderr.decode()
            receipt=json.loads((build/'report.json').read_text());assert receipt['complete']
            r['builds'].append(pin(build/'report.json'));binaries[variant]=Path(receipt['binary']['file']);save()
        for case,args in [('ordinary',[]),('repeated',['--','10'])]:
            for variant,binary in binaries.items():
                cmd=[str(binary),'--threads','1','--gpu','off',*args]
                child=subprocess.run(cmd,capture_output=True,timeout=10)
                row=dict(case=case,variant=variant,command=cmd,exitCode=child.returncode,
                         stdout=child.stdout.decode(),stderr=child.stderr.decode())
                r['observations'].append(row);save();assert child.returncode==0 and not child.stderr
                lines=child.stdout.decode().splitlines(keepends=True)
                if variant=='diagnostic':
                    fields=lines.pop().split();assert len(fields)==4 and fields[0]=='p131-identity'
                    calls,iterations,hits=map(int,fields[1:]);assert 0<=calls<=iterations and 0<=hits<=iterations
                    row['counts']=dict(calls=calls,iterations=iterations,identicalTrueSteps=hits,fraction=hits/iterations if iterations else None)
                if case=='ordinary':assert ''.join(lines)==expected.read_text()
                else:
                    # Exact source tree has16+ occurrences of7, no8; saturated
                    # use-count is2, therefore10 repetitions sum to20.
                    assert len(lines)==3 and lines[:2]==['2\n','20\n']
                    assert lines[2].endswith('\n') and lines[2].strip().isdigit()
                row['independentOutputExact']=True;save()
        for row in inputs:assert pin(Path(row['file']))==row
        r['complete']=True;save();print(json.dumps(dict(complete=True,counts=[x['counts'] for x in r['observations'] if 'counts'in x])))
    except BaseException as e:r['error']=repr(e);save();raise

if __name__=='__main__':main()

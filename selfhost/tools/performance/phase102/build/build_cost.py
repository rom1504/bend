#!/usr/bin/env python3
"""Root-only guarded Clang comparison: complete builds and explicit PCH costs."""
import argparse
import importlib.util
import json
from pathlib import Path
import statistics
import sys
import time
sys.dont_write_bytecode = True
ROOT = Path(__file__).resolve().parents[5]
sys.path.insert(0, str(ROOT / 'selfhost/tools/performance/phase100'))
import run as R
import compact_ids as C
ACQ = {'source-index':'source-acquire01','image-render':'image-acquire01','dependency-plan':'dependency-acquire02'}


def main():
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument('--out', type=Path, required=True)
    p.add_argument('--apps', default=','.join(ACQ))
    p.add_argument('--rounds', type=int, default=3)
    p.add_argument('--fixtures', type=Path, nargs='+', required=True)
    p.add_argument('--cases', default='')
    a=p.parse_args();assert 1<=a.rounds<=6
    out=a.out.resolve();assert out.is_relative_to(ROOT/'selfhost/build/phase102')
    out.mkdir(parents=True,exist_ok=False)
    report=dict(kind='phase102-complete-build-and-prefix-pch',complete=False,started=time.time(),
                scope='CPU saved-C builds; PCH serializes AST, not runtime machine code. Clean total includes preparation. No source emission or compiler-image timing.',
                methods=[R.pin(__file__),R.pin(C.__file__),R.pin(R.__file__),
                         R.pin(R.PERF/'phase86/guard.py'),R.pin(R.PERF/'phase46/execute.py')],inputs=[],apps={},checks=[])
    def save():R.save(out/'report.json',report)
    save()
    try:
        cases={}
        for f in a.fixtures:
            report['inputs'].append(R.pin(f));v=R.read(f)
            assert v['complete'] and all(x['passed'] for x in v['records'])
            for case in v['cases']:
                if case['app'] not in a.apps.split(',') or (a.cases and case['id'] not in a.cases.split(',')):continue
                key=(case['app'],case['id'])
                if key in cases:assert cases[key]['expected']==case['expected']
                cases[key]=case
        assert cases
        if a.cases:assert set(a.cases.split(','))=={c['id'] for c in cases.values()}
        for app in a.apps.split(','):
            acq=ROOT/'selfhost/build/phase100'/ACQ[app]/'report.json';v=R.read(acq);assert v['complete']
            original=next(x for x in v['apps'] if x['id']==app)['products']['b2']['c']
            clang=v['context']['clang'];R.verify(original);R.verify(clang)
            report['inputs'] += [R.pin(acq),original,clang]
            source=Path(original['file']).read_text();compact,counts=C.transform(source)
            marker='// Tables\n// ======\n';assert source.count(marker)==1
            index=source.index(marker);prefix=source[:index];suffix=source[index:]
            assert prefix+suffix==source and '__LINE__' not in source
            folder=out/app;folder.mkdir();h=folder/'prefix.h';h.write_text(prefix)
            tail=folder/'suffix.c';tail.write_text(suffix);cc=folder/'compact.c';cc.write_text(compact)
            row=dict(source=original,compact=R.pin(cc),prefix=R.pin(h),suffix=R.pin(tail),renaming=counts,
                     prefixBytes=len(prefix.encode()),suffixBytes=len(suffix.encode()),rounds=[])
            report['apps'][app]=row;save()
            common=[clang['file'],'-isystem',str(Path(clang['file']).parents[1]/'include/clang'),'-std=c11','-O3']
            for rnd in range(a.rounds):
                d=folder/f'round{rnd}';d.mkdir();trial=dict(round=rnd,builds={});row['rounds'].append(trial);save()
                modes=['baseline','compact','pch'];modes=modes[rnd%3:]+modes[:rnd%3]
                for mode in modes:
                    binary=d/(mode+'.program')
                    if mode=='pch':
                        cache=d/'prefix.pch'
                        prep,_=R.guarded(d/'pch-prepare',common+['-x','c-header',h,'-o',cache])
                        trial['pchPreparation']=prep;trial['pch']=R.pin(cache);save()
                        args=common+['-include-pch',cache,tail,'-o',binary,'-lpthread','-lm']
                    else:args=common+[original['file'] if mode=='baseline' else cc,'-o',binary,'-lpthread','-lm']
                    job,_=R.guarded(d/(mode+'-build'),args)
                    trial['builds'][mode]=dict(job=job,binary=R.pin(binary));save()
                    for case in (c for c in cases.values() if c['app']==app):
                        for item in [case['expected'],*case['inputs']]:R.verify(item)
                        where=d/(mode+'-'+case['id']);entry=dict(app=app,round=rnd,mode=mode,case=case['id'],passed=False)
                        report['checks'].append(entry);save()
                        entry['job'],child=R.guarded(where,[binary,'--threads','1','--gpu','off','--',*case['argv']],seconds=30)
                        entry['passed']=(where/'stdout.log').read_bytes()==Path(case['expected']['file']).read_bytes() and not child['stderr']
                        save();assert entry['passed'],where
                trial['pchCleanTotalSeconds']=trial['pchPreparation']['seconds']+trial['builds']['pch']['job']['seconds']
                save()
            med={mode:statistics.median(t['builds'][mode]['job']['seconds'] for t in row['rounds']) for mode in ['baseline','compact','pch']}
            row['summary']=dict(medians=med,compactOverBaseline=med['compact']/med['baseline'],
               warmPchOverBaseline=med['pch']/med['baseline'],
               cleanPchMedianSeconds=statistics.median(t['pchCleanTotalSeconds'] for t in row['rounds']),
               preparationMedianSeconds=statistics.median(t['pchPreparation']['seconds'] for t in row['rounds']))
            print(json.dumps(dict(app=app,summary=row['summary'])),flush=True);save()
        for item in report['methods']+report['inputs']:R.verify(item)
        report['complete']=True
    except BaseException as error:
        report['error']=repr(error);raise
    finally:report['finished']=time.time();save()


if __name__=='__main__':main()

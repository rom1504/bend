#!/usr/bin/env python3
"""Fresh, guarded diagnostics of compiler23/upstream saved native programs."""
import argparse
import importlib.util
import json
import re
import sys
import time
from pathlib import Path

sys.dont_write_bytecode = True
ROOT = Path(__file__).resolve().parents[5]
HERE = Path(__file__).resolve().parent

def module(name, path):
    spec = importlib.util.spec_from_file_location(name, path)
    obj = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(obj)
    return obj

S = module('survey_support', ROOT/'selfhost/tools/performance/programs/support.py')
N = module('survey_counts', HERE.parent/'profiles/native-counts.py')
O = module('survey_oracle', ROOT/'selfhost/tools/performance/phase46/oracle.py')
read = lambda p: json.loads(Path(p).read_text())

def products():
    paths = [
        ('selfhost', 'phase68/native-facts23-lexer'),
        ('selfhost', 'phase68/native-facts23-rest'),
        ('upstream', 'phase67/native-baseline02'),
        ('upstream', 'phase67/native-heldout-baseline02'),
    ]
    result, pins = {}, [S.identity(__file__), S.identity(HERE.parent/'profiles/native-counts.py'),
        S.identity(ROOT/'selfhost/tools/performance/programs/support.py'),
        S.identity(ROOT/'selfhost/tools/performance/phase46/oracle.py'),
        S.identity(ROOT/'selfhost/tools/performance/phase46/cases.json')]
    pins.extend(S.identity(p) for p in O.ORACLE_FILES)
    for role, folder in paths:
        path = ROOT/'selfhost/build'/folder/'report.json'
        acquired = read(path)
        assert acquired['complete']
        recipe = read(acquired['recipe']['path'])
        assert recipe['upstreamCommit'] == '059266225b77c8ca256ac6b25ee5c21449bab151'
        pins += [S.identity(path), acquired['recipe']]
        toolroot = str(Path(recipe['clang']).parent.parent)+'/'
        pins += [x for x in recipe['inputs'] if x['path'].startswith(toolroot)
                 or Path(x['path']).name in ('ld','ld.bfd','x86_64-linux-gnu-ld.bfd')]
        if role == 'selfhost':
            pins.append(next(x for x in recipe['inputs'] if x['path'] == recipe['api']))
        for row in acquired['records']:
            if row['role'] != role:
                continue
            assert row['correct']
            emission = read(row['emissionReceipt']['path'])
            assert emission['complete'] and emission['output'] == row['nativeSource']
            assert emission['observation']['checked'] and emission['observation']['status'] == 'ok'
            key = (row['case'], role)
            assert key not in result
            result[key] = dict(row, recipe=recipe)
            pins += [row[k] for k in ('source','nativeSource','executable','emissionReceipt')]
    for case in ('numeric','array','tree','lexer','closures','map'):
        a,b = result[(case,'selfhost')], result[(case,'upstream')]
        assert a['source'] == b['source']
        for key in ('clang','clangArgs','linkArgs','cpu','compilerEnvironment'):
            assert a['recipe'][key] == b['recipe'][key], key
    pins = list({p['path']:p for p in pins}.values())
    verify(pins)
    return result, pins

def verify(pins):
    for pin in pins:
        assert S.identity(pin['path']) == pin, pin['path']

def site_counts(code):
    """Count allocator call sites, including runtime helpers, not caller stacks."""
    assert 'ps23_' not in code
    matches = list(re.finditer(r'\bheap_alloc\(e,', code))
    sites = []
    for i, m in enumerate(matches):
        line = code.count('\n',0,m.start())+1
        start,end = code.rfind('\n',0,m.start())+1,code.find('\n',m.start())
        text = code[start:end]
        assert not text.lstrip().startswith(('//','*')), text
        sites.append(dict(index=i,sourceLine=line,text=text.strip()))
    for i,m in reversed(list(enumerate(matches))):
        code = code[:m.start()]+f'PS23_ALLOC({i},e,'+code[m.end():]
    support = '''
/* Diagnostic allocation-site counts; never use this executable for timings. */
static unsigned long long ps23_sites[%d];
#define PS23_ALLOC(i,e,c) (__atomic_fetch_add(&ps23_sites[i],1ull,__ATOMIC_RELAXED),heap_alloc((e),(c)))
static void ps23_report(void) {
  fputs("{\\"kind\\":\\"phase68-allocation-sites\\",\\"sites\\":[",stderr);
  for (unsigned i=0;i<sizeof(ps23_sites)/sizeof(*ps23_sites);i++)
    fprintf(stderr,"%%s%%llu",i?",":"",__atomic_load_n(&ps23_sites[i],__ATOMIC_RELAXED));
  fputs("]}\\n",stderr);
}
''' % len(sites)
    anchor = re.findall(r'^OUTLINE (?:Loc|u64) heap_alloc_miss\(Env e, (?:Cls|u32) cls\) \{$',code,re.M)
    assert len(anchor)==1
    code = code.replace(anchor[0],support+anchor[0],1)
    anchor = 'int main(int argc, char** argv) {'
    assert code.count(anchor)==1
    code = code.replace(anchor,anchor+'\n  if (atexit(ps23_report)) return 125;',1)
    return code,sites

def observed(dest, process, case, count, warm=0):
    catalog = {c['name']:c for c in read(ROOT/'selfhost/tools/performance/phase46/cases.json')}
    expected = [catalog[case]['expected'],O.digest(O.points(catalog[case]),warm),O.digest(O.points(catalog[case]),count)]
    words = (dest/'stdout.log').read_text().strip().splitlines()
    return dict(expected=expected,stdout=words,correct=bool(process['complete'] and len(words)==4
        and all(w.isdecimal() for w in words) and list(map(int,words[:3]))==expected))

def main():
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument('--out',type=Path,required=True)
    p.add_argument('--cases',default='tree,lexer,closures,map')
    p.add_argument('--mode',choices=['counts','debug'],default='counts')
    a=p.parse_args()
    names=a.cases.split(',')
    assert set(names)<= {'numeric','array','tree','lexer','closures','map'}
    out=a.out.resolve()
    assert out.is_relative_to(ROOT/'selfhost/build/phase68')
    out.mkdir(parents=True,exist_ok=False)
    data,pins=products()
    jobs=[dict(case=c,role=r,source=data[(c,r)]['nativeSource'],originalExecutable=data[(c,r)]['executable'])
          for c in names for r in ('selfhost','upstream')]
    S.save(out/'plan.json',dict(inputs=pins,mode=a.mode,jobs=jobs,diagnosticOnly=True))
    report=dict(complete=False,started=time.time(),plan=S.identity(out/'plan.json'),records=[])
    try:
        with S.ExecutionGuard(rss_mib=2048,available_mib=4096) as guard:
            def run(cmd,dest,seconds=90,env=None):
                return guard.run(['taskset','-c','3',*map(str,cmd)],dest,time.monotonic()+seconds,env=env)
            report['perfProbe']=run(['perf','stat','-e','task-clock','--','true'],out/'perf-capability',10)
            report['perfParanoid']=Path('/proc/sys/kernel/perf_event_paranoid').read_text().strip()
            for job in jobs:
                case,role=job['case'],job['role']
                dest=out/(case+'-'+role);dest.mkdir()
                recipe=data[(case,role)]['recipe']
                source=Path(job['source']['path'])
                item=dict(job=job,runs=[])
                report['records'].append(item)
                if a.mode=='counts':
                    code,sites=site_counts(source.read_text())
                    code,segments=N.instrument(code)
                    source=dest/'program.c';source.write_text(code)
                    item.update(source=S.identity(source),sites=sites,segments=segments)
                exe=dest/'program'
                item['build']=run([recipe['clang'],*recipe['clangArgs'],*(['-g'] if a.mode=='debug' else []),source,*recipe['linkArgs'],'-o',exe],dest/'build')
                S.save(out/'report.json',report)
                assert item['build']['complete'],(case,role,'build')
                item['executable']=S.identity(exe)
                for n in ([1,17] if a.mode=='counts' else [1]):
                    d=dest/('run-'+str(n))
                    proc=run([exe,'--threads','1','--gpu','off','--',n,0],d,30)
                    obs=observed(d,proc,case,n)
                    row=dict(repetitions=n,process=proc,**obs)
                    item['runs'].append(row)
                    assert obs['correct'],(case,role,n)
                    if a.mode=='counts':
                        logs=[json.loads(s) for s in (d/'stderr.log').read_text().splitlines()]
                        assert len(logs)==2
                        row['counts']=next(x for x in logs if x['kind']=='phase68-native-counts')
                        row['allocationSites']=next(x for x in logs if x['kind']=='phase68-allocation-sites')['sites']
                        assert row['counts']['invalidClassCalls']==0
                if a.mode=='debug':
                    item['textExtractions']=[]
                    for label,binary in [('original',job['originalExecutable']['path']),('debug',exe)]:
                        sec=dest/(label+'.text')
                        result=run(['objcopy','--dump-section','.text='+str(sec),binary,dest/(label+'-section-copy.elf')],dest/('text-'+label),10)
                        assert result['complete']
                        item['textExtractions'].append(dict(process=result,section=S.identity(sec)))
                    item['textIdentical']=item['textExtractions'][0]['section']['sha256']==item['textExtractions'][1]['section']['sha256']
                    assert item['textIdentical'],(case,role,'debug text differs')
                item['complete']=True
                S.save(out/'report.json',report)
                print(json.dumps(dict(case=case,role=role,mode=a.mode,complete=True)),flush=True)
        verify(pins)
        report['complete']=True
    except BaseException as error:
        report['error']=repr(error)
        raise
    finally:
        report['finished']=time.time()
        S.save(out/'report.json',report)

if __name__=='__main__':
    main()

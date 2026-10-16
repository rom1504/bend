#!/usr/bin/env python3
"""Full-output controls for actual Bend-produced C, with reusable reference products."""
import argparse
from pathlib import Path
import sys
import time
sys.dont_write_bytecode = True
ROOT = Path(__file__).resolve().parents[4]
sys.path.insert(0, str(ROOT/'selfhost/tools/performance/phase100'))
import run as R
G = R.module("phase102_control_guard", Path(__file__).with_name("guarded.py"))
R.guarded = G.guarded


def execute(folder, argv, cpu, expected_exit):
    try: job, child = R.guarded(folder, argv, seconds=30, cpu=cpu)
    except AssertionError:
        if expected_exit == 0: raise
        job = R.read(folder.parent/(folder.name+'-job.json'))
        child = R.read(folder/'child.json')
        assert expected_exit != 0 and child['returncode'] == expected_exit
        assert job['process']['returncode'] == expected_exit and not job['process'].get('stoppedFor')
    assert child['returncode'] == expected_exit
    return job, child


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--emission', type=Path, required=True)
    p.add_argument('--manifest', type=Path, required=True)
    p.add_argument('--reuse', type=Path, nargs='*', default=[])
    p.add_argument('--out', type=Path, required=True)
    a = p.parse_args(); out = a.out.resolve(); out.mkdir(parents=True, exist_ok=False)
    emission = R.read(a.emission); assert emission['complete']
    manifest = R.read(a.manifest)
    previous = [R.read(file) for file in a.reuse]
    report = dict(complete=False, started=time.time(), method=R.pin(__file__),
        emission=R.pin(a.emission), manifest=R.pin(a.manifest), products={}, executions=[],
        reusedReports=[R.pin(file) for file in a.reuse],
        inputs=[R.pin(G.__file__),R.pin(Path(__file__).with_name('guard-long-args.py'))],
        reuseScope='Only authenticated complete products reused; incomplete prior controls remain incomplete.')
    (out/'snapshot-check-emitted.py').write_bytes(Path(__file__).read_bytes())
    def save(): R.save(out/'report.json', report)
    save()
    try:
        release, context = R.authenticate(); report['context'] = context
        for item in manifest.get('pins', []):
            actual = R.pin(item.get('file', item.get('path')))
            assert all(actual[k] == item[k] for k in ('sha256','bytes')); report['inputs'].append(actual)
        for source in dict.fromkeys(c['source'] for c in manifest['records']):
            produced = [r for r in emission['programs'] if r['source']['file'] == str(Path(source).resolve())]
            assert len(produced) == 1; produced = produced[0]
            R.verify(produced['source']); R.verify(produced['c']); R.verify(produced['receipt'])
            folder = out/Path(source).stem; folder.mkdir()
            row = dict(source=R.pin(source), variants={}, emissionReceipt=produced['receipt'])
            report['products'][source] = row; save()
            old = next((r['products'][source] for r in reversed(previous) if source in r.get('products', {})
                and all('binary' in r['products'][source]['variants'].get(k,{}) for k in ('baseline','upstream'))), None)
            if old:
                assert old['source'] == row['source']
                baseline = old['variants']['baseline']; upstream = old['variants']['upstream']
                row['upstreamAdmission'] = old['upstreamAdmission']; R.verify(row['upstreamAdmission'])
            else:
                prefix = folder/'upstream'; base = folder/'baseline'
                R.guarded(folder/'admit', [context['bun']['file'],R.PERF/'phase86/reference.mjs','typescript',source,prefix,'1'])
                admitted = R.read(str(prefix)+'.json')
                assert admitted['complete'] and admitted['calls'][0]['observation'] == dict(status='ok',checked=True)
                row['upstreamAdmission'] = R.pin(str(prefix)+'.json')
                R.guarded(folder/'emit-baseline', R.NATIVE.native_args(release,source,base,stage='b2'))
                baseline = dict(c=R.pin(str(base)+'.1.c')); upstream = dict(c=R.pin(str(prefix)+'.1.c'))
            for role, product in [('baseline',baseline),('candidate',dict(c=produced['c'])),('upstream',upstream)]:
                R.verify(product['c'])
                if role == 'candidate' and old and old['variants'].get('candidate',{}).get('c') == produced['c']:
                    cached = old['variants']['candidate']
                    if 'binary' in cached: product = cached
                if 'binary' in product: R.verify(product['binary'])
                else:
                    cc = context['clang']['file']; binary = folder/(role+'.program')
                    product['build'], _ = R.guarded(folder/(role+'-build'), [cc,'-isystem',
                        Path(cc).parents[1]/'include/clang','-std=c11','-O3',product['c']['file'],'-o',binary,'-lpthread','-lm'])
                    product['binary'] = R.pin(binary)
                row['variants'][role] = product; save()
            for case in (c for c in manifest['records'] if c['source'] == source):
                if case.get('requireBaselineCIdentity'):
                    assert baseline['c']['sha256'] == produced['c']['sha256']
                code = Path(produced['c']['file']).read_text()
                for name in case.get('requireTRMC', []):
                    symbol = 'NF_FID_' + ''.join(str(ord(c))+'_' for c in name) + '_trmc'
                    assert symbol in code, ('TRMC must activate', name)
                for name in case.get('forbidTRMC', []):
                    symbol = 'NF_FID_' + ''.join(str(ord(c))+'_' for c in name) + '_trmc'
                    assert symbol not in code, ('TRMC must refuse', name)
                expected = Path(case['expected']).read_bytes() if 'expected' in case else case.get('stdout','').encode()
                stderr = case.get('stderr','').encode(); exit_code = case.get('returncode',0)
                for workers in case.get('workers',[1]):
                    for role in ('baseline','candidate','upstream'):
                        folder2 = out/f'{case["id"]}-t{workers}-{role}'
                        rec = dict(case=case['id'],workers=workers,role=role,passed=False)
                        report['executions'].append(rec); save()
                        rec['job'], child = execute(folder2,[row['variants'][role]['binary']['file'],
                            '--threads',str(workers),'--gpu','off','--',*case.get('argv',[])],
                            {1:'3',2:'2,3',4:'0,1,2,3'}[workers],exit_code)
                        rec['passed'] = (folder2/'stdout.log').read_bytes() == expected and (folder2/'stderr.log').read_bytes() == stderr
                        rec['returncode'] = child['returncode']; save(); assert rec['passed'], folder2
                print(R.json.dumps(dict(case=case['id'],passed=True)),flush=True)
        for item in [report['method'],report['manifest'],report['emission'],*report['inputs'],*report['reusedReports']]: R.verify(item)
        report['complete'] = True
    except BaseException as error:
        report['error'] = repr(error); raise
    finally: report['finished'] = time.time(); save()


if __name__ == '__main__': main()

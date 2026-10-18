#!/usr/bin/env python3
"""Serial cache controls; root supplies one external CPU3/resource guard."""
import argparse, hashlib, json, os, shutil, statistics, subprocess, sys, time
from pathlib import Path
sys.dont_write_bytecode = True
HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[3]
MASK = 2**32 - 1
MIX = 'function_f_109_105_120'
EDGES = [(0,0),(1,7),(7,1),(19,23),(2**31,1),(MASK,MASK),(MASK,0),(0,MASK),(MASK,7),(2**31-1,2**31)]

def pin(file):
    file = Path(file).resolve(strict=True)
    return dict(file=str(file), bytes=file.stat().st_size, sha256=hashlib.sha256(file.read_bytes()).hexdigest())

def answer(n, seed, multiplier):
    first = ((n * multiplier + 1013904223) & MASK) ^ seed
    return ((first * multiplier + 1013904223) & MASK) ^ ((seed + 7) & MASK)

def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--api', type=Path, required=True); p.add_argument('--out', type=Path, required=True)
    p.add_argument('--source', type=Path, default=HERE/'cases/arithmetic.bend')
    p.add_argument('--bun', type=Path, default=ROOT/'selfhost/.bootstrap/bun-1.4.3/bun')
    p.add_argument('--qbe', type=Path, default=ROOT/'selfhost/build/phase107/toolchain/qbe-1.3/qbe')
    p.add_argument('--whole-object', action='store_true', help='Also compare optimized whole-object cold/warm and runtime')
    p.add_argument('--repeat', type=int, default=10000000); p.add_argument('--rounds', type=int, default=3)
    a = p.parse_args(); assert 1 <= a.repeat <= MASK and 1 <= a.rounds <= 20
    a.source, a.api, a.bun, a.qbe = [file.resolve(strict=True) for file in [a.source,a.api,a.bun,a.qbe]]
    out = a.out.resolve(); out.mkdir(parents=True, exist_ok=False)
    work = out/'work'; work.mkdir(); source = work/'arithmetic.bend'
    original = a.source.read_bytes(); assert original.count(b'1664525') == 1
    assert original == (HERE/'cases/arithmetic.bend').read_bytes(), 'Oracle applies only to the arithmetic fixture'
    edited = original.replace(b'1664525', b'1664527'); source.write_bytes(original)
    (out/'original.bend').write_bytes(original); (out/'edited.bend').write_bytes(edited)
    compiler = HERE/'compile.mjs'; cache = out/'cache'; known = {}
    def remember(record):
        assert pin(record['file']) == record, record
        previous = known.setdefault(record['file'], record); assert previous == record, 'Input changed between jobs'
    for file in [__file__, compiler, a.source, HERE/'cases/arithmetic.bend', a.api, a.bun, a.qbe, sys.executable, '/usr/bin/as', '/usr/bin/gcc', '/usr/bin/ld']:
        remember(pin(file))
    shutil.copyfile(__file__, out/'method.py'); shutil.copyfile(compiler, out/'compiler-method.mjs')
    report = dict(kind='phase107-cache-controls', complete=False, passed=False, started=time.time(),
        inputs=list(known.values()), snapshots=[pin(out/'method.py'),pin(out/'compiler-method.mjs'),pin(out/'original.bend'),pin(out/'edited.bend')],
        output=str(out), cache=str(cache), affinity=sorted(os.sched_getaffinity(0)), builds=[], jobs=[], observations=[],
        scope='Finite arithmetic cache/invalidation controls, not compiler qualification or a universal speedup.',
        clockScope='Subprocess wall includes host startup, checking, lowering, cache validation and linking; child component clocks are retained separately.',
        oracle='Independent Python integer arithmetic, masked to U32 after multiply/add; no compiler IR/interpreter used.')
    def save():
        report['inputs'] = list(known.values())
        (out/'report.json').write_text(json.dumps(report, indent=2)+'\n')
    def run(label, command, expected=None, timeout=90):
        cmd = list(map(str, command)); row = dict(label=label, command=cmd, started=time.time(), complete=False)
        report['jobs'].append(row); save(); begin = time.perf_counter()
        stdout, stderr = out/(label+'.stdout'), out/(label+'.stderr')
        try:
            with stdout.open('xb') as so, stderr.open('xb') as se:
                child = subprocess.run(cmd, cwd=ROOT, stdout=so, stderr=se, timeout=timeout)
            row.update(returncode=child.returncode, complete=True)
        except Exception as error:
            row['error'] = repr(error); raise
        finally:
            row.update(seconds=time.perf_counter()-begin, finished=time.time())
            for name, file in [('stdout',stdout),('stderr',stderr)]:
                if file.exists(): row[name] = pin(file)
            save()
        assert child.returncode == 0, (label, child.returncode, str(stderr))
        if expected is not None:
            assert stdout.read_bytes() == expected.encode() and stderr.read_bytes() == b'', label
        return row
    def build(label, multiplier, salt='', whole=False):
        dest = out/label; own_cache = out/'whole-cache' if whole else cache
        cmd = [a.bun,compiler,source,'--api',a.api.resolve(),'--out',dest,'--entry','bench','--backend','qbe','--qbe',a.qbe.resolve(),'--cache',own_cache]
        cmd += ['--whole-object','--budget','4096'] if whole else ['--budget','0','--no-tail','--no-fuse']
        if salt: cmd += ['--abi-salt',salt]
        job = run(label,cmd); receipt = json.loads((dest/'report.json').read_text())
        assert receipt['complete'] and receipt['source'] == pin(source) and receipt['options']['entry'] == 'bench'
        assert receipt['options']['units'] is (not whole) and receipt['options']['budget'] == (4096 if whole else 0)
        assert receipt['jobs'] and all(j['status'] == 0 and not j.get('signal') for j in receipt['jobs'])
        for item in receipt['inputs'] + receipt['frontendFiles']:
            if item['file'] != str(source): remember(item)
            else: assert item == pin(source)
        assert pin(receipt['binary']['file']) == receipt['binary']
        rows = {r['name']:r for r in receipt['cache']}; assert len(rows) == len(receipt['cache']) and 'runner' in rows
        objects = []
        for row in rows.values():
            assert len(row['key']) == 64 and all(c in '0123456789abcdef' for c in row['key'])
            folder = own_cache/row['key']; record = json.loads((folder/'record.json').read_text()); obj = pin(folder/'object.o')
            assert record['key'] == row['key'] and obj['sha256'] == record['sha256']
            objects.append(dict(name=row['name'], record=pin(folder/'record.json'), object=obj))
        shutil.copyfile(source,dest/'input-snapshot.bend')
        item = dict(id=label, multiplier=multiplier, sourceSnapshot=pin(dest/'input-snapshot.bend'), report=pin(dest/'report.json'), binary=receipt['binary'], cache=receipt['cache'], objects=objects,
            wallSeconds=job['seconds'], compilerSeconds=receipt['seconds'], childSeconds=sum(j['seconds'] for j in receipt['jobs']), childClocks=receipt['jobs'])
        report['builds'].append(item); save()
        for i,(n,seed) in enumerate(EDGES):
            want = answer(n,seed,multiplier); check = run(label+'-check-'+str(i),[receipt['binary']['file'],'--expect',want,n,seed],str(want)+'\n',30)
            report['observations'].append(dict(build=label,args=[n,seed],expected=want,job=check['label']))
        save(); return item,rows
    try:
        cold,c = build('cold',1664525); assert MIX in c and len(c)>2 and all(not r['hit'] for r in c.values())
        warm,w = build('warm',1664525); assert c.keys()==w.keys() and all(r['hit'] and r['key']==c[n]['key'] for n,r in w.items())
        source.write_bytes(edited); changed,e = build('edited',1664527)
        assert e.keys()==c.keys() and all(r['hit']==(n!=MIX) and (r['key']==c[n]['key'])==(n!=MIX) for n,r in e.items())
        warm_edit,we = build('warm-edited',1664527); assert e.keys()==we.keys() and all(r['hit'] and r['key']==e[n]['key'] for n,r in we.items())
        salted,s = build('abi-salt',1664527,'phase107-cache-controls-v2')
        assert s.keys()==e.keys() and all(r['hit']==(n=='runner') and (r['key']==e[n]['key'])==(n=='runner') for n,r in s.items())
        target = cache/s[MIX]['key']/'object.o'; assert target.resolve().is_relative_to(cache.resolve())
        shutil.copyfile(target,out/'object-before.o'); before = pin(target); data = bytearray(target.read_bytes()); assert data
        data[len(data)//2] ^= 1; target.write_bytes(data); shutil.copyfile(target,out/'object-corrupt.o')
        report['corruption'] = dict(target=str(target),before=pin(out/'object-before.o'),corrupt=pin(out/'object-corrupt.o'),key=s[MIX]['key']); save()
        rebuilt,r = build('corrupt-rebuild',1664527,'phase107-cache-controls-v2')
        assert r.keys()==s.keys() and all(x['key']==s[n]['key'] and x['hit']==(n!=MIX) for n,x in r.items())
        assert r[MIX].get('corrupt') is True and pin(target)==before
        if a.whole_object:
            source.write_bytes(original); optimized,o = build('whole-cold',1664525,whole=True); assert set(o)=={'program','runner'} and all(not x['hit'] for x in o.values())
            whole_warm,ow = build('whole-warm',1664525,whole=True); assert ow.keys()==o.keys() and all(x['hit'] and x['key']==o[n]['key'] for n,x in ow.items())
            samples = {'units':[],'whole':[]}; n,seed=12345,277; want=answer(n,seed,1664525)
            for turn in range(a.rounds):
                order=[('units',cold),('whole',optimized)]; order=order[::-1] if turn%2 else order
                for name,item in order:
                    sample=run('runtime-'+str(turn)+'-'+name,[item['binary']['file'],'--repeat',a.repeat,'--expect',want,n,seed],str((want*a.repeat)&MASK)+'\n',30)
                    samples[name].append(sample['seconds'])
            report['tradeoff']=dict(coldBuildSeconds={'units':cold['wallSeconds'],'whole':optimized['wallSeconds']},warmBuildSeconds={'units':warm['wallSeconds'],'whole':whole_warm['wallSeconds']},runtimeSeconds=samples,args=[n,seed],expected=want,repeat=a.repeat,rounds=a.rounds,
                wholeToUnitsRuntimeRatio=statistics.median(samples['whole'])/statistics.median(samples['units']),scope='One arithmetic workload; optimization plus unit granularity changes together, not a causal unit-size-only comparison.')
        for item in known.values(): assert pin(item['file'])==item
        report.update(complete=True,passed=True)
    except Exception as error:
        report['error']=repr(error); raise
    finally:
        report.update(finished=time.time(),wallSeconds=time.time()-report['started']); save()
    print(json.dumps(dict(complete=True,passed=True,builds=len(report['builds']),observations=len(report['observations']),report=pin(out/'report.json'))))

if __name__ == '__main__': main()

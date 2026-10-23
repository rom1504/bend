"""Guarded completed-stage disk estimate and exact raw-QBE dedup; no targets."""
import argparse
import importlib.util
import json
import os
from pathlib import Path
import shutil

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[4]
spec = importlib.util.spec_from_file_location('p126_native_plan', HERE/'plan-v2.py')
P = importlib.util.module_from_spec(spec); spec.loader.exec_module(P)


def equal(a, b):
    with a.open('rb') as x, b.open('rb') as y:
        while True:
            left, right = x.read(1024**2), y.read(1024**2)
            if left != right: return False
            if not left: return True


def main():
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument('--plan', type=Path, required=True)
    ap.add_argument('--stage', choices=['after-n1', 'before-n2'], required=True)
    ap.add_argument('--out', type=Path, required=True)
    a = ap.parse_args(); assert not a.out.exists()
    plan = P.verify_plan(a.plan)
    paths = {k:Path(plan['artifacts'][k]) for k in ['hosted','n1','self']}
    h, n1 = [P.read(paths[k]/'report.json') for k in ['hosted','n1']]
    assert h['complete'] and n1['complete'] and h['product'] in n1['inputs']
    assert plan['source'] in h['inputs'] and plan['runtime'] in n1['inputs']
    inputs = [P.pin(__file__), P.pin(a.plan), P.pin(paths['hosted']/'report.json'),
              P.pin(paths['n1']/'report.json'), h['product'], n1['binary'], n1['object']]
    assembly = P.pin(paths['n1']/'program.s'); inputs.append(assembly)
    for row in inputs: P.verify(row)
    # Same-QBE N2 uses the same builder/toolchain/runtime; use actual N1 output
    # sizes, 96MiB for remaining suites/logs and 32MiB unallocated slack. The
    # native stdout stage retains its original independent 128MiB file cap.
    n2_bytes = assembly['bytes']+n1['object']['bytes']+n1['binary']['bytes']+8*1024**2
    r = dict(complete=False, targetsRun=False, stage=a.stage, inputs=inputs,
        hostedReport=P.pin(paths['hosted']/'report.json'), freeBefore=shutil.disk_usage(ROOT).free,
        actualN1OutputBytes=n2_bytes, suiteReserveBytes=96*1024**2, slackBytes=32*1024**2,
        scope='Completed-stage disk estimate, not a future-size proof. Stop before next target if reserve is insufficient. Exact QBE dedup preserves bytes and paths; no report or executable is replaced.')
    try:
        if a.stage == 'before-n2':
            native = P.read(paths['self']/'report.json')
            assert native['complete'] and native['gates']['emission'] == 'passed'
            assert native['gates']['build'] == 'not-requested'
            assert native['image'] == n1['binary'] and plan['source'] in native['inputs']
            assert native['imageReceipt'] == P.pin(paths['n1']/'report.json')
            for expected in [plan['assets'][k] if k != 'cache' else plan['assets']['cache']['carrier']
                             for k in ['base','cache','selection','admission']]:
                assert expected in h['inputs'] and expected in native['inputs']
            P.verify(native['product']); inputs.extend([P.pin(paths['self']/'report.json'),native['product']])
            left, right = Path(h['product']['file']), Path(native['product']['file'])
            assert h['product']['sha256'] == native['product']['sha256'] and equal(left,right), 'Raw hosted/native QBE differs'
            ls, rs = left.stat(), right.stat()
            assert (ls.st_dev,ls.st_mode,ls.st_uid,ls.st_gid) == (rs.st_dev,rs.st_mode,rs.st_uid,rs.st_gid)
            assert not left.is_symlink() and not right.is_symlink()
            saved = 0
            if ls.st_ino != rs.st_ino:
                assert rs.st_nlink == 1
                temporary = right.with_name('program.ssa.p126-exact-link')
                assert not temporary.exists(); os.link(left,temporary); os.replace(temporary,right)
                saved = rs.st_blocks*512
            P.verify(h['product']); P.verify(native['product'])
            r.update(byteExact=True, nativeReport=P.pin(paths['self']/'report.json'),
                     nativeProduct=native['product'], reclaimedAllocatedBytes=saved)
            remaining = n2_bytes
        else:
            remaining = max(128*1024**2,n2_bytes)
        r['requiredFreeBytes'] = remaining+r['suiteReserveBytes']+r['slackBytes']
        r['freeAfter'] = shutil.disk_usage(ROOT).free
        assert r['freeAfter'] > r['requiredFreeBytes'], 'Insufficient reserve: stop before next target; completed artifacts preserved'
        r['complete'] = True
    except BaseException as error:
        r['error'] = str(error); raise
    finally:
        a.out.parent.mkdir(parents=True,exist_ok=True)
        with a.out.open('x') as f: json.dump(r,f,indent=2);f.write('\n')
    print(json.dumps({k:r[k] for k in ['complete','stage','freeAfter','requiredFreeBytes']}))


if __name__ == '__main__': main()

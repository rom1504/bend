#!/usr/bin/env python3
"""Derive additive native-corpus methods without executing any compiler/target."""
import argparse
import ast
import hashlib
import json
import os
from pathlib import Path

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[4]
RAW = ROOT / 'selfhost/build/phase70'
NAMES = 'list-pipeline,bst,expression,array-map,tape-observer,string-order'


def pin(path):
    path = Path(path).resolve(strict=True)
    data = path.read_bytes()
    return dict(path=str(path), sha256=hashlib.sha256(data).hexdigest(), bytes=len(data))


def write(path, value):
    with path.open('x') as stream:
        stream.write(value if isinstance(value, str) else json.dumps(value, indent=2) + '\n')


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--out', required=True, type=Path)
    a = p.parse_args()
    assert os.sched_getaffinity(0) == {0}, 'Source-only preparation belongs on CPU0'
    out = a.out.resolve()
    assert out.is_relative_to(RAW) and not out.exists()
    out.mkdir(parents=True)
    results = []

    def derive(name, relative, expected, edits):
        parent = ROOT / relative
        before = pin(parent)
        assert before['sha256'] == expected, parent
        source = parent.read_text()
        changes = []
        for old, new, count in edits:
            assert source.count(old) == count, (name, old, source.count(old), count)
            source = source.replace(old, new)
            changes.append(dict(before=old, after=new, count=count))
        if name.endswith('.py'):
            ast.parse(source, filename=name)
        dest = out / name
        write(dest, source)
        receipt = dict(kind='phase70-coverage-method-derivation', parent=before,
                       output=pin(dest), edits=changes, producer=pin(__file__), targetsExecuted=False)
        write(dest.with_suffix('.derivation.json'), receipt)
        results.append(receipt)

    root = 'ROOT=Path(' + repr(str(ROOT)) + ')'
    coverage = "ROOT/'selfhost/tools/performance/phase70/coverage'"
    derive('run.py', 'selfhost/tools/performance/phase67/benchmark/run.py',
           '1c5003a5329b0deb24460b3b5e07d29a146eafbe79fadb8b75c1e6109799c188', [
        ("ROOT=HERE.parents[4];OLD=HERE.parents[1]/'phase46'", root+';OLD='+coverage, 1),
        ("HERE.parents[1]/'programs/support.py'", "ROOT/'selfhost/tools/performance/programs/support.py'", 1),
        ("default='numeric,array,closures'", 'default='+repr(NAMES), 1),
        ('a.out=a.out.resolve();a.out.mkdir', "a.out=a.out.resolve();assert a.out.is_relative_to(ROOT/'selfhost/build/phase70');a.out.mkdir", 1),
        ("{'numeric':4096,'array':512,'closures':8192,'tree':128,'map':64,'lexer':64}",
         "{'list-pipeline':256,'bst':32,'expression':128,'array-map':128,'tape-observer':128,'string-order':128}", 1),
        ("str(OLD/'execute.py')", "str(ROOT/'selfhost/tools/performance/phase46/execute.py')", 1),
        ("kind='phase67-native-'", "kind='phase70-native-coverage-'", 1)])
    derive('emit.mjs', 'selfhost/tools/performance/phase67/benchmark/emit.mjs',
           '8fabddd82219104ba30d22a79ef0ea72c7e2e8ac0ee6587f0b2314bca37d789e', [
        ("const root=path.resolve(import.meta.dirname,'../../../../..');", 'const root='+json.dumps(str(ROOT))+';', 1),
        ('selfhost/tools/performance/phase46/cases.json', 'selfhost/tools/performance/phase70/coverage/cases.json', 1),
        ("await import('../../../development/release.mjs')", "await import(pathToFileURL(path.join(project,'tools/development/release.mjs')))", 1)])
    derive('freeze.py', 'selfhost/tools/performance/phase67/benchmark/freeze.py',
           '520fb8019ee74dd60c265f090a69b9ead6d88644676873969a8ff03823f01ed7', [
        ('ROOT=HERE.parents[4]', root, 1),
        ("files += [ROOT/'selfhost/tools/performance/phase46'/n for n in ['cases.json','oracle.py','execute.py','make-batch.py']]",
         "files += [ROOT/'selfhost/tools/performance/phase70/coverage'/n for n in ['cases.json','oracle.py','prepare.py','make-batch.py']]\nfiles += [ROOT/'selfhost/tools/performance/phase46'/n for n in ['execute.py','make-batch.py']]", 1),
        ('selfhost/tools/performance/phase46/cases.json', 'selfhost/tools/performance/phase70/coverage/cases.json', 1),
        ("ROOT/'selfhost/tools/performance/phase46'/(c['name']+'-batch.bend')", coverage+"/(c['name']+'-batch.bend')", 1),
        ("files += [a.api,", " for d in c.get('dependencies',[]):\n  assert identity(ROOT/d['path'])['sha256']==d['sha256']; files += [ROOT/d['path']]\nfiles += [a.api,", 1),
        ("kind='phase67-native-method-v2'", "kind='phase70-native-coverage-method-v1'", 1),
        ("a.out.parent.mkdir(parents=True,exist_ok=True)", "assert a.out.resolve().is_relative_to(ROOT/'selfhost/build/phase70')\na.out.parent.mkdir(parents=True,exist_ok=True)", 1)])
    derive('compare.py', 'selfhost/build/phase69/methods01/compare-native-v2.py',
           'b09b38af16ecf4cce59c6893ef4e5123014566d740194da175dbcf11c11ecdd5', [
        ('compiler23/candidate/upstream', 'Phase69/candidate/upstream', 1),
        ('baseline23', 'baseline69', 8), ('Baseline23', 'Baseline69', 1),
        ('selfhost/tools/performance/phase46/oracle.py', 'selfhost/tools/performance/phase70/coverage/oracle.py', 2),
        ('selfhost/tools/performance/phase46/cases.json', 'selfhost/tools/performance/phase70/coverage/cases.json', 1),
        ("p=argparse.ArgumentParser();", "p=argparse.ArgumentParser();p.add_argument('--baseline',type=Path,nargs='+',required=True);p.add_argument('--upstream',type=Path,nargs='+',required=True);p.add_argument('--plan',type=Path,required=True);", 1),
        ("default='numeric,array,closures,tree,map,lexer'", 'default='+repr(NAMES), 1),
        ("paths=[('baseline69',ROOT/'selfhost/build/phase68'/n/'report.json') for n in ['native-facts23-lexer','native-facts23-rest']]",
         "paths=[('baseline69',v/'report.json' if v.is_dir() else v) for v in a.baseline]", 1),
        ("paths += [('upstream',ROOT/'selfhost/build/phase67'/n/'report.json') for n in ['native-baseline02','native-heldout-baseline02']]",
         "paths += [('upstream',v/'report.json' if v.is_dir() else v) for v in a.upstream]", 1),
        ("names=a.cases.split(',');counts={'numeric':77504,'array':61440,'closures':57888,'tree':1280,'map':1152,'lexer':448}\nplan={n:dict(repetitions=counts[n],warmups=(counts[n]//8//16)*16) for n in names}",
         "names=a.cases.split(',');plan=read(a.plan);pins.append(S.identity(a.plan))\nfor n in names:\n assert type(plan[n]['repetitions']) is int and 16<=plan[n]['repetitions']<=1000000 and plan[n]['repetitions']%16==0\n assert type(plan[n]['warmups']) is int and 0<=plan[n]['warmups']<=1000000 and plan[n]['warmups']%16==0", 1),
        ("out.is_relative_to(ROOT/'selfhost/build/phase69')", "out.is_relative_to(ROOT/'selfhost/build/phase70')", 1)])
    write(out/'methods.json', dict(kind='phase70-native-coverage-methods', producer=pin(__file__),
                                  targetsExecuted=False, methods=results,
                                  catalog=pin(HERE/'cases.json'), oracle=pin(HERE/'oracle.py')))
    print(json.dumps(dict(manifest=pin(out/'methods.json'), derivatives=len(results), targetsExecuted=False)))


if __name__ == '__main__':
    main()

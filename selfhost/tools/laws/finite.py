#!/usr/bin/env python3
"""Execute a frozen finite suite; semantic mutation rejection is not admission failure."""
import argparse
import json
from pathlib import Path
import sys

HERE=Path(__file__).resolve().parent
ROOT=HERE.parents[2]
sys.path.insert(0,str(ROOT/'selfhost/tools/build'))
from assets import load_assets,asset
from common import pin,verify,run,write_json,fresh_output,timeout


def semantic_rejection(result,witness):
    if not result.get('complete') or not result.get('inputsUnchanged') or result.get('compile',{}).get('status')!='ok':
        raise ValueError('Source admission or execution failure is not semantic rejection')
    rows={row['id']:row for row in result['rows']}
    row=rows.get(witness,{})
    if result.get('passed') or row.get('passed') or 'actual' not in row or 'expected' not in row or row['actual']==row['expected']:
        raise ValueError('The frozen witness must exhibit a complete semantic mismatch')


def main():
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument('--manifest',type=Path,required=True)
    p.add_argument('--assets',type=Path,required=True)
    p.add_argument('--out',type=Path,required=True)
    p.add_argument('--native',action='store_true')
    p.add_argument('--expect-mutation',action='store_true')
    p.add_argument('--seconds',type=float,default=120)
    a=p.parse_args();timeout(a.seconds)
    data=json.loads(a.manifest.read_text())
    if data.get('kind')!='bend-extracted-production-finite-controls-v1' or not data.get('complete'):
        raise ValueError('A maintained exact-source prepared finite suite is required')
    if bool(data['mutation'])!=a.expect_mutation or (a.native and a.expect_mutation):
        raise ValueError('Explicit JS semantic mutation classification required; native mutation controls unsupported')
    for row in [data['operationalAssets'],*data['originalSources'],*data['frozenInputs'],*data['b2'].values()]:verify(row)
    assets=load_assets(a.assets,ROOT)
    node=asset(assets,'law-node')
    if data['operationalAssets']!=pin(a.assets): raise ValueError('Prepared and executing assets manifests differ')
    worker=a.manifest.resolve().parent/'methods/run.mjs'
    if worker.read_bytes()!=(HERE/'finite-run.mjs').read_bytes(): raise ValueError('Prepared worker differs from maintained implementation')
    out=fresh_output(a.out,ROOT)
    inputs=[pin(a.manifest),pin(a.assets),pin(worker),pin(__file__),pin(HERE/'finite-run.mjs'),pin(ROOT/'selfhost/tools/build/common.py'),node]
    report=dict(schema='bend-finite-suite-check-v1',complete=False,native=a.native,mutationControl=a.expect_mutation,
                formalProof=False,wholeCompilerProved=False,inputs=inputs,rows={},sourceInputs=data['originalSources'])
    def save():write_json(out/'report.json',report)
    def execute(name,argv,expected=0):
        folder=out/(name+'-process');folder.mkdir()
        receipt=run(argv,cwd=ROOT,stdout=folder/'stdout.log',stderr=folder/'stderr.log',seconds=a.seconds)
        report['rows'][name]=receipt;save()
        if receipt.get('exitCode')!=expected or receipt.get('timedOut') or receipt.get('error'):
            raise ValueError('Finite suite process failed/refused: '+name)
        return folder
    try:
        execute('compile',[node['file'],'--stack-size=4096','--max-old-space-size=1024',str(worker),str(a.manifest.resolve()),str(out/'execution'),'emit-native' if a.native else 'js'],int(a.expect_mutation))
        result_file=out/'execution/report.json';result=json.loads(result_file.read_text());report['execution']=pin(result_file)
        if not result.get('complete') or not result.get('inputsUnchanged') or result.get('compile',{}).get('status')!='ok':
            raise ValueError('Finite suite did not complete with checked source')
        if a.expect_mutation:
            witness=data['mutation']['case'];semantic_rejection(result,witness);report['rejectedWitness']=witness
        elif a.native:
            if not result['passed'] or result['nativeExecutionPerformed']:raise ValueError('Unexpected native acquisition state')
            clang=asset(assets,'law-clang');inputs.append(clang)
            include=Path(clang['file']).parent.parent/'include/clang'
            if not include.is_dir():raise ValueError('Explicit Clang installation lacks its include/clang directory')
            binary=out/'laws'
            execute('clang',[clang['file'],'-isystem',str(include),'-std=c11','-O3',str(out/'execution/laws.c'),'-o',str(binary),'-lm','-pthread'])
            report['binary']=pin(binary)
            folder=execute('native',[str(binary)])
            expected=a.manifest.resolve().parent/'native.expected.txt'
            if (folder/'stdout.log').read_bytes()!=expected.read_bytes() or (folder/'stderr.log').read_bytes():
                raise ValueError('Native complete stdout/stderr differs')
            report.update(expected=pin(expected),actual=pin(folder/'stdout.log'),cases=len(data['nativeCaseIds']))
        else:
            if not result['passed'] or len(result['rows'])!=len(data['cases']):raise ValueError('Finite complete-value case mismatch')
            report['cases']=len(result['rows'])
        for row in [*inputs,*data['originalSources'],*data['frozenInputs'],*data['b2'].values()]:verify(row)
        report.update(complete=True,inputsUnchanged=True)
    except BaseException as error:
        report['error']=repr(error);raise
    finally:save()
    print(json.dumps({key:report[key] for key in ['complete','native','mutationControl']}))


if __name__=='__main__':main()

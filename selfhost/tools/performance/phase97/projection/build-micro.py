#!/usr/bin/env python3
"""Acquire and build one frozen helper micro under serial resource guards."""
import argparse
from pathlib import Path
import sys
sys.dont_write_bytecode=True
ROOT=Path(__file__).resolve().parents[5]
sys.path.insert(0,str(ROOT/'selfhost/tools/laws/phase97'))
from common import BUILD,CLANG,pin,read,save,verify,run,passed


def main():
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument('--frozen',type=Path,required=True)
    p.add_argument('--role',choices=['baseline','candidate'],required=True)
    p.add_argument('--out',type=Path,required=True)
    a=p.parse_args();out=a.out.resolve();frozen=a.frozen.resolve()
    assert out.is_relative_to(BUILD) and not out.exists()
    manifest=read(frozen/a.role/'manifest.json')
    for item in manifest['frozenInputs']:verify(item)
    source=frozen/a.role/'micro.bend'
    assert pin(source) in manifest['frozenInputs']
    acquire=ROOT/'selfhost/tools/performance/phase97/acquire.mjs'
    bun=ROOT/'selfhost/build/phase66/bun-toolchain01/bun'
    inputs=[pin(__file__),pin(Path(__file__).resolve()),pin(ROOT/'selfhost/tools/laws/phase97/common.py'),
            pin(frozen/'receipt.json'),pin(frozen/a.role/'manifest.json'),pin(source),pin(acquire),pin(bun),pin(CLANG)]
    job=run(out.with_name(out.name+'-acquire'),[bun,acquire,source,out],90)
    assert passed(job),job['stderr'][-2000:]
    data=read(out/'report.json');assert data['complete'] and data['holes']==0 and data['source']==pin(source)
    verify(data['c'])
    report=dict(complete=False,inputs=inputs,acquisition=pin(out/'report.json'),acquire=job['receipt'])
    save(out/'build.json',report)
    try:
        binary=out/'program'
        build=run(out/'clang',[CLANG,'-isystem',CLANG.parent.parent/'include/clang','-std=c11','-O3',out/'program.c','-o',binary,'-lm','-pthread'],120)
        report['build']=build['receipt'];save(out/'build.json',report)
        assert passed(build),build['stderr'][-2000:]
        for item in inputs:verify(item)
        verify(data['c']);report.update(complete=True,binary=pin(binary),inputsUnchanged=True)
    except BaseException as error:report['error']=repr(error);raise
    finally:save(out/'build.json',report)
    print(a.role,'built',flush=True)


if __name__=='__main__':main()

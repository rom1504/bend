#!/usr/bin/env python3
"""Apply the independently frozen literal fault to unchanged representation laws."""
import argparse
from pathlib import Path
import sys
sys.dont_write_bytecode=True
from common import ROOT,BUILD,pin,read,save,verify


def main():
    p=argparse.ArgumentParser(description=__doc__);p.add_argument('--out',type=Path,required=True)
    out=p.parse_args().out.resolve();assert out.is_relative_to(BUILD);out.mkdir(parents=True,exist_ok=False)
    positive=ROOT/'selfhost/build/phase96/representation-source03'
    manifest=read(positive/'manifest.json')
    for item in [manifest['source'],manifest['proof'],*manifest['outputs']]:verify(item)
    recipe=ROOT/'selfhost/tools/laws/phase97/challenge/bad01-literal-span-payload.json'
    fault=read(recipe);source=(positive/'production.bend').read_text()
    body=next(x['extracted'] for x in manifest['definitions'] if x['name']==fault['function'])
    assert body.count(fault['before'])==1 and source.count(body)==1
    changed=source.replace(body,body.replace(fault['before'],fault['after'],1),1)
    for role,text in [('baseline',source),('mutant',changed)]:
        folder=out/role;folder.mkdir();(folder/'production.bend').write_text(text)
        (folder/'laws.bend').write_bytes((positive/'laws.bend').read_bytes())
    jobs=[dict(name='baseline-laws',source=pin(out/'baseline/laws.bend'),expectedExit=0,requires=[],classification='unchanged representation laws'),
          dict(name='mutant-helper',source=pin(out/'mutant/production.bend'),expectedExit=0,requires=['baseline-laws'],classification='independently selected safe semantic mutant'),
          dict(name='mutant-law',source=pin(out/'mutant/laws.bend'),expectedExit=1,requires=['mutant-helper'],classification='unchanged representation law rejects payload damage')]
    save(out/'plan.json',dict(method=pin(__file__),checker=pin(Path(__file__).with_name('check.py')),positive=pin(positive/'manifest.json'),recipe=pin(recipe),jobs=jobs,targetsRun=False))


if __name__=='__main__':main()

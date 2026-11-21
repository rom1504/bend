"""Add the checked guarded scan rule to an independently checked compiler source."""
import argparse
import json
from pathlib import Path
import shutil
from core import install, blocks, body, src, BUILD, ROOT, digest

def compose(parent, check, api, out):
    parent=parent.resolve();out=out.resolve()
    data=(parent/'compiler.bend').read_bytes();old=blocks(data)
    origin=json.loads(check.read_bytes())
    assert origin['complete'] and origin['checked'] and origin['unresolvedHoles']==0
    assert origin['source']==src.pin(parent/'compiler.bend')
    out.mkdir(parents=True);stage=out/'maintained';shutil.copytree(parent/'maintained',stage)
    folder=ROOT/'research/phase199/scan-lowering'
    paths=[folder/(module+'.bend') for module in ('recognizer','pipeline','hook')]
    pairs=set(install(stage,'x185_array_version',[p.read_bytes() for p in paths],api.resolve()))
    cfg=stage/'src/compiler.json'
    assembled=src.maintained_assemble(cfg,stage,'x86');new=blocks(assembled)
    changed={k for k in new if k not in old or body(new[k])!=body(old[k])}
    assert changed==pairs and set(old)<=new.keys()
    assert len(changed&old.keys())==1
    assert not {n for _,n in changed}.intersection(json.loads(cfg.read_bytes())['protectedDeclarations'])
    dest=out/'compiler.bend';dest.write_bytes(assembled)
    result={'parent':src.pin(parent/'compiler.bend'),'sourceCheck':src.pin(check),
        'checkedAPI':src.pin(api/'report.json'),'modules':[src.pin(p) for p in paths],
        'selectedSource':src.pin(dest),'method':src.pin(__file__),'changed':[list(k) for k in sorted(changed)]}
    (out/'report.json').write_text(json.dumps(result,indent=2)+'\n')
    print(result['selectedSource'])
if __name__=='__main__':
    p=argparse.ArgumentParser()
    for flag in ['parent','check','api','out']:p.add_argument('--'+flag,type=Path,required=True)
    a=p.parse_args();compose(a.parent,a.check,a.api,a.out)

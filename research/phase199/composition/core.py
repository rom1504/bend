"""Compose previously measured machine selectors onto the qualified Phase198 source."""
import argparse
import json
from pathlib import Path
import shutil
import tail
from tail import ROOT, P198, BUILD, PARENT, src, body, blocks, digest

def install(stage, hook, fragments, checked_api):
    checked=json.loads((BUILD/checked_api/'report.json').read_bytes())
    assert checked['complete'] and checked['checked'] and not checked.get('changedInputs')
    assert src.pin(checked['source']['file']) == checked['source']
    book=blocks(Path(checked['source']['file']).read_bytes())
    payload=b'\n\n'.join(f.strip() for f in fragments)
    proposed=blocks(payload)
    assert ('def',hook) in proposed and all(body(r)==body(book[k]) for k,r in proposed.items())
    owners=[p for p in (stage/'src/back/x86').glob('*.bend') if ('def',hook) in blocks(p.read_bytes())]
    assert len(owners)==1,hook
    owner=owners[0]; old=owner.read_bytes(); slot=blocks(old)['def',hook]
    reference=blocks((PARENT/'maintained'/owner.relative_to(stage)).read_bytes())['def',hook]
    assert body(slot)==body(reference)
    assert all(k==('def',hook) or k not in blocks(old) for k in proposed)
    owner.write_bytes(old[:slot['offset']]+b'\n'+payload+b'\n\n'+old[slot['offset']+len(slot['data']):])
    return list(proposed)
def build(out):
    assert digest((PARENT/'compiler.bend').read_bytes())==tail.PARENT_HASH
    out.mkdir(parents=True);stage=out/'maintained';shutil.copytree(PARENT/'maintained',stage)
    cfg=Path('src/compiler.json');before=blocks((PARENT/'compiler.bend').read_bytes())
    tail.apply(stage);pending=set(tail.SIX)
    quotient=(P198/'quotient/rule.bend').read_bytes().partition(b'@unsafe\ndef p198q_fallback(')[0]
    word=(P198/'word-primitives/select.bend').read_bytes()
    split=blocks(word)['def','x198w_op']['offset']
    assert split>0
    for hook,fragments,source in [
      ('x185_sf_body',[word[split:]],'word-api03'),
      ('x186_u32_float_probe',[word[:split],(P198/'word-primitives/machine.bend').read_bytes()],'word-api03'),
      ('x191_ff_work',[quotient,(P198/'quotient-machine/machine.bend').read_bytes()],'quotient-machine-api01')]:
        pending.update(install(stage,hook,fragments,source))
    assembled=src.maintained_assemble(stage/cfg,stage,'x86')
    final=blocks(assembled)
    assert set(before)<=set(final)
    diff={k for k in final if k not in before or body(before[k])!=body(final[k])}
    assert diff==pending,(diff-pending,pending-diff)
    assert not {n for k,n in diff}.intersection(json.loads((stage/cfg).read_bytes())['protectedDeclarations'])
    cli=out/'compiler.bend';cli.write_bytes(assembled)
    receipt={'source':src.pin(cli),'parent':src.pin(PARENT/'compiler.bend'),'method':src.pin(__file__),'changed':[k for k in sorted(diff & before.keys())],'new':[k for k in sorted(diff-before.keys())]}
    (out/'report.json').write_text(json.dumps(receipt,indent=2)+'\n');print(receipt['source'],len(diff))
if __name__=='__main__':
    p=argparse.ArgumentParser();p.add_argument('--out',type=Path,required=True);build(p.parse_args().out)

"""Authenticate a Phase200 maintained source patch and assemble its bytes in memory."""
import argparse
from difflib import unified_diff
import gzip
import hashlib
import json
from pathlib import Path
import shutil
import subprocess
import sys
from unittest.mock import patch

HERE=Path(__file__).resolve().parent
ROOT=HERE.parents[2]
sys.path.insert(0,str(ROOT/'research/phase199/composition'))
from tail import blocks,body,src

BUILD=ROOT/'selfhost/build'
PARENT=BUILD/'phase198/p199-integrated01'
PARENT_HASH='a48b1532ec45ac23cb972796f0101a8bf1864ed8769c6a2daee114ee268ce313'
CHECK=BUILD/'phase198/p199-integrated-check01/report.json'
PHASE=ROOT/'research/phase200'
P199=BUILD/'phase199'

def readjson(file):return json.loads(Path(file).read_bytes())

def identity(data):return dict(bytes=len(data),sha256=hashlib.sha256(data).hexdigest())

def relative_pin(path):
    path=Path(path)
    return dict(file=str(path.resolve().relative_to(ROOT)),**identity(path.read_bytes()))

def link_checked(module,api,focus):
    receipt=readjson(api)
    assert receipt['complete'] and receipt['checked'] and not receipt.get('error') and not receipt.get('changedInputs')
    assert src.pin(receipt['source']['file'])==receipt['source'] and src.pin(receipt['api']['file'])==receipt['api']
    witness=readjson(focus)
    assert witness['complete']
    definitions=blocks(module.read_bytes())
    checked=blocks(Path(receipt['source']['file']).read_bytes())
    assert all(k in checked and body(checked[k])==body(r) for k,r in definitions.items())
    return definitions,dict(module=relative_pin(module),apiReceipt=relative_pin(api),
                checkedSource=receipt['source']['sha256'],checkedAPI=receipt['api']['sha256'],
                measurements=relative_pin(focus))

def assemble(args):
    parent=args.parent.resolve();stage=parent/'maintained'
    parent_bytes=(parent/'compiler.bend').read_bytes()
    assert identity(parent_bytes)['sha256']==PARENT_HASH
    origin=readjson(args.check)
    assert origin['complete'] and origin['checked'] and origin['unresolvedHoles']==0
    assert origin['source']['sha256']==PARENT_HASH and origin['source']['bytes']==len(parent_bytes)
    cfg=stage/'src/compiler.json';old=blocks(parent_bytes)
    pristine=src.maintained_assemble(cfg,stage,'x86')
    assert pristine==parent_bytes
    hooks=[('spill','x191_function_saved','address-selection.bend','frame-forward.bend',PHASE/'spill/spill.bend',args.spill_api,args.spill_focus)]
    if args.with_tag:
        hooks.append(('tag','x185_float_call','floating.bend','floating.bend',PHASE/'abi/fast-ownership.bend',args.tag_api,args.tag_focus))
    overlays={};expected={};certificates={}
    folder=stage/'src/back/x86'
    def contents(p):return overlays.get(p,p.read_bytes())
    for name,hook,hook_owner,helper_owner,module,api,focus in hooks:
        defs,cert=link_checked(module,api,focus);certificates[name]=cert
        witness=readjson(focus)
        if name=='spill':
            assert witness['manifest']['file'].endswith('/p199-integrated-native45-01/programs.manifest.json')
            assert witness['emission']==src.pin(witness['emission']['file'])
            assert readjson(witness['emission']['file'])['api']['sha256']==cert['checkedAPI']
            row=next(c for c in witness['cases'] if c['id']=='editdist')
            assert row['comparisons']['direct']['median']<=0.98 and row['comparisons']['direct']['wins']>=4
            cert['incumbentRatios']={c['id']:c['comparisons']['direct']['median'] for c in witness['cases']}
        else:
            assert witness['api']==src.pin(api)
            assert any(c['candidateOverBaseline']<1 and c['skippedImmediateCalls']>0 for c in witness['cases'])
            cert['incumbentRatios']={c['id']:c['candidateOverBaseline'] for c in witness['cases']}
        key=('def',hook)
        assert key in old and key in defs and all(k==key or k not in old for k in defs)
        assert not (expected.keys() & defs.keys())
        original=contents(folder/hook_owner);section=blocks(original)[key]
        assert body(section)==body(old[key])
        # A typed forwarding definition occupies the original hook. Its helper
        # bodies follow existing type declarations in their machine-pass owner.
        replacement=defs[key]['data'].strip()+b'\n'
        overlays[folder/hook_owner]=original[:section['offset']]+b'\n'+replacement+b'\n'+original[section['offset']+len(section['data']):]
        helper=folder/helper_owner
        extras=b'\n\n'.join(r['data'].strip() for k,r in defs.items() if k!=key)
        overlays[helper]=contents(helper).rstrip()+b'\n\n'+extras+b'\n'
        expected.update(defs)
    real_read=src.read
    def virtual_read(path):
        p=Path(path).resolve()
        return overlays[p] if p in overlays else real_read(p)
    with patch.object(src,'read',side_effect=virtual_read):
        result=src.maintained_assemble(cfg,stage,'x86')
    after=blocks(result)
    changed={k for k in after if k not in old or body(after[k])!=body(old[k])}
    assert old.keys()<=after.keys() and changed==expected.keys()
    assert all(body(after[k])==body(r) for k,r in expected.items())
    assert not {n for _,n in changed}.intersection(readjson(cfg)['protectedDeclarations'])
    # An early helper type would fail independent checker admission even with
    # verified bodies. Verify the selected ordering while only bytes exist.
    assert after['type','X191FrameStore']['offset']<after['def','x199s_add']['offset']
    diffs=[]
    for p,data in sorted(overlays.items()):
        name=str(p.relative_to(stage));before=p.read_text().splitlines(keepends=True)
        diffs.extend(unified_diff(before,data.decode().splitlines(keepends=True),fromfile='a/'+name,tofile='b/'+name))
    combined=''.join(diffs).encode()
    dry=subprocess.run(['patch','--dry-run','--batch','--fuzz=0','-p1','-d',str(stage)],input=combined,capture_output=True,check=True)
    info=dict(kind='phase200-maintained-x86-source-replay',scope='Source assembly and accepted declaration identity; no independent whole-source check or compiler execution.',
              parent=relative_pin(parent/'compiler.bend'),parentCheck=relative_pin(args.check),method=relative_pin(__file__),
              selectedSource=identity(result),patch=identity(combined),rows=certificates,
              replacements=sorted([k[1] for k in changed if k in old]),
              additions=sorted([k[1] for k in changed if k not in old]),patchDryRun=dry.stdout.decode())
    if args.record:
        base=args.record
        base.with_suffix('.json').write_text(json.dumps(info,indent=2)+'\n')
        base.with_suffix('.patch.gz').write_bytes(gzip.compress(combined,mtime=0))
    if args.source_only:
        destination=args.source_only.resolve()
        destination.mkdir(parents=True,exist_ok=False)
        cli=destination/'compiler.bend';cli.write_bytes(result)
        (destination/'report.json').write_text(json.dumps({'source':src.pin(cli),'composition':info,
            'manifest':src.pin(cfg),'sourceOnly':True},indent=2)+'\n')
    if args.out:
        out=args.out.resolve()
        out.mkdir(parents=True,exist_ok=False)
        work=out/'maintained';shutil.copytree(stage,work)
        subprocess.run(['patch','--batch','--fuzz=0','-p1','-d',str(work)],input=combined,check=True,capture_output=True)
        replay=src.maintained_assemble(work/'src/compiler.json',work,'x86')
        assert replay==result
        (out/'compiler.bend').write_bytes(replay)
        (out/'report.json').write_text(json.dumps(info,indent=2)+'\n')
    print(json.dumps({'source':info['selectedSource'],'replacements':info['replacements'],'additions':len(info['additions']),'patchBytes':len(combined)}))

if __name__=='__main__':
    p=argparse.ArgumentParser();p.add_argument('--parent',type=Path,default=PARENT);p.add_argument('--check',type=Path,default=CHECK)
    p.add_argument('--spill-api',type=Path,default=P199/'p200-spill-api01/report.json');p.add_argument('--spill-focus',type=Path,default=P199/'p200-spill-runtime03/report.json')
    p.add_argument('--tag-api',type=Path,default=P199/'p200-ownership-api01/report.json');p.add_argument('--tag-focus',type=Path,default=P199/'p200-ownership-focus01/report.json')
    p.add_argument('--with-tag',action='store_true');p.add_argument('--record',type=Path);p.add_argument('--out',type=Path);p.add_argument('--source-only',type=Path)
    assemble(p.parse_args())

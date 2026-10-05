#!/usr/bin/env python3
"""Materialize a reviewed aggregate proposal overlay; never compile or run targets."""
import argparse
import hashlib
import json
from pathlib import Path
import shutil

HERE = Path(__file__).resolve().parent


def identity(p):
    b=p.read_bytes()
    return dict(bytes=len(b),sha256=hashlib.sha256(b).hexdigest())


def main():
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument('--variant',choices=['scalar03','vector01'],required=True)
    p.add_argument('--out',type=Path,required=True,help='Fresh overlay tree, not a live compiler')
    a=p.parse_args()
    manifest=json.loads((HERE/'manifest.json').read_text())
    for x in manifest['files']:
        assert identity(HERE/x['path'])=={k:x[k] for k in ['bytes','sha256']},x['path']
    assert not a.out.exists()
    a.out.mkdir(parents=True)
    variants=['scalar03']+(['vector01'] if a.variant=='vector01' else [])
    targets={}
    for variant in variants:
        base=HERE/'payloads'/variant
        for src in sorted(base.rglob('*')):
            if src.is_file():
                relative=src.relative_to(base);dst=a.out/relative
                dst.parent.mkdir(parents=True,exist_ok=True);shutil.copyfile(src,dst)
                assert identity(dst)==identity(src)
                targets[str(relative)]=identity(src)
    receipt=dict(kind='phase48-deferred-aggregate-overlay',variant=a.variant,
        status='unselected',targetExecuted=False,baseline=manifest['baseline'],
        producer=identity(Path(__file__)),manifest=identity(HERE/'manifest.json'),files=targets,
        scope='Overlay only. Use the frozen baseline checked snapshot and seven explicit overlays with snapshot-candidate.py; this tool never modifies maintained source.')
    with (a.out/'overlay-receipt.json').open('x') as f:
        json.dump(receipt,f,indent=2);f.write('\n')
    print(json.dumps(dict(variant=a.variant,files=len(targets),out=str(a.out.resolve()),targetExecuted=False)))


if __name__=='__main__':
    main()

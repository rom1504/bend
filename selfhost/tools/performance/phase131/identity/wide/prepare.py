"""Four bounded field-count overlays on the exact frozen final source."""
import argparse
import importlib.util
import json
from pathlib import Path

ROOT=Path(__file__).resolve().parents[6]
HERE=Path(__file__).resolve().parent
spec=importlib.util.spec_from_file_location('compose',ROOT/'selfhost/tools/performance/phase131/prepare.py')
P=importlib.util.module_from_spec(spec);spec.loader.exec_module(P)
SOURCE=ROOT/'selfhost/build/phase131/combined-literals-source01/compiler.bend'
SHA='1bc5930edcf80cda6c3572645df3c846fa631a83c2b936f20c83b05e0a6728f9'

p=argparse.ArgumentParser(description=__doc__);p.add_argument('--out',type=Path,required=True);a=p.parse_args()
out=a.out.resolve();assert not out.exists() and out.is_relative_to(ROOT/'selfhost/build/phase131')
assert P.pin(SOURCE)['sha256']==SHA
modules=[HERE/'wide.bend',HERE/'controls.bend'];overrides={'nol_fields','nol_ctor_fields','p131rg_width','p118b_project_borrow'}
original=SOURCE.read_text();result,added,protected=P.compose(original,[x.read_text()for x in modules],overrides,set())
before=P.blocks(original);after=P.blocks(result)
assert all(before[name]==after[name]for name in protected)
out.mkdir();(out/'compiler.bend').write_text(result)
for i,m in enumerate(modules):(out/f'module{i}.bend').write_bytes(m.read_bytes())
(out/'prepare.py').write_bytes(Path(__file__).read_bytes())
r=dict(complete=True,checked=False,targetsRun=False,nativeQualified=False,selected=False,
    source=P.pin(out/'compiler.bend'),parent=P.pin(SOURCE),overrides=sorted(overrides),added=added,
    protectedDeclarations=protected,physicalLines=len(result.splitlines()),parentLines=len(original.splitlines()),
    inputs=[P.pin(__file__),P.pin(SOURCE),P.pin(P.__file__),P.pin(P.DIRECT_VERIFIER),*map(P.pin,modules)],
    scope='Only layout telescope/descriptor count, shallow width and exact derived-import contract widen8to16. '
          'Runtime, late field template, request gates and all protected verification declarations unchanged.')
(out/'manifest.json').write_text(json.dumps(r,indent=2)+'\n');print(json.dumps(r['source']))

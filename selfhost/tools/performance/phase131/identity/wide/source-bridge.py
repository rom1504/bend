"""Authenticate the actual compiler declarations copied by the wide fixture."""
import argparse
import importlib.util
import json
from pathlib import Path

ROOT=Path(__file__).resolve().parents[6];HERE=Path(__file__).resolve().parent
spec=importlib.util.spec_from_file_location('p',ROOT/'selfhost/tools/performance/phase131/prepare.py')
P=importlib.util.module_from_spec(spec);spec.loader.exec_module(P)
p=argparse.ArgumentParser(description=__doc__);p.add_argument('--out',type=Path,required=True);a=p.parse_args()
source=ROOT/'selfhost/build/phase131/combined-literals-source01/compiler.bend'
assert P.pin(source)['sha256']=='1bc5930edcf80cda6c3572645df3c846fa631a83c2b936f20c83b05e0a6728f9'
names=['KTerm','KDef','dn','da','p88_string_eq_go','p98_eq_finish','p88_string_eq']
selected=P.blocks(source.read_text());prefix=P.blocks((HERE/'prefix.bend').read_text())
assert set(prefix)==set(names)
for name in names:assert P.norm(selected[name])==P.norm(prefix[name]),name
for case in ['compiler-kdef','record-transfer']:
    fixture=P.blocks((HERE/(case+'.bend')).read_text())
    for name in names:assert P.norm(selected[name])==P.norm(fixture[name]),(case,name)
out=a.out.resolve();assert not out.exists() and out.is_relative_to(ROOT/'selfhost/build/phase131');out.mkdir()
r=dict(complete=True,targetsRun=False,source=P.pin(source),exactDeclarations=names,
    inputs=[P.pin(__file__),P.pin(P.__file__),P.pin(source),*[P.pin(HERE/x)for x in ['prefix.bend','compiler-kdef.bend','record-transfer.bend']]],
    scope='Normalized exact declaration bridge, ignoring comments and whitespace only. Workload constructors/oracles and generated runtime semantics are separate checks.')
(out/'report.json').write_text(json.dumps(r,indent=2)+'\n');print(json.dumps(dict(complete=True,names=names)))

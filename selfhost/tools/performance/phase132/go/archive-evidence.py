"""Copy compact Go experiment evidence without executables or cache trees."""
import hashlib
import json
from pathlib import Path
import shutil

ROOT=Path(__file__).resolve().parents[5]
OUT=ROOT/'implementation/phase132/evidence/go'
OUT.mkdir(parents=True,exist_ok=True)
assert not (OUT/'archive-index.json').exists()
copied=[]


def keep(source,dest):
    source=ROOT/source;dest=OUT/dest
    data=source.read_bytes();data.decode('utf-8');assert b'\0' not in data
    dest.parent.mkdir(parents=True,exist_ok=True);assert not dest.exists()
    shutil.copyfile(source,dest)
    assert dest.read_bytes()==data
    copied.append(dict(original=str(source),archive=str(dest.relative_to(OUT)),
        bytes=len(data),sha256=hashlib.sha256(data).hexdigest()))


for run in ('go-cache01','go-cache02'):
    origin=Path('selfhost/build/phase132')/run
    for name in ('report.json','method.py','version.stdout','version.stderr'):
        keep(origin/name,Path(run)/name)
    for stage in sorted((ROOT/origin).glob('[0-9][0-9]-*')):
        for source in sorted(stage.rglob('*')):
            if not source.is_file():continue
            rel=source.relative_to(ROOT/origin)
            if 'source' in rel.parts or source.name in (
                'build.stdout','build.stderr','execute.stdout','execute.stderr','list.stdout','list.stderr'):
                keep(source.relative_to(ROOT),Path(run)/rel)
    origin=Path('selfhost/build/phase132')/(run+'-guard')
    for name in ('process.json','inputs.json','method.json','stdout.log','stderr.log'):
        keep(origin/name,Path(run+'-guard')/name)
keep(Path('selfhost/build/phase132/go-analysis01/report.json'),Path('analysis/report.json'))
keep(Path('selfhost/tools/performance/phase132/go/analyze.py'),Path('analysis/method.py'))
keep(Path(__file__).relative_to(ROOT),Path('archive-method.py'))
report=dict(complete=True,targetsRun=False,files=copied,
    archivedBytes=sum(x['bytes'] for x in copied),
    scope='Exact UTF-8 source/command/result copies; binaries, archives, binary export data and build cache trees omitted. Original absolute paths in receipts are provenance, not required archive locations. Use this mapping to locate retained copies. Primary-source receipts and README are tracked separately.')
(OUT/'archive-index.json').write_text(json.dumps(report,indent=2)+'\n')
print(json.dumps(dict(complete=True,files=len(copied),bytes=report['archivedBytes'],out=str(OUT))))

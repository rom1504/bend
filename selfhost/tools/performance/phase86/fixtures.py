#!/usr/bin/env python3
"""Freeze closed-module pilot inputs; preserve reused workload bodies verbatim."""
import hashlib,json
from pathlib import Path
ROOT=Path(__file__).resolve().parents[4]
out=ROOT/'selfhost/build/phase86/fixtures';out.mkdir(exist_ok=False)
rows={}
for name,file,size in [('numeric_closed','numeric-recurrence.bend',1024),('map_closed','map-churn.bend',128)]:
    original=ROOT/'selfhost/tools/performance/phase37/fixtures-new'/file
    suffix=f'\n# Phase86: closed-module entry; original workload body above is unchanged.\ndef main() -> IO(Unit):\n  IO.print(U32.show(bench({size}, 123)))\n'
    target=out/(name+'.bend');target.write_bytes(original.read_bytes()+suffix.encode())
    rows[name]=dict(file=str(target),original=str(original),originalSha256=hashlib.sha256(original.read_bytes()).hexdigest(),append=suffix)
for name,text in {
    'unicode':'import Base\n\ndef main() -> IO(Unit):\n  IO.print("😀🦋猫")\n',
    'type_error':'import Base\n\ndef main() -> U32:\n  True{}\n',
    'parse_error':'import Base\n\ndef main( -> U32:\n  42\n',
    'extra_import':'import Base\nimport Missing\n\ndef main() -> U32:\n  42\n',
}.items():
    target=out/(name+'.bend');target.write_text(text);rows[name]=dict(file=str(target))
(out/'provenance.json').write_text(json.dumps(rows,indent=2)+'\n')
print(out)

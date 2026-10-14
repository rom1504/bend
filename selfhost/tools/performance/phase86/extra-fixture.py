#!/usr/bin/env python3
"""A valid additional-import control, after the original hit a syntax error."""
import hashlib,json
from pathlib import Path
ROOT=Path(__file__).resolve().parents[4]
out=ROOT/'selfhost/build/phase86/fixtures-extra';out.mkdir(exist_ok=False)
files={
    'main.bend':'import Base\nimport ./helper.bend as Helper\n\ndef main() -> U32:\n  Helper.answer()\n',
    'helper.bend':'import Base\n\ndef answer() -> U32:\n  42\n',
}
records=[]
for name,text in files.items():
    f=out/name;f.write_text(text);records.append(dict(file=str(f),sha256=hashlib.sha256(f.read_bytes()).hexdigest()))
(out/'provenance.json').write_text(json.dumps(dict(reason='Original extra_import used invalid import syntax and exercised only parser refusal. This valid source graph distinguishes pilot scope rejection from an ordinary B2 success.',files=records),indent=2)+'\n')

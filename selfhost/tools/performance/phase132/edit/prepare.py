#!/usr/bin/env python3
"""Freeze one real emitter-source edit; this is an incremental-build witness."""
import hashlib
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[5]
SOURCE = ROOT/'selfhost/build/phase131/combined-literals-source01/compiler.bend'
OUT = ROOT/'selfhost/build/phase132/source-edit01'

def pin(path):
    p=Path(path).resolve(); h=hashlib.sha256()
    with p.open('rb') as f:
        for b in iter(lambda:f.read(1048576),b''): h.update(b)
    return dict(file=str(p),bytes=p.stat().st_size,sha256=h.hexdigest())

assert not OUT.exists()
before=SOURCE.read_text()
assert pin(SOURCE)['sha256']=='1bc5930edcf80cda6c3572645df3c846fa631a83c2b936f20c83b05e0a6728f9'
begin=before.index('def p111q_main() -> String:\n')
end=before.index('\n\n',begin)
old=before[begin:end]
assert old.count('%result')==2 and '%answer' not in old
new=old.replace('%result','%answer')
after=before[:begin]+new+before[end:]
assert len(after.encode())==len(before.encode())
assert after[:begin]==before[:begin] and after[end:]==before[end:]
OUT.mkdir()
(OUT/'compiler.bend').write_text(after)
(OUT/'before.bend').write_text(old+'\n')
(OUT/'after.bend').write_text(new+'\n')
report=dict(complete=True,sourceChecked=False,inputs=[pin(__file__),pin(SOURCE)],
    source=pin(OUT/'compiler.bend'),before=pin(OUT/'before.bend'),after=pin(OUT/'after.bend'),
    changedDeclarations=['p111q_main'],changedLiteralOccurrences=2,sourceBytesUnchanged=True,
    producer=pin(ROOT/'selfhost/build/phase111/p131-final-native01-n2/program'),
    baselineQbe=pin(ROOT/'selfhost/build/phase130/p131-final-self01/program.ssa'),
    scope='Experimental emitter spelling edit only: generated main local %result becomes %answer. Runtime/public ABI and all other source bytes remain unchanged. Not a production promotion or an incremental frontend.')
(OUT/'report.json').write_text(json.dumps(report,indent=2)+'\n')
print(json.dumps(report))

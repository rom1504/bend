#!/usr/bin/env python3
"""Derive source-bound self-check/fixed-point/native methods; execute no target."""
import argparse
import hashlib
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[6]
RAW = ROOT / 'selfhost/build/phase66'
PARENT = ROOT / 'selfhost/build/phase65/qualification-method01/methods.json'
PARENT_SHA = 'dbfc1a96c1c0bf1dd0c29e26cbdd9df119eec160568f6ea56fe15ee557796a22'
NAMES = {'bootstrap/setup.mjs', 'bootstrap/reproduce.mjs',
         'qualification/self-check.mjs', 'qualification/checked-image.mjs',
         'qualification/native3.mjs'}


def pin(value):
    file = Path(value['file'] if isinstance(value, dict) else value).resolve(strict=True)
    actual = dict(file=str(file), sha256=hashlib.sha256(file.read_bytes()).hexdigest())
    if isinstance(value, dict):
        assert actual['sha256'] == value['sha256'], file
    return actual


p = argparse.ArgumentParser(description=__doc__)
p.add_argument('--out', type=Path, required=True)
a = p.parse_args()
out = a.out.resolve()
assert out.parent == RAW.resolve() and not out.exists()
assert pin(PARENT)['sha256'] == PARENT_SHA
parent = json.loads(PARENT.read_text())
assert parent['complete'] and parent['targetsExecuted'] is False
inputs = [pin(__file__), pin(PARENT)]
rows = []
for original in parent['rows']:
    relative = original['relative']
    if relative not in NAMES:
        continue
    source = pin(original['output'])
    text = Path(source['file']).read_text()
    edits = []

    def change(old, new):
        global text
        count = text.count(old)
        assert count, (relative, old)
        text = text.replace(old, new)
        edits.append(dict(old=old, new=new, occurrences=count))

    if 'selfhost/build/phase65' in text:
        change('selfhost/build/phase65', 'selfhost/build/phase66')
    if 'inside Phase65' in text:
        change('inside Phase65', 'inside Phase66')
    if relative == 'bootstrap/setup.mjs':
        change("  const bootstrap=read(emission.subject.bootstrap),config=read(emission.config);",
               "  const bootstrap=read(emission.subject.bootstrap),config=read(emission.config);\n"
               "  assert.equal(bootstrap.revision,'059266225b77c8ca256ac6b25ee5c21449bab151');\n"
               "  assert.equal(bootstrap.baseSha256,'99ac43f2b2bb3e3f39acdcedcecbbd3cb44749ce13969c827d6973fa66f7facf');")
    if relative == 'qualification/checked-image.mjs':
        change('import {verifyAttempt} from "file:///home/ai/bend2/build/publish/bend/selfhost/tools/development/workflow.mjs";\n', '')
        change(" const attempt=await verifyAttempt(directory);",
               " const declared=JSON.parse(fs.readFileSync(path.join(directory,'attempt.json'),'utf8'));\n"
               " const frozenWorkflow=pin(path.join(declared.snapshot.root,'tools/development/workflow.mjs'));\n"
               " assert(declared.snapshot.sources.some(row=>row.frozen.file===frozenWorkflow.file&&row.frozen.sha256===frozenWorkflow.sha256),'Workflow must belong to the original snapshot');\n"
               " const {verifyAttempt}=await import(pathToFileURL(frozenWorkflow.file));\n"
               " const attempt=await verifyAttempt(directory);")
        change('new URL("file:///home/ai/bend2/build/publish/bend/selfhost/tools/development/workflow.mjs"),',
               'frozenWorkflow.file,')
    if relative == 'qualification/native3.mjs':
        change("exact complete C-byte equality, separately staged private baseline and candidate caches.",
               "complete C-byte comparison reported descriptively across the upstream migration, separately staged private baseline and candidate caches.")
        change("assert(row.byteEqual,id);row.pass=true;",
               "row.byteEqualityScope='Descriptive old/new compiler comparison: migration changes may alter correct C bytes; both independent stdout oracles remain mandatory.';row.pass=true;")
    replay = Path(source['file']).read_text()
    for edit in edits:
        assert replay.count(edit['old']) == edit['occurrences']
        replay = replay.replace(edit['old'], edit['new'])
    assert replay == text
    inputs.append(source)
    rows.append(dict(relative=relative, parent=source, edits=edits, text=text))
assert {row['relative'] for row in rows} == NAMES
for item in inputs:
    pin(item)
out.mkdir(parents=True)
for row in rows:
    target = out / row['relative']
    target.parent.mkdir(parents=True, exist_ok=True)
    with target.open('x') as stream:
        stream.write(row.pop('text'))
    row['output'] = pin(target)
result = dict(kind='phase66-core-qualification-methods', complete=True,
              dataOnly=True, targetsExecuted=False, producer=pin(__file__),
              parent=pin(PARENT), inputs=inputs, rows=rows,
              scope='Fresh B2 own-source type check and full B2/B3 byte equality retain their exact gates. Native baseline/candidate use their own original frozen workflow and still require all three independent stdout oracles; old/new C byte equality is descriptive because the upstream ABI changed. No target, semantic qualification or release admission is established by this factory.')
with (out/'methods.json').open('x') as stream:
    stream.write(json.dumps(result, indent=2)+'\n')
print(json.dumps(dict(methods=pin(out/'methods.json'), files=len(rows), targetsExecuted=False)))

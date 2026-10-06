#!/usr/bin/env python3
"""Derive image-provenance successors; preserve every semantic oracle body."""
import hashlib
import json
from pathlib import Path

here = Path(__file__).resolve().parent
old = here.parents[1] / 'phase53'


def identity(file):
    return dict(file=str(file.resolve()), sha256=hashlib.sha256(file.read_bytes()).hexdigest())


def once(text, before, after):
    assert text.count(before) == 1, before
    return text.replace(before, after)


parents = [
    ('semantic-source-v1.mjs', 'e4d13b112787ee5b217a9821c5ef2e47e01cd797c18dce0c7ab8834a58379c98', 'source-controls.mjs'),
    ('semantic-runtime-v2.mjs', '77dfb7094d437d304f65c2de99da0e15600d9161d0b8b528156aca7ca76336a3', 'numeric-controls.mjs'),
    ('semantic-composition-v3.mjs', 'f715c8afccabb197e8922bdc2a0dcb847e2735e3751acc6c58f29efdd1201a1a', 'composition-controls.mjs'),
    ('semantic-overapplication-v1.mjs', 'acece432d04089e6e8861b5a1897a5e906f7eb86b1b105d80e18c71d80b86dca', 'overapplication-controls.mjs')]
rows = []
for name, expected, output in parents:
    parent = old / name
    assert identity(parent)['sha256'] == expected
    original = parent.read_text()
    text = original.replace("path.join(import.meta.dirname,", "path.join(retained53,")
    text = once(text, "import {spawnSync} from 'node:child_process';",
                "import {spawnSync} from 'node:child_process';\nimport {readImage,sameImage,verifyImageEmission} from './image-provenance.mjs';\nconst retained53=path.resolve(import.meta.dirname,'../../phase53');")
    text = text.replace("kind:'phase53-", "kind:'phase56-b2-")
    if output == 'source-controls.mjs':
        text = once(text, 'verify(defect.source,import.meta.dirname)', 'verify(defect.source,retained53)')
        text = once(text, 'verify(defect.parentController,import.meta.dirname)', 'verify(defect.parentController,retained53)')
        text = once(text,
            "const selectedAttempt=verify(m.roles.direct.attempt,path.dirname(path.resolve(manifestFile)));",
            "const selectedImage=readImage(m.roles.direct.image,path.dirname(path.resolve(manifestFile)));")
        start = text.index('const selected=JSON.parse(fs.readFileSync(selectedAttempt')
        end = text.index('\nconst directIdentity={};', start)
        text = text[:start] + "const acquisitionFile=path.resolve(manifestFile),acquisition=m;assert(acquisition.complete&&acquisition.passed);" + text[end:]
        text = once(text, 'inputs:[identity(selectedAttempt),identity(acquisitionFile),',
                    'inputs:[...selectedImage.inputs,identity(acquisitionFile),identity(new URL(\'./image-provenance.mjs\',import.meta.url)),')
        start = text.index("   if(role==='direct'){")
        end = text.index('\n   else ', start)
        text = text[:start] + "   if(role==='direct'){verifyImageEmission(receipt,selectedImage,row=>report.inputs.push(row));}" + text[end:]
        marker = '  for(const test of c.tests){'
    else:
        if output == 'numeric-controls.mjs':
            start = text.index(' const attemptFile=verify(standard.roles.direct.attempt')
            end = text.index('\n const catalogFile=', start)
            replacement = " const selectedImage=readImage(standard.roles.direct.image,path.dirname(path.resolve(standardFile))),numericImage=readImage(direct.roles.direct.image,path.dirname(path.resolve(directFile)));sameImage(selectedImage,numericImage);report.inputs.push(...selectedImage.inputs,...numericImage.inputs);"
        else:
            start = text.index(' const attemptFile=verify(direct.roles.direct.attempt')
            end = text.index('\n const catalogFile=', start)
            replacement = " const selectedImage=readImage(direct.roles.direct.image,path.dirname(path.resolve(directFile)));report.inputs.push(...selectedImage.inputs);"
        text = text[:start] + replacement + text[end:]
        start = text.index("  if(role==='direct'){")
        end = text.index("  }else{assert.equal(receipt.compiler.kind,'checked-pinned-typescript')", start)
        text = text[:start] + "  if(role==='direct'){\n   verifyImageEmission(receipt,selectedImage,row=>report.inputs.push(row));\n" + text[end:]
        text = once(text, 'pin(import.meta.filename);', "pin(import.meta.filename);pin(new URL('./image-provenance.mjs',import.meta.url));")
        marker = ' function execute('
    # The entire actual execution/oracle/count/exit section remains exact.
    oracle = original[original.index(marker):]
    assert text[text.index(marker):] == oracle
    text = once(text, "const out=path.resolve(", "const retainedParent=" + json.dumps(str(parent)) + ";\nconst out=path.resolve(")
    if output == 'source-controls.mjs':
        text = once(text, 'identity(import.meta.filename),identity(worker)',
                    'identity(import.meta.filename),identity(retainedParent),identity(worker)')
    else:
        text = once(text, 'pin(import.meta.filename);', 'pin(import.meta.filename);pin(retainedParent);')
    assert text[text.index(marker):] == oracle
    target = here / output
    with target.open('x') as stream:
        stream.write(text)
    rows.append(dict(parent=identity(parent), successor=identity(target),
                     oracleTailSha256=hashlib.sha256(oracle.encode()).hexdigest(),
                     oracleTailByteIdentical=True,
                     changes='Provenance admission uses explicit B2 image/checked program receipts; retained worker/reference paths and report kind are rebound. No execution, oracle, count or exception policy changes.'))
with (here / 'controls-derivation.json').open('x') as stream:
    json.dump(dict(kind='phase56-semantic-controller-derivation', complete=True, dataOnly=True,
                   producer=identity(Path(__file__)), helper=identity(here / 'image-provenance.mjs'),
                   rows=rows, targetExecuted=False), stream, indent=2)
    stream.write('\n')
print(json.dumps(dict(complete=True, targetExecuted=False, controllers=len(rows))))

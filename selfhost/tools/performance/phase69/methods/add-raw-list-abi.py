#!/usr/bin/env python3
"""Create new raw-case modules with the inherited minimal List runtime ABI."""
import hashlib
import json
from pathlib import Path

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[4]


def pin(p):
    p = p.resolve(strict=True)
    b = p.read_bytes()
    return dict(file=str(p), sha256=hashlib.sha256(b).hexdigest(), bytes=len(b))


abi = '''// Match the existing raw12 runtime ABI, without moving an existing
// declaration or changing a BookCache payload/source index. Constructor-table
// discovery scans the physical declaration list; source lookup stays unchanged.
const runtimeListType69 = t('ADT', 'List', [t('ADT', 'U32')]);
const runtimeList69 = {...def('List', t('Absent'), t('Typ')),
  kind: 'ADT', native: true,
  ctors: list([
    {...def('Nil', t('Absent'), runtimeListType69), kind: 'Ctr', arity: 0, native: true},
    {...def('Con', t('Absent'), all(78, t('ADT', 'U32'),
      all(79, runtimeListType69, runtimeListType69))), kind: 'Ctr', arity: 2, native: true},
  ])};
const withRuntimeList69 = book => Array.isArray(book) ? [...book, runtimeList69]
  : book.$ === 'Nil' ? list([runtimeList69])
  : {$: 'Con', head: book.head, tail: withRuntimeList69(book.tail)};

'''
paths = [
    ('reachability/controls/raw-cases.mjs', 'reachability/controls/raw-cases-v2.mjs', 'rawCases'),
    ('static-data/raw-review-cases.mjs', 'static-data/raw-review-cases-v2.mjs', 'rawStaticCases'),
    ('closure-factory/raw-combinator-cases-v4.mjs', 'closure-factory/raw-combinator-cases-v5.mjs', 'rawCases'),
]
outputs = []
for source, destination, export in paths:
    parent, output = HERE.parent/source, HERE.parent/destination
    text = parent.read_text()
    marker = 'export const '+export+' = ['
    assert text.count(marker) == 1 and text.endswith('];\n')
    edits = [dict(before=marker, after=abi+marker, count=1),
             dict(before='];\n', after='].map(test => ({...test, book: withRuntimeList69(test.book)}));\n',
                  scope='final module suffix only')]
    after = text.replace(marker, abi+marker)
    after = after[:-3] + edits[1]['after']
    with output.open('x') as f:
        f.write(after)
    record = dict(kind='phase69-raw-runtime-list-abi-correction', producer=pin(Path(__file__)),
                  parent=pin(parent), output=pin(output), edits=edits,
                  abiReference=pin(ROOT/'selfhost/tools/performance/phase68/controls/raw-controls-v7.mjs'),
                  dataOnly=True, targetsExecuted=False,
                  scope='Append one native List ADT to each outer raw book, preserving existing declaration order and ordinal positions, term bytes, expectations and BookCache payloads/index. Existing physical constructor discovery supplies CID_NIL/CID_CON; this repairs invalid native fixture packaging, not a compiler change.')
    with output.with_suffix('.derivation.json').open('x') as f:
        json.dump(record, f, indent=2)
        f.write('\n')
    outputs.append(pin(output))
print(json.dumps(dict(outputs=outputs, targetsExecuted=False)))

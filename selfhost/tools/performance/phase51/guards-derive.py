#!/usr/bin/env python3
"""Create an unqualified, same-check String guard batching experiment; execute nothing."""
import argparse
import hashlib
import json
from pathlib import Path

OLD_CAPTURE = 'const stringHostOwnKeys=Reflect.ownKeys;'
NEW_CAPTURE = 'const stringHostOwnKeys=Reflect.ownKeys,stringHostDescriptors=Object.getOwnPropertyDescriptors;'
OLD = """function stringHostGuard(){if(!stringHostDescriptor(regionGetDescriptor(globalThis,'String'),stringHostGlobal))return false;
 for(let i=0;i<stringHostRows.length;i++){const row=stringHostRows[i];if(regionGetPrototype(row.object)!==row.parent)return false;const keys=stringHostOwnKeys(row.object);if(keys.length!==row.keys.length)return false;
  for(let k=0;k<keys.length;k++)if(keys[k]!==row.keys[k]||!stringHostDescriptor(regionGetDescriptor(row.object,keys[k]),row.descriptors[keys[k]]))return false;}
 return true;}"""
NEW = """function stringHostGuard(){if(!stringHostDescriptor(regionGetDescriptor(globalThis,'String'),stringHostGlobal))return false;
 for(let i=0;i<stringHostRows.length;i++){const row=stringHostRows[i];if(regionGetPrototype(row.object)!==row.parent)return false;const descriptors=stringHostDescriptors(row.object),keys=stringHostOwnKeys(descriptors);if(keys.length!==row.keys.length)return false;
  for(let k=0;k<keys.length;k++)if(keys[k]!==row.keys[k]||!stringHostDescriptor(descriptors[keys[k]],row.descriptors[keys[k]]))return false;}
 return true;}"""

def identity(path):
    p = Path(path).resolve(strict=True); data = p.read_bytes()
    return dict(file=str(p), bytes=len(data), sha256=hashlib.sha256(data).hexdigest())

p = argparse.ArgumentParser(description=__doc__)
p.add_argument('--module', type=Path, required=True)
p.add_argument('--sha256', required=True)
p.add_argument('--out', type=Path, required=True)
a = p.parse_args()
assert not a.out.exists(), 'Fresh output only'
source = identity(a.module); producer = identity(__file__)
assert source['sha256'] == a.sha256, 'Source pin differs'
original = a.module.read_bytes(); text = original.decode()
assert text.count(OLD_CAPTURE) == text.count(OLD) == 1
assert 'stringHostDescriptors' not in text
changed = text.replace(OLD_CAPTURE, NEW_CAPTURE).replace(OLD, NEW)
assert changed.replace(NEW_CAPTURE, OLD_CAPTURE).replace(NEW, OLD).encode() == original
a.out.mkdir(parents=True)
target = a.out / 'batched-string-guard.mjs'; target.write_text(changed)
(a.out / 'consumed-guards-derive.py').write_bytes(Path(__file__).read_bytes())
assert identity(a.module) == source and identity(__file__) == producer
report = dict(kind='phase51-batched-string-guard', complete=True, parent=source, candidate=identity(target), producer=producer,
              targetExecution=False, qualified=False, installed=False, edits=[dict(old=OLD_CAPTURE,new=NEW_CAPTURE),dict(old=OLD,new=NEW)],
              hypothesis='Captured ordinary String objects permit inert batched descriptor inspection. Preserve every global/prototype/key-order/descriptor comparison freshly per entry; no cache or omitted check.',
              caveat='Additional descriptor-map allocation may cost more than individual native calls. Controls and clean timing must precede production consideration.')
(a.out / 'derivation.json').write_text(json.dumps(report, indent=2) + '\n')
print(json.dumps(dict(complete=True, report=identity(a.out / 'derivation.json'))))

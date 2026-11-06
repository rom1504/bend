#!/usr/bin/env python3
"""Extract supplemental pure controls from the exact frozen candidate source."""
import argparse
import importlib.util
import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
sys.dont_write_bytecode = True
sys.path.insert(0, str(ROOT / 'selfhost/tools/build'))
from common import pin, verify, fresh_output, write_json, require
import source as assembly

p = argparse.ArgumentParser(description=__doc__)
p.add_argument('--out', type=Path, required=True)
p.add_argument('--parent', type=Path, default=ROOT / 'selfhost/build/phase169/single-verify-api-source01/manifest.json')
a = p.parse_args()
parent = json.loads(a.parent.read_text())
require(parent['complete'], 'Complete frozen parent required')
verify(parent['source'])
require(parent['source']['sha256'] == 'bb75f86c8d32d74c9ce7d44885601b0e82eacc7e57464e1adf632721423e7a2f',
        'Unexpected candidate source; create a new preparation version')
module = ROOT / 'selfhost/tests/phase169/verifier-order-controls-v2.bend'
extractor = ROOT / 'experiments/phase147/tools/prepare.py'
spec = importlib.util.spec_from_file_location('phase169_order_extract', extractor)
E = importlib.util.module_from_spec(spec); spec.loader.exec_module(E)
original = Path(parent['source']['file']).read_bytes()
_, old = assembly.blocks(original)
_, extra = assembly.blocks(module.read_bytes())
require(not ({r['name'] for r in old} & {r['name'] for r in extra}), 'Supplement replaces parent declarations')
exports = ['p169svo_controls', 'p169svo_rows']
selected, inventory = E.extract([('frozen-single-verifier', original), ('supplemental-order-controls', module.read_bytes())],
                                exports, 2_000_000)
out = fresh_output(a.out, ROOT)
(out / 'compiler.bend').write_bytes(selected)
write_json(out / 'exports.json', dict(kind='bend-hosted-api-exports', version=1,
    exports=exports, protocol='hosted-api-v1', targets=['qbe'], preparationModes=['live'],
    scope='Pure finite verifier error-order controls; no malformed program execution'))
write_json(out / 'manifest.json', dict(complete=True, targetsRun=False, replacements=[],
    source=pin(out / 'compiler.bend'), exports=exports, declarations=inventory,
    inputs=[pin(__file__), pin(a.parent), parent['source'], pin(module), pin(extractor), pin(assembly.__file__)],
    parentSourceUnchanged=True))
print(json.dumps(dict(source=pin(out / 'compiler.bend'), declarations=len(inventory), targetsRun=False)))

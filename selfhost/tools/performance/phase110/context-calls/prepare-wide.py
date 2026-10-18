#!/usr/bin/env python3
"""Freeze a synthetic eight-owner ABI witness and independent oracle; data only."""
import argparse
import hashlib
import json
from pathlib import Path
HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[4]
def pin(path):
    data = path.read_bytes()
    return dict(file=str(path.resolve()), bytes=len(data), sha256=hashlib.sha256(data).hexdigest())
def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--source', type=Path, required=True)
    p.add_argument('--out', type=Path, required=True)
    a = p.parse_args(); out = a.out.resolve()
    if out.exists() or not out.is_relative_to(ROOT / 'selfhost/build/phase110'):
        raise ValueError('fresh Phase110 output required')
    source = a.source.read_text(); module = HERE / 'wide.bend'; harness = HERE / 'wide-controls.c'
    if 'def nx110ctx_verify(' not in source or 'def nx110ctx_wide_source(' in source:
        raise ValueError('one existing context facade and no earlier wide module required')
    out.mkdir(); (out / 'source.bend').write_text(source + '\n\n' + module.read_text())
    (out / 'harness.c').write_bytes(harness.read_bytes())
    values = ['alpha', 'bravo', 'charlie', 'delta', 'echo', 'foxtrot', 'golf', 'hotel']
    expected = [dict(name='wide-' + name, dropOrder=order, result='hotel',
                    aliases=values if name == 'shared' else ['hotel'], released=True)
                for name in ['unique', 'shared'] for order in ['result-first', 'aliases-first']]
    (out / 'expected.jsonl').write_text(''.join(json.dumps(row, separators=(',', ':')) + '\n' for row in expected))
    exports = ['nx110ctx_wide_source', 'nx110ctx_wide_qbe', 'nx110ctx_wide_c', 'nx110ctx_wide_report']
    command = [str(ROOT / 'selfhost/.bootstrap/bun-1.4.3/bun'), str(ROOT / 'selfhost/tools/stage0-library.mjs'),
               str(out / 'source.bend'), str(out / 'api.mjs'), *exports]
    record = dict(kind='phase110-context-wide-source', complete=True, targetsRun=False,
        synthetic=True, source=pin(out / 'source.bend'), inputs=[pin(a.source), pin(module), pin(harness), pin(Path(__file__))],
        outputs=[pin(out / 'source.bend'), pin(out / 'harness.c'), pin(out / 'expected.jsonl')],
        exports=exports, command=command, observations=4, modes=['baseline', 'threaded', 'context'], backends=['qbe', 'clang'],
        ownership='Eight distinct owning arguments; leaf sinks first seven and returns eighth; unique and independently aliased shared inputs, both output/alias release orders, zero pending/live.',
        scope='Synthetic machine ABI qualification beyond six registers: public/context9 arguments, threaded11; not an actual-source workload or selection input')
    (out / 'manifest.json').write_text(json.dumps(record, indent=2) + '\n')
    print(out / 'manifest.json')
if __name__ == '__main__': main()

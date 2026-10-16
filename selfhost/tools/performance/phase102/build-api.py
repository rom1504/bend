#!/usr/bin/env python3
"""Acquire a checked testing API from an exact reversible Bend source recipe."""
import argparse
from pathlib import Path
import sys
import time
sys.dont_write_bytecode = True
ROOT = Path(__file__).resolve().parents[4]
sys.path.insert(0, str(ROOT / 'selfhost/tools/performance/phase100'))
import run as R

EXPORTS = ['p86_prepare', 'p86_plan', 'p86_effect_file', 'kf_source',
           'nc_foreign_source', 'nr_compile_prepared', 'nc_compile_checked',
           'nr_prepare', 'nc_compile', 'nc_foreign_paths']


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--recipe', type=Path, required=True)
    p.add_argument('--out', type=Path, required=True)
    p.add_argument('--exports', default='')
    a = p.parse_args(); out = a.out.resolve(); out.mkdir(parents=True, exist_ok=False)
    report = dict(complete=False, started=time.time(), method=R.pin(__file__), recipe=R.pin(a.recipe),
                  scope='Checked upstream-built JavaScript testing API for the compiler written in Bend; not native B1/B2 qualification.')
    def save(): R.save(out/'report.json', report)
    save()
    try:
        recipe = R.read(a.recipe); assert recipe['complete']
        for name in ('source', 'candidate'): R.verify(recipe[name])
        before = Path(recipe['source']['file']).read_text(); text = before
        for change in recipe['changes']:
            at, old, new = change['offset'], change['old'], change['new']
            assert text[at:at+len(old)] == old
            text = text[:at] + new + text[at+len(old):]
        assert text == Path(recipe['candidate']['file']).read_text()
        for change in reversed(recipe['changes']):
            at, old, new = change['offset'], change['old'], change['new']
            assert text[at:at+len(new)] == new
            text = text[:at] + old + text[at+len(new):]
        assert text == before
        _, context = R.authenticate(); report['context'] = context
        node = R.pin('/home/ai/.nvm/versions/node/v24.18.0/bin/node')
        method = R.pin(ROOT/'selfhost/tools/stage0-library.mjs')
        report.update(source=recipe['candidate'], node=node, acquisitionMethod=method,
                      exports=EXPORTS + ([v for v in a.exports.split(',') if v]))
        (out/'compiler.bend').write_bytes(Path(recipe['candidate']['file']).read_bytes())
        report['snapshot'] = R.pin(out/'compiler.bend'); save()
        api = out/'checked-api.mjs'
        report['job'], _ = R.guarded(out/'acquire', ['env',
            'BEND_UPSTREAM=' + str(ROOT/'selfhost/.bootstrap/upstream-phase66'), node['file'],
            '--stack-size=65536', '--max-old-space-size=1536', method['file'],
            recipe['candidate']['file'], str(api), *report['exports']], seconds=180)
        report['api'] = R.pin(api)
        for item in [report['method'], report['recipe'], report['source'], node, method,
                     *context['inputs']]: R.verify(item)
        report['complete'] = True
    except BaseException as error:
        report['error'] = repr(error); raise
    finally: report['finished'] = time.time(); save()


if __name__ == '__main__': main()

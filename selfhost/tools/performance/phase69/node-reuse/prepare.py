#!/usr/bin/env python3
"""Prepare pinned cold-store/reuse saved-C arms; source/data work only."""
import argparse
import hashlib
import importlib.util
import json
import os
from pathlib import Path
import re
import sys
sys.dont_write_bytecode = True
ROOT = Path(__file__).resolve().parents[5]
SURVEY = ROOT / 'selfhost/tools/performance/phase68/parity-survey/run.py'
spec = importlib.util.spec_from_file_location('p69_reuse_inputs', SURVEY)
R = importlib.util.module_from_spec(spec)
spec.loader.exec_module(R)
NAME = '../phase37/fixtures-historical/tree-bitonic:warp_zip'
NODE = 'CID__CTOR_' + ''.join(str(ord(c)) + '_' for c in '../phase37/fixtures-historical/tree-bitonic:Node')
SYMBOL = 'NF_FID_' + ''.join(str(ord(c)) + '_' for c in NAME)


def identity(p):
    p = Path(p).resolve()
    return dict(path=str(p), sha256=hashlib.sha256(p.read_bytes()).hexdigest(), bytes=p.stat().st_size)


def replace(source, before, after, edits, why):
    assert source.count(before) == 1, (why, source.count(before))
    off = source.index(before)
    edits.append(dict(before=before, after=after, offsetInParent=off,
                      lineInParent=source.count('\n', 0, off) + 1, why=why))
    return source[:off] + after + source[off+len(before):]


def worker(source):
    matches = list(re.finditer(r'^INLINE Term ' + re.escape(SYMBOL) + r'\([^\n]*\) \{', source, re.M))
    assert len(matches) == 1
    m = matches[0]; end = m.end(); depth = 1
    while depth:
        assert source[end] not in '\"\''
        depth += (source[end] == '{') - (source[end] == '}')
        end += 1
    return m.start(), end, source[m.start():end]


def reuse(source, edits):
    start, end, body = worker(source)
    pairs = [
      ('spare_free(e, cls_fit(2), ctr_take(e, v_4294967293, 2, fields));',
       'Loc p69_spare_left = ctr_take(e, v_4294967293, 2, fields);'),
      ('spare_free(e, cls_fit(2), ctr_take(e, v_4294967292, 2, fields));',
       'Loc p69_spare_right = ctr_take(e, v_4294967292, 2, fields);'),
      ('u64 nd_24 = heap_alloc(e, cls_fit(2));',
       'u64 nd_24 = p69_spare_left >= HEAP_OFF ? p69_spare_left : heap_alloc(e, cls_fit(2));'),
      ('u64 nd_19 = heap_alloc(e, cls_fit(2));',
       'u64 nd_19 = p69_spare_right >= HEAP_OFF ? p69_spare_right : heap_alloc(e, cls_fit(2));'),
      ('return 1;\n} else {\nterm_sink(e, v_4294967289);',
       'return 1;\n} else {\nspare_free(e, cls_fit(2), p69_spare_left);\nterm_sink(e, v_4294967289);')]
    newbody = body
    local = []
    for before, after in pairs:
        newbody = replace(newbody, before, after, local, 'owned compatible local spare')
    return replace(source, body, newbody, edits, 'zipper reuse; preserve RFC/static fallback and branch cleanup')


def cold(source, edits):
    # Match the complete constructor build, including its exact constructor ID.
    # Whitespace is kept byte-for-byte; no runtime helper or unknown store changes.
    pattern = (r'(?P<alloc>^[ \t]*u64 (?P<nd>nd_[0-9]+) = [^\n]+;\n)'
      r'(?P<store0>^[ \t]*e.mem\[(?P=nd) \+ 0\] = )rfc_seal\(e, (?P<a>\w+)\);\n'
      r'(?P<store1>^[ \t]*e.mem\[(?P=nd) \+ 1\] = )rfc_seal\(e, (?P<b>\w+)\);\n'
      r'(?P<result>^[^\n]*?term_ctr\(' + re.escape(NODE) + r', (?P=nd)\);)')
    matches = list(re.finditer(pattern, source, re.M))
    assert len(matches) == 13, len(matches)
    for m in reversed(matches):
        before = m.group(0)
        after = m['alloc'] + m['store0'] + m['a'] + ';\n' + m['store1'] + m['b'] + ';\n' + m['result']
        source = replace(source, before, after, edits, 'known cold parent Node: move fields without eager seals')
    return source


def reverse(source, edits):
    for e in reversed(edits):
        off = e['offsetInParent']
        assert source[off:off+len(e['after'])] == e['after']
        source = source[:off] + e['before'] + source[off+len(e['after']):]
    return source


def main():
    assert os.sched_getaffinity(0) == {0}, 'source preparation belongs on CPU0'
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument('--out', type=Path, required=True)
    args = ap.parse_args()
    out = args.out.resolve(); assert out.is_relative_to(ROOT/'selfhost/build/phase69')
    products, pins = R.products()
    parent = products[('tree', 'selfhost')]
    source_path = Path(parent['nativeSource']['path'])
    original = source_path.read_text()
    assert original.startswith('#define NATIVE_PACK_CTORS 1\n#define NATIVE_SCALAR_ARRAYS 1\n#define NATIVE_UNSHARED_ARRAYS 1\n')
    assert '#define BANGS 39\n' in original
    out.mkdir(parents=True, exist_ok=False)
    jobs = []
    for arm in ('mode_only', 'reuse', 'cold', 'cold_reuse'):
        edits = []
        source = replace(original, '#define BANGS 39\n', '#define BANGS 0\n', edits, 'shared sequential-mode control')
        if arm in ('reuse', 'cold_reuse'): source = reuse(source, edits)
        if arm in ('cold', 'cold_reuse'): source = cold(source, edits)
        assert reverse(source, edits) == original
        dest = out / (arm + '.c'); dest.write_text(source)
        jobs.append(dict(arm=arm, source=identity(dest), edits=edits,
                         reverseRecoversOriginal=True,
                         runtimeHelpersUnchanged=True,
                         coldConstructorStoresRemoved=26 if arm in ('cold','cold_reuse') else 0,
                         retainedSpareCount=2 if arm in ('reuse','cold_reuse') else 0))
    result = dict(kind='phase69-cold-node-reuse-plan-v1', targetsExecuted=False,
      producer=identity(__file__), original=identity(source_path), acquisition=parent,
      inputs=pins, hypothesis=identity(ROOT/'experiments/phase69/P69-005-node-reuse.md'),
      method=identity(SURVEY), jobs=jobs,
      scope='Saved-C causal experiment only. All arms share BANGS0. Cold arm needs checked no-sharing proof; reuse preserves generic shared/static handling. No production modification, native execution or general conformance claim.')
    R.verify(pins)
    (out/'plan.json').write_text(json.dumps(result, indent=2)+'\n')
    print(json.dumps(dict(plan=identity(out/'plan.json'), targetsExecuted=False, arms=[x['arm'] for x in jobs])))

if __name__ == '__main__': main()

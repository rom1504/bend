#!/usr/bin/env python3
"""One exact saved-C diagnostic; no compiler or benchmark algorithm changes."""
import difflib, hashlib, importlib.util, json, re, sys, time
from pathlib import Path
sys.dont_write_bytecode = True
ROOT = Path(__file__).resolve().parents[4]
RAW = ROOT / 'selfhost/build/phase72'
spec = importlib.util.spec_from_file_location('support', ROOT / 'selfhost/tools/performance/programs/support.py')
S = importlib.util.module_from_spec(spec); spec.loader.exec_module(S)
source = ROOT / 'selfhost/build/phase70/compiler02-coverage-missing-five01/bst-selfhost/program.c'
original = source.read_text()
assert hashlib.sha256(source.read_bytes()).hexdigest() == 'b5aa3cc150e5c59ec0311404c66d552dc3562ef031312d7ab7636c1c4c522ae3'
def fid(name): return 'NF_FID_' + ''.join(str(ord(c)) + '_' for c in name)
prefix = '../../phase37/fixtures-new/bst:'
name = fid(prefix + 'p37.bst.insert')
m = re.search(r'NF_INLINE Term ' + name + r'\([^\n;]*\) \{', original)
assert m
depth, end = 1, m.end()
while depth:
    depth += (original[end] == '{') - (original[end] == '}'); end += 1
old = original[m.start():end]
new = old
edits = [
    ('Term v_4294967291;', 'Term p72_first, p72_second;'),
    ('u64 nd_16 = heap_alloc(e, cls_fit(2));\ne.mem[nd_16 + 0] = rfc_seal(e, nq_result_15[0]);\ne.mem[nd_16 + 1] = rfc_seal(e, nq_result_15[1]);\nv_4294967291 = term_ctr(CID_TUPLE, nd_16);',
     'p72_first = nq_result_15[0];\np72_second = nq_result_15[1];'),
    (fid(prefix+'insert.fin')+'(e, seq, nq_result_7, v_4294967292, v_4294967291)',
     fid('$product.'+prefix+'insert.fin')+'(e, seq, nq_result_7, v_4294967292, p72_first, p72_second)')]
for a, b in edits:
    assert new.count(a) == 1, a
    new = new.replace(a, b)
assert 'heap_alloc(' not in new and 'rfc_seal(' not in new
candidate = original[:m.start()] + new + original[end:]
path = RAW/'bst-virtual.c'
with path.open('x') as f: f.write(candidate)
with (RAW/'bst-virtual.patch').open('x') as f:
    f.write(''.join(difflib.unified_diff(original.splitlines(True), candidate.splitlines(True), fromfile=str(source), tofile=str(path))))
recipe_path = ROOT/'selfhost/build/phase71/recipe-v3.json'
recipe = json.loads(recipe_path.read_text())
report = dict(complete=False, producer=S.identity(__file__), source=S.identity(source), candidate=S.identity(path), recipe=S.identity(recipe_path))
with S.ExecutionGuard(rss_mib=2048, available_mib=4096) as guard:
    report['build'] = guard.run(['taskset','-c','3',recipe['clang'],*recipe['clangArgs'],str(path),*recipe['linkArgs'],'-o',str(RAW/'bst-virtual')], RAW/'bst-clang01', time.monotonic()+90)
report['complete'] = report['build']['complete']
if report['complete']: report['binary'] = S.identity(RAW/'bst-virtual')
S.save(RAW/'bst-preparation.json',report)
print(json.dumps(dict(complete=report['complete'], wallSeconds=report['build']['wallSeconds'])))
assert report['complete']

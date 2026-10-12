"""Source-only non-native generated dependency closure; BASELINE_API API FRESH_OUT."""
import hashlib, importlib.util, json, sys
from pathlib import Path
old, new, out = map(Path, sys.argv[1:])
out = out.resolve(); assert out.is_relative_to(Path('/home/ai/bend2/build/publish/bend/selfhost/build/phase75'))
out.mkdir(exist_ok=False)
root = Path('/home/ai/bend2/build/publish/bend')
parent = root/'selfhost/tools/performance/phase66/controls/frontend-closure.py'
source = parent.read_text()
assert source.count('    assert len(exports) == 99') == 1
scanner = out/'scanner.py'
scanner.write_text(source.replace('    assert len(exports) == 99', '    assert len(exports) in [100, 103]'))
spec = importlib.util.spec_from_file_location('scanner', scanner)
C = importlib.util.module_from_spec(spec)
spec.loader.exec_module(C)
a, b = C.program(old), C.program(new)
assert a['runtime'] == b['runtime']
assert set(b['exports']) - set(a['exports']) == {'driver_report_data', 'nr_prepare', 'nr_compile'}
assert all(b['exports'][k] == v for k,v in a['exports'].items())
assert set(a['exportSource'].splitlines()) <= set(b['exportSource'].splitlines())
roots = sorted(k for k in a['exports'] if not k.startswith('nc_'))
left, right = C.closure(a, roots), C.closure(b, roots)
assert left == right
changed = [n for n in sorted(left) if a['functions'][n]['source'] != b['functions'][n]['source']]
assert changed == [], changed
def pin(p):
    p = Path(p).resolve()
    return dict(file=str(p), sha256=hashlib.sha256(p.read_bytes()).hexdigest())
result = dict(complete=True, unchangedFunctions=len(left), roots=roots, changed=changed,
    scope='Exact generated closure of all exported roots not starting nc_, runtime and all prior public wrappers; three explicitly enumerated new private entry exports are excluded. No prior reachable function may change.',
    inputs=[pin(p) for p in [__file__, parent, scanner, old, new]])
(out/'report.json').write_text(json.dumps(result, indent=2)+'\n')
print(json.dumps(dict(complete=True, unchangedFunctions=len(left), changed=changed)))

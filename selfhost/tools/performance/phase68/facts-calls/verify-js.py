"""Source-only non-native generated dependency closure; BASELINE_API API FRESH_OUT."""
import hashlib, importlib.util, json, sys
from pathlib import Path
old, new, out = map(Path, sys.argv[1:])
out.mkdir(exist_ok=False)
root = Path(__file__).resolve().parents[5]
parent = root/'selfhost/tools/performance/phase66/controls/frontend-closure.py'
source = parent.read_text()
assert source.count('    assert len(exports) == 99') == 1
scanner = out/'scanner.py'
scanner.write_text(source.replace('    assert len(exports) == 99', '    assert len(exports) == 100'))
spec = importlib.util.spec_from_file_location('scanner', scanner)
C = importlib.util.module_from_spec(spec)
spec.loader.exec_module(C)
a, b = C.program(old), C.program(new)
assert a['runtime'] == b['runtime'] and a['exportSource'] == b['exportSource']
roots = sorted(k for k in a['exports'] if not k.startswith('nc_'))
left, right = C.closure(a, roots), C.closure(b, roots)
assert left == right
changed = [n for n in sorted(left) if a['functions'][n]['source'] != b['functions'][n]['source']]
assert changed == ['$kf_known$'], changed
def pin(p):
    p = Path(p).resolve()
    return dict(file=str(p), sha256=hashlib.sha256(p.read_bytes()).hexdigest())
result = dict(complete=True, unchangedFunctions=len(left)-1, roots=roots, changed=changed,
    scope='All exported non-native roots. Only the foreign-ID resolver changes; its behavior needs separate controls.',
    inputs=[pin(p) for p in [__file__, parent, scanner, old, new]])
(out/'report.json').write_text(json.dumps(result, indent=2)+'\n')
print(json.dumps(dict(complete=True, unchangedFunctions=len(left)-1, changed=changed)))

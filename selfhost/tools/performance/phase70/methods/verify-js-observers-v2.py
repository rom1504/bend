"""Source-only non-native generated dependency closure; BASELINE_API API FRESH_OUT."""
import hashlib, importlib.util, json, re, sys
from pathlib import Path
old, new, attempt_file, out = map(Path, sys.argv[1:])
out = out.resolve(); assert out.is_relative_to(Path('/home/ai/bend2/build/publish/bend/selfhost/build/phase70'))
out.mkdir(exist_ok=False)
root = Path('/home/ai/bend2/build/publish/bend')
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
assert changed == [], changed
def pin(p):
    p = Path(p).resolve()
    return dict(file=str(p), sha256=hashlib.sha256(p.read_bytes()).hexdigest())
attempt = json.loads(attempt_file.read_text())
assert attempt['checked'] and attempt['config']['strictExact']
assert pin(new)['sha256'] == attempt['api']['sha256']
snapshot = Path(attempt['snapshot']['root'])
frozen = {str(Path(item['frozen']['file']).relative_to(snapshot)): item['frozen'] for item in attempt['snapshot']['sources']}
modules = {
    'observer-emitter.bend': ('no_',),
    'observer-adapter.bend': ('no_',),
    'observer-layout.bend': ('no_', 'nol_'),
    'observer-literals.bend': ('no_',),
    'observer-analysis.bend': ('noa_',),
    'observer-plan.bend': ('no_',),
    'observer-integration.bend': ('no_',),
}
classified = []
for module, prefixes in modules.items():
    identity = frozen['src/back/native/'+module]
    source_file = Path(identity['file'])
    assert pin(source_file)['sha256'] == identity['sha256']
    names = re.findall(r'^def\s+([A-Za-z_]\w*)', source_file.read_text(), re.M)
    assert names and all(name.startswith(prefixes) for name in names)
    generated = ['$'+name+'$' for name in names]
    omitted = [name for name in names if '$'+name+'$' not in b['functions']]
    assert omitted == (['no_schema_spec'] if module == 'observer-layout.bend' else []), omitted
    assert not set(generated) & right, 'A newly classified native helper is reachable from a protected nonnative root'
    classified.append(dict(module=module, source=pin(source_file), prefixes=list(prefixes), definitions=names, emittedDefinitions=[name for name in names if name not in omitted], omittedPrivateDefinitions=omitted))
# The explicit classification documents ownership only. No new prefix or root
# exclusion is introduced; the identical original 100 public wrappers and every
# original non-nc_ root remain protected by the unchanged scanner above.
result = dict(complete=True, unchangedFunctions=len(left), roots=roots, changed=changed,
    nativeObserverClassification=classified, checkedAttempt=pin(attempt_file),
    unchangedPublicExports=len(a['exports']), additionalExcludedRoots=[],
    scope='Exact generated closure of all exported roots not starting nc_, runtime and public wrappers; no changed function permitted.',
    inputs=[pin(p) for p in [__file__, parent, scanner, old, new, attempt_file]] + [row['source'] for row in classified])
(out/'report.json').write_text(json.dumps(result, indent=2)+'\n')
print(json.dumps(dict(complete=True, unchangedFunctions=len(left), changed=changed)))

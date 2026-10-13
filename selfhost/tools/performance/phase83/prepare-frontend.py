#!/usr/bin/env python3
"""Freeze a check-only size/warmth diagnostic using existing Phase83 assets."""
import hashlib
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[4]
HERE = Path(__file__).resolve().parent
OLD = ROOT / 'selfhost/build/phase83/survey01/plan.json'
OUT = ROOT / 'selfhost/build/phase83/frontend01'
inputs = {}


def pin(file):
    file = Path(file).resolve(strict=True)
    data = file.read_bytes()
    p = dict(file=str(file), sha256=hashlib.sha256(data).hexdigest(), bytes=len(data))
    assert str(file) not in inputs or inputs[str(file)] == p
    inputs[str(file)] = p
    return p


def verify(p):
    actual = pin(p['file'])
    assert actual == p, p['file']
    return actual


old_pin = pin(OLD)
old = json.loads(OLD.read_text())
for p in old['inputs']:
    verify(p)
assert old['kind'] == 'phase68-native-compilation-plan'
roles = {r: old['roles'][r] for r in ['b2', 'typescript']}
prepared_pin = pin(roles['b2']['preparation'])
prepared = json.loads(Path(prepared_pin['file']).read_text())
assert prepared['complete'] and prepared['pass']
assert prepared['job']['role'] == 'b2' and prepared['job']['action'] == 'prepare'
assert prepared['plan'] == old_pin
for p in prepared['cache'] + prepared['products']:
    verify(p)

OUT.mkdir(parents=True, exist_ok=False)
cases = {}
for n in [8, 32, 65, 128]:
    parts = ['import Base\n\n']
    for i in range(n):
        argument = 'x' if i == 0 else f'f{i-1}(x)'
        parts.append(f'def f{i}(+x: U32) -> U32:\n  U32.add({argument}, {i+1})\n\n')
    parts.append(f'def main() -> U32:\n  f{n-1}(0)\n\n#|{n*(n+1)//2}\n')
    file = OUT / f'functions{n}.bend'
    file.write_text(''.join(parts))
    cases[f'functions{n}'] = dict(input=pin(file), functionCount=n,
                                expectedValue=n*(n+1)//2)
assert cases['functions65']['input']['sha256'] == old['cases']['functions65']['input']['sha256']

# Extract two complete, unchanged upstream helpers into a diagnostic module.
# Do not import main.ts: its Node loader registration would add unrelated work.
main = Path(roles['typescript']['bend']['file']).with_name('main.ts')
main_pin = pin(main)
text = main.read_text()
start = text.index('function book_promises(book: Bend.Book): string[] {')
end = text.index('// cli_say writes text', start)
body = text[start:end]
assert body.count('function book_promises(') == 1 and body.count('function term_refs(') == 1
assert 'cli_say' not in body
module = OUT / 'upstream-promises.ts'
module.write_text('import * as Bend from ' + json.dumps(Path(roles['typescript']['bend']['file']).as_uri())
                  + ';\n' + body + '\nexport { book_promises };\n')
upstream_report = pin(module)
derivation = dict(source=main_pin, startCharacter=start, endCharacter=end,
                  extractedSha256=hashlib.sha256(body.encode()).hexdigest(),
                  operation='Exact book_promises and term_refs extraction; prepend absolute Bend import and append export.')

for file in [HERE/'prepare-frontend.py', HERE/'frontend-sweep.mjs']:
    pin(file)
jobs = [dict(name=f'frontend-{case}-{role}', case=case, role=role)
        for case in cases for role in ['b2', 'typescript']]
plan = dict(kind='phase83-frontend-sweep', version=1, parentPlan=old_pin,
            roles=roles, preparation=prepared_pin, cases=cases, jobs=jobs,
            upstreamReport=upstream_report, derivation=derivation,
            repetitions=3, inputs=list(inputs.values()),
            cpu=old['cpu'], nodeArgs=old['nodeArgs'], seconds=old['seconds'],
            rssMiB=old['rssMiB'], availableMiB=old['availableMiB'],
            scope='Check-only with proof report. Fresh process per role/source; three ordinary calls in that process. No persistent inspector or semantic memo. Existing Bend Base preparation excluded; TS loads/checks Base each call. Public wrappers are instrumented: diagnostic clocks, not clean compilation parity or generated-program execution.')
(OUT/'plan.json').write_text(json.dumps(plan, indent=2)+'\n')
print(OUT/'plan.json')

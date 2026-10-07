#!/usr/bin/env python3
"""Data-only explicit identical-image A/A recipe from an existing binding recipe."""
import argparse
import hashlib
import json
import shlex
from pathlib import Path


def pin(file):
    file = Path(file).resolve(strict=True)
    return dict(file=str(file), sha256=hashlib.sha256(file.read_bytes()).hexdigest())


p = argparse.ArgumentParser(description=__doc__)
p.add_argument('recipe', type=Path)
a = p.parse_args()
r = json.loads(a.recipe.read_text())
binding = json.loads(Path(r['bindings']['file']).read_text())
assert pin(r['bindings']['file']) == r['bindings']
assert r['complete'] and r['pass'] and r['roles'] == ['baseline', 'candidate']
assert binding['roles']['baseline'] == binding['roles']['candidate']
assert binding['outputPolicies']['baseline'] == binding['outputPolicies']['candidate']
assert binding['roles']['baseline']['kind'] == 'checked'
out = a.recipe.parent
file = out/'aa-bindings.json'
assert not file.exists() and not (out/'aa-recipe.json').exists()
binding['comparison'] = 'fixed-source'
binding['scope'] = 'Identical actual checked attempt/API/driver in independent staged baseline/candidate roles. A/A variability diagnostic only.'
file.write_text(json.dumps(binding, indent=2)+'\n')
commands = {k: list(r['commands'][v]) for k, v in [('prepare', 'prepare'), ('compare', 'baseline-three')]}
for c in commands.values():
    c[c.index('--bindings')+1] = str(file.resolve())
    c[c.index('--cases')+1] = 'test-map-set-ops'
c = commands['compare']
c[c.index('--rounds')+1] = '6'
result = dict(kind='phase64-identical-image-aa-recipe', complete=True, dataOnly=True,
    targetExecuted=False, producer=pin(__file__), parent=pin(a.recipe), binding=pin(file),
    actualComparison='same-checked-image', rolesEqual=True, image=binding['roles']['baseline'],
    outputPolicy=binding['outputPolicies']['baseline'], commands=commands,
    cases=['test-map-set-ops'], rounds=6, workers=12, positionBalanced=True,
    scope='Two independently prepared private projects from byte-identical checked compiler inputs. '
          'Fresh process per sample, alternating positions across six rounds. Full raw-output checks retained. '
          'This measures same-campaign A/A variability; it cannot alone explain historical cross-campaign drift.')
target=out/'aa-recipe.json'
target.write_text(json.dumps(result, indent=2)+'\n')
(out/'aa-commands.txt').write_text('\n\n'.join('# '+k+'\n'+shlex.join(c) for k,c in commands.items())+'\n')
print(json.dumps(dict(recipe=pin(target), commands=str(out/'aa-commands.txt'))))

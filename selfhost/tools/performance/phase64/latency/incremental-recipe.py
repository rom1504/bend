#!/usr/bin/env python3
"""Set explicit repeated rounds in a fresh companion recipe; no targets run."""
import argparse
import hashlib
import json
import shlex
from pathlib import Path

p = argparse.ArgumentParser(description=__doc__)
p.add_argument('recipe', type=Path)
p.add_argument('--rounds', type=int, required=True)
a = p.parse_args()
assert 1 <= a.rounds <= 6
r = json.loads(a.recipe.read_text())
assert r['kind'] == 'phase64-fast-loop-recipe' and r['complete'] and r['pass']
assert r['roles'] == ['baseline', 'candidate'] and not r['crossGenerationComparison']
c = list(r['commands']['baseline-three'])
c[c.index('--rounds') + 1] = str(a.rounds)
assert c[c.index('--cases') + 1] == 'numeric-recurrence,lexer,test-map-set-ops'


def pin(file):
    file = Path(file).resolve(strict=True)
    return dict(file=str(file), sha256=hashlib.sha256(file.read_bytes()).hexdigest())


out = a.recipe.with_name('incremental-recipe.json')
commands = out.with_name('incremental-commands.txt')
assert not out.exists() and not commands.exists()
value = dict(kind='phase64-incremental-repeat-recipe', complete=True, dataOnly=True,
    targetExecuted=False, producer=pin(__file__), parent=pin(a.recipe),
    commands=dict(prepare=r['commands']['prepare'], compare=c),
    workers=6 * a.rounds, rounds=a.rounds, positionBalanced=a.rounds % 2 == 0,
    scope='Two genuine same-generation compiler images, three sources, fresh process per sample. '
          'Even rounds balance role order; no TypeScript timing is inferred from this incremental campaign.')
out.write_text(json.dumps(value, indent=2) + '\n')
commands.write_text('\n\n'.join('# ' + k + '\n' + shlex.join(v) for k, v in value['commands'].items()) + '\n')
print(json.dumps(dict(recipe=pin(out), commands=str(commands), workers=value['workers'])))

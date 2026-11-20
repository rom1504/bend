#!/usr/bin/env python3
"""Reuse strict runtime/oracle authentication with Phase198's frozen partition."""
from pathlib import Path
import importlib.util
import json
from types import SimpleNamespace

ROOT = Path(__file__).resolve().parents[3]
BUILD = ROOT / 'selfhost/build/phase198'
spec = importlib.util.spec_from_file_location('family_summary', ROOT / 'selfhost/tests/phase193/summarize.py')
P = importlib.util.module_from_spec(spec)
spec.loader.exec_module(P)
P.S.PARTITION = BUILD / 'partition01.json'
args = SimpleNamespace(report=BUILD / 'broad-runtime01/report.json', references=BUILD / 'broad-runtime-plan01/manifest.json', c_role='c', baseline_role='baseline', spread_limit=1.10, emission=[])
result = P.S.summarize(args)
manifest = P.B.read(args.references)
for alias, path, old_alias in [
    ('c', ROOT / 'selfhost/build/phase195/references01/manifest.json', 'c'),
    ('baseline', ROOT / 'selfhost/build/phase195/native45-01/programs.manifest.json', 'candidate'),
    ('candidate', BUILD / 'native45-01/programs.manifest.json', 'candidate')]:
    original = P.B.read(path)
    for item in original['inputs']:
        P.C.verify(item)
    old = {c['id']: c for c in original['cases']}
    for row in manifest['cases']:
        assert row['products'][alias] == old[row['id']]['products'][old_alias]
result.update(kind='phase198-authenticated-broad-runtime-summary', complete=True,
    inheritedMethod=result['method'], method=P.C.pin(Path(__file__)),
    defaultReferencePreserved='Mature Bend C',
    scope=result['scope'] + ' All45 cases and44 nonzero timed cases retained. Candidate and baseline are QBE-produced nativeN1 images; exact hosted and later native-generation comparisons establish transfer separately. The conservative heldout partition excludes all six Phase197 study cases.')
out = ROOT / 'research/phase198/qualification/broad-runtime-summary01.json'
assert not out.exists() and not out.with_suffix('.md').exists()
P.B.save(out, result, fresh=True)
out.with_suffix('.md').write_text(P.markdown(result).replace('# Phase193 runtime summary', '# Phase198 broad runtime summary', 1))
all_roles = result['subsets']['all']['roles']
print(json.dumps({'complete': True, 'baselineOverC': all_roles['baseline']['overC']['geomean'],
    'candidateOverC': all_roles['candidate']['overC']['geomean'],
    'candidateOverBaseline': all_roles['candidate']['overBaseline']['geomean'],
    'heldoutOverBaseline': result['subsets']['heldout']['roles']['candidate']['overBaseline']['geomean'],
    'warnings': result['warnings'], 'summary': str(out)}))

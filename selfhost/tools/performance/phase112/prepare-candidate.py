#!/usr/bin/env python3
"""Select explicit additive Bend source modules; no compiler algorithm here."""
import argparse
import json
from pathlib import Path
import subprocess
import sys

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[3]


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--profile', choices=['core', 'early', 'fusion', 'selectors', 'selectors-core', 'word', 'word-core', 'regions', 'multi', 'multi-wide'], required=True)
    parser.add_argument('--out', type=Path, required=True)
    args = parser.parse_args()
    recipe_path = HERE / 'recipes.json'
    recipe = json.loads(recipe_path.read_text())
    modules = [ROOT / p for p in recipe['modules']]
    overrides = [ROOT / p for p in recipe['overrides']]

    def add(name):
        profile = recipe['profiles'][name]
        if 'extends' in profile:
            add(profile['extends'])
        modules.extend(HERE / p for p in profile['modules'])
        overrides.extend(HERE / p for p in profile['overrides'])

    add(args.profile)
    command = [sys.executable, str(HERE / 'prepare.py'), '--out', str(args.out)]
    for path in modules:
        command.extend(['--module', str(path)])
    for path in overrides:
        command.extend(['--override', str(path)])
    subprocess.run(command, cwd=ROOT, check=True)
    (args.out / 'recipe.json').write_bytes(recipe_path.read_bytes())
    (args.out / 'profile.json').write_text(json.dumps(dict(profile=args.profile, command=command), indent=2) + '\n')


if __name__ == '__main__':
    main()

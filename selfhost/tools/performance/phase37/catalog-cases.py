#!/usr/bin/env python3
"""Print a frozen catalog group's comma-separated case IDs; execute nothing."""
import argparse
import json
from pathlib import Path
import re

parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument('group')
parser.add_argument('--catalog', type=Path, default=Path(__file__).with_name('catalog.json'))
args = parser.parse_args()
catalog = json.loads(args.catalog.read_text())
if catalog.get('status') != 'frozen':
    parser.error('Only the completed frozen coverage catalog may select timed points')
if args.group not in catalog['sets']:
    parser.error('Unknown group; available: ' + ', '.join(catalog['sets']))
selected = catalog['sets'][args.group]
if not selected or len(set(selected)) != len(selected):
    parser.error('Empty or duplicated selection')
known = {case['id'] for case in catalog['cases']}
if any(case not in known or not re.fullmatch('[a-z0-9][a-z0-9-]*', case) for case in selected):
    parser.error('Unknown or unsupported case ID')
print(','.join(selected))

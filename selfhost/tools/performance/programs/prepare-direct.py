#!/usr/bin/env python3
"""Maintained direct acquisition; forwards the unchanged reviewed Phase52 producer."""
import hashlib
from pathlib import Path
import runpy
import sys

parent = Path(__file__).resolve().parent.parent / 'phase52' / 'prepare-v2.py'
pins = {
    'prepare-v2.py': '7a08af571e14ed0f508d49eb1a8560b76d05cd6cf6438b5f4d119fadc818b017',
    'emit-worker-v2.mjs': 'f730abcde7203c61339f4eafefa144bc5c01031d5a1936c88d493afd5fe2d4a1',
}
for name, expected in pins.items():
    actual = hashlib.sha256(parent.with_name(name).read_bytes()).hexdigest()
    if actual != expected:
        raise RuntimeError('Changed pinned direct acquisition producer: ' + name)
for index, arg in enumerate(sys.argv[1:], 1):
    if arg == '--backend=legacy' or (arg == '--backend' and sys.argv[index + 1:index + 2] == ['legacy']):
        raise SystemExit('prepare-direct.py requires --backend direct; legacy recipes remain historical')
sys.argv = [str(parent), *sys.argv[1:], '--backend', 'direct']
runpy.run_path(str(parent), run_name='__main__')

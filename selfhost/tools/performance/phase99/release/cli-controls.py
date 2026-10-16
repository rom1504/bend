#!/usr/bin/env python3
"""Unchanged public CLI controls, with Phase99 output paths and parent provenance."""
import hashlib
from pathlib import Path

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[4]
PARENT = ROOT / 'selfhost/tools/native/cli-controls.py'
data = PARENT.read_bytes()
assert hashlib.sha256(data).hexdigest() == '18d1af81bcda6ed308ce05a86c3ccec665ccffe1157b805ab900ba0ad06b553c'
text = data.decode()
for old, new in [
    ("HERE = Path(__file__).resolve().parent", "HERE = Path(" + repr(str(PARENT.parent)) + ")"),
    ("N.ROOT/'selfhost/build/phase98'", "N.ROOT/'selfhost/build/phase99'"),
    ("inputs = [N.pin(file) for file in [__file__,", "inputs = [N.pin(file) for file in [" + repr(str(PARENT)) + ", __file__,")]:
    assert text.count(old) == 1
    text = text.replace(old, new)
namespace = dict(__name__='phase99_public_cli_controls', __file__=str(Path(__file__).resolve()))
exec(compile(text, str(PARENT), 'exec'), namespace)
if __name__ == '__main__': namespace['main']()

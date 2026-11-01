#!/usr/bin/env python3
"""Append only the object-boundary view to an explicit maintained compiler source."""
import argparse
from pathlib import Path
import re
import sys
sys.dont_write_bytecode = True
HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE.parent))
from common import fresh_output, pin, require, verify, workspace, write_json


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--workspace', type=Path); p.add_argument('--source', type=Path, required=True)
    p.add_argument('--out', type=Path, required=True); a = p.parse_args()
    root = workspace(a.workspace); source = pin(a.source)
    adapter = pin(root / 'selfhost/src/session/object-frames.bend')
    original = Path(source['file']).read_bytes(); extension = Path(adapter['file']).read_bytes()
    require(0 < len(original) <= 16 * 1024**2, 'Bounded explicit compiler source required')
    header = re.compile(rb'^(?:type|def|law) ([A-Za-z0-9_.]+)\b', re.M)
    names = header.findall(extension); require(len(names) == len(set(names)) == 3, 'Unexpected extension declaration set')
    require(not set(names).intersection(header.findall(original)), 'Extension would override a declaration')
    for name in [b'p140s_empty', b'p140s_named', b'p140g_prepare', b'p140r_begin_cursor', b'p140r_next', b'P134Cursor']:
        require(name in header.findall(original), 'Canonical session capability missing: ' + name.decode())
    out = fresh_output(a.out, root); (out / 'session.bend').write_bytes(original + b'\n' + extension + b'\n')
    verify(source); verify(adapter)
    report = dict(kind='bend-session-source-extension', version=1, complete=True,
                  checked=False, targetsRun=False, source=pin(out / 'session.bend'), parent=source,
                  extension=adapter, declarations=[x.decode() for x in names], overrides=[],
                  exports=pin(HERE / 'exports.json'), method=pin(__file__),
                  scope='Shared maintained compiler plus pure boundary adapter; no historical frontend/source fallback.')
    write_json(out / 'report.json', report)
    print(report['source']['file'])


if __name__ == '__main__': main()

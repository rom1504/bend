#!/usr/bin/env python3
"""Stream only selected query functions from full compiler QBE; no targets."""
import argparse
import collections
import hashlib
import json
from pathlib import Path
import re
import sys
sys.dont_write_bytecode = True
ROOT = Path(__file__).resolve().parents[5]
sys.path.insert(0, str(ROOT / 'selfhost/tools/profiler'))
from owners import FUNCTION, decoded_symbol, pin

WANTED = {'lookup', 'f_find', 'f_find_next', 'nc_ctor_owned', 'dn', 'dk', 'da', 'db', 'dc',
          'p137q_name_eq', 'p137q_key_eq', 'p137q_is_cache', 'p137q_is_adt', 'p137q_is_ctr'}
CALL = re.compile(r'call \$([A-Za-z0-9_.$]+)\(')


def extract(path, wanted_symbols=None):
    result = {}
    active = None
    body = []
    held = 0
    used = 0
    with path.open() as stream:
        for number, line in enumerate(stream, 1):
            if active is None:
                m = FUNCTION.match(line)
                if not m:
                    continue
                decoded = decoded_symbol(m[1]) or m[1]
                keep = m[1] in wanted_symbols if wanted_symbols is not None else decoded.split('.')[-1] in WANTED
                if not keep:
                    continue
                active = dict(symbol=m[1], decoded=decoded, qbeLine=number)
                body = [line]
                held = len(line)
            else:
                body.append(line)
                held += len(line)
                assert held <= 8 * 1024 * 1024, 'Unexpected selected function growth'
                if line == '}\n':
                    assert active['symbol'] not in result
                    result[active['symbol']] = dict(active, body=body)
                    used += held
                    assert used <= 32 * 1024 * 1024, 'Selected-body retention bound exceeded'
                    active = None
                    body = []
    assert active is None
    return result


def main():
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument('--request', action='append', required=True)
    ap.add_argument('--out', type=Path, required=True)
    a = ap.parse_args()
    out = a.out.resolve()
    assert not out.exists() and out.is_relative_to(ROOT / 'implementation/phase137/audit')
    out.mkdir()
    inputs = [pin(__file__), pin(ROOT / 'selfhost/tools/profiler/owners.py')]
    cases = []
    source = None
    for request in a.request:
        label, filename = request.split('=', 1)
        receipt = Path(filename).resolve()
        r = json.loads(receipt.read_text())
        assert r['complete'] and r['exitCode'] == 0
        source = source or r['source']
        assert r['source'] == source
        qbe = Path(r['product']['file'])
        assert pin(qbe) == r['product']
        inputs += [pin(receipt), r['product'], r['source'], r['image']]
        fs = extract(qbe)
        scc = {m[1] for f in fs.values() for line in f['body'] for m in [CALL.search(line)]
               if m and (decoded_symbol(m[1]) or '').startswith('$p126scc.')}
        fs.update(extract(qbe, scc))
        folder = out / label
        folder.mkdir()
        rows = []
        for i, f in enumerate(fs.values()):
            text = ''.join(f.pop('body'))
            path = folder / (str(i).zfill(3) + '-' + f['decoded'].replace('$', '')[:100] + '.ssa')
            path.write_text(text)
            calls = []
            lines = text.splitlines()
            for index, line in enumerate(lines):
                m = CALL.search(line)
                if m:
                    calls.append(dict(line=f['qbeLine'] + index, symbol=m[1], decoded=decoded_symbol(m[1]) or m[1]))
            rows.append(dict(f, body=pin(path), lines=len(lines), calls=calls,
                             staticTake9Sites=sum('call $p111_rt_take(' in line and line.rstrip().endswith('w 9)') for line in lines),
                             staticSinkSites=sum('call $p111_rt_sink(' in line for line in lines),
                             runtimeBorrowReadSites=sum('call $p118_rt_borrow_fields(' in line for line in lines)))
        cases.append(dict(label=label, request=pin(receipt), qbe=r['product'], producer=r['image'], source=r['source'],
                          selectedBodyBytes=sum(f['body']['bytes'] for f in rows), functions=rows))
    for item in inputs:
        assert pin(item['file']) == item, item['file']
    report = dict(kind='phase137-streamed-full-compiler-query-audit', complete=True, targetsRun=False,
                  inputs=inputs, cases=cases,
                  scope='Two streaming passes per full IR retain only named query/helper bodies and directly referenced SCC workers, at most32MiB. No complete function map or complete IR String. Calls are static; unrecorded callees and indirect scheduling are not a closed call graph. No runtime/frequency claim.')
    (out / 'report.json').write_text(json.dumps(report, indent=2) + '\n')
    print(json.dumps(dict(complete=True, cases=len(cases), selectedBytes=[c['selectedBodyBytes'] for c in cases], report=pin(out / 'report.json'))))


if __name__ == '__main__':
    main()

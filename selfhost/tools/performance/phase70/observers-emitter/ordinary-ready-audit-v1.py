#!/usr/bin/env python3
"""Read saved emitted C; predict the narrow P70-008 guard without target runs."""
import argparse
import hashlib
import importlib.util
import json
import os
import re
from pathlib import Path

HERE = Path(__file__).resolve().parent
AUDITOR = HERE.parent/'observer-controls/emission-audit-v2.py'
spec = importlib.util.spec_from_file_location('saved_c_audit', AUDITOR)
helper = importlib.util.module_from_spec(spec)
spec.loader.exec_module(helper)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('out', type=Path)
    parser.add_argument('sources', nargs='+', type=Path)
    args = parser.parse_args()
    assert os.sched_getaffinity(0) == {0}
    assert not args.out.exists() and args.out.resolve().is_relative_to(HERE)
    inputs = [helper.pin(__file__), helper.pin(AUDITOR)]
    rows = []
    pattern = r'\b(NF_FID_(?:[0-9]+_)+)\(Env e, bool seq, Term\* nf_out[^;{}]*\)\s*\{'
    for file in args.sources:
        pin = helper.pin(file)
        inputs.append(pin)
        source = file.read_text()
        workers = {}
        for found in re.finditer(pattern, source):
            name = ''.join(chr(int(code)) for code in found[1][len('NF_FID_'):].split('_') if code)
            assert name not in workers
            begin, end = helper.function_span(source, found[1])
            workers[name] = dict(signature=found[0][:-1].rstrip(),
                bodySha256=hashlib.sha256(source[begin:end].encode()).hexdigest())
        observers = []
        for name in sorted(workers):
            if name.startswith('$observer.') and not name.startswith('$observer.adapter.'):
                owner = name[len('$observer.'):]
                assert '$observer.adapter.'+owner in workers
                observers.append(dict(owner=owner, ordinary=workers.get(owner),
                    product=workers.get('$product.'+owner), observer=workers[name],
                    adapter=workers['$observer.adapter.'+owner], wouldSkip=owner in workers))
        rows.append(dict(source=pin, privateWorkerCount=len(workers), observers=observers))
        assert helper.pin(file) == pin
    for pin in inputs:
        assert helper.pin(pin['file']) == pin
    report = dict(kind='phase70-P70-008-saved-c-eligibility-audit-v1', inputs=inputs,
        rows=rows, targetsExecuted=0,
        scope='Source evidence: emitted private definitions show final NF admission. Predicted skip/retain only; no candidate compiler execution, dynamic call coverage or timing.')
    args.out.write_text(json.dumps(report, indent=2)+'\n')
    print(json.dumps(dict(rows=[dict(source=Path(r['source']['file']).parent.name,
        skip=[x['owner'] for x in r['observers'] if x['wouldSkip']],
        retain=[x['owner'] for x in r['observers'] if not x['wouldSkip']]) for r in rows], targetsExecuted=0)))


if __name__ == '__main__':
    main()

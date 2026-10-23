"""Bounded paired hosted requests with exact QBE identity; run under root guard."""
import argparse
import hashlib
import json
from pathlib import Path
import subprocess
import time

ROOT = Path(__file__).resolve().parents[4]


def pin(path):
    path = Path(path).resolve()
    b = path.read_bytes()
    return dict(file=str(path), bytes=len(b), sha256=hashlib.sha256(b).hexdigest())


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--baseline', type=Path, required=True)
    p.add_argument('--candidate', type=Path, required=True)
    p.add_argument('--source', type=Path, required=True)
    p.add_argument('--expected', type=Path, required=True)
    p.add_argument('--out', type=Path, required=True)
    p.add_argument('--rounds', type=int, default=3)
    a = p.parse_args()
    out = a.out.resolve()
    if out.exists() or not out.is_relative_to(ROOT/'selfhost/build/phase128'):
        raise ValueError('Fresh Phase128 directory required')
    out.mkdir()
    method = ROOT/'selfhost/tools/performance/phase118/native-hosted-v2.mjs'
    runtime = ROOT/'selfhost/.bootstrap/bun-1.4.3/bun'
    apis = dict(baseline=a.baseline.resolve(), candidate=a.candidate.resolve())
    inputs = [pin(__file__), pin(method), pin(runtime), pin(a.source), pin(a.expected)]
    for api in apis.values():
        inputs += [pin(api), pin(api.parent/'report.json')]
    report = dict(complete=False, inputs=inputs, rows=[],
        scope='Fresh hosted processes, identical source, prepared Base and byte-identical QBE. This is hosted producer cost, not native N1 throughput.')
    save = lambda: (out/'report.json').write_text(json.dumps(report, indent=2)+'\n')
    save()
    for round in range(a.rounds):
        order = ['baseline','candidate'] if round%2 == 0 else ['candidate','baseline']
        for name in order:
            dest = ROOT/f'selfhost/build/phase111/p128-{out.name}-{round}-{name}'
            command = [str(runtime),str(method),str(apis[name]),str(a.source.resolve()),str(dest),'cache','array']
            started = time.monotonic()
            with (out/f'{round}-{name}.stdout').open('xb') as stdout, (out/f'{round}-{name}.stderr').open('xb') as stderr:
                child = subprocess.run(command,cwd=ROOT,stdout=stdout,stderr=stderr,timeout=90)
            row = dict(round=round,variant=name,command=command,status=child.returncode,wallSeconds=time.monotonic()-started)
            report['rows'].append(row)
            if child.returncode:
                save(); raise RuntimeError('Request failed '+name)
            emitted = json.loads((dest/'report.json').read_text())
            row.update(report=pin(dest/'report.json'), qbe=pin(dest/'program.ssa'), stages=emitted.get('stages'))
            row['exactQbe'] = (dest/'program.ssa').read_bytes() == a.expected.read_bytes()
            save()
            if not emitted['complete'] or not row['exactQbe']:
                raise ValueError('Emission identity failure')
    for item in inputs:
        if pin(item['file']) != item:
            raise ValueError('Changed input')
    report['complete'] = True
    save()
    print(json.dumps(dict(complete=True, rows=len(report['rows']))))


if __name__ == '__main__':
    main()

"""Build exact upstream-emitted C with pinned Clang-O2; outer guard owns limits."""
import argparse
import hashlib
import json
from pathlib import Path
import subprocess
import time

ROOT = Path(__file__).resolve().parents[4]


def pin(path):
    path = Path(path).resolve()
    data = path.read_bytes()
    return dict(file=str(path), bytes=len(data), sha256=hashlib.sha256(data).hexdigest())


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--emission', type=Path, required=True)
    p.add_argument('--source-manifest', type=Path, required=True)
    p.add_argument('--out', type=Path, required=True)
    p.add_argument('--seconds', type=int, default=900)
    a = p.parse_args()
    out = a.out.resolve()
    assert not out.exists() and out.is_relative_to(ROOT/'selfhost/build/phase144')
    emission = json.loads(a.emission.read_text())
    assert emission['complete'] and emission['holes'] == 0
    selected = json.loads(a.source_manifest.read_text())
    assert selected['complete'] and emission['source'] == selected['source']
    assert pin(selected['source']['file']) == selected['source']
    cc = Path('/home/ai/.elan/toolchains/leanprover--lean4---v4.32.0/bin/clang')
    assert pin(cc)['sha256'] == '9fcd5fc4baeea9c449bcc9ca4b9db7714465107669498b0056a853f22f5f4def'
    inputs = [pin(__file__), pin(a.source_manifest), pin(a.emission), emission['c'], emission['source'], pin(cc)]
    for row in inputs:
        assert pin(row['file']) == row
    out.mkdir(parents=True)
    (out/'method.py').write_bytes(Path(__file__).read_bytes())
    command = [str(cc), '-isystem', str(cc.parent.parent/'include/clang'), '-O2',
               emission['c']['file'], '-o', str(out/'program'), '-lm', '-pthread']
    report = dict(kind='phase144-upstream-c-build', complete=False, inputs=inputs,
                  source=emission['source'], c=emission['c'], command=command,
                  scope='Same Bend compiler source; upstream C runtime, acquisition only. No native qualification.')
    save = lambda: (out/'report.json').write_text(json.dumps(report, indent=2)+'\n')
    save()
    start = time.monotonic()
    try:
        with (out/'stdout').open('xb') as so, (out/'stderr').open('xb') as se:
            child = subprocess.run(command, cwd=ROOT, stdout=so, stderr=se, timeout=a.seconds)
        report['exitCode'] = child.returncode
        assert child.returncode == 0
        report['binary'] = pin(out/'program')
        for row in inputs:
            assert pin(row['file']) == row
        report['complete'] = True
    except BaseException as error:
        report['error'] = repr(error)
    report['buildSeconds'] = time.monotonic()-start
    save()
    print(json.dumps({k:report.get(k) for k in ['complete','buildSeconds','binary','error']}))
    raise SystemExit(0 if report['complete'] else 1)


if __name__ == '__main__':
    main()

"""Pin two root-only sequential jobs; do not execute compiler or targets."""
import argparse
import hashlib
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[5]
HERE = Path(__file__).resolve().parent


def pin(path):
    path = Path(path).resolve()
    data = path.read_bytes()
    return dict(file=str(path), bytes=len(data), sha256=hashlib.sha256(data).hexdigest())


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--out', type=Path, required=True)
    args = parser.parse_args()
    out = args.out.resolve()
    assert not out.exists() and out.is_relative_to(ROOT/'selfhost/build/phase144')
    source_dir = ROOT/'selfhost/build/phase144/integrated-source01'
    source = source_dir/'compiler.bend'
    manifest = json.loads((source_dir/'manifest.json').read_text())
    assert manifest['complete'] and manifest['source'] == pin(source)
    assert manifest['source']['sha256'] == '992893e6cf6a5bf7d6d092812b3a5da20852feca882005f32a91e607cef0483b'
    api = ROOT/'selfhost/build/phase111/p144-range-census-api01'
    result = ROOT/'selfhost/build/phase144/range-second-pass01'
    assert not api.exists() and not result.exists()
    guard = ROOT/'selfhost/tools/performance/phase111/guard.py'
    checker = ROOT/'selfhost/tools/performance/phase111/check-api.py'
    runner = HERE/'range-second-pass-v01.mjs'
    bun = ROOT/'selfhost/.bootstrap/bun-1.4.3/bun'
    exports = ['p88_cache_prepare', 'p86_plan', 'p128raw_lower_request',
               'p114s_open', 'p114s_inline', 'p113k_functions', 'p134v_commit',
               'p114s_close', 'p113e_verify', 'p134rk_functions']

    def command(name, seconds, tail):
        return ['/usr/bin/python3', '-B', str(guard), '--out', str(out/(name+'-guard')),
                '--seconds', str(seconds), '--cpu', '3', '--rss-mib', '3072',
                '--available-mib', '16384', '--file-mib', '80', '--', *tail]

    plan = dict(kind='phase144-root-only-second-range-census-plan', complete=True,
                targetsRun=False, sequential=True, cpu=3,
                inputs=[pin(p) for p in [__file__, source, source_dir/'manifest.json',
                        guard, checker, runner, bun]],
                jobs=[dict(name='checked-api', seconds=140,
                    command=command('api', 120, ['/usr/bin/python3', '-B', str(checker),
                        '--source', str(source), '--out', str(api), *exports]),
                    successRequired={'report':str(api/'report.json'),'complete':True,'checked':True}),
                  dict(name='three-family-census', seconds=230,
                    command=command('census', 210, [str(bun), str(runner), str(api/'report.json'),
                        str(result), 'lexer', 'coverage-map-churn-128', 'coverage-closures-256']),
                    successRequired={'report':str(result/'report.json'),'complete':True})],
                scope='Source and orchestration only. Root runs jobs sequentially after existing resource lane is free. Every exact difference is retained; no production edit or pass omission.')
    out.mkdir(parents=True)
    (out/'method.py').write_bytes(Path(__file__).read_bytes())
    (out/'jobs.json').write_text(json.dumps(plan, indent=2)+'\n')
    print(json.dumps(dict(prepared=True, targetsRun=False, jobs=str(out/'jobs.json'))))


if __name__ == '__main__':
    main()

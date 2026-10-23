"""Bind the qualified, measured Phase126 source32; never install or run targets."""
from pathlib import Path
import gzip
import hashlib
import json

ROOT = Path(__file__).resolve().parents[4]
B = ROOT / 'selfhost/build'
OUT = ROOT / 'implementation/phase126/candidate.json'


def pin(path):
    path = Path(path)
    raw = path.read_bytes()
    return dict(file=str(path), bytes=len(raw), sha256=hashlib.sha256(raw).hexdigest())


def read(path):
    return json.loads(Path(path).read_text())


def main():
    assert not OUT.exists()
    source = B/'phase126/observer-divmod-source32/compiler.bend'
    assert pin(source)['sha256'] == '40c469114c4d1c75dceab456e1979bb5c0278744a02e6dbe4a37e63667740abb'
    archive = ROOT/'implementation/phase126/compiler-source32.bend.gz'
    assert gzip.decompress(archive.read_bytes()) == source.read_bytes()
    summary = B/'phase126/final32-summary.json'
    stats = read(summary)
    assert stats['complete'] and len(stats['screens']) == 1
    screen = stats['screens'][0]
    assert screen['population'] == 'full-original45' and screen['timedCases'] == 44
    assert screen['correctnessObservationCount'] == 405
    jobs = B/'phase113/p126-native32-resume01-qualification/report.json'
    j = read(jobs)
    assert j['complete'] and len(j['jobs']) == 12 and all(r['status'] == 0 for r in j['jobs'])
    comparison = B/'phase126/p126-native32-qbe-comparison.json'
    assert read(comparison)['complete'] and read(comparison)['byteExact']
    controls = [B/'phase126/observer32-finite/report.json', B/'phase118/p126-final32-controls-run/report.json']
    for path in controls:
        assert read(path)['complete']
    api_report = B/'phase111/p126-observer32-api/report.json'
    runtime_report = B/'phase126/runtime-divmod01/report.json'
    assert read(api_report)['complete'] and read(runtime_report)['complete']
    runtime = B/'phase126/runtime-divmod01/runtime.o'
    assert pin(runtime)['sha256'] == '5cbc477f3f04fe87621fde3e347a913b869727aa8365a22af31d71c1d097d011'
    d = dict(complete=True, experimental=True, installed=False, nativeQualified=True,
        source=pin(source), sourceArchive=pin(archive),
        api=pin(B/'phase111/p126-observer32-api/api.mjs'), runtime=pin(runtime),
        sourceManifest=pin(source.with_name('manifest.json')), checkedApi=pin(api_report),
        runtimeReport=pin(runtime_report), emission=pin(B/'phase126/final32-emission.json'),
        controls=[pin(p) for p in controls], timing=pin(summary),
        compilerCost=pin(B/'phase118/p126-final32-cost/report.json'),
        nativeCheckpoint=dict(plan=pin(B/'phase126/native32-resume-plan01.json'), jobs=pin(jobs),
            comparison=pin(comparison), n1=pin(B/'phase111/p126-native32-n1/program'),
            n2=pin(B/'phase111/p126-native32-self/build/program'), qbe=read(comparison)['hostedQbe'],
            scope='Hosted to N1 to N2; exact raw QBE, focused19 on both images, original45 correctness on N2. No installed promotion, ELF fixed point or N2-to-N3.'),
        machineBuild=dict(method=pin(ROOT/'selfhost/tools/performance/phase123/build-aligned.py'),
                          assemblerOption='-mbranches-within-32B-boundaries'),
        method=pin(__file__),
        scope='Checked Bend source32: local F32, finite scalar tables, safe conditional recursive preparation, verified flat observers, Nat.divmod products and exact two-member tail cycles. Original45 runtime from the checked hosted API; native one-shot qualification is independent. Typed ABI, tree-shell reshape and source33 are excluded. Installed selections unchanged.')
    for key, path in [('nativeCompilerCost', B/'phase112/p126-native32-transport01/report.json'),
                      ('matchedParentNativeCompilerCost', B/'phase112/p126-native32-transport01-phase125/report.json')]:
        if path.exists():
            assert read(path)['complete']
            d[key] = pin(path)
    OUT.write_text(json.dumps(d, indent=2)+'\n')
    print(json.dumps(dict(complete=True, targetsRun=False, candidate=pin(OUT))))


if __name__ == '__main__':
    main()

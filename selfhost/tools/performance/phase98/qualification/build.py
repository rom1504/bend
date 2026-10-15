#!/usr/bin/env python3
"""Root-only guarded matched-O2 Clang build; never edits its input C."""
import argparse
import json
from pathlib import Path
import shutil
import sys
import time
from support import Bindings, ROOT, S, baseline, pin, read


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--emission-receipt', type=Path, required=True)
    p.add_argument('--binary', type=Path, required=True)
    p.add_argument('--out', type=Path, required=True)
    p.add_argument('--seconds', type=int, default=420)
    p.add_argument('--rss-mib', type=int, default=6144)
    a = p.parse_args(); out = a.out.resolve(); binary = a.binary.resolve()
    assert not out.exists() and not binary.exists()
    assert 2048 <= a.rss_mib <= 6144
    assert shutil.disk_usage(ROOT).free > 240 * 1024**2
    b = Bindings(); ctx = baseline(b)
    b.bind(__file__); b.bind(Path(__file__).with_name('support.py'))
    emission_pin = b.bind(a.emission_receipt); emission = read(emission_pin['file'])
    assert emission['complete']
    c = b.bind(emission['row']['output'] if emission.get('kind') == 'phase98-native-qualification-request' else emission['c'])
    assert c['bytes'] <= 64 * 1024**2
    if 'row' in emission: assert emission['passed'] and emission['inputsUnchanged']
    cc = ctx['clang']['file']; binary.parent.mkdir(parents=True, exist_ok=True)
    command = ['bash', '-c', 'ulimit -f 65536; ulimit -c 0; exec "$@"', 'phase98', 'taskset', '-c', '2,3',
               cc, '-isystem', str(Path(cc).parents[1] / 'include/clang'), '-O2', c['file'], '-o', str(binary), '-lm', '-pthread']
    with S.ExecutionGuard(rss_mib=a.rss_mib, available_mib=16384) as guard:
        process = guard.run(command, out, time.monotonic() + a.seconds)
    b.unchanged()
    S.save(out / 'inputs.json', list(b.rows.values()))
    S.save(out / 'method.json', dict(method=pin(__file__), emission=emission_pin, c=c, cPatched=False,
                                    rssMiB=a.rss_mib, availableMiB=16384, cpu='2,3', binary=pin(binary) if binary.exists() else None,
                                    scope='Matched compiler-image O2 flags; explicit full-Clang resource allowance, same serial guard.'))
    print(json.dumps(process))
    sys.exit(0 if process['complete'] and process['returncode'] == 0 else 1)


if __name__ == '__main__': main()

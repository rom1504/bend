#!/usr/bin/env python3
"""Join completed native receipts without executing a compiler or changing them."""
import argparse
import hashlib
import json
from pathlib import Path


def read(path):
    data = Path(path).read_bytes()
    return json.loads(data), dict(file=str(Path(path).resolve()), bytes=len(data),
                                 sha256=hashlib.sha256(data).hexdigest())


def main():
    p = argparse.ArgumentParser(description=__doc__)
    for name in ['pair', 'reference', 'machine', 'out']:
        p.add_argument('--' + name, type=Path, required=True)
    a = p.parse_args()
    pair, pp = read(a.pair)
    reference, rp = read(a.reference)
    machine, mp = read(a.machine)
    assert pair['complete'] and pair['independentProductsExact']
    assert not pair.get('diagnostic') and reference['complete'] and machine['complete']
    assert len(pair['jobs']) == 2
    before, after = pair['jobs']
    assert after['mode'] == 'warm' and after['exactOracle']
    assert after['product']['sha256'] == reference['product']['sha256']
    assert after['product']['bytes'] == reference['product']['bytes']
    assert any(p['sha256'] == after['product']['sha256'] and
               p['bytes'] == after['product']['bytes'] for p in machine['inputs'])
    assert reference['runtime'] in machine['inputs']
    assert any(p['file'] == after['source'] and
               p['sha256'] == reference['source']['sha256'] for p in pair['inputs'])
    all_stages = sum(j['stages']['totalMs'] / 1000 for j in pair['jobs'])
    all_io = sum(j['ioMs'] / 1000 for j in pair['jobs'])
    native_gap = pair['nativeSeconds'] - all_stages - all_io - pair['prepareMs'] / 1000
    transport = sum(j['transportSeconds'] for j in pair['jobs'])
    runner_gap = pair['totalSeconds'] - pair['nativeSeconds'] - transport
    assert native_gap >= 0 and runner_gap >= 0
    fresh = reference['totalSeconds'] + machine['buildSeconds']
    subtotal = after['stages']['totalMs'] / 1000 + after['transportSeconds'] + machine['buildSeconds']
    charged = subtotal + after['ioMs'] / 1000 + pair['prepareMs'] / 1000 + native_gap + runner_gap
    result = dict(kind='phase140-rebuild-receipt-join', complete=True,
        inputs=[pp, rp, mp], product=after['product'], warmStages=after['stages'],
        freshExecutableSubtotalSeconds=fresh, warmExecutableSubtotalSeconds=subtotal,
        subtotalSpeedup=fresh/subtotal, warmChargedSessionOverheadSeconds=charged,
        conservativeSpeedup=fresh/charged, nativeUnattributedSeconds=native_gap,
        runnerUnattributedSeconds=runner_gap, machineSeconds=machine['buildSeconds'],
        warmTransportSeconds=after['transportSeconds'],
        primingNativeSeconds=before['stages']['totalMs']/1000,
        scope='Single observations, not a confidence interval. Available-executable costs join exact-product compiler receipts with one measured QBE/as/link replay. Charged estimate assigns ALL session preparation and unattributed process/runner time to B. Acquisition, A priming, outer resource guard and qualification are separate. No new target run or native qualification.')
    assert not a.out.exists()
    a.out.parent.mkdir(parents=True, exist_ok=True)
    a.out.write_text(json.dumps(result, indent=2) + '\n')
    print(json.dumps({k: result[k] for k in ['subtotalSpeedup', 'conservativeSpeedup', 'warmExecutableSubtotalSeconds', 'warmChargedSessionOverheadSeconds']}))


if __name__ == '__main__':
    main()

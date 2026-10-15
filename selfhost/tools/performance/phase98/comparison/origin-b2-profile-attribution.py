#!/usr/bin/env python3
"""Offline attribution of the completed exact-origin B2 capture; runs no target."""
import argparse
from collections import Counter
import hashlib
import importlib.util
import json
from pathlib import Path
import re
import subprocess

ROOT = Path(__file__).resolve().parents[5]
BUILD = ROOT / 'selfhost/build/phase98'
METHOD = ROOT / 'selfhost/tools/performance/phase88/ownership/analyze.py'
spec = importlib.util.spec_from_file_location('ownership', METHOD)
M = importlib.util.module_from_spec(spec); spec.loader.exec_module(M)
A = M.A


def pin(path):
    path = Path(path).resolve(); data = path.read_bytes()
    return dict(file=str(path), bytes=len(data), sha256=hashlib.sha256(data).hexdigest())


def symbol(name, prefix):
    return prefix + ''.join(str(ord(c)) + '_' for c in name)


def decode(name):
    match = re.fullmatch(r'(NF|WL)_FID_((?:\d+_)+)', name)
    return (match[1] + ':' + ''.join(chr(int(c)) for c in match[2].rstrip('_').split('_'))) if match else name


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--out', type=Path, required=True)
    args = parser.parse_args(); assert not args.out.exists()
    capture = BUILD / 'ownership-origin-b2-self01'
    windows_path = capture / 'windows.json'; analysis_path = capture / 'analysis.json'
    windows = json.loads(windows_path.read_text()); analysis = json.loads(analysis_path.read_text())
    assert all(windows[k] for k in ['complete', 'targetComplete', 'fullCExact', 'diagnosticExact', 'zeroLoss'])
    for key in ['preparation', 'binding', 'analysis', 'method', 'process', 'samples', 'output']:
        assert windows[key] == pin(windows[key]['file'])
    prep = json.loads(Path(windows['preparation']['file']).read_text())
    for item in prep['inputs']: assert pin(item['file']) == item
    binary = Path(prep['image']['file']); c_path = Path(prep['oracle']['c']['file'])
    assert pin(binary) == prep['image'] and pin(c_path) == prep['oracle']['c']
    assert prep['image']['sha256'] == 'c481bd2c1b057dee537442765aca1b36786437fe37b3543dc405677329f18554'
    assert prep['oracle']['c']['sha256'] == '6ae1675a1472afff7a871eb2cf3b42186ca51d0f1b28c03b567863fc4dcdd9d6'
    process = json.loads(Path(windows['process']['file']).read_text())
    request = next(p for p in analysis['phases'] if p['name'] == 'request-1')
    count = request['samples']; assert count == windows['requestSamples'] == 8823
    leaves = {x['function']: x['samples'] for x in request['leaf_functions']}
    owners = Counter()
    for row in request['ownership_callers']: owners[row['physical_owner']] += row['samples']
    assert sum(owners.values()) == request['ownership_physical_owner_recovered'] == request['ownership_samples'] == 4463
    leaf_rows = [dict(symbol=s, name=decode(s), samples=n, percentRequest=100*n/count)
                 for s, n in sorted(leaves.items(), key=lambda x: -x[1])]
    owner_rows = [dict(symbol=s, name=decode(s), samples=n, percentRequest=100*n/count,
                      leafPlusPhysicalOwnershipSamples=n+leaves.get(s, 0),
                      leafPlusPhysicalOwnershipPercentRequest=100*(n+leaves.get(s, 0))/count)
                  for s, n in owners.most_common()]
    symbol_rows = {}
    for line in subprocess.check_output(['nm', '-n', '-S', str(binary)], text=True).splitlines():
        parts = line.split()
        if len(parts) == 4:
            try: start, size = int(parts[0], 16), int(parts[1], 16)
            except ValueError: continue
            symbol_rows[parts[3]] = (start, size)
    walker = symbol('p88_string_eq_go', 'NF_FID_')
    assert symbol_rows[walker] == (0xc62270, 0x9ea)
    regions = [dict(name='entry and owning-fallback region; includes shared-root test', start=0xc62270, end=0xc6279f),
               dict(name='inlined borrowed observer walk and result checks', start=0xc6279f, end=0xc628ed),
               dict(name='borrowed-adapter first-root disposal prelude and shared-tail transfer', start=0xc628ed, end=0xc62952),
               dict(name='remaining common exits and owning-fallback cleanup', start=0xc62952, end=0xc62c5a)]
    header, mappings, samples, marks = M.read_samples(capture / 'samples.txt')
    assert header == analysis['header'] and marks == analysis['marks']
    selected = [s for s in samples if request['start_ns'] <= s['mono'] < request['end_ns']]
    assert len(selected) == count
    segments = A.load_segments(binary)
    mappings = [m for m in mappings if m['path'] and Path(m['path']).resolve() == binary]
    def address(pc):
        for mapping in mappings:
            if mapping['start'] <= pc < mapping['end']:
                return A.virtual_address(pc, mapping, segments)
        return None
    pc_counts = Counter(address(s['pc']) for s in selected)
    for region in regions:
        n = sum(n for pc, n in pc_counts.items() if pc is not None and region['start'] <= pc < region['end'])
        region.update(samples=n, percentWalker=100*n/leaves[walker], percentRequest=100*n/count,
                      start=hex(region['start']), endExclusive=hex(region.pop('end')))
    assert [x['samples'] for x in regions] == [79, 577, 51, 36]
    assert sum(x['samples'] for x in regions) == leaves[walker]
    args.out.mkdir(parents=True)
    c = c_path.read_text()
    spans = []
    def add_c(name, kind):
        if kind == 'scheduler':
            sym = symbol(name, 'FID_'); start = c.index('  WL_CASE(' + sym + ')\n')
            end = c.index('\n  WL_CASE(', start + 1)
        else:
            sym = symbol(name, 'NF_FID_')
            match = re.search(r'(?m)^(?:NF_INLINE|INLINE) (?:Term|Loc|void) ' + sym + r'\([^\n;]*\) \{', c)
            assert match; start = match.start(); pos = c.index('{', start); depth = 0
            while pos < len(c):
                if c[pos] == '{': depth += 1
                elif c[pos] == '}':
                    depth -= 1
                    if depth == 0: end = pos + 2; break
                pos += 1
            else: raise AssertionError(name)
        data = c[start:end].encode()
        spans.append(dict(name=name, kind=kind, cSymbol=sym, byteStart=len(c[:start].encode()),
                          byteEnd=len(c[:end].encode()), lineStart=c.count('\n', 0, start)+1,
                          lineEnd=c.count('\n', 0, end-1)+1, bytes=len(data),
                          sha256=hashlib.sha256(data).hexdigest(), text=c[start:end]))
    for name in ['$direct.kc', '$direct.nt_choose', '$direct.String.append', 'native_k_44186', '$direct.p88_string_eq']:
        add_c(name, 'scheduler')
    for name in ['dn', 'dk', 'ks', 'p98_tag_eq_read', 'p88_string_eq_go', '$observer.p88_string_eq_go', '$observer.adapter.p88_string_eq_go']:
        add_c(name, 'native')
    append = next(x['text'] for x in spans if x['name'] == '$direct.String.append')
    continuation = next(x['text'] for x in spans if x['name'] == 'native_k_44186')
    assert ('STK(1) = ' + symbol('native_k_44186', 'FID_') + ';') in append
    assert ('WL_JMP(' + symbol('$direct.String.append', 'FID_') + ');') in append
    assert 'rfc_seal(e, v_4294923110)' in continuation and 'term_ctr(CID_SCON, nd_44187)' in continuation
    assembly = []
    for label, sym in [('walker', walker), ('kc', symbol('$direct.kc', 'WL_FID_')),
                       ('nt_choose', symbol('$direct.nt_choose', 'WL_FID_')),
                       ('public-equality', symbol('$direct.p88_string_eq', 'WL_FID_')),
                       ('append-continuation', symbol('native_k_44186', 'WL_FID_'))]:
        start, size = symbol_rows[sym]
        command = ['objdump', '-d', '--no-show-raw-insn', '--start-address='+hex(start), '--stop-address='+hex(start+size), str(binary)]
        text = subprocess.check_output(command, text=True)
        path = args.out / (label + '.asm'); path.write_text(text)
        assembly.append(dict(label=label, symbol=sym, start=hex(start), endExclusive=hex(start+size), command=command, output=pin(path)))
        if label == 'walker':
            lines = [line for line in text.splitlines() if re.match(r'^\s*[0-9a-f]+:', line)]
            borrowed = [line for line in lines if 0xc6279f <= int(line.split(':')[0], 16) < 0xc628ed]
            assert borrowed and not any(re.search(r'\bcallq?\b', line) for line in borrowed)
            assert sum('jne ' in line and 'c6279f' in line for line in lines) == 2
    windows_summary = []
    for w in windows['windows']:
        windows_summary.append(dict(startSeconds=w['startRequestWallSeconds'], endSeconds=w['endRequestWallSeconds'], samples=w['samples'],
            topLeaves=[dict(name=decode(x['function']), samples=x['samples'], percent=x['percent']) for x in w['leaves'][:8]],
            topOwnership=[dict(leaf=x['leaf'], owner=decode(x['physicalOwner']), samples=x['samples'], percent=x['percentWindow']) for x in w['ownershipCallers'][:8]]))
    report = dict(kind='phase98-origin-b2-complete-profile-attribution', complete=True, targetsRun=False,
        method=pin(__file__), inputs=[pin(windows_path), pin(analysis_path), prep['image'], prep['oracle']['c'], windows['samples'], windows['process'], windows['preparation']],
        scope=dict(targetComplete=True, fullCExact=True, diagnosticExact=True, zeroLoss=True,
                   guardWallSeconds=process['wallSeconds'], peakTreeRssBytes=process['peakTreeRssBytes'], request={k: request[k] for k in ['name', 'start_ns', 'end_ns', 'wall_ms', 'process_cpu_ms', 'reported_ms']},
                   coverage=windows['coverage'], requestSamples=count, ownershipSamples=4463,
                   ownershipPercentRequest=100*4463/count),
        leaves=leaf_rows, physicalOwnershipOwners=owner_rows, walkerMachineRegions=regions,
        cSpans=spans, assembly=assembly, windows=windows_summary,
        limitations=['One successful complete self-compilation request; percentages use request samples, not the 8872 complete-process samples.',
                     'Physical owner attribution is not a logical/inclusive call tree; musttail-eliminated ancestors are unavailable.',
                     'NF_p88_string_eq_go includes an inlined borrowed observer: its symbol alone does not identify the fallback.',
                     'Leaf plus physically owned cleanup is a disjoint observed bucket, not an estimate of removable time.',
                     'Second-root drop at return PC minus one 0xc62aa6 is in a merged tail and cannot all be charged to the borrowed adapter.',
                     'Wall windows are not compiler stages. Base has eight samples and runtime setup none.',
                     'This capture alone does not quantify the causal B1/B2 difference or a speedup; no old watchdog profile is used.'])
    report_path = args.out / 'report.json'; report_path.write_text(json.dumps(report, indent=2)+'\n')
    print(json.dumps(dict(complete=True, targetsRun=False, report=pin(report_path), borrowedWalkSamples=577, requestSamples=count)))


if __name__ == '__main__': main()

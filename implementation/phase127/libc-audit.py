#!/usr/bin/env python3
"""Offline exact-libc region audit of the already completed Phase127 captures."""
import collections
import hashlib
import json
from pathlib import Path
import re
import subprocess

ROOT = Path(__file__).resolve().parents[2]
OUT = Path(__file__).resolve().parent


def pin(path):
    path = Path(path).resolve()
    digest = hashlib.sha256()
    with path.open('rb') as stream:
        for block in iter(lambda: stream.read(1024 * 1024), b''):
            digest.update(block)
    return dict(file=str(path), bytes=path.stat().st_size, sha256=digest.hexdigest())


def save(path, value):
    with path.open('x') as stream:
        json.dump(value, stream, indent=2); stream.write('\n')


def main():
    libc = Path('/usr/lib/x86_64-linux-gnu/libc-2.31.so')
    library = pin(libc)
    assert library['sha256'] == 'd13f170ab30a0f91d9713e0c2196efa5fe0bc42f0f2737cf0e56380df8051159'
    old_asm = ROOT/'implementation/phase119/libc-copy-fill.asm'
    assembly = subprocess.check_output(['objdump', '-d', '-M', 'intel',
        '--start-address=0xa3930', '--stop-address=0xa3de3', str(libc)], text=True)
    assert assembly == old_asm.read_text()
    frames = subprocess.check_output(['readelf', '--debug-dump=frames', str(libc)], text=True)
    blocks = re.split(r'\n\s*\n', frames)
    cie = next(b for b in blocks if b.startswith('00000000 ') and ' CIE' in b)
    assert 'DW_CFA_def_cfa: r7 (rsp) ofs 8' in cie
    assert 'DW_CFA_offset: r16 (rip) at cfa-8' in cie
    selected = []
    unwind = []
    for block in blocks:
        match = re.search(r'pc=([0-9a-f]+)\.\.([0-9a-f]+)', block)
        if not match:
            continue
        start, end = (int(n, 16) for n in match.groups())
        if start < 0xa3de3 and end > 0xa3930:
            assert 'cie=00000000 ' in block
            assert all(line.strip() == 'DW_CFA_nop' for line in block.splitlines()[1:] if line.strip())
            selected.append(block)
            unwind.append(dict(start=hex(start), end=hex(end), cfaRegister='rsp',
                               cfaOffset=8, returnAddressOffset=-8))
    (OUT/'libc-cfi.txt').write_text(cie + '\n\n' + '\n\n'.join(selected) + '\n')
    regions = dict(schema='bend-reviewed-elf-regions-v1', object=library,
        evidence=[pin(old_asm), pin(OUT/'libc-cfi.txt'), pin(__file__)],
        addressSpace='ELF virtual addresses; end exclusive; translate ASLR mapping before lookup',
        ranges=[dict(start='0xa3930', end='0xa3c29', name='libc.copy_region',
                     category='memory_copy', basis='Reviewed loads/stores, overlap branches and REP MOVS'),
                dict(start='0xa3c30', end='0xa3de3', name='libc.fill_region',
                     category='memory_fill', basis='Reviewed byte broadcast, vector stores and REP STOS')],
        physicalUnwindRows=unwind,
        limitations=['Region names describe instructions, not an exported dynamic symbol or source caller.',
          'Fill includes bzero/memset/wmemset entries and checks; sampled PCs do not establish fill byte or length.',
          'Use individual FDE intervals for unwind, not the broad classification ranges or intervening padding.',
          'Return-address recovery requires authenticated module mapping, mapped-stack bounds and alignment.',
          'Only one physical caller is established; tail-erased logical ancestors cannot be recovered.'])
    save(OUT/'libc-regions.json', regions)
    report_path = ROOT/'selfhost/build/phase127/paired01/report.json'
    report = json.loads(report_path.read_text())
    assert report['complete'] and report['passed']
    results = dict(complete=True, inputs=[pin(report_path), pin(OUT/'libc-regions.json')], cases=[])
    for name, summary in report['summary'].items():
        case = dict(name=name, variants={})
        for variant in ('phase125', 'phase126'):
            raw, weighted, by_period = collections.Counter(), collections.Counter(), collections.defaultdict(collections.Counter)
            total, total_weight, captures = 0, 0, []
            for row in report['rows']:
                if (row['workload'], row['variant'], row['mode']) != (name, variant, 'sample'):
                    continue
                actual = pin(row['analysis']['file'])
                assert actual == row['analysis']
                analysis = json.loads(Path(actual['file']).read_text())
                quality = analysis['quality']
                assert quality['zero_loss'] and quality['handler_intact'] and quality['main_thread_shutdown']
                assert quality['near_complete_process_cpu_coverage'] and quality['delivery_plausible']
                header = analysis['header']; period = header['period_us']
                total += header['samples']; total_weight += period * header['samples']
                captures.append(actual)
                for pc in analysis['pcs']:
                    if pc['mapping'] != str(libc):
                        continue
                    address = int(pc['elf_address'], 16)
                    kind = 'copy' if 0xa3930 <= address < 0xa3c29 else 'fill' if 0xa3c30 <= address < 0xa3de3 else 'other'
                    raw[kind] += pc['samples']; weighted[kind] += period * pc['samples']
                    by_period[period][kind] += pc['samples']
            cpu = summary[variant]['clean']['cpuSeconds']['median']
            case['variants'][variant] = dict(cleanCpuSeconds=cpu, totalSamples=total,
                adequatePooledSamples=total >= 500, captures=captures, rawCounts=dict(raw),
                byPeriodCounts=dict(by_period), totalPeriodWeightedSamplesUs=total_weight,
                weightedFractions={kind:weighted[kind]/total_weight for kind in ('copy','fill','other')},
                approximateCpuSeconds={kind:cpu*weighted[kind]/total_weight for kind in ('copy','fill','other')})
        old, new = (case['variants'][v] for v in ('phase125','phase126'))
        case['cleanCpuIncreaseSeconds'] = new['cleanCpuSeconds']-old['cleanCpuSeconds']
        case['approximateFillIncreaseSeconds'] = new['approximateCpuSeconds']['fill']-old['approximateCpuSeconds']['fill']
        results['cases'].append(case)
    results['method'] = 'Pool samples weighted by each capture period, then multiply fraction by separately measured median clean process CPU. Approximate attribution, not causal saving or confidence interval; closure group below500samples is exploratory.'
    descriptors = {}
    for phase in (125,126):
        qbe = ROOT/f'selfhost/build/phase111/p{phase}-native{"06" if phase==125 else "32"}-full-emit/program.ssa'
        with qbe.open() as stream:
            line = next(line for line in stream if line.startswith('export data $p111_program ='))
        fields = line.split('{', 1)[1].split('}', 1)[0].split(',')
        descriptors[str(phase)] = dict(qbe=pin(qbe), declaration=line.strip(), capabilities=int(fields[11].strip()[2:]))
    runtime = ROOT/'selfhost/build/phase126/runtime-divmod01/runtime.c'
    header = runtime.with_name('runtime.h')
    assert 'uint64_t capabilities;' in header.read_text()
    results['descriptors'] = descriptors
    results['runtimeInputs'] = [pin(runtime), pin(header)]
    save(OUT/'libc-profile-comparison.json', results)
    print(json.dumps({c['name']:{'totalCpuIncrease':c['cleanCpuIncreaseSeconds'],
          'approximateFillIncrease':c['approximateFillIncreaseSeconds']} for c in results['cases']},indent=2))


if __name__ == '__main__':
    main()

#!/usr/bin/env python3
"""Read-only machine inspection of existing Phase109 binaries; never runs targets."""
import argparse
from collections import Counter
import hashlib
import json
from pathlib import Path
import re
import shutil
import statistics
import subprocess

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[4]
WORKERS = ['nx_list_reverse', 'nx_string_reverse']
PRODUCTION = ['NF_FID_110_116_95_114_101_118_101_114_115_101_',
              'NF_FID_83_116_114_105_110_103_46_114_101_118_101_114_115_101_46_103_111_']
HELPERS = ['nx_rt_id', 'nx_rt_fast_id', 'nx_rt_take2', 'nx_rt_fast_take2',
           'nx_rt_field', 'nx_rt_fast_field', 'nx_rt_build2', 'nx_rt_fast_build2',
           'nx_rt_rebuild2', 'nx_construct2', 'ctr_take', 'rfc_seal', 'rfc_wrap',
           'cls_fit', 'term_aux', 'heap_alloc', 'spare_free']


def pin(path):
    raw = path.read_bytes()
    return dict(file=str(path), bytes=len(raw), sha256=hashlib.sha256(raw).hexdigest())


def command(args):
    return subprocess.check_output(list(map(str, args)), text=True)


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--suite', type=Path, required=True)
    p.add_argument('--out', type=Path, required=True)
    a = p.parse_args()
    suite, out = a.suite.resolve(), a.out.resolve()
    if not out.is_relative_to(ROOT / 'implementation/phase109/evidence') or out.exists():
        raise ValueError('fresh output below implementation/phase109/evidence required')
    out.mkdir(parents=True)
    tools = {name: Path(shutil.which(name)) for name in ['objdump', 'nm', 'size']}
    report = dict(kind='phase109-offline-machine-shapes', version=1,
                  targetsRun=False, complete=False, inputs=[pin(Path(__file__).resolve())],
                  tools={name: dict(pin=pin(path), version=command([path, '--version']).splitlines()[0])
                         for name, path in tools.items()}, profiles=[])
    for policy in ['raw', 'trusted', 'fused']:
        directory = suite / (policy + '-reverse-kernel')
        receipt = json.loads((directory / 'report.json').read_text())
        report['inputs'].append(pin(directory / 'report.json'))
        for variant in receipt['builds']:
            binary = directory / variant
            identity = pin(binary)
            if identity != receipt['builds'][variant]['binary']:
                raise ValueError('binary does not match benchmark receipt')
            report['inputs'].append(identity)
            prefix = policy + '-' + variant
            nm = command([tools['nm'], '-S', '--defined-only', binary])
            symbols = {}
            for line in nm.splitlines():
                fields = line.split()
                if len(fields) == 4:
                    symbols[fields[3]] = dict(address=int(fields[0], 16), bytes=int(fields[1], 16), kind=fields[2])
            text_dump = command([tools['objdump'], '-s', '-j', '.text', binary])
            text_bytes = bytearray()
            for line in text_dump.splitlines():
                match = re.match(r'^\s+[0-9a-f]+\s+((?:[0-9a-f]{8}(?:\s+|$)){1,4})', line)
                if match:
                    text_bytes.extend(bytes.fromhex(match.group(1)))
            # objdump's last word can be short; derive byte size from section header
            # and reject truncated extraction rather than claiming text identity.
            header = command([tools['objdump'], '-h', binary])
            text_size = int(next(line.split()[2] for line in header.splitlines()
                                 if len(line.split()) > 2 and line.split()[1] == '.text'), 16)
            if len(text_bytes) != text_size:
                # Full extraction that admits the final short hex group.
                text_bytes = bytearray()
                for line in text_dump.splitlines():
                    match = re.match(r'^\s+[0-9a-f]+\s+(.*)$', line)
                    if match:
                        region = match.group(1)[:35]
                        for word in region.split():
                            if re.fullmatch(r'(?:[0-9a-f]{2}){1,4}', word):
                                text_bytes.extend(bytes.fromhex(word))
                if len(text_bytes) != text_size:
                    raise ValueError('incomplete executable text extraction')
            inspected = []
            selected = WORKERS + PRODUCTION + HELPERS
            selected += [name + '.cold' for name in selected if name + '.cold' in symbols]
            for name in selected:
                if name not in symbols:
                    continue
                asm = command([tools['objdump'], '-d', '--no-show-raw-insn', '--disassemble=' + name, binary])
                path = out / (prefix + '--' + name + '.asm')
                path.write_text(asm)
                instructions = []
                for line in asm.splitlines():
                    match = re.match(r'^\s*([0-9a-f]+):\s+(\S+)(?:\s+(.*))?$', line)
                    if match:
                        instructions.append(dict(address=int(match.group(1), 16),
                            mnemonic=match.group(2), operands=match.group(3) or ''))
                calls = []
                tail_jumps = []
                for instruction in instructions:
                    target = re.search(r'<([^>]+)>', instruction['operands'])
                    if instruction['mnemonic'].startswith('call'):
                        calls.append(target.group(1) if target else instruction['operands'])
                    elif instruction['mnemonic'].startswith('jmp') and target and not target.group(1).startswith(name):
                        tail_jumps.append(target.group(1))
                hot_loop = None
                if name in WORKERS and variant.startswith('direct-') or name in PRODUCTION and variant == 'production-qbe':
                    edges = []
                    for instruction in instructions:
                        m = re.match(r'([0-9a-f]+) <', instruction['operands'])
                        if instruction['mnemonic'].startswith('jmp') and m:
                            target = int(m.group(1), 16)
                            if symbols[name]['address'] <= target < instruction['address']:
                                edges.append((target, instruction['address']))
                    if edges:
                        start, end = max(edges, key=lambda edge: edge[1] - edge[0])
                        body = [ins for ins in instructions if start <= ins['address'] <= end]
                        hot_loop = dict(start=hex(start), backedge=hex(end),
                            instructionSites=len(body),
                            callSites=[re.search(r'<([^>]+)>', ins['operands']).group(1)
                              for ins in body if ins['mnemonic'].startswith('call')],
                            note='Static nonempty loop range; excludes callees and counts branch sites, not dynamic instructions.')
                inspected.append(dict(name=name, **symbols[name], instructionSites=len(instructions),
                    mnemonics=dict(Counter(ins['mnemonic'] for ins in instructions)),
                    staticCallSites=calls, staticNonlocalJumps=tail_jumps, loop=hot_loop,
                    assembly=pin(path)))
            timings = [t['workerSeconds'] for t in receipt['timings'] if t['variant'] == variant]
            profile = dict(policy=policy, variant=variant, binary=identity,
                executableText=dict(bytes=text_size, sha256=hashlib.sha256(text_bytes).hexdigest()),
                sizeTool=command([tools['size'], binary]), symbols=inspected,
                existingTiming=dict(samples=timings, median=statistics.median(timings),
                    source=str(directory / 'report.json'), newTargetsRun=False) if timings else None)
            report['profiles'].append(profile)
    for record in report['inputs']:
        if pin(Path(record['file'])) != record:
            raise ValueError('input changed during inspection')
    report['complete'] = True
    (out / 'report.json').write_text(json.dumps(report, indent=2) + '\n')
    print(json.dumps(dict(complete=True, targetsRun=False, profiles=len(report['profiles']), out=str(out))))


if __name__ == '__main__':
    main()

"""Check the frozen transfer and build independent scalar native and mature C products."""
import argparse
from hashlib import sha256
import json
import os
from pathlib import Path
import subprocess
import time

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
SOURCE = HERE / 'packet-window.bend'
EXPECTED_SOURCE = '62f91b9f53e3f094414549368432cabe6cae4253d457ad22cc93db216b78877a'
EXPECTED_ORACLES = 'ddea827a138db0006e377f4e67b112d4d9699f1d41499695be4947c6e55180d5'


def read(path):
    return json.loads(path.read_text())


def write(path, obj):
    path.write_text(json.dumps(obj, indent=2) + '\n')


def pin(path):
    file = Path(path).resolve()
    return dict(file=str(file), bytes=file.stat().st_size, sha256=sha256(file.read_bytes()).hexdigest())


def authenticate(row):
    assert pin(row['file']) == row, row['file']
    return row['file']


def command(out, name, argv, binary_stdout=None):
    argv = [str(x) for x in argv]
    start = time.monotonic()
    result = subprocess.run(argv, capture_output=True, timeout=35)
    stdout = binary_stdout or out / (name + '.stdout')
    stdout.write_bytes(result.stdout)
    err = out / (name + '.stderr')
    err.write_bytes(result.stderr)
    receipt = dict(argv=argv, exit=result.returncode, seconds=time.monotonic()-start,
                   stdout=pin(stdout), stderr=pin(err))
    write(out / (name + '.json'), receipt)
    if result.returncode:
        raise RuntimeError(name + ': ' + (result.stderr+result.stdout)[-1500:].decode(errors='replace'))
    return receipt


def checks(out, role, binary, rows):
    proofs = []
    for index, row in enumerate(rows):
        count = int(index < 2)
        args = [str(binary), '+RTS', '--threads', '1', '--gpu', 'off', '-RTS', '--RTS',
                str(count), '0', *map(str, row['inputs'])]
        p = subprocess.run(args, capture_output=True, timeout=8)
        lines = p.stdout.decode(errors='replace').splitlines()
        expected = [row['output'].rstrip('\n'), '0', str(count)]
        observation = dict(inputs=row['inputs'], expected=expected, stdout=lines,
                           stderr=p.stderr.decode(errors='replace'), exit=p.returncode)
        proofs.append(observation)
        write(out / (role+'-checks.json'), proofs)
        assert not p.returncode and not p.stderr and len(lines) == 4 and lines[:3] == expected and lines[3].isdecimal(), observation
        words = list(map(int, lines[0].split(',')))
        assert words == [row['carry'], *row['cells']]
    return len(proofs)


def main(out, roles):
    assert os.sched_getaffinity(0) == {3}
    out.mkdir(parents=True, exist_ok=False)
    oracle = HERE / 'oracles.json'
    assert pin(SOURCE)['sha256'] == EXPECTED_SOURCE and pin(oracle)['sha256'] == EXPECTED_ORACLES
    summary = dict(complete=False, source=pin(SOURCE), oracles=pin(oracle), products={})
    write(out/'report.json', summary)
    if 'check' in roles:
        command(out, 'source-check', ['selfhost/.assets/bin/bun','selfhost/tools/build/check-source.mjs',
            '--source',SOURCE,'--out',out/'upstream','--manifest','selfhost/src/compiler.json',
            '--upstream','selfhost/.bootstrap/upstream-phase182'])
        upstream = read(out/'upstream/report.json')
        assert upstream['complete'] and upstream['typeAccepted'] and upstream['unresolvedHoles'] == 0
        summary['upstream'] = pin(out/'upstream/report.json')
    rows = read(oracle)['transfer']
    if 'native' in roles:
        request = read(ROOT/'selfhost/build/phase198/progress-native45-02/local-fold/machine/report.json')
        for item in request['inputs']:
            authenticate(item)
        cmd = request['compilerCommand'][:]
        assert cmd[8] == 'x86-object' and Path(cmd[9]).name == 'local-fold.bend'
        cmd[9] = str(SOURCE)
        obj = out/'native.o'
        command(out, 'native-emit', cmd, obj)
        assert obj.read_bytes().startswith(b'\x7fELF')
        tools = read(ROOT/'selfhost/build/phase194/assets.json')['assets']
        cc,rt = [authenticate(tools[key]) for key in ('linker','qbe-runtime')]
        tc = request['toolchain']
        binary = out/'native'
        command(out, 'native-link', [cc,*tc['linkerFlags'],obj,rt,*tc['libraries'],'-o',binary])
        summary['products']['native'] = dict(binary=pin(binary), object=pin(obj), compiler=pin(cmd[0]),
            checks=checks(out,'native',binary,rows))
        write(out/'report.json', summary)
    if 'c' in roles:
        ref = ROOT/'selfhost/build/phase184/bend-products01/local-fold/bend-c'
        template = read(ref/'emission/request.json')
        image = authenticate(template['image'])
        src = out/'program.c'
        command(out, 'c-emit', [image,SOURCE,'-o',src])
        machine = read(ref/'build.json')
        clang = authenticate(machine['compiler'])
        ccargs = machine['process']['command'][:]
        assert ccargs[0] == clang
        ccargs[ccargs.index(machine['source']['file'])] = str(src)
        binary = out/'c'
        ccargs[ccargs.index('-o')+1] = str(binary)
        command(out, 'c-link', ccargs)
        summary['products']['c'] = dict(binary=pin(binary), emittedSource=pin(src),
            compiler=pin(image), cCompiler=pin(clang), checks=checks(out,'c',binary,rows))
    summary['complete'] = True
    write(out/'report.json', summary)


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('--out',type=Path,required=True)
    parser.add_argument('--roles',default='check,native,c')
    args=parser.parse_args()
    main(args.out.resolve(),set(args.roles.split(',')))

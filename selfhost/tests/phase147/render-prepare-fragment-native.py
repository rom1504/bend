#!/usr/bin/env python3
"""Prepare matched renderer sources and root-owned build jobs; execute no target."""
import argparse
import importlib.util
import json
from pathlib import Path
import sys

sys.dont_write_bytecode = True
ROOT = Path(__file__).resolve().parents[3]
spec = importlib.util.spec_from_file_location('phase147_prepare', ROOT/'experiments/phase147/tools/prepare.py')
P = importlib.util.module_from_spec(spec)
spec.loader.exec_module(P)
from common import verify


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--kernel', type=Path, required=True)
    parser.add_argument('--controls', type=Path, required=True)
    parser.add_argument('--workload', type=Path, required=True)
    parser.add_argument('--out', type=Path, required=True)
    args = parser.parse_args()
    kernel, controls = json.loads(args.kernel.read_text()), json.loads(args.controls.read_text())
    P.require(kernel['complete'] and controls['complete'] and controls['passed'], 'Closed checked controls required')
    P.require(kernel['source'] in controls['inputs'], 'Controls do not bind kernel source')
    inputs = [P.pin(__file__), P.pin(P.__file__), P.pin(args.kernel), P.pin(args.controls),
              kernel['source'], P.pin(args.workload)]
    for item in inputs: verify(item)
    out = P.fresh_output(args.out, ROOT)
    rows, jobs, sources = [], [], []
    for role, flag in [('original', '0'), ('calls', '1'), ('fragments', '2')]:
        entry = ('def main() -> IO(U32):\n  p147qn_main('+flag+')\n').encode()
        body, declarations = P.extract([
            ('checked-kernel', Path(kernel['source']['file']).read_bytes()),
            ('native-workload', args.workload.read_bytes()), ('entry', entry)], ['main'])
        source = out/(role+'.bend'); source.write_bytes(body); sources.append(body)
        destination = out.parent/(out.name.replace('plan', role))
        command = ['python3', '-B', ROOT/'selfhost/tools/build/native.py',
            '--assets', ROOT/'selfhost/manifests/assets-native.json', '--image-key', 'qbe-n2',
            '--host', 'native', '--target', 'qbe', '--stage', 'N2', '--source', source,
            '--mode', 'cache', '--out', destination, '--seconds', '90']
        jobs.append(P.guard('build-render-'+role, destination, command, 100, disk=128))
        rows.append(dict(role=role, source=P.pin(source), declarations=declarations,
                         build=str(destination/'report.json'), binary=str(destination/'program')))
    for i in [1, 2]:
        P.require(sources[0].replace(b'p147qn_main(0)', ('p147qn_main('+str(i)+')').encode()) == sources[i],
                  'Matched sources differ beyond selected entry mode')
    for item in inputs: verify(item)
    manifest = dict(kind='phase147-three-mode-native-render-preparation', version=1, complete=True,
        targetsRun=False, qualified=False, inputs=inputs, rows=rows,
        controls=P.pin(args.controls), kernel=P.pin(args.kernel), jobs=jobs,
        sourceDifference='Exactly main(0/1/2); all original/call-only/general renderer, fixture and IO bodies identical.',
        scope='Complete current Map/Lexer/compiler branch-free bodies under original scalar rendering policy. Each iteration renders and writes one complete function; not full selected compiler throughput.')
    P.write_json(out/'manifest.json', manifest); P.write_json(out/'jobs.json', jobs)
    pairs=[]
    for reference in [0,1]:
        label='original' if reference==0 else 'calls'
        comparison=dict(manifest,kind='phase147-matched-native-render-preparation',version=3,
            parentPreparation=P.pin(out/'manifest.json'),
            entrySelection=dict(reference=reference,candidate=2),
            rows=[dict(rows[reference],role='baseline',actualRole=label),dict(rows[2],role='candidate',actualRole='fragments')],
            inputs=inputs+[P.pin(out/'manifest.json')])
        path=out/(label+'-comparison.json');P.write_json(path,comparison)
        destination=out.parent/(out.name+'-'+label+'-pairs')
        command=['python3','-B',Path(__file__).with_name('render-fragment-native-pairs.py'),
            '--preparation',path,'--out',destination]
        pairs.append(P.guard('fragment-pairs-versus-'+label,destination,command,180,disk=32))
    P.write_json(out/'pairs-jobs.json',pairs)
    print(json.dumps(dict(manifest=P.pin(out/'manifest.json'), jobs=P.pin(out/'jobs.json'))))


if __name__ == '__main__': main()

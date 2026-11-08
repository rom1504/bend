#!/usr/bin/env python3
"""Execute actual native N1/N2/Q3 generations, without promoting a selection."""
import argparse
import copy
from pathlib import Path
import sys
import time

sys.dont_write_bytecode = True
import native
import request as requests
from common import (changed_inputs, fresh_output, pin, require, same_bytes,
                    timeout, workspace, write_json)


def chain(args):
    require(args.target == 'qbe', 'Native fixed-point chain requires the QBE entry')
    root = workspace(args.workspace)
    timeout(args.seconds)
    first = requests.plan(args)  # Validate inputs before creating any output.
    require(not args.plan, 'Use request.py/native.py --plan for preflight; chain executes generations')
    out = fresh_output(args.out, root)
    inputs = [pin(__file__), *first['inputs']]
    report = dict(kind='bend-native-bootstrap-chain', version=1, complete=False,
                  inputs=inputs, source=first['source'], producer=first['image'],
                  producerHost=args.host, producerStage=args.stage, generations=[],
                  semanticsQualified=False, selected=False,
                  scope='Actual N1 emits N2, then actual N2 emits Q3. Byte fixed point is separate from semantic conformance.')
    start = time.monotonic()

    def left():
        remaining = args.seconds - (time.monotonic() - start)
        if remaining <= 0:
            raise TimeoutError('Bootstrap whole-chain deadline exceeded')
        return remaining

    def save():
        report['seconds'] = time.monotonic() - start
        write_json(out / 'report.json', report)

    save()
    try:
        parent_image, parent_receipt = args.image, args.image_receipt
        for stage, dirname in [('N1', 'n1'), ('N2', 'n2')]:
            build = copy.copy(args)
            build.out = out / dirname
            build.seconds, build.ir, build.retain_ir = left(), None, True
            build.expected_stdout = None
            build.output_stage, build.output_protocol = stage, 'qbe-source-v1'
            if stage == 'N2':
                build.host, build.stage, build.image_key = 'native', 'N1', None
                build.image, build.image_receipt = parent_image, parent_receipt
                build.expected = out / 'n1/program.ssa'
            product = native.build(build)
            receipt = pin(build.out / 'report.json')
            report['generations'].append(dict(stage=stage, complete=product['complete'], report=receipt))
            save()
            require(product['complete'], 'Actual ' + stage + ' generation failed')
            parent_image, parent_receipt = build.out / 'program', build.out / 'report.json'
        report['machineIdentity'] = {
            name: same_bytes(out / ('n1/' + name), out / ('n2/' + name))
            for name in ('program.ssa', 'program.s', 'program.o', 'program')}
        # Different object/ELF layout is evidence, not permission to skip N2 execution.
        q3 = copy.copy(args)
        q3.out, q3.seconds = out / 'q3', left()
        q3.host, q3.stage, q3.image_key = 'native', 'N2', None
        q3.image, q3.image_receipt = parent_image, parent_receipt
        q3.expected = out / 'n2/program.ssa'
        product = requests.execute(q3)
        report['generations'].append(dict(stage='Q3', complete=product['complete'],
                                         report=pin(q3.out / 'report.json')))
        require(product['complete'], 'Actual N2 Q3 execution failed')
        report['qbeFixedPoint'], report['complete'] = True, True
    except BaseException as error:
        report['error'] = repr(error)
    finally:
        report['changedInputs'] = changed_inputs(inputs)
        if report['changedInputs']:
            report['complete'] = False
        save()
    return report


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    requests.arguments(parser)
    parser.add_argument('--runtime-key', default='qbe-runtime')
    parser.add_argument('--runtime', type=Path)
    parser.add_argument('--runtime-argument-convention', choices=['bend-legacy-v1', 'bend-rts-v1'])
    args = parser.parse_args()
    result = chain(args)
    import json
    print(json.dumps({k: result.get(k) for k in ('complete', 'seconds', 'qbeFixedPoint', 'machineIdentity', 'error')}, indent=2))
    return 0 if result['complete'] else 1


if __name__ == '__main__':
    sys.exit(main())

#!/usr/bin/env python3
"""Use the existing runner/observer with one explicit frontend stderr contract.

Only three decimal timing fields vary. All raw output is retained by run.py;
stdout, status, samples, inputs, stages and quality checks stay unchanged.
"""
from pathlib import Path
import re
import sys

sys.dont_write_bytecode = True
ROOT = Path(__file__).resolve().parents[4]
sys.path.insert(0, str(ROOT / 'selfhost/tools/profiler'))
import run

ORIGINAL_MATCH = run.output_matches


def output_matches(path, expected):
    if expected['kind'] == 'phase175-frontend-timing-line-v1':
        if set(expected) != {'kind', 'priorObservation', 'adapter'}:
            raise ValueError('Unexpected timing contract fields')
        if run.pin(__file__) != expected['adapter']:
            raise ValueError('Timing adapter identity differs')
        run.verify(expected['priorObservation'])
        return re.fullmatch(rb'phase175 base_ms=([0-9]+) frontend_ms=([0-9]+) observation_ms=([0-9]+)\n',
                            Path(path).read_bytes()) is not None
    return ORIGINAL_MATCH(path, expected)


if __name__ == '__main__':
    if len(sys.argv) < 2 or sys.argv[1] not in ('capture', 'observe'):
        raise SystemExit('usage: adapter.py capture RUN_ARGS | observe STAGE_OBSERVE_ARGS')
    operation = sys.argv.pop(1)
    run.output_matches = output_matches
    if operation == 'capture':
        run.main()
    else:
        # Import after installing the same contract used for capture; the
        # original observer revalidates every frozen raw output and stage.
        import stages_v1
        sys.argv.insert(1, 'observe')
        raise SystemExit(stages_v1.main())

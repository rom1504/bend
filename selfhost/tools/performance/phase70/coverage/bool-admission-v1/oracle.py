#!/usr/bin/env python3
"""Independent small-array/truth-table goldens; never executes Bend or C."""
import json
import math
import struct


def outputs():
    update, clone, shared = [], [], []
    for initial, replacement in [(False, True), (True, False)]:
        values = [initial] * 4
        values[0] = replacement
        old, values[1] = values[1], replacement
        update.append(10 * old + values[1])

        original = [initial] * 4
        copy = list(original)
        old, copy[2] = copy[2], replacement
        clone.append(100 * sum(original) + 10 * old + sum(copy))

        left = [initial] * 4
        right = left
        old, left[1] = left[1], replacement
        shared.append(100 * old + 10 * sum(left) + sum(right))

    nan = math.nan
    producers = [True, False, 4294967295 < 0, nan != nan, -0.0 == 0.0,
        0 < 1, False or True, True ^ True, True, False ^ True,
        not False, True, not False, bool(0 & 1), bool(4294967295 & 1)]
    cases = {
        'update': update,
        'clone': clone,
        'shared': shared,
        'mixed': [3, 4294967295, struct.unpack('<I', struct.pack('<f', -1.5))[0], ord('🙂')],
        'producers': list(map(int, producers)),
        'enum-refusal': [1 + 10],
        'foreign-refusal': [sum([1 != 0] * 2)],
    }
    return {name: ''.join(str(int(value)) + '\n' for value in values) for name, values in cases.items()}


if __name__ == '__main__':
    print(json.dumps(outputs(), indent=2))

"""Independent scalar model for the packet-window program and existing local-fold."""
import json
from pathlib import Path

HERE = Path(__file__).resolve().parent
MASK = (1 << 32) - 1
CAPACITY = 64
PRIMARY = (6147, 0x1234567b)
ALTERNATE = (263, 0xfffffffd)
EXTRA = ((0, 0), (1, 0), (3, 7), (4, 0xffffffff), (63, 1), (64, 2), (65, 3), (127, 123))


def packet(count, seed):
    cells = [seed ^ 0x9e3779b9] * CAPACITY
    cells[0] = (seed + 0x10203040) & MASK
    cells[17] = seed ^ 0x80000000
    cells[63] = (seed * 17 + 3) & MASK
    carry = seed ^ 0xa5a5a5a5
    starts = ((2 - (seed & 7)) & MASK, (seed ^ 0xfffffff0) & MASK)
    counts = (count, count // 5 + 3)
    for length, start in zip(counts, starts):
        for step in range(length):
            index = (start + step) & MASK
            slot = index % CAPACITY
            carry = (carry + cells[slot]) & MASK
            cells[slot] = carry ^ index
    value = carry ^ 0x811c9dc5
    for cell in cells:
        value = ((value ^ cell) * 16777619) & MASK
    return dict(inputs=[count, seed], starts=list(starts), counts=list(counts), carry=carry,
                cells=cells, digest=value, output=','.join(map(str, [carry, *cells]))+'\n')


def original(count, seed):
    cells = [seed] * 128
    carry = 0
    for index in range(count):
        slot = index % 128
        carry = (carry + cells[slot]) & MASK
        cells[slot] = carry ^ (index & MASK)
    return dict(inputs=[count, seed], carry=carry, cells=cells, output=str(carry)+'\n')


if __name__ == '__main__':
    result = dict(transfer=[packet(*point) for point in (PRIMARY, ALTERNATE, *EXTRA)],
                  original=[original(4096,17),original(6149,0xf1234567)])
    assert result['original'][0]['carry'] == 2339999928
    (HERE/'oracles.json').write_text(json.dumps(result,indent=2)+'\n')

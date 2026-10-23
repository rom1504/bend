"""Independent output oracle for the extracted persistent-index proxy.

Host test arithmetic only; this neither implements Patricia insertion nor
compiles or executes targets. IO.now's unit is milliseconds.
"""


def checksum(size):
    if not isinstance(size, int) or not 0 <= size <= 256:
        raise ValueError('The frozen proxy contains exactly 256 names')
    value = 2166136261
    # The second update pass writes versions1001..1000+size; query source order
    # is unchanged. No native tree, hash, or lookup implementation is reused.
    for version in range(1001, 1001 + size):
        value = (value * 16777619 + version) & 0xffffffff
    return value


def ordinary_stdout():
    return ''.join(str(checksum(n)) + '\n' for n in [0, 1, 16, 64, 256])


def expected_prefix(repetitions, warmups, size):
    if any(not isinstance(n, int) or not 0 <= n <= 1000000000
           for n in [repetitions, warmups]):
        raise ValueError('Nonnegative bounded repetition counts required')
    value = checksum(size)
    return [str(value), str((warmups * value) & 0xffffffff),
            str((repetitions * value) & 0xffffffff)]


def parse_timed(stdout, stderr, status, repetitions, warmups, size):
    if isinstance(stdout, bytes):
        stdout = stdout.decode('ascii')
    if isinstance(stderr, bytes):
        stderr = stderr.decode('ascii')
    if status != 0 or stderr:
        raise ValueError('Expected exit0 and empty stderr')
    lines = stdout.splitlines()
    if len(lines) != 4 or stdout != '\n'.join(lines) + '\n':
        raise ValueError('Expected exactly four LF-terminated output lines')
    if lines[:3] != expected_prefix(repetitions, warmups, size):
        raise ValueError('Independent pass/checksum oracle mismatch')
    if not lines[3].isascii() or not lines[3].isdigit():
        raise ValueError('Expected an unsigned decimal elapsed-milliseconds line')
    milliseconds = int(lines[3])
    if str(milliseconds) != lines[3]:
        raise ValueError('Noncanonical time line')
    return dict(complete=True, checksum=checksum(size), elapsedMilliseconds=milliseconds,
                runtimeSeconds=milliseconds * 0.001,
                timerUnit='milliseconds', aboveTwentyMillisecondFloor=milliseconds >= 20)


def validate(stdout, repeats, warmups, size):
    result = parse_timed(stdout, '', 0, repeats, warmups, size)
    result['runtimeMilliseconds'] = result['elapsedMilliseconds']
    return result

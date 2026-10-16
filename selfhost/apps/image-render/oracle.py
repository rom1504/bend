#!/usr/bin/env python3
"""Independent signed-integer Mandelbrot reference, full PPM validator, fixtures.

No Bend/compiler imports or subprocesses. Python's unbounded signed integers
and floor division specify the pixels independently of Bend's U32 encoding.
"""
import argparse
import hashlib
import json
from pathlib import Path
import re
import sys

SCALE = 4096
APP_USAGE = ('Usage: image-render --size WIDTH HEIGHT --iterations COUNT [--tile ROWS]\n'
             'Writes a complete P3 PPM image to stdout.\n'
             'WIDTH/HEIGHT: 1..1024; COUNT: 1..4096; ROWS: 1..1024.\n'
             'Defaults: 256 256, 128 iterations, 4 rows per tile.\n'
             'Native runtime: --threads N --gpu off -- <application options>\n')


def bounds(width, height, iterations, tile=4):
    if not (1 <= width <= 1024 and 1 <= height <= 1024
            and 1 <= iterations <= 4096 and 1 <= tile <= 1024):
        raise ValueError('size 1..1024, iterations 1..4096, tile 1..1024 required')


def escape(real, imaginary, iterations):
    zr = zi = 0
    for count in range(iterations):
        r2, i2 = zr * zr // SCALE, zi * zi // SCALE
        if r2 + i2 > 4 * SCALE:
            return count
        zr, zi = r2 - i2 + real, (2 * zr * zi) // SCALE + imaginary
    return iterations


def pixels(width, height, iterations):
    bounds(width, height, iterations)
    for y in range(height):
        imaginary = (2 * y + 1) * (3 * SCALE) // (2 * height) - 3 * SCALE // 2
        for x in range(width):
            real = (2 * x + 1) * (3 * SCALE) // (2 * width) - 2 * SCALE
            count = escape(real, imaginary, iterations)
            yield (0, 0, 0) if count == iterations else tuple(count * k % 256 for k in (9, 7, 13))


def render(width, height, iterations, tile=4):
    bounds(width, height, iterations, tile)
    rows = ['P3', f'{width} {height}', '255']
    rows.extend(' '.join(map(str, rgb)) for rgb in pixels(width, height, iterations))
    return '\n'.join(rows) + '\n'


def parse_ppm(data):
    """Parse the entire ASCII PPM, including exact dimension/channel count."""
    text = data.decode('ascii') if isinstance(data, bytes) else data
    tokens = re.sub(r'#[^\n]*', '', text).split()
    if len(tokens) < 4 or tokens[0] != 'P3':
        raise ValueError('expected complete P3 PPM header')
    if any(re.fullmatch(r'[0-9]+', token) is None for token in tokens[1:]):
        raise ValueError('expected unsigned decimal PPM values')
    width, height, maximum, *channels = map(int, tokens[1:])
    if not (1 <= width <= 1024 and 1 <= height <= 1024 and maximum == 255):
        raise ValueError('unexpected PPM dimensions or maximum')
    if len(channels) != 3 * width * height or any(c > 255 for c in channels):
        raise ValueError('wrong pixel count or channel range')
    return width, height, channels


def validate(data, width, height, iterations, tile=4, exact=True):
    bounds(width, height, iterations, tile)
    got_width, got_height, actual = parse_ppm(data)
    if (got_width, got_height) != (width, height):
        raise ValueError('dimensions differ from requested image')
    expected = [channel for rgb in pixels(width, height, iterations) for channel in rgb]
    for index, (got, want) in enumerate(zip(actual, expected)):
        if got != want:
            pixel, channel = divmod(index, 3)
            y, x = divmod(pixel, width)
            raise ValueError(f'pixel ({x},{y}) channel {channel}: got {got}, expected {want}')
    text = data.decode('ascii') if isinstance(data, bytes) else data
    if exact and text != render(width, height, iterations, tile):
        raise ValueError('pixels match but complete PPM text/newlines differ')
    return dict(passed=True, width=width, height=height, pixels=width * height,
                sha256=hashlib.sha256(text.encode('ascii')).hexdigest(), exactText=exact)


def write_exact(file, text):
    data = text.encode('ascii')
    if file.exists():
        if file.read_bytes() != data:
            raise ValueError(f'refusing changed fixture: {file}')
    else:
        file.write_bytes(data)


def cases(out_dir: Path, depth='smoke', selected=None):
    """Runner contract: deterministic argv and complete expected stdout."""
    if depth not in ('smoke', 'survey'):
        raise ValueError('depth must be smoke or survey')
    out_dir = Path(out_dir); out_dir.mkdir(parents=True, exist_ok=True)
    specs = [('single', 1, 1, 1, 1), ('corners', 3, 3, 16, 1),
             ('rectangle', 7, 5, 32, 2), ('odd-rows', 19, 13, 64, 3),
             ('fine-tiles', 32, 24, 96, 1), ('one-tile', 32, 24, 96, 24),
             ('default-tile', 17, 9, 32, None)]
    if depth == 'survey':
        specs += [('survey-small', 128, 96, 256, 4),
                  ('survey-medium', 256, 192, 384, 8),
                  ('survey-large', 384, 256, 512, 8),
                  ('survey-production', 512, 384, 1024, 8),
                  ('production-one-tile', 512, 384, 1024, 512)]
    result = []
    images = {}
    for name, width, height, iterations, tile in specs:
        if selected is not None and name not in selected:
            continue
        argv = ['--size', str(width), str(height), '--iterations', str(iterations)]
        if tile is not None: argv += ['--tile', str(tile)]
        image_key = (width, height, iterations)
        if image_key not in images:
            images[image_key] = render(width, height, iterations, tile or 4)
        expected = images[image_key]
        file = out_dir / (name + '.expected.ppm'); write_exact(file, expected)
        result.append(dict(id=name, argv=argv, expected=expected, input_files=[], parallel=True,
                           width=width, height=height, iterations=iterations, tile=tile or 4,
                           pixelCount=width * height, expected_file=str(file.resolve()),
                           expected_sha256=hashlib.sha256(expected.encode('ascii')).hexdigest()))
    # CLI oracles are specified independently; never read emitted/native output.
    invalid = 'image-render: invalid arguments\n' + APP_USAGE
    controls = [('cli-zero-dimension', ['--size', '0', '1', '--iterations', '1'], invalid),
                ('cli-dimension-limit', ['--size', '1025', '1', '--iterations', '1'], invalid),
                ('cli-missing-iterations', ['--size', '8', '8'], invalid),
                ('cli-help', ['--help'], APP_USAGE)]
    for name, argv, expected in controls:
        if selected is not None and name not in selected:
            continue
        file = out_dir / (name + '.expected.txt'); write_exact(file, expected)
        result.append(dict(id=name, argv=argv, expected=expected, input_files=[], parallel=False,
                           expected_exit_code=0, expected_stderr='', expected_file=str(file.resolve()),
                           expected_sha256=hashlib.sha256(expected.encode('ascii')).hexdigest()))
    manifest = [{k: v for k, v in row.items() if k != 'expected'} for row in result]
    write_exact(out_dir / (depth + '.json'), json.dumps(manifest, indent=2) + '\n')
    return result


def self_check():
    # Analytic points, independent of any generated Bend output.
    assert escape(0, 0, 100) == escape(-2 * SCALE, 0, 100) == 100
    assert escape(0, SCALE, 100) == 100
    assert escape(SCALE, 0, 100) == 3
    assert escape(2 * SCALE, 0, 100) == 2
    assert escape(-3 * SCALE, 0, 100) == 1
    assert render(1, 1, 1) == 'P3\n1 1\n255\n0 0 0\n'
    assert render(7, 5, 32, 1) == render(7, 5, 32, 5)
    good = render(3, 3, 16); validate(good, 3, 3, 16)
    invalid = ['P3\n1 1\n255\n1 0 0\n', 'P3\n1 1\n255\n0 0\n',
               'P3\n1 1\n255\n0 0 0 0\n', 'P3\n1 1\n255\n256 0 0\n',
               'P3\n1 1\n255\n0 0 0\n\n']
    for bad in invalid:
        try: validate(bad, 1, 1, 1)
        except ValueError: pass
        else: raise AssertionError('validator admitted damaged image')
    return dict(passed=True, analyticPoints=6, damagedImagesRejected=len(invalid), targetsRun=False)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    sub = parser.add_subparsers(dest='command', required=True)
    for name in ('render', 'validate'):
        p = sub.add_parser(name); p.add_argument('--size', type=int, nargs=2, required=True)
        p.add_argument('--iterations', type=int, required=True); p.add_argument('--tile', type=int, default=4)
        if name == 'render': p.add_argument('-o', '--output', type=Path)
        else:
            p.add_argument('image', type=Path)
            p.add_argument('--pixels-only', action='store_true', help='permit equivalent PPM whitespace/comments')
    p = sub.add_parser('fixtures'); p.add_argument('out', type=Path)
    p.add_argument('--depth', choices=['smoke', 'survey'], default='smoke')
    sub.add_parser('self-check')
    args = parser.parse_args()
    if args.command == 'self-check': print(json.dumps(self_check())); return
    if args.command == 'fixtures':
        rows = cases(args.out, args.depth); print(json.dumps(dict(cases=len(rows), targetsRun=False))); return
    width, height = args.size
    if args.command == 'validate':
        print(json.dumps(validate(args.image.read_bytes(), width, height, args.iterations, args.tile, not args.pixels_only)))
    else:
        text = render(width, height, args.iterations, args.tile)
        if args.output: write_exact(args.output, text)
        else: sys.stdout.write(text)


if __name__ == '__main__': main()

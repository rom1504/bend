"""Compose frozen mechanism versions; all dependencies live beside this file."""
from pathlib import Path
import importlib.util

HERE = Path(__file__).resolve().parent


def module(name):
    spec = importlib.util.spec_from_file_location('p102_combined_' + name, HERE / name / 'prepare.py')
    value = importlib.util.module_from_spec(spec); spec.loader.exec_module(value)
    return value


def transform(source, text='linked', typed=True, input_only=False):
    counts = {}
    assert text in ('none', 'linked', 'chunk')
    if text == 'linked': source, counts['text'] = module('text').transform(source)
    if text == 'chunk':
        source, counts['text'] = module('chunk').transform(source,
            mode='input' if input_only else 'all', append=not input_only, compare=True)
    if typed: source, counts['typed'] = module('typed').transform(source)
    return source, counts

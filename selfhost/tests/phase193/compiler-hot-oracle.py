#!/usr/bin/env python3
"""Literal index-update results; no index, lookup or compiler execution."""
import argparse
import importlib.util
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
spec = importlib.util.spec_from_file_location('oracle166',ROOT/'experiments/phase166/lookup-oracle.py')
O = importlib.util.module_from_spec(spec)
spec.loader.exec_module(O)


def expected_values(i):
    def row(name, kind, width, capacity):
        return [name,kind,(i+width)&O.MASK,(i+capacity)&O.MASK,
                O.term('Absent','',0,0,0,0),O.term('Absent','',0,0,0,0),[],False,False]
    return [row('costarring','local',3,103),row('compiler_hot_value','local',1,101),
            row('costarring','updated',33,133),row('liquid','alloca',4,104),
            row('compiler_hot_value','updated',11,111),row('compiler_hot_values','local',2,102),
            row('解析.λ名字','local',5,105),row('','local',6,106),O.absent(),O.absent()]


def expected(rounds):
    result = 2166136261
    for i in range(rounds):
        values = expected_values(i)
        h,g = 2166136261,5381
        for word in O.result_words(values):
            h,g = O.mix(h,word),(g*33+word)&O.MASK
        for word in (len(values),h,g):
            result = O.mix(result,word)
    return result


if __name__ == '__main__':
    p = argparse.ArgumentParser(description=__doc__)
    group = p.add_mutually_exclusive_group(required=True)
    group.add_argument('--rounds',type=int)
    group.add_argument('--values',type=int)
    a = p.parse_args()
    if a.rounds is not None:
        assert 0 <= a.rounds <= 100000
        print(expected(a.rounds))
    else:
        assert 0 <= a.values <= O.MASK
        print(json.dumps(expected_values(a.values),ensure_ascii=False))

"""Enforce the declared successor chain, then reuse the frozen native binder."""
import argparse
import importlib.util
from pathlib import Path
import sys
sys.dont_write_bytecode = True
HERE = Path(__file__).resolve().parent
spec = importlib.util.spec_from_file_location('phase131_frozen_native', HERE / 'qualify.py')
V = importlib.util.module_from_spec(spec); spec.loader.exec_module(V)


def main():
    p = argparse.ArgumentParser(add_help=False)
    for name in ['admission', 'producer', 'reproduction', 'n3-build']:
        p.add_argument('--' + name, type=Path)
    a, _ = p.parse_known_args()
    V.require(a.admission and a.producer, 'Admission and declared native producer required')
    V.require(V.Q.pin(V.__file__)['sha256'] ==
              '28a5d00beb5744d8d41c192f5efca3926a28a0b78952124f7123b43b45626e14',
              'Frozen native binder changed')
    ad = V.read(a.admission)
    V.require(ad.get('qualificationMethod') == V.Q.pin(__file__), 'Wrong successor qualification method')
    V.require(V.Q.pin(a.producer) == ad['permittedProducer'], 'Declared native producer differs')
    V.require(ad['source']['sha256'] == '1bc5930edcf80cda6c3572645df3c846fa631a83c2b936f20c83b05e0a6728f9', 'Wrong final source')
    codegen = ad.get('changeKind') == 'declared-codegen-change'
    V.require(codegen or ad.get('changeKind') == 'byte-preserving-algorithm-candidate',
              'Unknown successor change policy')
    expected = 'N0->N1->N2->N3;Q2=Q3' if codegen else 'N0->N1->N2;Q1=Q2'
    V.require(ad.get('requiredReproduction') == expected, 'Declared reproduction policy differs')
    V.require(bool(a.reproduction) == codegen and bool(a.n3_build) == codegen,
              'Codegen changes require N3 and Q2/Q3 reproduction; algorithms require Q1/Q2')
    V.retain(V.Q.pin(__file__))
    # All source, checked API, runtime, producer, toolchain, raw QBE and native
    # focused19/ordinary45 gates below are the unchanged original implementation.
    spec = importlib.util.spec_from_file_location('phase131_final_contract', HERE / 'final-source-contract.py')
    F = importlib.util.module_from_spec(spec); spec.loader.exec_module(F); F.install(V)
    V.retain(V.Q.pin(F.__file__))
    V.main()


if __name__ == '__main__': main()

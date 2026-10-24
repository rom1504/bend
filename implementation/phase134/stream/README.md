# First streaming native checkpoint

Experimental native-qualified source, not installed. [Report](../README.md).

`compiler.bend.gz` restores the exact source identified by `receipt.json`.
`evidence.tar.gz` contains19 named receipts/logs, individually hashed and checked
after compression. It excludes generated APIs, native binaries and107-MB QBE
products; those are authenticated by the retained build receipts.

Qualification: exact Q1=Q2, focused19 on N1/N2, ordinary45 on N2, unchanged runtime,
unchanged verifier/proof bodies,15 checked finite controls. This is finite native
qualification, not a proof of whole-compiler correctness. The observation pair
and matched small-request timing show a memory win and a time regression.
Keep this as an ablation/fallback while evaluating bounded write batching.

The corresponding local image is
`selfhost/build/phase111/p134-n2/program`. Use the existing authenticated
`phase130/native-request.py` with the Phase130 compact Base carrier and the
unchanged Phase128 runtime; follow the Phase131 capsule's invocation format.
Recheck receipt identities before use. The source capsule alone does not bundle
the native toolchain or bootstrap binary.

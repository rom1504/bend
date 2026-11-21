#!/usr/bin/env bash
set -euo pipefail
D=selfhost/build/phase201
J=research/phase201/cold/job.py
R=research/phase201/cold/replay.py
S=selfhost/build/phase204/cont02/compiler.bend
B="image:$D/p203rankimage01/program.gz"
C="image:$D/p204image03/program.gz"
python3 -B "$J" p204check07 70 768 selfhost/.assets/bin/bun selfhost/tools/build/check-source.mjs --source "$S" --out OUT --manifest selfhost/build/phase198/progress-portfolio01/maintained/src/compiler.json --upstream selfhost/.bootstrap/upstream-phase182
python3 -B "$J" p204image03 420 1536 python3 -B "$R" --out OUT --full --source "$S" --product-runtime "$D/runtime01/runtime.o" --save-image "$B"
python3 -B "$J" p204ab03 100 768 python3 -B "$R" --out OUT --reference "$D/p202self01smoke/results.json" "$B" "$C" "$C" "$B"
python3 -B "$J" p204self03 410 1536 python3 -B "$R" --out OUT --full --source "$S" --product-runtime "$D/runtime01/runtime.o" --reference "$D/p204image03/results.json" "$C"
python3 -B "$J" p204transfer03 150 1024 python3 -B research/phase201/cold/transfer.py --out OUT --image "$D/p204image03/program.gz" --cases mandelbrot editdist tree-bitonic lexer test-rle-roundtrip test-map-set-ops local-fold coverage-bst-64 coverage-closures-256 coverage-unicode-text-64 coverage-expression-128 coverage-numeric-recurrence-256

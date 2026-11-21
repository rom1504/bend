#!/usr/bin/env bash
# Run from repository root. Fresh run IDs, one controlled hardware lane.
set -eu
job() {
  local name=$1 budget=$2
  shift 2
  python3 -B research/phase201/cold/job.py "$name" "$budget" 2048 "$@"
}
p=selfhost/build/phase201
s=selfhost/build/phase202
q=selfhost/build/phase198/progress-native-image01
case "$1" in
  check)
    job "$2" 55 selfhost/.assets/bin/bun selfhost/tools/build/check-source.mjs --source "$3/compiler.bend" --out OUT --manifest selfhost/build/phase198/progress-portfolio01/maintained/src/compiler.json --upstream selfhost/.bootstrap/upstream-phase182
    ;;
  sized)
    job "$2" 96 python3 -B research/phase202/elf/screen.py --fixture "$s/elfsizedfixture02" --out OUT
    ;;
  invalid)
    job "$2" 50 python3 -B research/phase202/elf/negative.py --fixture "$s/elfsizednegative02" --out OUT
    ;;
  opcodes)
    job "$2" 80 python3 -B research/phase202/opcodes/screen.py --fixture "$s/opcodefixture04" --image "$q/program" --image-receipt "$q/report.json" --out OUT
    ;;
  acquire)
    job "$2" 460 python3 -B research/phase201/cold/replay.py --out OUT --full --save-image --source "$3/compiler.bend" --product-runtime "$p/runtime01/runtime.o" "image:$p/acquire02/program.gz"
    ;;
  self)
    job "${2}smoke" 45 python3 -B research/phase201/cold/replay.py --out OUT "image:$p/$4/program.gz"
    python3 -c 'import json,sys; read=lambda p:json.load(open(p))["runs"][0]; a,b=map(read,sys.argv[1:]); assert a["objectSha256"]==b["objectSha256"] and a["verifierStdout"]==b["verifierStdout"]=="768"' "$p/smoke01/results.json" "$p/${2}smoke/results.json"
    job "$2" 460 python3 -B research/phase201/cold/replay.py --out OUT --full --source "$3/compiler.bend" --reference "$p/$4/results.json" --product-runtime "$p/runtime01/runtime.o" "image:$p/$4/program.gz"
    python3 -B research/phase202/cold/compare.py "$p/$4/results.json" "$p/$2/results.json"
    ;;
  frozen)
    job "$2" 460 python3 -B research/phase201/cold/replay.py --out OUT --full "image:$p/$3/program.gz"
    ;;
  *) exit 64 ;;
esac

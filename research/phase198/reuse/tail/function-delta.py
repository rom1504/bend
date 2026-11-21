"""Compare every defined ELF64 function before and after the checked selector."""

import hashlib
import json
from pathlib import Path
from struct import unpack_from

from recover import BUILD, HERE, pin, read, write


def functions(path):
    raw = Path(path).read_bytes()
    assert raw[:6] == b"\x7fELF\x02\x01" and unpack_from("<H", raw, 16)[0] == 1
    offset = unpack_from("<Q", raw, 40)[0]
    size, count, _ = unpack_from("<HHH", raw, 58)
    sections = [unpack_from("<IIQQQQIIQQ", raw, offset + i * size) for i in range(count)]
    symbols = next(section for section in sections if section[1] == 2)
    strings = sections[symbols[6]]
    names = raw[strings[4]:strings[4] + strings[5]]
    result = {}
    for i in range(symbols[5] // symbols[9]):
        at = symbols[4] + i * symbols[9]
        name, info, _, section, start, length = unpack_from("<IBBHQQ", raw, at)
        if info & 15 != 2 or section == 0:
            continue
        sh = sections[section]
        assert start + length <= sh[5]
        data = raw[sh[4] + start:sh[4] + start + length]
        symbol = names[name:names.index(b"\0", name)].decode()
        assert symbol not in result
        result[symbol] = (length, hashlib.sha256(data).hexdigest())
    return result


def main():
    recovery = BUILD / "heap-tail-auth01/report.json"
    rows = []
    for program in read(recovery)["products"]:
        for role in ("baseline", "candidate"):
            assert pin(program[role]["file"]) == program[role]
        baseline = functions(program["baseline"]["file"])
        candidate = functions(program["candidate"]["file"])
        assert baseline.keys() == candidate.keys()
        changed = {name for name in baseline if baseline[name] != candidate[name]}
        callers = {site["caller"] for site in program["tailSites"]["candidate"]}
        assert changed == callers
        table = sorted((name, baseline[name], candidate[name]) for name in baseline)
        table_hash = hashlib.sha256(json.dumps(table, separators=(",", ":")).encode()).hexdigest()
        rows.append(dict(
            id=program["id"], baseline=program["baseline"], candidate=program["candidate"],
            symbols=len(baseline), unchangedExactBytes=len(baseline) - len(changed),
            changed=len(changed), changedOutsideTailCallers=0, newOrRemovedSymbols=0,
            baselineFunctionBytes=sum(s[0] for s in baseline.values()),
            candidateFunctionBytes=sum(s[0] for s in candidate.values()),
            functionTableSha256=table_hash,
        ))
    write(HERE / "function-delta.json",
          dict(recovery=pin(recovery), method=pin(__file__), rows=rows,
               scope="Defined ELF STT_FUNC symbol payload bytes in the two relocatable objects. "
               "External relocation resolutions and linked addresses are outside this comparison."))


if __name__ == "__main__":
    main()

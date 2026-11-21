"""Inspect every retained progress program's public segment references and compiler ABI."""

import json
import struct
from collections import Counter
from pathlib import Path

import tail


def relocations(path):
    data = path.read_bytes()
    assert data[:6] == b"\x7fELF\x02\x01"
    sections_at = struct.unpack_from("<Q", data, 40)[0]
    width, count, names_index = struct.unpack_from("<HHH", data, 58)
    sections = [struct.unpack_from("<IIQQQQIIQQ", data, sections_at + i * width) for i in range(count)]

    def contents(section):
        return data[section[4]:section[4]+section[5]]

    def name(strings, offset):
        return strings[offset:strings.index(b"\0", offset)].decode()

    section_names = contents(sections[names_index])
    kinds = Counter()
    for relocation in sections:
        if relocation[1] != 4:
            continue
        owner = sections[relocation[7]]
        section_name = name(section_names, owner[0])
        symbols = sections[relocation[6]]
        strings = contents(sections[symbols[6]])
        for i in range(relocation[5] // relocation[9]):
            at = relocation[4] + i * relocation[9]
            address, info, addend = struct.unpack_from("<QQq", data, at)
            symbol = symbols[4] + (info >> 32) * symbols[9]
            symbol_name = name(strings, struct.unpack_from("<I", data, symbol)[0])
            if symbol_name.startswith("p111_FID_"):
                kinds[(section_name, info & 0xffffffff)] += 1
    return kinds


def main():
    names = (
        "p186rt_fid p186rt_expand p186rt_reads p186rt_writes p186rt_jump p114t_buffer "
        "p111v_counted_call p111q_segment_table p111q_segment_datum p111q_symbol "
        "x181_reg x181_load x186_saves_text x186_saves_mask x186_saves_offset "
        "x190_stmt x190_stmts x194_ps_pick x194_ps_step x181_function "
        "x185_function_setup x181_program_stmts"
    ).split()
    checked_path = tail.BUILD / "heap-api-source02/compiler.bend"
    progress_path = tail.PARENT / "compiler.bend"
    prior = tail.blocks(checked_path.read_bytes())
    progress = tail.blocks(progress_path.read_bytes())
    identical = {}
    for n in names:
        key = ("def", n)
        assert tail.body(prior[key]) == tail.body(progress[key]), n
        identical[n] = tail.digest(tail.body(prior[key]))

    native = tail.BUILD / "progress-native45-01/programs.manifest.json"
    manifest = json.loads(native.read_text())
    assert manifest["roles"]["candidate"]["compilerSource"]["sha256"] == tail.PARENT_HASH
    rows = []
    for case in manifest["cases"]:
        product = case["products"]["candidate"]["generatedSource"]
        path = Path(product["file"])
        assert tail.src.pin(path) == product
        kinds = relocations(path)
        assert set(kinds) == {(".data", 1)}, (case["id"], kinds)
        rows.append(dict(case=case["id"], sha256=product["sha256"], publicDataPointers=kinds[(".data", 1)]))
    assert len(rows) == 45
    compilers = []
    for stage in ("progress-native-image01", "progress-native-self01", "progress-native-reproduction01"):
        receipt = tail.BUILD / stage / "report.json"
        machine = json.loads(receipt.read_text())
        product = machine["object"]
        path = Path(product["file"])
        assert machine["complete"] and not machine.get("changedInputs")
        assert path.stat().st_size == product["bytes"] and tail.digest(path.read_bytes()) == product["sha256"]
        kinds = relocations(path)
        assert set(kinds) == {(".data", 1)}, (stage, kinds)
        compilers.append(dict(stage=stage, receiptSha256=tail.digest(receipt.read_bytes()),
                              objectSha256=product["sha256"], objectBytes=product["bytes"],
                              publicDataPointers=kinds[(".data", 1)]))
    runtime = tail.ROOT / "selfhost/src/runtime/qbe/runtime.c"
    report = dict(
        kind="phase199-tail-public-abi-source-and-object-audit", targetsRun=False,
        checkedSource=tail.digest(checked_path.read_bytes()), progressSource=tail.digest(progress_path.read_bytes()),
        native45Manifest=tail.digest(native.read_bytes()), runtimeSource=tail.digest(runtime.read_bytes()),
        unchangedBodies=identical, rows=rows, publicDataPointers=sum(x["publicDataPointers"] for x in rows),
        publicTextRelocations=0, nativeCompilers=compilers, nativeCallsFromCustomForeignCodeExamined=False,
    )
    (tail.HERE/"tail-abi.json").write_text(json.dumps(report, indent=2)+"\n")


if __name__ == "__main__":
    main()

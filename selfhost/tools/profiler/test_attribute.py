#!/usr/bin/env python3
import hashlib
import json
from pathlib import Path
import struct
import tempfile
import unittest
from unittest.mock import patch
import analyze
from attribute import (UNKNOWN, aggregate_events, attribute, attribute_events, bind_owners, binding_sections,
                       binding_symbols, binding_symbol, parse_callers, parse_contexts,
                       receipt_binding, validate_applied_rule, validate_table)


def table():
    result = {"schema": "bend-bounded-physical-unwind-v1", "object": {"sha256": "a" * 64},
              "rows": [{"start": 0x100, "end": 0x200, "cfa": 8, "ra": -8}]}
    identity = {"objectSha256": result["object"]["sha256"], "rows": result["rows"]}
    result["id"] = hashlib.sha256(json.dumps(identity, sort_keys=True, separators=(",", ":")).encode()).hexdigest()
    return result


def callers(rows="0\t4001\n4294967295\t0\n", count=2):
    t = table()
    return ("BEND_PHYSICAL_CALLERS_V1\nunwind_id\t%s\nobject_sha256\t%s\nsamples\t%d\nROWS\n%sEND\n" %
            (t["id"], t["object"]["sha256"], count, rows))


def owner_fixture(directory):
    binary, qbe = Path(directory) / 'program', Path(directory) / 'program.ssa'
    qbe.write_text('synthetic QBE identity')
    blob = bytearray(2048)
    blob[:6] = b'\x7fELF\x02\x01'
    struct.pack_into('<HH', blob, 16, 2, 62)
    struct.pack_into('<Q', blob, 40, 0x400)
    struct.pack_into('<HH', blob, 58, 64, 4)
    # Real section-header bytes distinguish executable functions and data labels.
    for number, flags, address, size in [(1, 6, 0x300, 0x80), (3, 3, 0x100, 0x180)]:
        struct.pack_into('<IIQQQQIIQQ', blob, 0x400+64*number,
                         0, 1, flags, address, address, size, 0, 0, 8, 0)
    for offset, value in {0:11101, 8:192, 16:2, 32:1, 48:24, 56:8, 88:5, 96:0x200}.items():
        struct.pack_into('<Q', blob, 0x100+offset, value)
    struct.pack_into('<QQ', blob, 0x200, 0x300, 0x310)
    binary.write_bytes(blob)
    symbols = ('1: 00000100 192 OBJECT GLOBAL DEFAULT 3 p111_program\n'
               '2: 00000200 16 NOTYPE LOCAL DEFAULT 3 p111_segments\n'
               '3: 00000300 16 FUNC GLOBAL DEFAULT 1 function0\n'
               '4: 00000310 0 NOTYPE LOCAL DEFAULT 1 function1\n')
    owners = {'schema':'bend-qbe-lowered-owners-v1', 'identities':{'qbe':analyze.pin(qbe)},
              'descriptor':{'segment_count':2,'main_fid':1},
              'fids':[{'fid':0,'symbol':'function0'},{'fid':1,'symbol':'function1'}],
              'functions':[{'symbol':'function0'},{'symbol':'function1'}]}
    return binary, blob, owners, symbols


class AttributeTests(unittest.TestCase):
    def test_valid_callers_and_unknowns(self):
        header, rows = parse_callers(callers())
        validate_table(table(), header)
        self.assertEqual(rows, [(0, 0x4001), (UNKNOWN, 0)])

    def test_malformed_sidecar_headers(self):
        for text in [callers().replace("BEND_PHYSICAL_CALLERS_V1", "bad"),
                     callers().replace("END\n", ""),
                     callers().replace("samples\t2", "samples\t2\nsamples\t2"),
                     callers().replace("samples\t2", "samples\t-1"),
                     callers().replace("samples\t2", "samples\t1"),
                     callers().replace("ROWS", "unknown\tvalue\nROWS")]:
            with self.subTest(text=text[:40]), self.assertRaises(ValueError):
                parse_callers(text)

    def test_unknown_sentinel_strict(self):
        for rows in ["0\t0\n", "4294967295\t4001\n", "4294967296\t1\n",
                     "0\t10000000000000000\n", "0 nope\n"]:
            with self.assertRaises(ValueError):
                parse_callers(callers(rows, 1))

    def test_table_id_and_object_binding(self):
        header, _ = parse_callers(callers())
        for key in ("unwind_id", "object_sha256"):
            with self.assertRaises(ValueError):
                validate_table(table(), {**header, key: "b" * 64})
        changed = table()
        changed["rows"][0]["cfa"] = 16
        with self.assertRaises(ValueError):
            validate_table(changed, header)

    def test_cfi_pc_intervals_half_open(self):
        leaf = {"objectSha256": "a" * 64, "elfAddress": 0x100}
        validate_applied_rule(0, leaf, table())
        validate_applied_rule(0, {**leaf, "elfAddress": 0x1ff}, table())
        for address in (0xff, 0x200, None):
            with self.assertRaisesRegex(ValueError, "original leaf PC"):
                validate_applied_rule(0, {**leaf, "elfAddress": address}, table())

    def test_wrong_cfi_object_and_index(self):
        leaf = {"objectSha256": "a" * 64, "elfAddress": 0x100}
        with self.assertRaisesRegex(ValueError, "wrong leaf object"):
            validate_applied_rule(0, {**leaf, "objectSha256": "b" * 64}, table())
        with self.assertRaisesRegex(ValueError, "outside table"):
            validate_applied_rule(1, leaf, table())
        validate_applied_rule(UNKNOWN, {}, table())

    def test_context_available_and_unknown(self):
        text = "BEND_DISPATCH_SAMPLES_V1\ncontext_available\t1\nsamples\t2\nIDS\n12\n4294967295\nEND\n"
        header, fids = parse_contexts(text)
        self.assertTrue(header["context_available"])
        self.assertEqual(fids, [12, UNKNOWN])
        with self.assertRaises(ValueError):
            parse_contexts(text.replace("context_available\t1", "context_available\t0"))
        with self.assertRaises(ValueError):
            parse_contexts(text.replace("samples\t2", "samples\t3"))

    def test_linked_owner_binding_checks_actual_pointer_order(self):
        with tempfile.TemporaryDirectory() as directory:
            binary, blob, owners, symbols = owner_fixture(directory)
            with patch("attribute.analyze.ELF.load_segments", return_value=[(0, 0, len(blob))]), \
                 patch("attribute.subprocess.check_output", side_effect=lambda args, **_: symbols if "-s" in args else ""):
                binding = bind_owners(owners, binary)[2]
                self.assertEqual(binding["checkedFids"], 2)
                self.assertEqual(binding["runtimeDescriptor"], dict(capabilities=5, registerWidth=24, resultWidth=8))
                self.assertTrue(binding["liveRegisterBank"])
                struct.pack_into("<QQ", blob, 0x200, 0x310, 0x300)
                binary.write_bytes(blob)
                with self.assertRaisesRegex(ValueError, "mismatch at FID"):
                    bind_owners(owners, binary)

    def test_cross_role_duplicates_bind_actual_required_addresses(self):
        with tempfile.TemporaryDirectory() as directory:
            binary, blob, owners, symbols = owner_fixture(directory)
            symbols += ('5: 00000320 16 FUNC LOCAL DEFAULT 1 p111_program\n'
                        '6: 00000240 0 NOTYPE LOCAL DEFAULT 3 function0\n'
                        '7: 00000330 16 FUNC LOCAL DEFAULT 1 p111_fid_arity\n'
                        '8: 00000260 0 NOTYPE LOCAL DEFAULT 3 p111_fid_arity\n')
            with patch('attribute.analyze.ELF.load_segments', return_value=[(0,0,len(blob))]), \
                 patch('attribute.subprocess.check_output', side_effect=lambda args,**_:symbols if '-s' in args else ''):
                functions, fids, binding = bind_owners(owners,binary)
                self.assertEqual([r['elfAddress'] for r in fids],[0x300,0x310])
                self.assertEqual(set(functions),{'function0','function1'})
                self.assertEqual(binding['symbolLookup']['policy'],'required-role-and-allocated-section-v1')

    def test_queried_same_role_ambiguity_is_rejected(self):
        for extra,role in [('5: 00000320 16 FUNC LOCAL DEFAULT 1 function0\n','function'),
                           ('5: 00000240 0 NOTYPE LOCAL DEFAULT 3 p111_program\n','data')]:
            with self.subTest(role=role), tempfile.TemporaryDirectory() as directory:
                binary,blob,owners,symbols=owner_fixture(directory)
                with patch('attribute.analyze.ELF.load_segments',return_value=[(0,0,len(blob))]), \
                     patch('attribute.subprocess.check_output',side_effect=lambda args,**_:symbols+extra if '-s' in args else ''):
                    with self.assertRaisesRegex(ValueError,'Ambiguous ELF '+role+' symbol'):
                        bind_owners(owners,binary)

    def test_repeated_symbol_tables_and_unqueried_ambiguity(self):
        with tempfile.TemporaryDirectory() as directory:
            binary,blob,owners,symbols=owner_fixture(directory)
            symbols += ('5: 00000300 16 FUNC GLOBAL DEFAULT 1 function0\n'
                        '6: 00000330 16 FUNC LOCAL DEFAULT 1 unqueried\n'
                        '7: 00000340 16 FUNC LOCAL DEFAULT 1 unqueried\n')
            with patch('attribute.analyze.ELF.load_segments',return_value=[(0,0,len(blob))]), \
                 patch('attribute.subprocess.check_output',side_effect=lambda args,**_:symbols if '-s' in args else ''):
                self.assertEqual(bind_owners(owners,binary)[2]['checkedFids'],2)
            candidates=binding_symbols(symbols,binding_sections(binary))
            with self.assertRaisesRegex(ValueError,'Ambiguous ELF function symbol: unqueried'):
                binding_symbol(candidates,'unqueried','function')

    def test_wrong_section_roles_and_unsupported_symbol_kinds_refuse(self):
        with tempfile.TemporaryDirectory() as directory:
            binary,_,_,_=owner_fixture(directory);sections=binding_sections(binary)
            for line in ['1: 00000200 16 FUNC LOCAL DEFAULT 3 target\n',
                         '1: 00000300 16 OBJECT LOCAL DEFAULT 1 target\n',
                         '1: 00000300 16 IFUNC LOCAL DEFAULT 1 target\n',
                         '1: 00000400 16 NOTYPE LOCAL DEFAULT 1 target\n',
                         '1: 00000300 16 FUNC GLOBAL DEFAULT UND target\n']:
                for role in ['data','function']:
                    with self.subTest(line=line,role=role),self.assertRaisesRegex(ValueError,'Missing ELF'):
                        binding_symbol(binding_symbols(line,sections),'target',role)
            for flags,kind in [(0,1),(0x402,1),(3,8)]:
                altered={**sections,3:{**sections[3],'flags':flags,'type':kind}}
                with self.assertRaisesRegex(ValueError,'Missing ELF data'):
                    binding_symbol(binding_symbols('1: 00000200 16 OBJECT LOCAL DEFAULT 3 target\n',altered),'target','data')

    def test_truncated_section_headers_refused(self):
        with tempfile.TemporaryDirectory() as directory:
            binary,blob,_,_=owner_fixture(directory);binary.write_bytes(blob[:0x480])
            with self.assertRaisesRegex(ValueError,'Truncated ELF section headers'):
                binding_sections(binary)

    def test_receipt_pins_capture_and_sidecars(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            case = root / "case"
            case.mkdir()
            paths = {key: case / name for key, name in (("analysis", "analysis.json"),
                     ("capture", "samples.txt"), ("callers", "callers.txt"))}
            for key, path in paths.items():
                path.write_text(key)
            identities = {key: analyze.pin(path) for key, path in paths.items()}
            row = {("profile" if key == "capture" else key): value for key, value in identities.items()}
            (root / "report.json").write_text(json.dumps({"schema": "bend-native-profile-run-v1",
                                                        "complete": True, "rows": [row]}))
            self.assertTrue(receipt_binding(paths["analysis"], identities)["verified"])
            identities["callers"] = {**identities["callers"], "sha256": "b" * 64}
            with self.assertRaisesRegex(ValueError, "receipt identity mismatch"):
                receipt_binding(paths["analysis"], identities)

    def test_context_only_mode_preserves_raw_order_and_unknown_callers(self):
        with tempfile.TemporaryDirectory() as directory:
            case = Path(directory) / "case"
            case.mkdir()
            binary, samples, analysis_path = (case / name for name in ("binary", "samples.txt", "analysis.json"))
            contexts, owners = case / "contexts.txt", case / "owners.json"
            binary.write_bytes(b"test binary identity")
            samples.write_text("BEND_MAIN_CPU_SAMPLES_V1\nexe\t%s\npid\t1\ntid\t1\nfinal_tid\t1\n"
                "period_us\t8000\ncapacity\t100\nmain_thread_cpu_ns\t16000000\nprocess_cpu_ns\t16000000\n"
                "samples\t2\ndropped\t0\noverruns\t0\nhandler_intact\t1\nMAPS\nPCS\n200\n100\nEND\n" % binary)
            head, maps, counts = analyze.parse_capture(samples)
            analysis_path.write_text(json.dumps({"header": head, "maps": maps,
                "pcs": [{"pc": hex(pc), "samples": count} for pc, count in counts.items()],
                "identities": {"capture": analyze.pin(samples), "binary": analyze.pin(binary), "mapped_objects": []}}))
            contexts.write_text("BEND_DISPATCH_SAMPLES_V1\ncontext_available\t1\nsamples\t2\nIDS\n0\n4294967295\nEND\n")
            owners.write_text("{}")
            row = {"symbol": "function", "lowered_owner": "factory", "owner_basis": "test"}
            def resolved(pc):
                return {"pc": hex(pc), "object": str(binary), "symbol": "function", "decoded": "function",
                        "elfAddress": pc, "rangeBasis": "elf_size", "objectSha256": analyze.pin(binary)["sha256"]}
            with patch("attribute.Resolver") as resolver, patch("attribute.bind_owners", return_value=({"function": row}, [row], {})):
                resolver.return_value.resolve.side_effect = resolved
                resolver.return_value.errors = {}
                result, events = attribute(analysis_path, contexts_path=contexts, owners_path=owners)
                self.assertEqual([event["leaf"]["pc"] for event in events], ["0x200", "0x100"])
                self.assertEqual([event["callerStatus"] for event in events], ["unavailable", "unavailable"])
                self.assertFalse(result["physicalCallerAttribution"]["available"])
                self.assertIsNone(result["unwindId"])
                self.assertEqual(result["coverage"]["unknownCallerSamples"], 2)
                self.assertEqual(result["coverage"]["knownDispatchSamples"], 1)
                self.assertEqual(events[0]["dispatchContext"]["loweredOwner"], "factory")
                self.assertEqual(sum(row["samples"] for row in result["contextLeafMatrix"]), 2)
                # Same histogram, different order: the raw capture hash must reject it.
                samples.write_text(samples.read_text().replace("200\n100", "100\n200"))
                with self.assertRaisesRegex(ValueError, "identity changed"):
                    attribute(analysis_path, contexts_path=contexts)

    def test_callers_and_table_are_optional_only_as_pair(self):
        with self.assertRaisesRegex(ValueError, "together"):
            attribute("unused-analysis", callers_path="unused-callers")
        with self.assertRaisesRegex(ValueError, "together"):
            attribute("unused-analysis", table_path="unused-table")

    def test_event_receipt_rejects_incomplete_mismatching_or_changed_inputs(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            case = root / "case"
            case.mkdir()
            events, binary, owners = (case / name for name in ("events.json", "binary", "owners.json"))
            binary.write_bytes(b"test binary")
            owners.write_text("{}")
            events.write_text(json.dumps({"schema": "bend-native-dispatch-events-v1",
                "context_kind": "active-dispatch-not-logical-ancestry", "segment_count": 1,
                "runtime_segment_count": 4, "unknown_fid": UNKNOWN, "counter_names": ["alloc"],
                "rows": [{"fid": 0, "segment_address": "0x300", "counts": [1]}]}))
            receipt = {"schema": "bend-native-profile-run-v1", "complete": True, "inputs": [analyze.pin(binary)],
                       "rows": [{"events": analyze.pin(events), "command": [str(binary)]}]}
            receipt_path = root / "report.json"
            binding = ({}, [{"elfAddress": 0x300, "lowered_owner": "factory"}], {"elfType": 2})
            with patch("attribute.bind_owners", return_value=binding):
                receipt_path.write_text(json.dumps(receipt))
                self.assertTrue(attribute_events(events, binary, owners)["pairing"]["verified"])
                for changes in [{"complete": False}, {"changedInputs": ["binary"]}, {"rows": []},
                                {"rows": receipt["rows"] * 2}, {"schema": "unknown"},
                                {"inputs": [{**analyze.pin(binary), "sha256": "0" * 64}]}]:
                    receipt_path.write_text(json.dumps({**receipt, **changes}))
                    with self.subTest(changes=changes), self.assertRaises(ValueError):
                        attribute_events(events, binary, owners)

    def test_event_owner_counts_keep_unknown_and_runtime_denominators(self):
        doc = {"schema": "bend-native-dispatch-events-v1", "context_kind": "active-dispatch-not-logical-ancestry",
               "segment_count": 1, "runtime_segment_count": 4, "unknown_fid": UNKNOWN,
               "counter_names": ["alloc", "drop"], "complete": True, "counts_enabled": True,
               "counter_overflow": False, "invalid_context_events": 0,
               "rows": [{"fid": 0, "segment_address": "0x300", "counts": [3, 1]},
                        {"fid": 1, "segment_address": "0x0", "counts": [2, 0]},
                        {"fid": UNKNOWN, "segment_address": "0x0", "counts": [5, 1]}]}
        fids = [{"elfAddress": 0x300, "lowered_owner": "my_function"}]
        result = aggregate_events(doc, fids, {"elfType": 2})
        self.assertEqual(result["totals"], {"alloc": 10, "drop": 2})
        owner = next(r for r in result["topOwnersPerCounter"]["alloc"] if r["owner"] == "my_function")
        self.assertEqual(owner["fractionOfAllEvents"], .3)
        self.assertTrue(result["quality"]["usableCounts"])
        self.assertFalse(aggregate_events({**doc, "counter_overflow": True}, fids, {"elfType": 2})["quality"]["usableCounts"])
        for badrow in [{"fid": 0, "segment_address": "0x310", "counts": [3, 1]},
                       {"fid": 0, "segment_address": "0x300", "counts": [-1, 1]},
                       {"fid": 5, "segment_address": "0x0", "counts": [3, 1]},
                       {"fid": 1, "segment_address": "0x300", "counts": [3, 1]}]:
            with self.assertRaises(ValueError):
                aggregate_events({**doc, "rows": [badrow]}, fids, {"elfType": 2})
        with self.assertRaises(ValueError):
            aggregate_events({**doc, "rows": doc["rows"] + [doc["rows"][0]]}, fids, {"elfType": 2})

    def test_entry_dispatches_do_not_count_continuations_as_function_entries(self):
        doc = {"schema": "bend-native-dispatch-events-v1", "context_kind": "active-dispatch-not-logical-ancestry",
               "segment_count": 2, "runtime_segment_count": 4, "unknown_fid": UNKNOWN,
               "counter_names": ["dispatches"], "complete": True, "counts_enabled": True,
               "counter_overflow": False, "invalid_context_events": 0,
               "rows": [{"fid": 0, "segment_address": "0x300", "counts": [3]},
                        {"fid": 1, "segment_address": "0x400", "counts": [7]}]}
        fids = [dict(elfAddress=0x300, lowered_owner='f', role='direct_segment', symbol='direct.f'),
                dict(elfAddress=0x400, lowered_owner='f', role='anonymous_lowered_segment', symbol='continuation')]
        result = aggregate_events(doc, fids, {"elfType": 2})
        self.assertEqual(result['totals']['dispatches'], 10)
        self.assertEqual(len(result['entrySegmentDispatches']), 1)
        self.assertEqual(result['entrySegmentDispatches'][0]['dispatches'], 3)


if __name__ == "__main__":
    unittest.main()

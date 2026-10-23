"""Synthetic offline checks: no Bend target or compiler is executed."""
import importlib.util
import json
import os
from pathlib import Path
import tempfile
import unittest
from unittest import mock

SPEC = importlib.util.spec_from_file_location("bend_profiler_analysis", Path(__file__).with_name("analyze.py"))
A = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(A)


def symbol(start, size, name, section=1):
    return dict(start=start, size=size, name=name, section=section)


class Symbols(unittest.TestCase):
    def setUp(self):
        self.sections = {1: dict(start=100, end=300, name=".text"),
                         2: dict(start=400, end=420, name=".fini")}

    def test_sized_gaps_do_not_inherit_previous_symbol(self):
        index = A.SymbolIndex([symbol(100, 10, "a"), symbol(150, 20, "b")], self.sections)
        self.assertEqual(index.resolve(109)["name"], "a")
        self.assertIsNone(index.resolve(110))
        self.assertIsNone(index.resolve(149))

    def test_unsized_qbe_ranges_are_explicit_and_section_bounded(self):
        index = A.SymbolIndex([symbol(100, 0, "qbe"), symbol(150, 0, "last"),
                               symbol(400, 0, "fini", 2)], self.sections)
        self.assertEqual(index.resolve(149)["range_basis"], "next_symbol_inferred")
        self.assertEqual(index.resolve(150)["range_basis"], "exact_entry_only")
        self.assertIsNone(index.resolve(151))
        self.assertIsNone(index.resolve(299))
        self.assertIsNone(index.resolve(350))
        self.assertEqual(index.resolve(400)["name"], "fini")
        self.assertIsNone(index.resolve(401))

    def test_unsized_alias_does_not_extend_a_known_size(self):
        index = A.SymbolIndex([symbol(100, 10, "a"), symbol(100, 0, "alias"),
                               symbol(150, 10, "b")], self.sections)
        self.assertEqual(index.resolve(105)["aliases"], ["a", "alias"])
        self.assertIsNone(index.resolve(120))

    def test_readelf_parsing_keeps_text_only_and_deduplicates(self):
        sections = A.parse_sections("""  [13] .text PROGBITS 0000000000402000 002000 000100 00 AX 0 0 16
  [14] .data PROGBITS 0000000000500000 003000 000100 00 WA 0 0 16
  [15] .fini PROGBITS 0000000000403000 002100 000009 00 AX 0 0 4""")
        self.assertEqual(set(sections), {13, 15})
        text = """  1: 0000000000402000 20 FUNC GLOBAL DEFAULT 13 sized
  2: 0000000000402020 0 NOTYPE GLOBAL DEFAULT 13 qbe
  3: 0000000000500000 20 OBJECT GLOBAL DEFAULT 14 data
  4: 0000000000000000 0 FUNC GLOBAL DEFAULT UND free
  5: 0000000000402000 20 FUNC GLOBAL DEFAULT 13 sized"""
        self.assertEqual(len(A.parse_symbols(text, sections)), 2)

    def test_pie_translation_uses_file_offset_and_elf_segment(self):
        mapping = dict(start=0x70002000, end=0x70003000, offset=0x2000)
        self.assertEqual(A.ELF.virtual_address(0x7000202A, mapping, [(0x2000, 0x402000, 0x800)]), 0x40202A)
        self.assertIsNone(A.ELF.virtual_address(0x70002900, mapping, [(0x2000, 0x402000, 0x800)]))

    def test_source_name_decoding_is_conservative(self):
        self.assertEqual(A.decode_name("p113d_FID_36_100_105_114_101_99_116_46_102_111_111_"), "p113d_FID_$direct.foo")
        self.assertEqual(A.decode_name("p111_FID_97_"), "p111_FID_a")
        self.assertEqual(A.decode_name("x_999999999999_50_50_"), "x_999999999999_50_50_")
        self.assertEqual(A.decode_name("x_0_1_2_"), "x_0_1_2_")


class Capture(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.directory = Path(self.temp.name)
        self.binary = self.directory / "program"
        self.library = self.directory / "library.so"
        self.binary.write_bytes(b"synthetic executable identity")
        self.library.write_bytes(b"synthetic library identity")

    def tearDown(self):
        self.temp.cleanup()

    def make_capture(self, **changes):
        header = dict(exe=str(self.binary), pid=100, tid=100, period_us=1000,
                      capacity=100000, final_tid=100, main_thread_cpu_ns=500000000,
                      process_cpu_ns=500000000, samples=500, dropped=0, overruns=0,
                      handler_intact=1)
        header.update(changes)
        maps = []
        for path, start in [(self.binary, 0x100000), (self.library, 0x200000)]:
            st = path.stat()
            maps.append(f"{start:x}-{start+0x1000:x} r-xp 00002000 "
                        f"{os.major(st.st_dev):02x}:{os.minor(st.st_dev):02x} {st.st_ino} {path}")
        pcs = ["100005"] * 200 + ["100055"] * 100 + ["200005"] * 150 + ["300005"] * 50
        path = self.directory / "samples.txt"
        path.write_text("BEND_MAIN_CPU_SAMPLES_V1\n" + "".join(f"{k}\t{v}\n" for k, v in header.items()) +
                        "MAPS\n" + "\n".join(maps) + "\nPCS\n" + "\n".join(pcs) + "\nEND\n")
        return path

    def load_object(self, path):
        names = [symbol(0x402000, 40, "bend_FID_102_111_111_"),
                 symbol(0x402040, 0, "qbe"), symbol(0x402080, 0, "last")]
        if Path(path) == self.library:
            names = [symbol(0x402000, 40, "free")]
        return [(0x2000, 0x402000, 0x1000)], A.SymbolIndex(names, {1: dict(start=0x402000, end=0x403000, name=".text")})

    def test_complete_report_conserves_denominator_and_library_identity(self):
        with mock.patch.object(A, "load_object", side_effect=self.load_object):
            report = A.analyze_capture(self.make_capture(), self.binary, clean_cpu_seconds=2.0)
        self.assertTrue(report["usable"])
        self.assertEqual(sum(r["samples"] for r in report["top_functions"]), 500)
        self.assertEqual(sum(r["samples"] for r in report["groups"]), 500)
        self.assertEqual(report["quality"]["unknown_samples"], 50)
        self.assertEqual(report["quality"]["inferred_symbol_range_samples"], 100)
        self.assertEqual(len(report["identities"]["mapped_objects"]), 2)
        self.assertEqual(next(r for r in report["top_functions"] if r["name"] == "free")["estimated_clean_cpu_seconds"], 0.6)
        json.dumps(report)

    def test_loss_and_poor_coverage_are_preserved_not_claimed(self):
        for changes in [dict(dropped=2), dict(overruns=1), dict(handler_intact=0),
                        dict(process_cpu_ns=2000000000), dict(main_thread_cpu_ns=10000000000)]:
            with self.subTest(changes=changes), mock.patch.object(A, "load_object", side_effect=self.load_object):
                report = A.analyze_capture(self.make_capture(**changes), self.binary, clean_cpu_seconds=2.0)
                self.assertFalse(report["usable"])
                self.assertEqual(len(report["pcs"]), 4)
                self.assertNotIn("estimated_clean_cpu_seconds", report["top_functions"][0])
                self.assertTrue(report["quality"]["limitations"])

    def test_missing_library_stays_in_denominator(self):
        capture = self.make_capture()
        self.library.unlink()
        with mock.patch.object(A, "load_object", side_effect=self.load_object):
            report = A.analyze_capture(capture, self.binary)
        self.assertEqual(report["quality"]["unknown_samples"], 200)
        self.assertIn(str(self.library), report["object_errors"])

    def test_corrupt_count_and_wrong_binary_rejected(self):
        with self.assertRaises(ValueError):
            A.parse_capture(self.make_capture(samples=501))
        with self.assertRaises(ValueError):
            A.analyze_capture(self.make_capture(), self.library)

    def test_low_sample_count_and_incomplete_threads(self):
        header, _, _ = A.parse_capture(self.make_capture())
        header.update(samples=100, main_thread_cpu_ns=100000000, process_cpu_ns=100000000)
        self.assertFalse(A.capture_quality(header)["usable_for_process_cpu_attribution"])
        header.update(sampler_scope="all_created_threads", sampled_thread_cpu_ns=100000000,
                      threads_allocated=2, threads_ready=1, threads_ended=1,
                      thread_overflow=0, thread_clock_failures=0, timer_disarm_failures=0)
        self.assertFalse(A.capture_quality(header)["thread_lifecycle_complete"])


if __name__ == "__main__":
    unittest.main()

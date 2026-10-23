#!/usr/bin/env python3
"""Synthetic CFI boundary tests. No target programs are executed."""
import unittest
from unwind import CFIError, header, prepare_rows, requested_ranges


CIE = '''Contents of the .eh_frame section:

00000000 0000000000000014 00000000 CIE "zR" cf=1 df=-8 ra=16
   LOC CFA ra
0000000000000000 rsp+8 c-8

'''


def fde(start=0x100, end=0x200, offset=0x18, cie=0, rows=""):
    return "%08x 00000014 0000001c FDE cie=%08x pc=%016x..%016x\n%s\n" % (offset, cie, start, end, rows)


def ranges(start=0x100, end=0x200):
    return requested_ranges({"ranges": [{"start": start, "end": end}]})


class UnwindTests(unittest.TestCase):
    def test_inherited_cie(self):
        result = prepare_rows(CIE + fde(), ranges())
        self.assertEqual(result["rows"], [{"start": 0x100, "end": 0x200, "cfa": 8, "ra": -8}])
        self.assertTrue(result["complete"])
        self.assertEqual(result["coveredBytes"], 256)

    def test_explicit_rows_and_other_registers(self):
        text = CIE + fde(rows="LOC CFA rbp ra\n00000100 rsp+16 c-16 c-8\n00000120 rsp+32 c-16 c-8\n00000200 rsp+8 u c-8")
        result = prepare_rows(text, ranges(0x110, 0x140))
        self.assertEqual(result["rows"], [
            {"start": 0x110, "end": 0x120, "cfa": 16, "ra": -8},
            {"start": 0x120, "end": 0x140, "cfa": 32, "ra": -8}])

    def test_delayed_first_row_inherits(self):
        result = prepare_rows(CIE + fde(rows="LOC CFA ra\n00000120 rsp+16 c-8"), ranges())
        self.assertEqual([(r["start"], r["end"], r["cfa"]) for r in result["rows"]],
                         [(0x100, 0x120, 8), (0x120, 0x200, 16)])

    def test_expression_reject_and_partial(self):
        text = CIE + fde(rows="LOC CFA ra\n00000100 rsp+8 c-8\n00000120 exp c-8\n00000180 rsp+8 c-8")
        with self.assertRaisesRegex(CFIError, "unsupported CFA"):
            prepare_rows(text, ranges())
        result = prepare_rows(text, ranges(), True)
        self.assertFalse(result["complete"])
        self.assertEqual(result["coveredBytes"], 160)
        self.assertEqual([(r["start"], r["end"]) for r in result["skipped"]], [(0x120, 0x180)])

    def test_padding_is_not_covered(self):
        text = CIE + fde(end=0x180) + fde(start=0x190, offset=0x40)
        with self.assertRaisesRegex(CFIError, "no .eh_frame"):
            prepare_rows(text, ranges())
        result = prepare_rows(text, ranges(), True)
        self.assertEqual(result["skipped"][0]["start"], 0x180)
        self.assertEqual(result["skipped"][0]["end"], 0x190)

    def test_overlapping_fdes_are_ambiguous(self):
        with self.assertRaisesRegex(CFIError, "ambiguous"):
            prepare_rows(CIE + fde() + fde(start=0x180, offset=0x40), ranges())

    def test_bad_cie(self):
        for text, reason in [(CIE + fde(cie=0x88), "missing CIE"),
                             (CIE.replace("ra=16", "ra=15") + fde(), "return register"),
                             (CIE.replace('"zR"', '"zRS"') + fde(), "signal-frame")]:
            with self.subTest(reason=reason), self.assertRaisesRegex(CFIError, reason):
                prepare_rows(text, ranges())

    def test_unsupported_ra_register_or_rule(self):
        for cfa, ra in [("rbp+16", "c-8"), ("rsp+8", "u"), ("rsp+8", "s"), ("rsp+8", "r3")]:
            with self.subTest(cfa=cfa, ra=ra), self.assertRaisesRegex(CFIError, "unsupported"):
                prepare_rows(CIE + fde(rows="LOC CFA ra\n00000100 %s %s" % (cfa, ra)), ranges())

    def test_nonmonotone_and_outside_rows_rejected(self):
        for rows in ["00000120 rsp+8 c-8\n00000110 rsp+8 c-8", "00000201 rsp+8 c-8"]:
            with self.assertRaisesRegex(CFIError, "boundaries"):
                prepare_rows(CIE + fde(rows="LOC CFA ra\n" + rows), ranges())

    def test_irrelevant_unsupported_frame_does_not_block(self):
        text = CIE + fde() + fde(0x500, 0x600, 0x40, rows="LOC CFA ra\n00000500 exp u")
        self.assertTrue(prepare_rows(text, ranges())["complete"])

    def test_debug_frame_cannot_override_eh_frame(self):
        text = CIE + fde() + "Contents of the .debug_frame section:\n" + fde()
        self.assertTrue(prepare_rows(text, ranges())["complete"])

    def test_declared_rules_must_match(self):
        document = {"physicalUnwindRows": [{"start": "0x100", "end": "0x200",
                    "cfaRegister": "rsp", "cfaOffset": 16, "returnAddressOffset": -8}]}
        with self.assertRaisesRegex(CFIError, "disagrees"):
            prepare_rows(CIE + fde(), requested_ranges(document))

    def test_requested_ranges_fail_closed(self):
        for document in [{"ranges": []}, {"ranges": [{"start": 2, "end": 1}]},
                         {"ranges": [{"start": 1.5, "end": 4}]},
                         {"ranges": [{"start": True, "end": 4}]},
                         {"ranges": [{"start": 1, "end": 4}, {"start": 3, "end": 6}]}]:
            with self.assertRaises(CFIError):
                requested_ranges(document)

    def test_physical_rows_take_priority(self):
        document = {"ranges": [{"start": 0, "end": 1000}], "physicalUnwindRows": [
            {"start": "0x100", "end": "0x200", "cfaRegister": "rsp",
             "cfaOffset": 8, "returnAddressOffset": -8}]}
        self.assertEqual(prepare_rows(CIE + fde(), requested_ranges(document))["coveredBytes"], 256)

    def test_header_contract(self):
        text = header({"id": "sample", "object": {"file": '/test/"file', "device": 1,
                     "inode": 2, "sha256": "hash"}, "rows": [
                         {"start": 256, "end": 512, "cfa": 8, "ra": -8}]})
        self.assertIn("#define BEND_UNWIND_ROW_COUNT 1", text)
        self.assertIn("UINT64_C(0x100), UINT64_C(0x200), 8, -8", text)
        self.assertIn('BEND_UNWIND_OBJECT_PATH "/test/\\\"file"', text)


if __name__ == "__main__":
    unittest.main()

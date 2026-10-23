"""Synthetic owner-map tests; no compiler execution."""
import importlib.util
from pathlib import Path
import tempfile
import unittest

SPEC = importlib.util.spec_from_file_location("bend_profiler_owners", Path(__file__).with_name("owners.py"))
O = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(O)


def symbol(name, prefix="p111"):
    return prefix + "_FID_" + "".join(str(ord(char)) + "_" for char in name)


def qbe(names, private=()):
    public = [symbol(name) for name in names]
    functions = public + [symbol(name, "p113d") for name in private]
    bodies = "".join(f"function l ${name}(l %state) {{\n@entry\nret 0\n}}\n" for name in functions)
    fields = ["l 11101", "l 192", "l " + str(len(public)), "l 0", "l 0"] + ["l 0"] * 7
    fields += ["l $p111_segments"] + ["l 0"] * 11
    return bodies + "data $p111_segments = align 8 { " + ", ".join("l $" + name for name in public) + " }\n" + \
        "export data $p111_program = align 8 { " + ", ".join(fields) + " }\n"


class Owners(unittest.TestCase):
    def parse(self, text):
        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory) / "program.ssa"
            path.write_text(text)
            return O.parse_qbe_owners(path)

    def test_nested_lambdas_and_continuations_keep_lexical_owner(self):
        names = ["outer", "$p111.k.1", "$p111.k.3", "$direct.outer", "$p111.k.2", "next"]
        report = self.parse(qbe(names, ["$p111.k.3", "$direct.outer", "$product.outer"]))
        self.assertEqual([r["lowered_owner"] for r in report["fids"]], ["outer"] * 5 + ["next"])
        self.assertEqual(report["fids"][2]["fid"], 2)
        self.assertEqual(report["coverage"]["invalid_groups"], 0)
        private = {row["decoded"]: row for row in report["functions"] if row["symbol"].startswith("p113d")}
        self.assertEqual(private["$direct.outer"]["lowered_owner"], "outer")
        self.assertEqual(private["$p111.k.3"]["lowered_owner"], "outer")
        self.assertIsNone(private["$product.outer"]["lowered_owner"])
        self.assertFalse(report["producer_provenance_verified"])

    def test_mismatch_invalidates_whole_group_and_next_group_recovers(self):
        report = self.parse(qbe(["a", "$p111.k.1", "$direct.b", "$p111.k.2", "c", "$direct.c"]))
        self.assertEqual([r["lowered_owner"] for r in report["fids"]], [None] * 4 + ["c", "c"])
        self.assertEqual(report["coverage"]["invalid_groups"], 1)

    def test_unknown_generated_kind_and_orphan_fail_closed(self):
        report = self.parse(qbe(["$p111.k.0", "a", "$new.reordered", "$p111.k.1"]))
        self.assertTrue(all(row["lowered_owner"] is None for row in report["fids"]))

    def test_native_wrapper_is_distinct_lowered_identity(self):
        report = self.parse(qbe(["$native.Nat.add", "$p111.k.1", "$direct.$native.Nat.add"]))
        self.assertEqual([r["lowered_owner"] for r in report["fids"]], ["$native.Nat.add"] * 3)

    def test_bad_table_or_descriptor_rejected(self):
        for text in [qbe(["a"]).replace("l 11101", "l 11102"),
                     qbe(["a"]).replace("l $" + symbol("a") + " }", "l $absent }"),
                     qbe(["a"]).replace("l 192, l 1", "l 192, l 2"),
                     qbe(["a"]).replace("l $" + symbol("a") + " }", "l $" + symbol("a") + " + 8 }")]:
            with self.subTest(text=text), self.assertRaises(ValueError):
                self.parse(text)

    def test_table_order_not_function_or_numeric_name_order(self):
        text = qbe(["a", "$p111.k.50", "$p111.k.3", "$direct.a"])
        report = self.parse(text)
        self.assertEqual(report["fids"][1]["decoded"], "$p111.k.50")
        self.assertEqual(report["fids"][2]["decoded"], "$p111.k.3")

    def test_multiline_tables(self):
        report = self.parse(qbe(["a", "$direct.a"]).replace(", l $p111_FID_", ",\nl $p111_FID_"))
        self.assertEqual(report["coverage"]["owned_fids"], 2)


if __name__ == "__main__":
    unittest.main()

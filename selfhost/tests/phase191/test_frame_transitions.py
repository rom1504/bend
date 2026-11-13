"""Finite parser and boundary controls; does not compile or execute targets."""
import importlib.util
from pathlib import Path
import unittest

spec = importlib.util.spec_from_file_location("transitions", Path(__file__).with_name("frame-transitions.py"))
module = importlib.util.module_from_spec(spec)
spec.loader.exec_module(module)


def instructions(rows):
    return [dict(address=hex(0x1000 + i), offset=i, bytes=1, mnemonic=op, operands=args)
            for i, (op, args) in enumerate(rows)]


class Transitions(unittest.TestCase):
    def count(self, rows):
        values = instructions(rows)
        return module.transition_stats(values, values)["static"]["frame_store_next_load_transitions"]

    def test_store_load_and_only_first_read(self):
        self.assertEqual(self.count([
            ("mov", "%rax,-0x10(%rbp)"), ("add", "$0x1,%rcx"),
            ("mov", "-0x10(%rbp),%rdx"), ("mov", "-0x10(%rbp),%rsi")]), 1)

    def test_barriers(self):
        for middle in [("call", "2000 <callee>"), ("jmp", "1002 <join>"),
                       ("mov", "%rax,(%rdi)"), ("mov", "%rax,0x4000"),
                       ("mov", "%rax,%rbp"), ("push", "%rax"),
                       ("movb", "$1,-0x10(%rbp)"), ("mov", "%eax,-0xc(%rbp)"),
                       ("mov", "-0x10(%rbp),%al")]:
            with self.subTest(middle=middle):
                self.assertEqual(self.count([
                    ("mov", "%rax,-0x10(%rbp)"), middle,
                    ("mov", "-0x10(%rbp),%rdx")]), 0)

    def test_disjoint_slots_and_widths(self):
        self.assertEqual(self.count([
            ("mov", "%rax,-0x10(%rbp)"), ("mov", "%eax,-0x4(%rbp)"),
            ("mov", "-0x10(%rbp),%rdx"), ("mov", "-0x4(%rbp),%ecx")]), 2)
        self.assertEqual(self.count([
            ("mov", "%eax,-0x10(%rbp)"), ("mov", "-0x10(%rbp),%rdx")]), 0)

    def test_join_gap_and_indirect_jump(self):
        rows = instructions([("mov", "%rax,-0x10(%rbp)"),
                             ("mov", "-0x10(%rbp),%rdx"), ("jmp", "1001 <join>")])
        self.assertEqual(module.transition_stats(rows[:2], rows)["witnesses"], [])
        rows[2]["operands"] = "*%rax"
        self.assertEqual(module.transition_stats(rows[:2], rows)["witnesses"], [])
        rows = instructions([("mov", "%rax,-0x10(%rbp)"), ("add", "$1,%rcx"),
                             ("mov", "-0x10(%rbp),%rdx")])
        self.assertEqual(module.transition_stats([rows[0], rows[2]], rows)["witnesses"], [])

    def test_scaled_operand_split(self):
        self.assertEqual(module.operands("0x8(%rax,%r12,4),%rdi # note"),
                         ["0x8(%rax,%r12,4)", "%rdi"])


if __name__ == "__main__":
    unittest.main()

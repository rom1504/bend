"""Offline generated-source inspection controls; no tools or targets execute."""
import importlib.util
from pathlib import Path
import tempfile
import unittest

HERE=Path(__file__).resolve().parent
spec=importlib.util.spec_from_file_location('bench_inspection',HERE/'inspect.py')
I=importlib.util.module_from_spec(spec)
spec.loader.exec_module(I)


class InspectionContracts(unittest.TestCase):
    def inspect(self,text,target):
        with tempfile.TemporaryDirectory() as directory:
            source=Path(directory)/'source';source.write_text(text)
            return I.analyze_source(source,target)

    def test_assembly_counts_labels_instructions_and_direct_or_indirect_calls(self):
        report=self.inspect('.text\n.globl entry\nentry:\n pushq %rbp # call ignored\n'
                            ' call function@PLT\n.Llocal: callq *%rax\n1: ret\n'
                            '.data\nvalue: .quad function\n# fake: call absent\n','x86')
        self.assertEqual(report['assemblySymbols'],4)
        self.assertEqual(report['assemblyInstructions'],4)
        self.assertEqual(report['assemblyMnemonics'],dict(call=1,callq=1,pushq=1,ret=1))
        self.assertEqual(report['lexicalCalls'],{'*%rax':1,'function@PLT':1})
        self.assertNotIn('qbeFunctions',report)
        self.assertIn('not parsed instructions',report['scope'])

    def test_existing_c_and_qbe_lexical_counts_remain_distinct(self):
        qbe=self.inspect('export function $entry() {\n call $worker()\n}\n','qbe')
        self.assertEqual(qbe['qbeFunctions'],1)
        self.assertEqual(qbe['lexicalCalls'],{'worker':1})
        c=self.inspect('int entry(void) { return worker(); }\n','c')
        self.assertIsNone(c['qbeFunctions'])
        self.assertEqual(c['lexicalCalls'],{'entry':1,'worker':1})
        self.assertNotIn('assemblyInstructions',c)


if __name__=='__main__': unittest.main()

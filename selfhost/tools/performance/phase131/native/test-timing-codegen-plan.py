"""Offline admission-boundary checks; no compiler or benchmark processes."""
import copy
import importlib.util
from pathlib import Path
import sys
import unittest

sys.dont_write_bytecode = True
spec = importlib.util.spec_from_file_location('p131_final_timing', Path(__file__).with_name('timing-codegen-plan.py'))
M = importlib.util.module_from_spec(spec)
spec.loader.exec_module(M)


class FinalCodegenAdmission(unittest.TestCase):
    def setUp(self):
        self.method = dict(file='/test/qualify-final.py', bytes=2252, sha256=M.FINAL_METHOD_SHA)
        self.ad = dict(kind='phase131-native-acquisition-admission', complete=True,
            sourceChecked=True, changeKind='declared-codegen-change',
            requiredReproduction='N0->N1->N2->N3;Q2=Q3',
            source=dict(sha256=M.FINAL_SHA), qualificationMethod=self.method.copy())

    def test_final_contract_accepts_without_fabricated_reproduction(self):
        original = copy.deepcopy(self.ad)
        M.codegen_contract(self.ad, self.method)
        self.assertEqual(self.ad, original)
        self.assertNotIn('nativeQualified', self.ad)

    def test_old_fast_policy_rejected(self):
        self.ad['changeKind'] = 'byte-preserving-algorithm-candidate'
        self.ad['requiredReproduction'] = 'N0->N1->N2;Q1=Q2'
        with self.assertRaises(ValueError):
            M.codegen_contract(self.ad, self.method)

    def test_new_policy_cannot_omit_third_generation(self):
        self.ad['requiredReproduction'] = 'N0->N1->N2;Q1=Q2'
        with self.assertRaises(ValueError):
            M.codegen_contract(self.ad, self.method)

    def test_other_source_rejected(self):
        self.ad['source']['sha256'] = '0' * 64
        with self.assertRaises(ValueError):
            M.codegen_contract(self.ad, self.method)

    def test_mutated_method_rejected_even_with_matching_admission(self):
        self.method['sha256'] = '0' * 64
        self.ad['qualificationMethod'] = self.method.copy()
        with self.assertRaises(ValueError):
            M.codegen_contract(self.ad, self.method)

    def test_unbound_method_rejected(self):
        self.ad['qualificationMethod']['file'] = '/other/qualify-final.py'
        with self.assertRaises(ValueError):
            M.codegen_contract(self.ad, self.method)

    def test_incomplete_or_unchecked_rejected(self):
        for field in ['complete', 'sourceChecked']:
            with self.subTest(field=field):
                ad = copy.deepcopy(self.ad)
                ad[field] = False
                with self.assertRaises(ValueError):
                    M.codegen_contract(ad, self.method)


if __name__ == '__main__':
    unittest.main()

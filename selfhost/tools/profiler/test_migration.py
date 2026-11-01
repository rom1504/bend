"""Offline migration controls; no compiler, sampler or native program executes."""
import copy
import json
from pathlib import Path
import tempfile
import unittest
from unittest.mock import patch

import concat_v1 as C
import elf
import owners
from test_owners import qbe

HERE=Path(__file__).resolve().parent


class Migration(unittest.TestCase):
    def test_elf_segments_and_empty_rejection(self):
        with patch.object(elf,'command',return_value=' LOAD 0x100 0x400100 0 0x200 0x200 R E 0x1000\n'):
            self.assertEqual(elf.load_segments('/unused'),[(0x100,0x400100,0x200)])
        with patch.object(elf,'command',return_value=''),self.assertRaises(ValueError):elf.load_segments('/unused')

    def test_owner_sources_are_explicit_and_not_producer_proof(self):
        with tempfile.TemporaryDirectory() as directory:
            source=Path(directory)/'emitter.bend';source.write_text('frozen contract')
            product=Path(directory)/'program.ssa';product.write_text(qbe(['a']))
            unbound=owners.parse_qbe_owners(product)
            bound=owners.parse_qbe_owners(product,[source])
            self.assertEqual(unbound['identities']['emitter_contract_sources'],[])
            self.assertEqual(bound['identities']['emitter_contract_sources'],[owners.pin(source)])
            self.assertFalse(bound['producer_provenance_verified'])

    def test_concat_hooks_are_reversible_and_single_use(self):
        source=('uint64_t p125_rt_concat_typed(void) {\n'+ '\n'.join(old for _,old,_ in C.HOOKS)+'\n}\n').encode()
        support=(HERE/'runtime-support.inc.c').read_bytes()
        changed,extended,edits=C.materialize(source,support)
        recovered=changed.decode()
        for row in reversed(edits):recovered=recovered.replace(row['diagnostic'],row['original'],1)
        self.assertEqual(recovered.encode(),source)
        self.assertNotEqual(extended,support)
        with self.assertRaises(ValueError):C.materialize(changed,extended)
        with self.assertRaises(ValueError):C.materialize(source.replace(b'return left;',b'return right;'),support)

    def document(self):
        expected=json.loads((HERE/'controls/runtime-control.expected.json').read_text())
        names=C.extend_expectation(expected)['counterNames']
        counts=[0]*23
        for name,value in {'concat_attempts':3,'concat_nodes_examined':4,'concat_success_empty':1,'concat_success_splice':1,'concat_refused_shared_rfc':1}.items():counts[names.index(name)]=value
        return dict(schema='bend-native-dispatch-events-v1',complete=True,counter_overflow=False,invalid_context_events=0,
                    counter_names=names,counts_enabled=True,segment_count=2,counter_bytes=7*23*8,rows=[dict(fid=0,counts=counts)])

    def test_concat_conservation_and_no_timing_claim(self):
        doc=self.document();result=C.summarize(doc)
        self.assertEqual(result['refusalFraction'],1/3)
        self.assertFalse(result['timingClaim']);self.assertFalse(result['exactProgramOutputVerified'])
        for change in ['duplicate','bad-outcome','overflow','disabled','storage']:
            broken=copy.deepcopy(doc)
            if change=='duplicate':broken['rows']*=2
            elif change=='bad-outcome':broken['rows'][0]['counts'][-7]+=1
            elif change=='overflow':broken['counter_overflow']=True
            elif change=='disabled':broken['counts_enabled']=False
            else:broken['counter_bytes']-=8
            with self.subTest(change=change),self.assertRaises(ValueError):C.summarize(broken)

    def test_frozen_abi_is_unmodified_and_new_columns_zero(self):
        expected=json.loads((HERE/'controls/runtime-control.expected.json').read_text())
        original=copy.deepcopy(expected);extended=C.extend_expectation(expected)
        self.assertEqual(expected,original)
        self.assertEqual(len(extended['counterNames']),23)
        self.assertTrue(all(extended['totals'][name]==0 for _,name in C.COUNTERS))
        import hashlib
        self.assertEqual(hashlib.sha256((HERE/'controls/runtime-control.c').read_bytes()).hexdigest(),expected['source']['sha256'])


if __name__=='__main__':unittest.main()

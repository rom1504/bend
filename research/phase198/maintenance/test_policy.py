#!/usr/bin/env python3
"""Cheap source-transport regressions; no Bend compiler or target execution."""
import copy, importlib.util, json, sys, tempfile, unittest
from pathlib import Path
sys.dont_write_bytecode=True
HERE=Path(__file__).resolve().parent
spec=importlib.util.spec_from_file_location('policy_source',HERE/'source-proposed.py');s=importlib.util.module_from_spec(spec);spec.loader.exec_module(s)
BASE=b'''type Word is Data:
  WordValue{}

@unsafe
def choose(+x: U32) -> U32:
  x

def protected(x: U32) -> U32:
  x

def main() -> U32:
  choose(1)
'''
BLOCK=b'''def extra(x: U32) -> U32:
  x

@unsafe
def choose(+x: U32) -> U32:
  extra(x)
'''
class PolicyTests(unittest.TestCase):
 def setUp(self):
  self.tmp=tempfile.TemporaryDirectory();self.addCleanup(self.tmp.cleanup);self.root=Path(self.tmp.name)
  for name,data in [('preamble.bend',b'# preamble\n'),('body.bend',BASE),('policy.bend',BLOCK),('extra.bend',b'def additive() -> U32:\n  0\n')]: (self.root/name).write_bytes(data)
  _,items=s.blocks(BASE)
  self.manifest={'kind':'bend-maintained-source-v1','preamble':'preamble.bend','modules':['body.bend'],'order':[[0,x['kind'],x['name']] for x in items],'defaultProfile':'x86','profiles':{'x86':{'protocol':'native-x86-source-v1','policyBlock':{'replace':'choose','module':'policy.bend'}},'qbe':{}},'protectedDeclarations':{'protected':{'normalizedSha256':s.digest(s.normalized([x for x in items if x['name']=='protected']))}}}
 def assemble(self,profile='x86'):
  path=self.root/'manifest.json';path.write_text(json.dumps(self.manifest));return s.maintained_assemble(path,self.root,profile,True)
 def block(self,data): (self.root/'policy.bend').write_bytes(data)
 def refuses(self):
  with self.assertRaises(ValueError):self.assemble()
 def test_exact_splice_and_map_origins(self):
  data,mapping=self.assemble();_,items=s.blocks(BASE); old=next(x['data'] for x in items if x['name']=='choose')
  self.assertEqual(data,b'# preamble\n'+BASE.replace(old,BLOCK))
  for row in mapping:
   source=(self.root/row['file']).read_bytes()
   self.assertEqual(source[row['sourceStartByte']:row['sourceStartByte']+row['spanBytes']],data[row['generatedStartByte']:row['generatedStartByte']+row['spanBytes']])
  self.assertEqual([r['file'] for r in mapping if r['name'] in ('choose','extra')],['policy.bend','policy.bend'])
 def test_unaffected_profile_ignores_policy_file(self):
  before=self.assemble('qbe');self.block(b'not a valid module');self.assertEqual(before,self.assemble('qbe'))
 def test_no_option_retains_original(self):
  del self.manifest['profiles']['x86']['policyBlock'];self.assertEqual(self.assemble(),self.assemble('qbe'))
 def test_malformed_selectors(self):
  for value in [None,[],{},'choose',{'replace':'choose'},{'replace':'choose','module':'policy.bend','extra':1},{'replace':3,'module':'policy.bend'},{'replace':'choose()','module':'policy.bend'},{'replace':'missing','module':'policy.bend'},{'replace':'Word','module':'policy.bend'}]:
   with self.subTest(value=value):self.manifest['profiles']['x86']['policyBlock']=value;self.refuses()
 def test_only_x86_profile(self):
  self.manifest['profiles']['qbe']['policyBlock']=self.manifest['profiles']['x86']['policyBlock']
  with self.assertRaises(ValueError):self.assemble('qbe')
 def test_protocol_required(self):
  del self.manifest['profiles']['x86']['protocol'];self.refuses()
 def test_protected_replacement(self):
  self.manifest['profiles']['x86']['policyBlock']['replace']='protected';self.refuses()
 def test_original_protection_enforced(self):
  (self.root/'body.bend').write_bytes(BASE.replace(b'def protected(x: U32) -> U32:\n  x',b'def protected(x: U32) -> U32:\n  0'));self.refuses()
 def test_original_signature_and_quantities(self):
  for old,new in [(b'+x:',b'x:'),(b'U32) -> U32:',b'U32) -> Bool:'),(b'@unsafe\n',b''),(b'+x:',b'+other:')]:
   with self.subTest(change=new):self.block(BLOCK.replace(old,new));self.refuses()
 def test_multiline_signature_refused(self):
  self.block(BLOCK.replace(b'def choose(+x: U32) -> U32:',b'def choose(+x: U32)\n -> U32:'));self.refuses()
 def test_traversal_and_reused_module(self):
  for name in ['../policy.bend','/tmp/policy.bend','body.bend','',3]:
   with self.subTest(name=name):self.manifest['profiles']['x86']['policyBlock']['module']=name;self.refuses()
 def test_missing_or_duplicate_replacement(self):
  for value in [BLOCK.replace(b'choose(',b'other('),BLOCK+BLOCK]:
   self.block(value);self.refuses()
 def test_shadow_canonical_name_even_different_kind(self):
  self.block(BLOCK+b'law protected : U32\n');self.refuses()
 def test_shadow_constructor_name(self):
  self.block(BLOCK+b'def WordValue() -> U32:\n  0\n');self.refuses()
 def test_new_constructor_shadows_canonical(self):
  self.block(BLOCK+b'type Fresh is Data:\n  protected{}\n');self.refuses()
 def test_new_constructor_shadows_replacement(self):
  self.block(BLOCK+b'type Fresh is Data:\n  choose{}\n');self.refuses()
 def test_new_constructor_shadows_helper(self):
  self.block(BLOCK+b'type Fresh is Data:\n  extra{}\n');self.refuses()
 def test_shadow_additive_declaration(self):
  self.manifest['profiles']['x86']['modules']=['extra.bend'];self.block(BLOCK+b'def additive() -> U32:\n  1\n');self.refuses()
 def test_main_replacement_or_shadow_refused(self):
  self.block(BLOCK+b'def main() -> U32:\n  1\n');self.refuses();self.manifest['profiles']['x86']['policyBlock']['replace']='main';self.refuses()
 def test_duplicate_new_declaration_refused(self):
  self.block(BLOCK+b'def extra(x: U32) -> U32:\n  x\n');self.refuses()
 def test_canonical_law_pair_refused(self):
  body=BASE+b'law choose : U32 -> U32\n';(self.root/'body.bend').write_bytes(body);self.manifest['order'].append([0,'law','choose']);self.refuses()
 def test_bad_inventory_still_refused(self):
  self.manifest['order']=self.manifest['order'][:-1];self.refuses()
 def test_symlink_escape_refused(self):
  (self.root/'policy.bend').unlink();(self.root/'policy.bend').symlink_to('/etc/hosts');self.refuses()
if __name__=='__main__':
 # Run the existing maintained-profile regression suite against the proposal too.
 sys.modules['source']=s
 path=HERE.parents[2]/'selfhost/tools/build/test_source_profiles.py'
 original_spec=importlib.util.spec_from_file_location('existing_profile_tests',path)
 original=importlib.util.module_from_spec(original_spec);original_spec.loader.exec_module(original)
 suite=unittest.TestSuite([unittest.defaultTestLoader.loadTestsFromTestCase(PolicyTests),unittest.defaultTestLoader.loadTestsFromModule(original)])
 result=unittest.TextTestRunner(verbosity=2).run(suite)
 sys.exit(not result.wasSuccessful())

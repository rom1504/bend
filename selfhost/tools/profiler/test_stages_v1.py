"""Offline stage contracts: order, repeated/optional boundaries and denominators."""
import copy,unittest
import stages_v1 as S

class StageTests(unittest.TestCase):
 def setUp(self):
  self.owners={'fids':[dict(fid=i,symbol='s'+str(i),role='direct_segment') for i in range(3)]}
  self.spec=dict(schema='bend-native-stage-spec-v1',markers=[dict(label='begin',fid=0,symbol='s0',multiplicity='once'),dict(label='drain',fid=1,symbol='s1',multiplicity='first'),dict(label='optional',fid=2,symbol='s2',multiplicity='optional')],requiredOrder=['begin','drain'],intervals=[dict(label='whole',begin='begin',end='drain'),dict(label='conditional',begin='optional',end='drain')])
  self.linked={i:dict(elfAddress=0x100+i) for i in range(3)}
  def ob(n):return dict(wallNs=n,cpuNs=n,threadNs=n,sampleOrdinal=n)
  self.side=dict(complete=True,sequentialOnly=True,badOrderOrDuplicate=False,clockError=False,expectedSegments=3,requiredObservedInOrder=2,finish=ob(10),markers=[dict(label='begin',fid=0,address='0x100',multiplicity='once',entries=1,truncated=False,observations=[ob(1)]),dict(label='drain',fid=1,address='0x101',multiplicity='first',entries=2,truncated=False,observations=[ob(6),ob(8)]),dict(label='optional',fid=2,address='0x102',multiplicity='optional',entries=0,truncated=False,observations=[])])
 def check(self):return S.check_observations(self.spec,self.owners,self.side,self.linked,10)
 def test_first_and_absent_optional(self):
  got=self.check();events=[dict(leaf={},dispatchContext={}) for _ in range(10)]
  rows=S.summarize_intervals(self.spec,got,self.side['finish'],events,{})
  self.assertEqual(rows[0]['samples'],3);self.assertEqual(rows[0]['boundarySamplesExcluded'],2)
  self.assertEqual(rows[0]['topActiveOwners'][0]['fractionOfAllSamples'],1)
  self.assertFalse(rows[0]['quantitativeProfileAdmitted']);self.assertFalse(rows[1]['available'])
 def test_repeated_once_rejected(self):
  self.side['markers'][0]['entries']=2
  with self.assertRaisesRegex(ValueError,'unique'):self.check()
 def test_required_order_rejected(self):
  self.side['markers'][0]['observations'][0].update(wallNs=7,cpuNs=7,threadNs=7,sampleOrdinal=7)
  with self.assertRaisesRegex(ValueError,'reordered'):self.check()
 def test_wrong_address_rejected(self):
  self.side['markers'][0]['address']='0x999'
  with self.assertRaisesRegex(ValueError,'address'):self.check()
 def test_ordinal_outside_capture_rejected(self):
  self.side['finish']['sampleOrdinal']=11
  with self.assertRaisesRegex(ValueError,'finish'):self.check()
 def test_optional_repeated_has_no_single_interval(self):
  row=self.side['markers'][2];row['entries']=2;row['observations']=[dict(wallNs=3,cpuNs=3,threadNs=3,sampleOrdinal=3),dict(wallNs=4,cpuNs=4,threadNs=4,sampleOrdinal=4)]
  got=self.check();rows=S.summarize_intervals(self.spec,got,self.side['finish'],[dict(leaf={}) for _ in range(10)],{})
  self.assertFalse(rows[1]['available'])
 def test_optional_one_valid_nested_interval(self):
  row=self.side['markers'][2];row['entries']=1;row['observations']=[dict(wallNs=3,cpuNs=3,threadNs=3,sampleOrdinal=3)]
  got=self.check();rows=S.summarize_intervals(self.spec,got,self.side['finish'],[dict(leaf={}) for _ in range(10)],{})
  self.assertTrue(rows[1]['available']);self.assertEqual(rows[1]['samples'],1)
 def test_unescaped_runtime_label_rejected(self):
  self.spec['markers'][0]['label']='bad"label'
  with self.assertRaisesRegex(ValueError,'ASCII'):S.validate_spec(self.spec,self.owners)
 def test_duplicate_fid_rejected(self):
  self.spec['markers'][1]['fid']=0
  with self.assertRaisesRegex(ValueError,'Duplicate'):S.validate_spec(self.spec,self.owners)
 def test_map_retains_exact_spec_and_multiplicity(self):
  text=S.map_header(self.spec,self.owners,'a'*64)
  self.assertIn('"'+('a'*64)+'"',text);self.assertIn('bgs_mode[BGS_COUNT]={0,1,2}',text)
if __name__=='__main__':unittest.main()

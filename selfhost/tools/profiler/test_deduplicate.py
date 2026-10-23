import contextlib
import io
import json
from pathlib import Path
import tempfile
import unittest
from unittest.mock import patch

import deduplicate as D


class ArtifactRetention(unittest.TestCase):
    def campaign(self,root):
        build=root/'build';case=build/'run'/'case';case.mkdir(parents=True)
        oracle=build/'oracle.ssa';oracle.write_bytes(b'x'*65536)
        output=case/'stdout';output.write_bytes(oracle.read_bytes())
        empty=case/'stderr';empty.write_bytes(b'')
        expected=dict(stdout=dict(kind='exact',**D.pin(oracle)),stderr=dict(kind='exact',**D.pin(empty)))
        manifest=dict(workloads=[dict(name='work',variants=[dict(name='base',expected=expected)])])
        report=dict(complete=True,passed=True,changedInputs=[],rows=[dict(workload='work',variant='base',
            correct=True,stdout=D.pin(output),stderr=D.pin(empty))])
        rp=case.parent/'report.json';rp.write_text(json.dumps(report))
        (case.parent/'manifest.json').write_text(json.dumps(manifest))
        return build,oracle,output,rp

    def test_exact_completed_output_keeps_paths_bytes_and_pins(self):
        with tempfile.TemporaryDirectory() as directory:
            root=Path(directory);build,oracle,output,rp=self.campaign(root)
            identity=D.pin(output);receipt=root/'dedup.json'
            with patch.object(D,'ROOT',root),patch.object(D,'BUILD',build), \
                 patch('sys.argv',['deduplicate','--report',str(rp),'--out',str(receipt)]), \
                 contextlib.redirect_stdout(io.StringIO()):
                D.main()
            self.assertEqual(D.pin(output),identity)
            self.assertEqual(output.stat().st_ino,oracle.stat().st_ino)
            data=json.loads(receipt.read_text());self.assertTrue(data['complete'])
            self.assertGreater(data['recoveredAllocatedBytes'],0)

    def test_incomplete_run_cannot_mutate_output(self):
        with tempfile.TemporaryDirectory() as directory:
            root=Path(directory);build,oracle,output,rp=self.campaign(root)
            data=json.loads(rp.read_text());data['complete']=False;rp.write_text(json.dumps(data))
            inode=output.stat().st_ino
            with patch.object(D,'ROOT',root),patch.object(D,'BUILD',build), \
                 patch('sys.argv',['deduplicate','--report',str(rp),'--out',str(root/'receipt')]):
                with self.assertRaises(ValueError):D.main()
            self.assertEqual(output.stat().st_ino,inode)

    def test_symlink_and_outside_build_are_rejected(self):
        with tempfile.TemporaryDirectory() as directory:
            root=Path(directory);build,oracle,output,rp=self.campaign(root)
            link=build/'link';link.symlink_to(oracle)
            with patch.object(D,'ROOT',root),patch.object(D,'BUILD',build):
                with self.assertRaises(ValueError):D.regular(link)
                with self.assertRaises(ValueError):D.regular(root/'outside')


if __name__=='__main__':unittest.main()

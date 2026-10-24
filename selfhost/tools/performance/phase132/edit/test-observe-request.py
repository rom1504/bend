#!/usr/bin/env python3
"""Offline parser controls; no compiler or target process is launched."""
import importlib.util
from pathlib import Path
import tempfile
import unittest

spec=importlib.util.spec_from_file_location('observer',Path(__file__).with_name('observe-request.py'))
O=importlib.util.module_from_spec(spec);spec.loader.exec_module(O)


class ObserveTests(unittest.TestCase):
    def test_stat_with_parentheses_and_thread_children(self):
        with tempfile.TemporaryDirectory() as td:
            root=Path(td); p=root/'123';(p/'task/123').mkdir(parents=True);(p/'task/124').mkdir()
            fields=['0']*22;fields[0]='R';fields[11]='7';fields[12]='3';fields[19]='456';fields[21]='13'
            (p/'stat').write_text('123 (worker (name)) '+' '.join(fields))
            (p/'task/123/children').write_text('125 126');(p/'task/124/children').write_text('126 127')
            row=O.process(123,root)
            self.assertEqual(row,dict(pid=123,startTicks=456,rssBytes=13*O.PAGE,userTicks=7,systemTicks=3,children=[125,126,127]))
    def test_missing_or_truncated_process_is_unknown(self):
        with tempfile.TemporaryDirectory() as td:
            root=Path(td);self.assertIsNone(O.process(999,root));(root/'123').mkdir();(root/'123/stat').write_text('123 (gone) R')
            self.assertIsNone(O.process(123,root))


if __name__=='__main__':unittest.main()

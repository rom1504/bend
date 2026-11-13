"""Apply existing exact-publication/rollback controls to the new adapter."""
import importlib.util
from pathlib import Path
import unittest

HERE=Path(__file__).resolve().parent

def load(name,path):
    spec=importlib.util.spec_from_file_location(name,path)
    module=importlib.util.module_from_spec(spec);spec.loader.exec_module(module)
    return module

legacy=load('p183_publication_tests',HERE.parent/'phase183/test_publish_assets.py')
legacy.P=load('p189_publication',HERE/'publish-assets.py')
PublicationTransaction=legacy.PublicationTransaction
if __name__=='__main__':unittest.main()

#!/usr/bin/env python3
"""Check the actual module graph using inherited mocks in an isolated fixture.

Terraform does not override provider blocks configured inside child modules with
a root mock. Copy the unchanged resource/input/output code, retain provider
requirements, and remove only concrete provider configurations from test copies.
"""
from pathlib import Path
import os,shutil,subprocess,tempfile
MODULES=Path(__file__).resolve().parents[2]
EXAMPLE=MODULES/'vpn-ha/examples/gcp-to-gcp'
with tempfile.TemporaryDirectory(prefix='vpn-composition-') as directory:
 root=Path(directory)
 for name in ['router','vpn-ha']:
  target=root/name;target.mkdir()
  for src in (MODULES/name).glob('*.tf'):
   content=src.read_text()
   if src.name=='provider.tf':content=content.split('\nprovider "google"')[0]+'\n'
   assert '\nprovider "google"' not in content, 'Concrete provider escaped fixture isolation'
   (target/src.name).write_text(content)
 work=root/'composition';work.mkdir()
 for src in EXAMPLE.glob('*.tf'):
  content=src.read_text().replace('"../../../router"','"../router"').replace('"../.."','"../vpn-ha"')
  if src.name=='main.tf':
   content=content.replace('module "routers" {','module "routers" {\n providers = { google = google }').replace('module "vpn" {','module "vpn" {\n providers = { google = google }').replace('module "routing" {','module "routing" {\n providers = { google = google }')
  (work/src.name).write_text(content)
 (work/'test-provider.tf').write_text('''terraform {
 required_providers { google = { source = "hashicorp/google", version = "= 8.10.0" } }
}
provider "google" {
 project = "mock-only"
 access_token = "invalid-mock-only-token"
 compute_custom_endpoint = "http://127.0.0.1:9/"
}
''')
 tests=work/'tests';tests.mkdir()
 test=(MODULES/'vpn-ha/tests/fixtures/composition.tftest.hcl.template').read_text().replace('mock_provider "google" {}','mock_provider "google" { alias = "mocked" }').replace('command = apply','command = apply\n providers = { google = google.mocked }')
 (tests/'composition.tftest.hcl').write_text(test)
 env={k:v for k,v in os.environ.items() if not k.startswith(('GOOGLE_','GCLOUD_','CLOUDSDK_','TF_VAR_'))}
 # Even an accidental real provider cannot use ambient ADC/metadata credentials.
 env.update(GOOGLE_OAUTH_ACCESS_TOKEN='invalid-mock-only-token',GOOGLE_APPLICATION_CREDENTIALS=str(root/'no-credentials.json'),TF_INPUT='0',TF_IN_AUTOMATION='1')
 for args in [['init','-backend=false','-no-color'],['validate','-no-color'],['test','-no-color']]:
  result=subprocess.run(['terraform',*args],cwd=work,env=env,text=True,capture_output=True)
  if result.returncode:raise SystemExit(result.stdout+result.stderr)
  if args[0]=='test':print(result.stdout)
 print('Composition verified using mocked providers only.')

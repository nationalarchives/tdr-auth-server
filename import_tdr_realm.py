#!/usr/bin/python3
import subprocess
import os

from update_realm_configuration import update_realm_configuration

env_properties_file = os.environ['KEYCLOAK_CONFIGURATION_PROPERTIES']
host = os.environ['KEYCLOAK_HOST']

update_realm_configuration('/tmp/', env_properties_file)
subprocess.call(['/opt/keycloak/bin/kc.sh', 'start', '--hostname', host, '--proxy', 'edge', '--log-console-output', 'json'])

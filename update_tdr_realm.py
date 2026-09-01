import requests
import json
import sys
import os

from update_realm_configuration import update_realm_configuration

stage_to_url = dict(
    local='http://localhost:8081',
    intg='https://auth.tdr-integration.nationalarchives.gov.uk',
    prod='https://auth.tdr.nationalarchives.gov.uk',
    staging='https://auth.tdr-staging.nationalarchives.gov.uk',
    sandbox = 'https://auth.tdr-sandbox.nationalarchives.gov.uk',
    dev = 'https://auth.tdr-development.nationalarchives.gov.uk'
)

stage: str = sys.argv[1]
update_policy: str = sys.argv[2]
client_secret = os.environ['REALM_ADMIN_CLIENT_SECRET']
env_properties_file = os.environ['KEYCLOAK_CONFIGURATION_PROPERTIES']
base_auth_url = stage_to_url.get(stage)

def get_access_token():
    payload = {
        'client_secret': client_secret,
        'grant_type': 'client_credentials',
        'client_id': 'tdr-realm-admin'
    }
    authentication_request = requests.post(
        f'{base_auth_url}/realms/tdr/protocol/openid-connect/token',
        data=payload
    )
    authentication_data = authentication_request.json()
    access_token = authentication_data['access_token']
    return access_token

def get_realm_data():
    update_realm_configuration('/keycloak-configuration/', env_properties_file)
    with open('/opt/keycloak/data/import/tdr-realm.json', 'r+') as realm:
        realm_data = json.load(realm)
    return realm_data

def generate_partial_import_data(full_realm_data):
    # Keys defined in the Keycloak representation for partial imports:
    # https://www.keycloak.org/docs-api/11.0/rest-api/index.html#_partialimportrepresentation
    partial_import_keys = ["clients", "roles", "groups", "identityProviders", "users"]
    partial_import_data = {"policy": f"{update_policy}"}

    for key in partial_import_keys:
        if key not in full_realm_data:
            continue
        else:
            partial_import_data[key] = full_realm_data[key]
    return partial_import_data

def update_realm():
    full_realm_data = get_realm_data()
    partial_import_data = generate_partial_import_data(full_realm_data)
    token = get_access_token()
    headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': f'bearer {token}'
    }

    # Two REST endpoints to update a Keycloak realm:
    # - PUT /{realm}: updates the top-level information of the realm.
    #                 Any user, roles or client information in the representation are ignored.
    #                 Takes the full realm representation
    # - POST /{realm}/partialImport: Partial import from a JSON file to an existing realm.
    #                 Allows importation of configuration of clients, roles, groups and identity providers
    #                 Depending on the policy set will overwrite, skip or fail for existing resources
    #                 Takes a partial realm representation
    top_level_result = requests.put(
        f'{base_auth_url}/admin/realms/tdr',
        data=json.dumps(full_realm_data),
        headers=headers
    )
    print(f"Top Level Import Response Status: {top_level_result.status_code}")

    partial_result = requests.post(
        f'{base_auth_url}/admin/realms/tdr/partialImport',
        data=json.dumps(partial_import_data),
        headers=headers
    )
    print(f"Partial Import Response Status: {partial_result.status_code}")

update_realm_configuration('/keycloak-configuration/', env_properties_file)
update_realm()

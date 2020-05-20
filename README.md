## TDR Auth server

All of our documentation is stored in the [tdr-dev-documentation](https://github.com/nationalarchives/tdr-dev-documentation) repository.

### Dockerfile
This repository holds the Dockerfile used to build our keycloak server which we will be using for authentication and authorisation. 

### Jenkinsfile
There is a Jenkinsfile build and push this to docker hub. The Jenkinsfile has three stages.
The first two are run in parallel. 

One clones the Home Office's govuk keycloak theme project and builds it.

The other clones a [TNA fork](https://github.com/nationalarchives/keycloak-sms-authenticator-sns) of BEIS' SMS MFA keycloak repo and builds that. The original repo is missing a dependency in the pom which I've added in the fork. 

The output from both of these are stashed and then unstashed in the third stage. They are then used to build the Dockerfile.

### import-realm shell script

The import-realm.sh runs scripts to update the Keycloak json configuration file (which is held in a private repository).

Primarily it injects secret values which cannot be safely stored in the configuration file.

### Configuration file
The standalone-ha.xml is mostly the standard configuration for keycloak with a few changes to get it to work with the load balancer. Some of these are discussed in the keycloak [documentation](https://www.keycloak.org/docs/latest/server_installation/#_setting-up-a-load-balancer-or-proxy)

### Updating Keycloak Configuration json

To update Keycloak with, for example, a new client:
1. Update the Keycloak json configuration file. See README for the tdr-configuration private repository on how to do this.
2. If the change to Keycloak makes use of a new secret value, for example a new client secret:
  * Add the new secret value to the parameter store using Terraform: https://github.com/nationalarchives/tdr-terraform-environments
    
    This ensures that the secret value is stored securely and is not exposed in the code.
  
  * Update the import-realm.sh script to replace the placeholder secret value in the realm-export.json configuration file, with the new secret value set in the Terraform.
3. Run the Jenkins build

Some comment to be deleted
   



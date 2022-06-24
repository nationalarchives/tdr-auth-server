# TDR Auth server

All of our documentation is stored in the [tdr-dev-documentation](https://github.com/nationalarchives/tdr-dev-documentation) repository.

## Dockerfile
This repository holds the Dockerfile used to build our keycloak server which we will be using for authentication and authorisation.

## Dockerfile-update
This is used for an ECS task which is run by the GitHub actions workflow defined in `.github/workflows/update.yml` It updates the realm configuration by calling the `update_tdr_realm.py` Python script.

## Docker Container

The docker container runs with the pre-defined `keycloak` user.

This user is part of the `root` group, but *does not* have root user permissions.

## GitHub actions
There are three actions workflows in `.github/worfklows/`
* test.yml - This runs the typescript tests, typescript linter and scala tests for the event-publisher SPI and the govuk-notify SPI.
* build.yml - This builds the two SPI jars, builds the custom tdr theme and then builds the docker image and tags it with a new version number.
* deploy.yml - This tags the image with the environment tag and restarts the ECS task to deploy the new version. 

## update_realm_configuration.py script

The import_env_realm.py runs scripts to update the Keycloak json configuration files (which are held in a private repository) with TDR environment specific properties and combines the individual realm json into a single json configuration file for import into Keycloak at start up.

## update_client_configuration.py script

The update_env_client_configuration.py script provides functions for updating Keycloak realm client json. 

Primarily it:
 * injects secret values which cannot be safely stored in the configuration file.
 * updates specific json elements based on the environment properties json file provided.
 

## TDR Theme

TDR has its own Keycloak theme: `tdr`

The TDR theme makes use of the standard Keycloak base theme, with specific overrides to the theme resources where required.

The TDR theme styling is a combination of [Gov.UK Design System](https://design-system.service.gov.uk/), with TDR specific overrides. 

It is based on the theme developed by the Home Office: https://github.com/UKHomeOffice/keycloak-theme-govuk 

For full documentation on Keycloak themes see: https://www.keycloak.org/docs/latest/server_development/index.html#_themes

## GovUK Notify Service (SPI)

TDR Keycloak uses GovUK Notify as its default email sender provider.

Each TDR environment has a separate GovUK Notify service defined:
* TDR Intg - service for the integration environment
* TDR Staging - service for the staging environment
* Transfer Digital Records - service for the production environment

The GovUK Notify Services require two secret values that are stored as AWS SSM parameters:
* API Key: this is the key to access the GovUK Notify service
* Template ID: this is the id of the GovUK Notify service email template

Both these AWS SSM parameter *values* need to set manually in the AWS SSM parameter store, as it is not programmatically possible to retrieve these from GovUK Notify

See here for full details about the GovUK Notify service: https://www.notifications.service.gov.uk/

## Configuration
There are two configuration files:
### build.conf
This contains config options that are needed at build time, when the docker image is built. Currently, this defines the database as postgres and enables the custom SPIs.

### keycloak.conf
This defines configuration options used when the server starts. Currently, this is the host name and logging options.

### Keycloak Email Sender Configuration

GovUK Notify is defined as the default email sender in the `build.conf` as `spi-email-sender-provider=govuknotify`

### Requesting access to GovUK Notify Services

Contact a member of the TDR team to request access to the TDR GovUK Notify Services

## Event Publishing Service (SPI)

This is an SPI (Service Provider Interface) that publishes Keycloak events to the notifications SNS topic (`tdr-notifications-{environment}`).

The SNS message is picked up by the `tdr-notification-{environment}` lambda which sends a Slack alert about the triggering Keycloak event. See [TDR notification lambda](https://github.com/nationalarchives/tdr-notifications)

The following events trigger the publishing service:
* When a user is assigned the 'admin' role

### Event Publishing Configuration

The event publishing SPI is defined as an event listener in the `build.conf` as `spi-events-listener-event-publisher-enabled=true`


## Updating TDR Realm Configuration json

A separate GitHub actions workflow is used to update the TDR realm configuration: [TDR Update Auth Server Configuration](https://github.com/nationalarchives/tdr-auth-server/actions/workflows/update.yml)

This is because on container start up, if a realm already exists, its configuration json is ignored. So restarting the container will not update the configuration.

The TDR Auth Server Update Jenkins job updates existing realm configuration using the Keycloak REST APIs: https://www.keycloak.org/docs-api/11.0/rest-api/index.html

Two REST endpoints are used to update a Keycloak realm:
* `PUT /{realm}`: updates the top-level information of the realm.    
  * Takes the full realm representation: https://www.keycloak.org/docs-api/11.0/rest-api/index.html#_realmrepresentation
  * Any user, roles or client information in the representation are ignored.
* `POST /{realm}/partialImport`: Partial import from a JSON file to an existing realm.
  * Takes a partial realm representation: https://www.keycloak.org/docs-api/11.0/rest-api/index.html#_partialimportrepresentation
  * Allows importation of configuration for: `clients`, `roles`, `groups` and `identity providers` only
  * Uses a policy option that controls what behaviour occurs for existing realm resources:
    * `SKIP`: Skips any existing resources and does not update them
    * `FAIL`: Causes the whole import to fail
    * `OVERWRITE`: Overwrites the existing resource
    * **Note**: This option only applies to the partial import


To update Keycloak with, for example, a new client:
1. Update the relevant Keycloak json configuration file (tdr-realm-export.json). See README for the [tdr-configurations](https://github.com/nationalarchives/tdr-configurations#keycloak-configurations-usage) private repository on how to do this.
2. If the change to Keycloak makes use of a new secret value, for example a new client secret:
    * Add the new secret value to the parameter store using Terraform: https://github.com/nationalarchives/tdr-terraform-environments
    
    This ensures that the secret value is stored securely and is not exposed in the code.

    * Update the update_client_configuration.py script to replace the placeholder secret value in the relevant realm json configuration file, with the new secret value set in the Terraform.
3. Run the GitHub actions workflow, selecting the relevant parameter options:
    * `environment`: the TDR environment to be updated
    * `update-policy`: what behaviour to apply if a resource already exists. See notes above regarding the possible options.
4. Once the GitHub actions workflow has been completed log into the Keycloak instance that has been updated as an administrator, and check the expected changes have been made.

## Running Locally

To run, build and test locally:

1. Copy the [tdr-realm-export.json](https://github.com/nationalarchives/tdr-configurations/blob/master/keycloak/tdr-realm-export.json) from the tdr-configurations repository into the tdr-auth-server directory
2. Navigate to the cloned repository: `$ cd tdr-auth-server`
3. Build the TDR theme:
    * If npm is not installed install [nvm](https://github.com/nvm-sh/nvm#intro) in root directory
    * Once nvm is installed run: `[root directory] $ nvm install 16.5.0`
    * Run the following commands in the root directory:  `[root directory] $ npm install` and `[root directory] $ npm run build-theme`
        * this will compile the theme sass, copy the static assets to the theme `resource` directory and compile the typescript for WebAuthn.
4. Build both spi jars:
    * From the root directory run the following command: `sbt assembly`
    * This will generate the jar for the GovUK Notify service and the Event Publisher service
5. Update the start script. In the `import_tdr_realm.py` replace:

    `subprocess.call(['/opt/keycloak/bin/kc.sh', 'start'])` with

    `subprocess.call(['/opt/keycloak/bin/kc.sh', 'start-dev', '--import-realm'])`

   Don't commit these changes.
6. Build the docker image locally:
    * Run the docker build command: `[root directory] $ docker build -t [account id].dkr.ecr.[region].amazonaws.com/tdr-auth-server:[your build tag] .`
7. Run the local docker image:
    ```
    [root directory] $ docker run -d --name [some name] -p 8081:8080 \
    -e KEYCLOAK_ADMIN=admin -e KEYCLOAK_ADMIN_PASSWORD=admin -e KEYCLOAK_IMPORT=/tmp/tdr-realm.json \
    -e REALM_ADMIN_CLIENT_SECRET=[some value] -e CLIENT_SECRET=[some value] -e BACKEND_CHECKS_CLIENT_SECRET=[some value] \
    -e REPORTING_CLIENT_SECRET=[some value] \
    -e USER_ADMIN_CLIENT_SECRET=[some value] \
    -e KEYCLOAK_CONFIGURATION_PROPERTIES=[env]_properties.json \
    -e FRONTEND_URL=[home page url] \
    -e GOVUK_NOTIFY_TEMPLATE_ID=[govuk notify service template id] \
    -e GOVUK_NOTIFY_API_KEY=[govuk notify service api key] \   
    -e DB_VENDOR=h2 \
    -e SNS_TOPIC_ARN=[Tdr notifications topic arn] \
    -e TDR_ENV=[Tdr environment] \
    -e KEYCLOAK_HOST=[Keycloak host] \
    [account id].dkr.ecr.[region].amazonaws.com/tdr-auth-server:[your build tag]
    ```
    * `KEYCLOAK_ADMIN`: root Keycloak user name
    * `KEYCLOAK_ADMIN_PASSWORD`: password for the root Keycloak user
    * `KEYCLOAK_IMPORT`: Location of the generated Keycloak TDR realm json file that contains the configuration for the TDR realm
    * `REALM_ADMIN_CLIENT_SECRET`: tdr realm admin client secret value
    * `CLIENT_SECRET`: tdr client secret value
    * `BACKEND_CHECKS_CLIENT_SECRET`: tdr-backend-checks client secret value
    * `USER_ADMIN_CLIENT_SECRET`: tdr user admin client secret value
    * `KEYCLOAK_CONFIGURATION_PROPERTIES`: json file containing specific Keycloak configuration to a TDR environment
    * `FRONTEND_URL`: TDR application home page URL
    * `GOVUK_NOTIFY_TEMPLATE_ID`: the GovUK Notify service template id secret value to be used
    * `GOVUK_NOTIFY_API_KEY`: the GovUK Notify service api key secret value to be used
    * `DB_VENDOR`: the type of database to use. In the dev environment, we use Keycloak's embedded H2 database
    * `SNS_TOPIC_ARN`: the AWS topic arn to publish event messages to
    * `TDR_ENV`: the name of the TDR environment where Keycloak is running
    * `KEYCLOAK_HOST`: the host for keycloak for example localhost:8081
8. Navigate to http://localhost:8081/auth/admin
9. Log on using the `KEYCLOAK_ADMIN_PASSWORD` and `KEYCLOAK_ADMIN` defined in the docker run command

To log into the running docker container with a bash shell: `$ docker exec -it [your container name] bash`

Make changes to the realm export json file as necessary to test new configurations.

Tip: the quickest way to view the TDR login theme (that is displayed to TDR users) is to (while logged into the console):
1. move your cursor to the top left (below the keycloak logo), Until it reveals the "Master" realm
2. select the "Master" Realm
3. go to the "Themes" tab
4. under "login theme", select "tdr" from the dropdown menu
5. sign out (click "Admin" on the top right and select "Sign out")

### Optionally Run Event Publishing to AWS SNS Topic

If you are working on the event publishing you can optionally send messages to an AWS SNS topic.

To run the event publishing:

1. When setting the environment variables for running the local docker image ensure the `SNS_TOPIC_ARN` value is the ARN of the topic you wish to publish to.
2. Once the local Keycloak container is running log into it: `$ docker exec -it [your container name] bash`
3. In the container run the following commands:
   * Navigate to the home directory: `[docker container] $ cd ~/`
   * Create AWS credential directory: `[docker container ~/] $ mkdir .aws`
   * Navigate to the created `./aws` directory: `[docker container ~/] $ cd /.aws`
   * Retrieve credentials from AWS SSO for the environment that will give access to the SNS topic
   * Add AWS credentials file to the AWS credential directory. Replace `placeholder value` with the retrieved credentials:
  ```
    [docker container ~/.aws directory] $ cat << EOF > credentials
    [default]
    aws_access_key_id=placeholder value
    aws_secret_access_key=placeholder value
    aws_session_token=placeholder value
    EOF
  ```
   * Check the `./aws/credentials` file has been created and contains the correct credentials.
   * Note as with all AWS SSO credentials these credentials are time limited and will need to be reset periodically, by repeating the last two commands.
   
   Alternatively you can add the necessary permissions to access the SNS topic arn by adding them as environment variables when starting the Keycloak container:
   * Make sure you have the permission variables set locally
   * Add the following environment variables to the Keycloak container start command:
   ```
    -e AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID \
    -e AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY \
    -e AWS_SESSION_TOKEN=$AWS_SESSION_TOKEN
   ```
4. Log into the locally running Keycloak (http://localhost:8081)
5. Go to the realm where you want to publish the event from.
6. Navigate to the events config tab: "Events" > "Config". Ensure the following configuration:
   * *Event Listeners*: includes the `event-publisher`
   * *Login Events Settings* > *Save Events*: `ON`
   * *Admin Events Settings* > *Save Events*: `ON`
   * *Admin Events Settings* > *Include Representation*: `ON`
7. Trigger the required event in Keycloak
8. Check the relevant SNS topic / cloudwatch logs that message has been sent.

### Update Realm Configuration Locally

To update the realm configuration on the locally running Keycloak instances:
1. Add the Keycloak configuration json file to the root of the project: tdr-realm-export.json
2. Make necessary changes to the configuration json
3. Add the following environment variables:
    * `REALM_ADMIN_CLIENT_SECRET`: tdr realm admin client secret value
    * `CLIENT_SECRET`: tdr client secret value
    * `BACKEND_CHECKS_CLIENT_SECRET`: tdr-backend-checks client secret value
    * `USER_ADMIN_CLIENT_SECRET`: tdr user admin client secret value
    * `KEYCLOAK_CONFIGURATION_PROPERTIES`: json file containing specific Keycloak configuration to a TDR environment
4. Run the following python command:

```
[location of repo] $ python update_tdr_realm.py local [update policy option: OVERWRITE/SKIP/FAIL]
```

### Update TDR Theme Locally

**Note:** The TDR theme sass is used by the TDR Transfer Frontend. When updating the sass for the theme, ensure that any changes are also implemented in the tdr-transfer-frontend repo: https://github.com/nationalarchives/tdr-transfer-frontend/tree/master/npm/css-src/sass
* This includes any changes to the `.stylelintrc.json`

1. Rebuild the image locally and run. `docker build -t [account id].dkr.ecr.[region].amazonaws.com/tdr-auth-server:[your build tag] .`
2. Make necessary changes to the TDR theme (freemarker templates/sass/static resources)
3. Run following command from the root directory: `[root directory] $ npm run build-local --container_name=[name of running container]`
4. Refresh the locally running Keycloak pages to see the changes.
5. Repeat steps 3 to 5 as necessary.

### Updating Emails

There are two components to consider when making changes to emails that Keycloak sends to users:
* the GovUK Notify Spi contained in the govuk-notify-spi directory
* the GovUK Notify template contained within the GovUK Notify service

Parameters from Keycloak to the GovUK template are passed using the personalisation Map in the NotifyEmailSenderProvider 

The key in the personalisation Map corresponds to the name of the personalisation variable defined in the template, for example: `((keycloakMessage))`

1. Make the necessary changes locally and build and run the Keycloak docker image locally
2. Make any necessary changes to the GovUKNotify TDR Intg service
 * this can be done by making changes to the existing keycloak template, or by creating a new test template and passing the test template's id in the docker `run` command environment variable: `GOVUK_NOTIFY_TEMPLATE_ID`
3. Deploy the new changes to Intg environment
4. Before deploying to each environment ensure any GovUK Notify template changes are made to the template in GovUK Notify service for the TDR environment:
 * TDR Intg
 * TDR Staging
 * Transfer Digital Records
 
#### Testing from the command line with sbt and npm

The tests should be run from the root directories using the subproject name.
`sbt govUkNotifySpi/test`
`sbt eventPublisherSpi/test`

You can also run both sets of tests by running `sbt assembly` from the root of the project.

There are tests for the login theme typescript which can be run in the root directory using `npm test` 

### Overriding default text

The emails and the login page have a file called `messages_en.properties` in the `/messages` directory of each. In this `messages_en.properties` file, you can override the default Keycloak text. 
Each message has an associated key/variable

#### How to find each messages key/variable

If not already in the docker container, run `docker exec -it keycloak bash`

1. Once in the container, run this command `cd opt/jboss/keycloak/themes/base/`

2. You will be presented with these 4 directories:

   1. account
   2. admin
   3. email
   4. login

3. `cd` into the one that interests you e.g. `cd account`

4. `cd` into the `messages` directory

5. run this command `cat messages_en.properties` to view the contents of the file

Once you have identified the line that you'd like to edit, copy and paste it into the messages `messages_en.properties`

## Databases

Keycloak uses a different database depending on whether it's running locally or on ECS. Local development uses the internal H2 database on the docker image. When it's running on ECS, it uses a postgresql RDS instance defined [here](https://github.com/nationalarchives/tdr-terraform-environments/blob/master/modules/keycloak/database.tf) 

## Sending Email Locally

In order to get emails working locally i.e. to test reset email we need to switch to prod mode.

1. Undo any changes in the `import_tdr_realm_py`
2. Update the start script. In the `import_tdr_realm.py` replace:

   `subprocess.call(['/opt/keycloak/bin/kc.sh', 'start'])` with

   `subprocess.call(['/opt/keycloak/bin/kc.sh', 'start', '--import-realm'])`
3. run `docker network create keycloak-network`
4. run `docker run --name keycloak-db --net keycloak-network -e POSTGRES_PASSWORD=password -e POSTGRES_USER=keycloak -e POSTGRES_DB=keycloak -d -p 5432:5432 postgres`
5. Add the line `RUN keytool -genkeypair -storepass password -storetype PKCS12 -keyalg RSA -keysize 2048 -dname "CN=server" -alias server -ext "SAN:c=DNS:localhost,IP:127.0.0.1" -keystore conf/server.keystore` in  the `Docker` file underneath `WORKDIR /opt/keycloak` line
6. Run the docker build command: `[root directory] $ docker build -t [account id].dkr.ecr.[region].amazonaws.com/tdr-auth-server:[your build tag] .`
7. Alter the docker run command to `docker run  --rm --name keycloak --net keycloak-network -p 8081:8080 -p 8443:8443 -e KC_DB_URL_HOST=keycloak-db -e KC_DB_USERNAME=keycloak -e KC_DB_PASSWORD=password -e KEYCLOAK_HOST=localhost:8443`
8. Navigate to https://localhost:8443 and ignore the warnings from your browser.

#### Troubleshoot for sending email locally

If you want to make changes to the themes whilst in prod mode add these lines to the `keycloak.conf`
```
spi-theme-cache-themes=false
spi-theme-cache-templates=false
spi-theme-static-max-age=-1
```
If you are connecting the frontend to your keycloak instance ensure you set the `AUTH_URL` to
`AUTH_URL=http://localhost:8081` and not `https://localhost:8443`.
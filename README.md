**This is a work in progress. It is very much not complete, the final approach or not even necesserily a good idea yet!**

# Postal

This repository contains everything you need to start using Postal straight away on your own servers.

## Getting started

1. Install Git, Docker and docker-compose. You should follow your own guidelines to do this.

2. Download/clone this repository

   ```
   mkdir -p /opt/postal
   git clone https://github.com/postalhq/docker-compose /opt/postal
   cd /opt/postal
   ```

3. Start the database components

   ```
   docker-compose --profile db up -d
   ```

4. Generate your initial configuration

   ```
   # command to do this needs to follow. it can be run through the app but
   # the content's isn't suitable for docker-compose and permissions are a
   # bit of a message. potentially, we can just have a script within this
   # repo that can generate this rather than requiring anything from postal
   # itself.
   docker-compose run bootstrap_config
   ```

5. Update your configuration. Look through the config files and make any updates
   as appropriate.

   - Connection details
   - DNS hostnames (which also need configuring)
   - Secrets

6. Initialize the database

   ```
   docker-compose run init
   ```

7. Run the rest of the application

   ```
   docker-compose --profile postal up -d
   ```

8. Go to the web interface

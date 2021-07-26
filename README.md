# Installing Postal

This repository contains everything you need to start using Postal straight away on your own servers. Follow these instructions to get started quickly. The purpose of this guide is to get you up and running as quickly as possible. We *strongly* recommend you use secure passwords wherever they're used.

## Service dependencies

Postal has a few dependencies on external services which you will need to provide for it. How you do this is entirely up to you. In this example, we're simply going to start the services from Docker containers and connect to them. This is not required (nor recommended) for production installations.

### MariaDB

MariaDB is used to store all mail and configuration data for your installation. It's the core to the whole thing working well. We recommend installing a nicely tuned and replicated database for all installations. If you use a small database server with large mail volume, you will not have a nice time.

```
docker run -d \
   --name postal-mariadb \
   -p 127.0.0.1:3306:3306 \
   --restart always \
   -e MARIADB_DATABASE=postal \
   -e MARIADB_ROOT_PASSWORD=postal \
   mariadb
```

This will start a MariaDB installation on port 3306 on your server. You can connect to this using the credentials provided above. Postal needs access to create and delete databases so, in this example, we will use the `root` user.

### RabbitMQ

RabbitMQ is responsible for dispatching messages between different processes - in our case, our workers. As with MariaDB, there are numerous ways for you to install this. For this guide, we're just going to run a single RabbitMQ worker.

```
docker run -d \
   --name postal-rabbitmq \
   -p 127.0.0.1:5672:5672 \
   --restart always \
   -e RABBITMQ_DEFAULT_USER=postal \
   -e RABBITMQ_DEFAULT_PASS=postal \
   -e RABBITMQ_DEFAULT_VHOST=postal \
   rabbitmq:3
```

## Postal

Once you have your services running, you can proceed to start Postal. To begin, clone this repository to somewhere on your computer.

```
git clone https://github.com/postalhq/install /opt/postal/install
```

### Configuration

Before you can start to run any processes, you'll need some configuration. This repository contains a script that will bootstrap a config directory by creating appropriate keys and config files. You can place this wherever you want on your system.

```
cd /opt/postal/install
./bootstrap-config.sh /opt/postal/config
```

Once this has completed, go and open up `/opt/postal/config/postal.yml` and replace any values as you see fit. The most important thing you'll need to change is the DNS configuration. For details on how to configure this, see the [DNS documentation](https://github.com/postalhq/install/blob/main/DNS.md).

### Docker Compose

Postal has a few processes that need to run in order to function. Each of these processes can (and should) be run within containers. To make getting started as easy as possible, this repository contains a `docker-compose.sh` file which does the heavy lifting. However, if you want full control, you can use this as a template for running you own processes using whatever technology you fancy.

### Initializing the database

Before you can do anything, you need to initialize the database schema and create your initial user. You can do this using the commands below.

```
cd /opt/postal/install
docker-compose run init_db
docker-compose run make_user
```

### Running processes

There are a few processes that need to be running.

* A web server (`web`)
* A SMTP server (`smtp`)
* A worker (`worker`)
* A cron process (`cron`)
* A message requeueing process (`requeuer`)

The Docker Compose file includes configuration for all of these. For simplicity, we assume you are running your installation on a dedicated server and run all processes using the host's networking. This allows for

```
cd /opt/postal/install
docker-compose up -d
```

### Upgrading

If there is a new release of Postal, you can upgrade to the latest version by simply running the following:

```
docker-compose pull
docker-compose up -d
```

### Scaling up

If you need to add additional capacity to your installation, the main component you can use to scale horizontally is the worker process. If you do this, you will need to make sure you don't create a bottleneck at your database - that may also need scaling up appropriately.

```
docker-compose up -d --scale worker=4
```

### Logging

All logs are written to STDOUT and STDERR for the running containers.

### Updating configuration

The configuration directory that you created earlier should be mounted into the containers at `/config`. There are a few things to note:

* If you need to reference another config file from `postal.yml`, you should remember that you will need to use paths like `/config/file.pem` rather than the path on the host system.

* You will need to restart Postal for most changes.

### Proxying web traffic

It is recommended to proxy web traffic on the host to your actual web server. This should handle SSL termination. We recommend using something like [Caddy](https://caddyserver.com) for this. When you enable this, you can update the bind address for the Postal web server in the `postal.yml` configuration file.

### Putting SMTP server on port 25

The default configuration runs the SMTP server on port 2525. If you wish to receive incoming email to your host, you will need to also listen on port 25. One of the easier ways to achieve this is to use an iptables NAT redirect rule.

```
sudo iptables -t nat -A PREROUTING -p tcp --dport 25 -j REDIRECT --to-port 2525
```

You will need to ensure that this persists on boot. The technique for doing this will vary based on operating system.

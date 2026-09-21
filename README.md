# Postal Installation Tools

This repository contains the tools needed to quickly get started with Postal.

For full details on how to use it [read the documentation](https://docs.postalserver.io).

## Instralling pre-requisites

There are a number of pre-requisites needed to run Postal. These are detailed [in the documentation](https://docs.postalserver.io/getting-started/prerequisites). If you're feeling a bit lazy (or just doing a lot of testing) , we have a couple of scripts which you can use to install everything needed.

**Note:** these will install database services with insecure passwords so shouldn't be used as-if for production environments.

For Postal v2 you can use the following:

```bash
curl https://raw.githubusercontent.com/postalserver/install/main/prerequisites/install-ubuntu.v2.sh | bash
```

For Postal v3 you can use the following:

```bash
curl https://raw.githubusercontent.com/postalserver/install/main/prerequisites/install-ubuntu.v3.sh | bash
```

## Configuration

`postal bootstrap <hostname>` writes `/opt/postal/config/postal.yml`. The generated
file lists **every** parameter supported by Postal: values that have a sensible
default are set explicitly, and parameters that have no default are left commented
out so you only uncomment the ones you need. A random Rails secret key is generated
and the example hostname is replaced with the hostname you provide.

When it finishes, bootstrap prints a summary of the SMTP server's TLS/SSL
configuration.

### Changing the database port

`main_db.port` and `message_db.port` are written explicitly (default `3306`). If
another MySQL/MariaDB service already listens on `3306` on the same host, change
both values - for example to `3307` - and update the MariaDB container's published
port to match.

## TLS for the SMTP server

Postal will only offer TLS if it is given a certificate and a private key. Both the
generated `postal.yml` and the container templates expect them in the config
directory:

```yaml
smtp_server:
  tls_enabled: true
  tls_certificate_path: /config/smtp.cert
  tls_private_key_path: /config/smtp.key
```

`/opt/postal/config` is mounted into every container at `/config`, so placing
`smtp.cert` and `smtp.key` in `/opt/postal/config` is enough and no container
changes are needed.

### Using certificates stored elsewhere

If your certificates live outside the config directory (for example those issued by
acme.sh), mount them with a Docker Compose override file. An example is provided:

```bash
cp examples/docker-compose.override.yml /opt/postal/install/docker-compose.override.yml
```

Then set the certificate and key source paths inside it and apply the change with
`postal restart`.

Compose merges an override file automatically, but only with the base file of the
matching name:

| base file            | override file                 |
|----------------------|-------------------------------|
| `docker-compose.yml` | `docker-compose.override.yml` |
| `compose.yaml`       | `compose.override.yaml`       |

This installer generates `docker-compose.yml`, so use `docker-compose.override.yml`.
Override files are not touched by `postal set-version` or `postal upgrade` (only
`docker-compose.yml` is rewritten), so they survive upgrades.

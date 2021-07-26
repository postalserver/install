# DNS for Postal

To work properly, you'll need to configure a number of DNS records for your Postal installation. Review the table below and create appropriate DNS records on your DNS server. You will need to enter the record names you choose in your `postal.yml` configuration file.

For this documentation we will assume you have allocated some IP addresses:

* `192.168.1.3` - IPv4 address for management, SMTP and other traffic
* `192.168.1.4` - IPv4 address for the "fast" web server (used for tracking)
* `2a00:1234:abcd:1::3` - IPv6 address for management, SMTP and other traffic
* `2a00:1234:abcd:1::4` - IPv6 address for the "fast" web server (used for tracking)

We will assume that you want to set up everything on the `mail.yourdomain.com` domain.

----

* **A Records** - you'll need these records for accessing the API, management interface & SMTP server.

  ```
  mail.yourdomain.com.         IN    A    192.168.1.3
  mail.yourdomain.com.         IN    AAAA 2a00:1234:abcd:1::3
  ```

* **SPF Record** - you can configure a global SPF record for your mail server which means domains don't need to each individually reference your server IPs. This allows you to make changes in the future.

  ```
  spf.mail.yourdomain.com.     IN    TXT   "v=spf1 ip4:192.168.0.0/28 ip6:2a00:1234:abcd:1::/64 ~all"
  ```

* **Return Path** - the return path domain is the default domain that is used as the `MAIL FROM` for all messages sent through a mail server. You should add DNS records as below.

  ```
  rp.mail.yourdomain.com.      IN    A     192.168.1.3
  rp.mail.yourdomain.com.      IN    AAAA  2a00:1234:abcd:1::3
  rp.mail.yourdomain.com.      IN    MX    10 mail.yourdomain.com
  rp.mail.yourdomain.com.      IN    TXT   "v=spf1 a mx include:spf.mail.yourdomain.com ~all"
  ```

  In addition to these, you'll need to enter a DKIM record. This differs depending on your installation. When the installation is initialised a key will be generated automatically. You can see the appropriate value for this record by running `postal default-dkim-record` on the host.

  ```
  postal._domainkey.rp.mail.yourdomain.com.      IN    TXT   "v=DKIM1; t=s; h=sha256; p=MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAzipajyThkwNmZs0cBjghowttXe1FhxplkBljpk90tzCfkFWJ+QHsUCNGmsFXhRALBol8cC4YHks5R9cjvGsphEM8C4jV2Nef5TxofAXuOpV5tbI0H3pBQY1cmP6I82VDAchsmfADCW/3XIFCPpYvnRFVlDnEQcuk4Ghl9LarhCZQqP8x7b38sPV6fcTrWL0HnNxEGAxRDiNWzGD1nEkp/m1o4STC7H8NvDbuZGkopmciDEE8cDxTbHGv7KRd72W5JewEx43nbtFUOEiv6D/otwT1xN2XF3JkOBtD3VcH+KB/zB6wwxJptNamw5kunskUoWwZwN488CpxxRF5tKPhCwIDAQAB;"
  ```

* **Route domain** - if you wish to receive incoming e-mail by sending messages directly to created routes in Postal, you'll need to configure a domain for this just to point to your MX servers.

  ```
  routes.mail.yourdomain.com.   IN    MX    10 mx.mail.yourdomain.com
  ```

* **Tracking domain** - to configure click & link tracking you'll need to configure a domain that will be used in rewritten links. This will point to the second IP address on your host. The second IP is used to distinguish traffic which is aimed at the management web server and that destined for the tracking web server.

  ```
  track.mail.yourdomain.com.    IN    A     192.168.0.4
  track.mail.yourdomain.com.    IN    AAAA  2a00:1234:abcd:1::4
  ```

----

In your `postal.yml` you should have something like that looks like the below,.

```yaml
dns:
  mx_records:
    - mail.yourdomain.com
  smtp_server_hostname: mail.yourdomain.com
  spf_include: spf.mail.yourdomain.com
  return_path: rp.mail.yourdomain.com
  route_domain: routes.mail.yourdomain.com
  track_domain: track.mail.yourdomain.com
  dkim_identifier: postal
  domain_verify_prefix: postal-verification
  custom_return_path_prefix: psrp
```

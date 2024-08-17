# Home Assistant Add-on: GandiDnsNg

## Installation

Follow these steps to get the add-on installed on your system:

1. Navigate in your Home Assistant frontend to **Supervisor** -> **Add-on Store**.
2. Find the "GandiDnsNg" add-on and click it.
3. Click on the "INSTALL" button.

## How to use

```yaml
api_auth_scheme: [Bearer|Apikey]
api_key: GANDI_API_KEY
domain: my-awesome-domain.rocks
reccords:
  - sub1
  - sub2
```
The api_auth_scheme should be `Bearer` (actual auth scheme) or `Apikey` (legacy auth scheme).
With this configuration, the add-on will update `sub1.my-awesome-domain.rocks` and `sub2.my-awesome-domain.rocks` dns reccords for your domain zone on your Gandi account. If you just want to update `my-awesome-domain.rocks` add `@` as reccord.

## Actual limitation !
Be careful, this add-on is using V5 gandi API and the function https://api.gandi.net/docs/livedns/#v5-livedns-domains-fqdn-records-rrset_name when updating a record, the api, remove ALL entries for this record in the DNS zone file. Eg: In your @ record, you can have MX records configured. Updating A record will erase MX records.

This add-on is not compatible with ipv6 and is theoriticaly useless for ipv6.


# Vault for sample app

## run vault
``` bash
./vault server -config=./config/vault.hcl
```

## init vault. only once after DB is reset.
``` bash
export VAULT_ADDR=http://127.0.0.1:8200
./vault operator init
```
- you will get unseal keys and root token like below. save them in safe place.
	```
	Unseal Key 1: G4n1dca3C7t/mpzAmAA2CM1bz6xrUrgsCwU3dINcBGcJ
	Unseal Key 2: OZPVGkltqpLmvHnP9QxWxyZ9H4rGAeuJU7lUa39I5Cpg
	Unseal Key 3: wypIR03lYUbUOREEC4H4kU9/NH01SnVU7BEBXcr75Rrj
	Unseal Key 4: VA3CKC4sHC+lMf9uXuj3m+RXkz08imoxrI17nOuAIRR1
	Unseal Key 5: Y4Xf11HCARw+xM0hEI+DzgnBB1DGnzSBT0yLicJ4rufy

	Initial Root Token: s.qnUWa9meIay29NKtwxdL8nUe
	```

## ready
``` bash
export VAULT_ADDR=http://127.0.0.1:8200
./vault operator unseal # 3 times
./vault login <root token>
```

## use KV
### ready. 1 time after DB reset.
```bash
./vault secrets enable -path=test1 kv
./vault secrets enable -path=test2 -version=2 kv
```
### test
``` bash
# kv ver.1
./vault write test1/test11 foo=bar
./vault read [-format=json|yaml|table|pretty] test1/test11
./vault read -field=<field> test1/test11
# kv ver.2
./vault kv put test2/test22 foo=bar
./vault kv get [-format=json|yaml|table|pretty] test2/test22
./vault kv get -field=<field> test2/test22
./vault kv patch test2/test22 hello=world	# append another kv to the path.
```

## policy and token
### create a policy
``` bash
./vault policy write <policy name> <policy file>
./vault policy list
./vault policy read <policy name>
```
### create a token for a policy
``` bash
./vault token create -policy="<policy name>" [-format=json|yaml|table|pretty]
```
* without 'VAULT_TOKEN' variable, most recent token is used for the command even in other session in the same machine. *
	``` bash
	VAULT_TOKEN='<token>' ./vault ...
	# or
	export VAULT_TOKEN='<token>'
	./vault ...
	```

## transit
### ready
- make a policy(optional)
	``` hcl
	path "transit/encrypt/orders" {
		capabilities = [ "update" ]
	}

	path "transit/decrypt/orders" {
		capabilities = [ "update" ]
	}
	```

- make key ring
	```bash
	./vault secrets enable transit
	./vault write -f transit/keys/orders
	```

- make a token(optional)

### encrypt & decrypt
``` bash
./vault write transit/encrypt/orders plaintext=$(base64 <<< "4111 1111 1111 1111")
#Key            Value
#---            -----
#ciphertext     vault:v1:FxSceBj6PvzcLtcts1Z30LxR69YwEmm9cL/iHFSrEjcoY39d0F9LaFL/TuXH2+Nl
#key_version    1
./vault write transit/decrypt/orders cyphertext="vault:v1:FxSceBj6PvzcLtcts1Z30LxR69YwEmm9cL/iHFSrEjcoY39d0F9LaFL/TuXH2+Nl"
#Key          Value
#---          -----
#plaintext    NDExMSAxMTExIDExMTEgMTExMQo=
base64 --decode <<< NDExMSAxMTExIDExMTEgMTExMQo=
#4111 1111 1111 1111
```

### rotate the encryption key
``` bash
./vault write -f transit/keys/orders/rotate	# with root token
./vault write transit/rewrap/orders ciphertext="vault:v1:FxSceBj6PvzcLtcts1Z30LxR69YwEmm9cL/iHFSrEjcoY39d0F9LaFL/TuXH2+Nl"	# with root token
#Key            Value
#---            -----
#ciphertext     vault:v2:IP3eqm1wVgtZCKTsRhRm7i19MGr90X2J+0ofpu3ocSgFqehTcbmQrtzLX8ZpxP1F
#key_version    2
./vault write transit/decrypt/orders ciphertext="vault:v2:IP3eqm1wVgtZCKTsRhRm7i19MGr90X2J+0ofpu3ocSgFqehTcbmQrtzLX8ZpxP1F"
Key          Value
---          -----
plaintext    NDExMSAxMTExIDExMTEgMTExMQo=
```

## database credential
1. enable database secrets engine
	``` bash
	./vault secrets enable database
	```
2. config DB connection
	```bash
	./vault write database/config/testdb plugin_name=mysql-database-plugin connection_url="{{username}}:{{password}}@tcp(127.0.0.1:13306)/" allowed_roles="vaultrole" username="vaultroot" password="qwer12#$"
	```
3. config role to make DB credentials
	```bash
	./vault write database/roles/vaultrole db_name=testdb creation_statements="SET ROLE vaultrole; CREATE USER '{{name}}'@'%' IDENTIFIED BY '{{password}}'; GRANT SELECT,INSERT,UPDATE ON testdb.* TO '{{name}}'@'%';" default_ttl="1h" max_ttl="24h"
	```
4. change vault user's db credential(recommended)
	```bash
	./vault write -force database/rotate-root/testdb
	```
5. make DB credentials
	```bash
	./vault read database/creds/vaultrole
	```
6. list DB credentials
	```bash
	./vault list sys/leases/lookup/database/creds/vaultrole
	```
7. revoke DB credential
	```bash
	./vault lease revoke database/creds/vaultrole/dElgGIagos6MjLyiB6l7mjc9
	```
8. renew DB credential.
	```bash
	./vault lease renew database/creds/vaultrole/dElgGIagos6MjLyiB6l7mjc9
	```
	1. Warning occurs if max_ttl would be reached by the renew command.
		```bash
		$ ./vault lease renew --format=json  database/creds/vaultrole/fQFTHAlW7lAMIDiPRhKngu1r
		> {
		>	"request_id": "f528ea49-740e-c0b2-8bc6-1badbfcc3187",
		>	"lease_id": "database/creds/vaultrole/fQFTHAlW7lAMIDiPRhKngu1r",
		>	"lease_duration": 2,
		>	"renewable": true,
		>	"data": null,
		>	"warnings": [
		>		"TTL of \"1m\" exceeded the effective max_ttl of \"2s\"; TTL value is capped accordingly"
		>	]
		>}
		```


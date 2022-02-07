# Vault for sample app

## run vault
``` bash
./vault server -config=./config/vault.hcl
```

## init vault. only once after DB is reset.
``` bash
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

## in your testing terminal...
``` bash
export VAULT_ADDR=http://127.0.0.1:8200
./vault operator unseal # 3 times
./vault login <root token>
./vault secrets enable -path=test1 -version=2 kv	# not necessary if DB is not reset.
./vault kv put test1/test11 foo=bar
./vault kv get [-format=json|yaml|table|pretty] test1/test11
./vault kv get -field=<field> test1/test11
./vault kv patch test1/test11 hello=world	# append another kv to the path.
```

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
  Unseal Key 1: kYjC9Ut6iCi9T0OsBFCY1Gb6gP68RgH+sj6PR4jLDsx0
  Unseal Key 2: bua5Y0Wh5HyVUY/h+QLg50xB7IAenMdl2jQ7NE8t5KE+
  Unseal Key 3: Ys1jn7RTSl9/vdFGk2bXb0q5r4WjXnlks4wZSDAiZhUx
  Unseal Key 4: 1uoNT6UuuQTKSr1PfQX7nObUiuwrd7fOJ+ytQMym6yH0
  Unseal Key 5: Ox3CVHn0r/KTWUoKJznyBXwWlLFKukXuQtk3DJ0TEKG3

  Initial Root Token: s.BysRnyqLYYGYS4hDJheZz5ew
  ```

## in your testing terminal...
``` bash
export VAULT_ADDR=http://127.0.0.1:8200
./vault operator unseal # 3 times
./vault login <root token>
./vault secrets enable -path=test1 kv   # not necessary if DB is not reset.
./vault write test1/test11 foo=bar
./vault read [-format=json|yaml|table|pretty] test1/test11
./vault read -field=<field> test1/test11
```

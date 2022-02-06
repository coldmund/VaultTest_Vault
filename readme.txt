./vault server -config=./config/vault.hcl
export VAULT_ADDR=http://127.0.0.1:8200

# only once
./vault operator init

./vault operator unseal (3 times)
./vault login <root token>
./vault secrets enable -path=test1 kv
./vault write test1/test11 foo=bar
./vault read [-format=json|yaml|table|pretty] test1/test11
./vault read -field=<field> test1/test11

# policy
./vault policy write ./config/app_policy.hcl
./vault token create -field token -policy=app_policy
# --> s.New30qzAp8dTZdWOcucSwyPc
export VAULT_TOKEN=s.New30qzAp8dTZdWOcucSwyPc
./vault write test1/cred password="qwer1234"
./vault read test1/cred --> 403 error
./vault write test1/ban asdf="qwer" --> 403 error
    # with root token
    ./vault read test1/cred --> OK
    ./vault write test1/ban asdf="qwer" --> OK
./vault read test1/ban --> OK

Unseal Key 1: pfN18x3Chkfjnhf1bNs7J7byCbsDWbQUsL0+iNy1fXzk
Unseal Key 2: +XeZgHrhB8QuCy/d7Prb5dTkysvf4CYtgogkLgREdG8F
Unseal Key 3: gocZjlZrFX7WVITJt+NX8uh4R/JG4wN7k4bcf/ZAweQb
Unseal Key 4: 98r39ocnOMP4lfhpcvF8UEiBtLz9HZzXn2Rj4Esc7aql
Unseal Key 5: keEPS7sJ8u954ze9rF/eMpJVsb41i191yMelxYhKT+1X

Initial Root Token: s.A7HqchrsmtZlh3oDUD2xoKtM

ui = true ## or false

# MySQL backend config
storage "mysql" {
  ha_enabled = "true"
  address = "127.0.0.1:3307"
  username = "user"
  password = "qwer12#$"
  database = "vaultdb"
  table = "vaulttable"
  #plaintext_connection_allowed = "true" #non-TLS mysql
  #path to CA.pem to verify MySQL SSL
  #tls_ca_file = "<path-to-mysql-ca-pem>" 
}

# Vault server listen configuration
listener "tcp" {
  address       = "0.0.0.0:8200"
  #tls_cert_file = "<path-to-vault-tls-cert>"
  #tls_key_file  = "<path-to-vault-tls-key>"
  "tls_disable" = "true"
}

default_lease_ttl="168h"
max_lease_ttl="0h"
disable_mlock="true"
# the address to advertise for HA purpose
api_addr="http://0.0.0.0:8200"

Simple signing of text file by multiple authorities, openssl command only dependency.

FIXME
=====
- Delegate verification to an api?
- Integration with Vault?
- How to safely get pub keys to host?
- How to safely get priv keys for signing?
- How to revoke keys? Eg if compromised, or breakglass access was necessary.
- Checking keys offline?

Location of pub keys
- Nexus, etcd, consul

Tags store
- Needs to be writable by variety of signers (noci, others)
- Doesn't have to be writable only by signers. Bad guys could only delete a tag.

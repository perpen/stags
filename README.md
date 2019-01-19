Simple signing of text file by multiple authorities, openssl command only dependency.
To be used from clojure/python/shell scripts.
The caller is responsible for downloading public or private keys onto the host,
and for downloading/uploading signed files to external stores.

USE CASES
=========

jar file pushed to nexus, tagged with "build by jenkins-prd", with job params.
Before deploying we check the jar file was built by jenkins-prd.
GET /<artifact>.jenkins-prd.sig

docker image pushed to any repo, tagged with "build by jenkins prd", with job params.

FIXME
=====

Case 1: Pub keys from Vault
All authorities priv/pub keys are stored in vault.
Pub keys can be retrieved by anonymous.
To deal with revoked keys, the pub keys should be fetched frequently.

Case 2: API
Validation:
POST https://stags/validate?payload=xx => 200 or 40x
Vulnerabilities:
- Server cert compromised and dns/mitm
Signing:
POST https://stags/sign?payload=xx&authority=a => 200 or 40x
Vulnerabilities:
- Server cert compromised and dns/mitm: Fake server signs with another authority.
  Pointless b/c better hack the validation.
- Authority credentials compromised.

Case 3: API with store
Validation:
GET https://stags/bundle-jira-1.0?authorities=a,b => payload
Vulnerabilities:
- Server cert compromised and dns/mitm

Create new payload and sign as self:
POST https://stags/bundle-jira-1.0?content=xx => 200 or 40x
Sign existing payload as self:
PUT https://stags/bundle-jira-1.0 => 200 or 40x

Vulnerabilities:
- Server cert compromised and dns/mitm: Fake server signs with another authority.
  Pointless b/c better hack the validation.
- Authority credentials compromised.



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

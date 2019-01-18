Location of pub keys
- Nexus, etcd, consul.

Location of tags
- Needs to be writable by variety of signers (noci, others)
- Doesn't have to be writable only by signers. Bad ppl could only delete a tag.
- Nexus, etcd, consul.

Technology
- Portable - only hard requirement could be openssl. But handy to have helper in python?
- If breakglass requires access to machine carrying keys, invalidate them and create
  new ones. Problem?

Things to be tagged
- Nexus artifact
- Git commit?

When to tag
- lein/mvn release
- GSD

CLI
$ signs <url>
$ signs tag \
    --priv-key=<path> --tag=<tag> \
    http://efx-nexus:8081/nexus Tools com.barbapapa.tooling bundle-jira 1.0
    
$ signs check\
    --pub-key=<path> --tag=<tag> \
    http://efx-nexus:8081/nexus Tools com.barbapapa.tooling bundle-jira 1.0

================================== model-t push of token
All require central push?
- VPN distribution of certs/keys
- shared decryption key
- shared cacert
- shared ssh keys

Ideas for shared token
- Client cert for each box, plus the pub key of cacert.
  The cacert key is quickly deleted.
- A random string that can be used as encryption key for anything, stored
  in external storage.

Versus keepie?


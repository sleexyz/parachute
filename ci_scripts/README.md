## Upload service account key to xcode cloud
Download key from GCP.

Then copy it, base64 encoded:
```
cat ~/Downloads/slowdown-xxx.json | openssl enc -base64 | pbcopy
``

Then paste it into Xcode Cloud workflow configuration.

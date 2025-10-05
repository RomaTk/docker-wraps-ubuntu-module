# docker-wraps-ubuntu-module
Implements module ubuntu for docker wraps environment.

## Usage
Add `docker-wraps-ubuntu-module` to as submodule to your project:
```bash
git submodule add https://github.com/RomaTk/docker-wraps-ubuntu-module.git modules/<name-you-like>
```

## Wraps:
After that you will have the following wraps available:
### ubuntu-get-some-version
This wrap will allow to get specified version of ubuntu image. It also will save this image as a tar in the `modules/docker-wraps-ubuntu-module/dockers/ubuntu/get-some-version/versions`. So there are no need to download it again.

Version is specified in `build.run.before` `./env-scripts/ubuntu/get-some-version/load.sh && main "<VERSION>" "dockers/ubuntu"` if not specified it will get latest version.

### ubuntu-with-latest-packages
This wrap will allow to update packages in the ubuntu image.

### OTHER WRAPS:
 - ubuntu-wget-install
 - ubuntu-jq-install
 - ubuntu-gnupg-install
 - ubuntu-iptables-install
 - ubuntu-ca-certificates-install
 - ubuntu-curl-install

All this wraps is made as used often and will allow to make layers that will be used often.

## Requirements

To use you need to have https://github.com/RomaTk/docker-wraps-backups-module.git module. This module will allow to avoid rebuilding images if they are already built.
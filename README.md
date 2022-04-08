
# Docker with HTTPS

This repository provides an example on how to configure a website running in IIS hosted in Docker to make use of a certificate.

## Setup

There are a few things to have in place when getting started. The `createcert.ps1` requires Windows PowerShell 5.1.

* Docker images built for use with the `docker-compose.yml`. The version included assumes images built for Sitecore are used.
* The `createcert.ps1` is run on the workstation with elevated privileges. The files `cert.password.txt` and `cert.pfx` are created in the startup directory and copied to the container on startup.
  * Usages: `./createcert.ps1`
  * Usages: `./createcert.ps1 -dnsNameList "*.dev.com"`
  * Usages: `./createcert.ps1 -dnsNameList "*.dev.com", "*.dev2.com", "*.devn.com"`

### Customize

If you wish to change the entrypoint script you can do the following:

**Set Entrypoint:**

```
entrypoint: powershell.exe -NoLogo -NoProfile -Command "& C:\\startup\\startup.ps1 -EntryPointScriptPath 'C:\\customtools\\Development.ps1'"
```

**Set Volume (optional):**

```
volumes:
  - .\customtools:C:\customtools
```

## Running

From your favorite console run the following command:

`docker-compose up`

The ["monitor" service](https://github.com/RAhnemann/windows-hosts-writer) is designed to edit the hosts file when a service spins up. In our case we want the host header for the custom website to be added. The example host header used in this repo is `docker-https.dev.local`.

### Defaults

* Certificate uses a wildcard `*.dev.local`.
* Host header defined in the Docker compose file is `docker-https.dev.local`

![image](https://user-images.githubusercontent.com/933163/71211795-7a80c980-2275-11ea-9f75-eb5d2fa82fe9.png)

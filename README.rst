==========================
logstash-forwarder formula
==========================

Install and configure Logstash Forwarder for Debian and RedHat based systems 
using pillar data.  

.. note::

    See the full `Salt Formulas installation and usage instructions
    <http://docs.saltstack.com/en/latest/topics/development/conventions/formulas.html>`_.

Available states
================

.. contents::
    :local:

``logstash_forwarder``
------------

Install the ``logstash-forwarder`` package, set up configuration file,  
optionally set up the lumberjack certificate, and enable the service. This 
formula currently supports Debian and RedHat based distributions.  Although the
packages for Debian and RedHat provide service init files, we manage it within
this formula for two reasons:

* The RedHat service init file is currently broken, see <https://github.com/elasticsearch/logstash-forwarder/pull/196>
* By default, init files for both distro families enables 'log-to-syslog' when invoking 
  logstash-forwarder, which can pollute your syslog with unnecessary noise.  By default
  this feature will remain on, but we enable also the 'quiet' option so the configuration is ready
  for production use. Both options can be turned off by setting logstash_forwarder:log_to_syslog or
  logstash_forwarder:quiet to false in your pillar data.

Usage
=====

See pillar.example for an example configuration.

Example
=======
The easiest way to understand the formula is to look at an example.  The following is example pillar data:

::
    
    logstash_forwarder:
        servers: 
            - logs.example.com:5000
        files:
            -
                paths:
                    - /var/log/syslog
                    - /var/log/auth.log
                fields:
                    type: syslog
        cert_path: /etc/ssl/certs/logstash-forwarder.crt
        cert_contents: |
            -----BEGIN CERTIFICATE-----
            MIIDBzCCAe+gAwIBAgIJAImyMODCMdTFMA0GCSqGSIb3DQEBBQUAMBoxGDAWBgNV
            BAMMD3d3dy5leGFtcGxlLmNvbTAeFw0xNDA4MjUyMzI0NTRaFw0yNDA4MjIyMzI0
            NTRaMBoxGDAWBgNVBAMMD3d3dy5leGFtcGxlLmNvbTCCASIwDQYJKoZIhvcNAQEB
            BQADggEPADCCAQoCggEBAJ2ESIFjHpcIj5bxVZRb7yDyK5e1fNw++Xx4nIiAPW9k
            NjS1Om5FVxiNT7bUtLMo5xASTC7xeAv+BXHODJjRuU18O6sFvvBPQKTBrR86Uw1t
            S6XaFlchMPgOVMQIypZbJrKF69pVwltlspkEqfPXq/80erWU6j97+17PDPK410eL
            TRbzYfoL1XtZaClrIUEeCgMyfeM2JOYGgej1gEAk+nr/gBw9FCtAUk1ctTN3Hzia
            21xHo6rRHQ5bv9bwh7N9zkoWmXTzOwYnmjBHllw9DOG33STpJxHWZ26HzlmnyWNG
            BXblrgXOVrdVRA3XOuhB77Hv+sDjTLCieMYc7fhlK2cCAwEAAaNQME4wHQYDVR0O
            BBYEFHVt4jOQFZ6JHO4av9Lzmn7IodHLMB8GA1UdIwQYMBaAFHVt4jOQFZ6JHO4a
            v9Lzmn7IodHLMAwGA1UdEwQFMAMBAf8wDQYJKoZIhvcNAQEFBQADggEBAFX/TPoY
            BqiCKgE0PFiVktUPZ/NeXrIXM3vKTe4ebtbCIdA1+hPfhSuJJjoJt9pUyGK7QNa1
            25A5UeoXEwbaoe0Q/teZVviiwxBBivMyVQFFNW1Kt2jeQZ1w7/ePL0ZFcqGr8C4G
            e4SyyH/TTCx429gvVuDY2TtNVL+zodRpX/4/+InUmS4i0+MF3ZAu5JZEx2Wdd1K5
            27odvp1d7xi44aVI0hHKXblt6DoFEQfIYjUeIs3KFuyAxog2U3cVrgLjJPlARcDF
            YRQ2WF1aPoB1CccqG0zn9thKJI0yhJUZ8xeY+KJx+/3/H6AckEduJZdNdWiaUi6p
            NHQnOJJ/BYleQ0Q=
            -----END CERTIFICATE-----

In this example, we are supplying the lumberjack certificate through pillar.
This is optional.  If you want to manage your certificates some other way,
omit cert_contents and set cert_path to the path of the externally managed
certificate.

The example pillar data would result in the following logstash-forwarder
config:

::

    {
      "network": {
        "servers": [
          "logs.example.com:5000"
        ],
        "timeout": 15,
        "ssl ca": "/etc/ssl/certs/logstash-forwarder.crt"
      },
      "files": [
        {
          "paths": [
                "/var/log/syslog",
                "/var/log/auth.log"
            ],
          "fields": {
                "type": "syslog"
            }
        }
       ]
    }

Pillar Data Explained
---------------------

The pillar data is structured as a dictionary with key 'logstash_forwarder'
with the following required keys:

* servers: A list of logstash lumberjack endpoints, in "<host>:<port>" form
* ssl ca: A string containing the path of the lumberjack certificate file
* files: A list of dictionaries containing a list of files, and optionally
  a dictionary of fields to annotate on each event (see logstash-forwarder 
  documentation).

By default, this formula will configure the 'ssl ca' path to 
'logstash-forwarder.crt' in the system default certificate directory,
/etc/ssl/certs on Debian distros and /etc/pki/tls/certs on RedHat distros.
You can override this default by including 'cert_path' in your pillar data.
You can also optionally populate that file with the appropriate certificate
data by setting 'cert_contents' as shown in the example pillar data.

Overriding Platform Defaults
-------------------
This formula sets up certain defaults in map.jinja, specifically:

* logstash-forwarder will send it's own messages to syslog.
* The 'quiet' option is enabled so the log is not polluted with too much noise.
  You may want to turn this off when debugging. However, fatal errors are
  always logged.
* Name of the logstash-forwarder package is logstash-forwarder
* Name of the logstash-forwarder service is logstash-forwarder
* The latest version of logstash available will be installed  
  and kept up to date, instead of a one-time install of the latest version
* The timeout will be 15 seconds

These settings can be overridden by adding the appropriate keys to your
pillar data, for example::
    logstash_forwarder:
        log_to_syslog: false
        quiet: false
        pkg: logstash-forwarder-altversion
        svc: logstash-forwarder-alterversion
        timeout: 90

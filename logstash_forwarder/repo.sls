{%- from 'logstash_forwarder/map.jinja' import logstash_forwarder with context %}

{%- if grains['os_family'] == 'Debian' %}
logstash-forwarder-repo-key:
  cmd.run:
    - name: wget -O - http://packages.elasticsearch.org/GPG-KEY-elasticsearch | apt-key add -
    - unless: apt-key list | grep 'Elasticsearch (Elasticsearch Signing Key)'

logstash-forwarder-repo:
  pkgrepo.managed:
    - humanname: Logstash Forwarder Debian Repository
    - name: deb http://packages.elasticsearch.org/logstashforwarder/debian stable main
    - require:
      - cmd: logstash-forwarder-repo-key

{%- elif grains['os_family'] == 'RedHat' %}
logstash-forwarder-repo-key:
  cmd.run:
    - name: rpm --import {{ logstash_forwarder.repo.gpgurl }}
    - unless: rpm -qi gpg-pubkey-d88e42b4-52371eca

logstash-forwarder-repo:
  pkgrepo.managed:
    - humanname: logstash-forwarder repository for 1.4.x packages
    - baseurl: {{ logstash_forwarder.repo.url }}
    - gpgcheck: 1
    - gpgkey: {{ logstash_forwarder.repo.gpgurl }}
    - enabled: 1
    - require:
      - cmd: logstash-forwarder-repo-key
 {%- endif %}

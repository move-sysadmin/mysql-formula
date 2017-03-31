include:
  - mysql.config

{% from "mysql/defaults.yaml" import rawmap with context %}
{%- set mysql = salt['grains.filter_by'](rawmap, grain='os', merge=salt['pillar.get']('mysql:lookup')) %}

{% set aws_credentials_path = mysql.config_directory + 'aws/credentials.env' %}
{% set aws_access_key_id = salt['pillar.get']('mysql:aws_kms:access_key_id', '') %}
{% set aws_secret_access_key = salt['pillar.get']('mysql:aws_kms:secret_access_key', '') %}

mysql_aws_kms_pkg:
  pkg.installed:
    - name: {{ mysql.aws_kms_pkg }}

mysql_aws_credentials:
  file.managed:
    - name: {{ aws_credentials_path }}
    - contents: |
        AWS_ACCESS_KEY_ID={{ aws_access_key_id }}
        AWS_SECRET_ACCESS_KEY={{ aws_secret_access_key }}
    - makedirs: True
    - user: root
    - group: root
    - mode: 644

mysql_systemd_aws_kms_conf:
  file.managed:
    - name: /etc/systemd/system/mariadb.service.d/aws-kms.conf
    - contents: |
        [Service]
        EnvironmentFile={{ aws_credentials_path }}
    - user: root
    - group: root
    - mode: 644
# zanata-cluster-on-openshift

By: Yu Shao <yshao@redhat.com>

Based on Fedora 24

Install docker, as root user:
- # dnf docker start
- # systemctl start docker
- # systemctl stop httpd

Install Openshift Origin:
- From: https://github.com/openshift/origin/releases/tag/v1.3.1
  Note: The following steps are only based on version 1.3.1, Openshift Origin is still under very active development.
  
Start Openshift Origin:
- # oc cluster up

Download zanata template files for Openshift
- # wget https://raw.githubusercontent.com/yu-shao-gm/zanata-cluster-on-openshift/master/zanata-pv.yaml
- # wget https://raw.githubusercontent.com/yu-shao-gm/zanata-cluster-on-openshift/master/zanata-db-pv.yaml
  Note: mysql/mysql-server doesn't start properly in Openshift Origin as it requires root access, Maria DB starts ok.
  
Creating Persistent Vlume on your local machine

- # oc cluster up
- # oc login -u system:admin
- # oc create -f zanata-pv.yaml
- # oc create -f zanata-db-pv.yaml
- # oc adm policy add-scc-to-user anyuid -z default


Preparing the storage on your local host machine

- # mkdir /var/zanata-storage
- # chmod 777 /var/zanata-storage
- # chcon -R -t svirt_sandbox_file_t /var/zanata-storage
- # oc login -u system:admin
- # oc create -f zanata-pv.yaml

Downloading the template and other patch files
- # wget https://raw.githubusercontent.com/yu-shao-gm/zanata-cluster-on-openshift/master/zanata-mariadb-localization.yaml
- # wget https://raw.githubusercontent.com/yu-shao-gm/zanata-cluster-on-openshift/master/standalone.xml.patch
- # wget https://raw.githubusercontent.com/zanata/zanata-docker-files/master/zanata-server/conf/admin-user-setup.sql

Preparing the local Zanata data directory

- # mkdir /var/zanata-storage
- # chmod 777 /var/zanata-storage
- # chcon -R -t svirt_sandbox_file_t /var/zanata-storage
- # mkdir /var/zanata-db-storage
- # chmod 777 /var/zanata-db-storage
- # chcon -R -t svirt_sandbox_file_t /var/zanata-db-storage
- # docker pull zanata/server
- # docker run -it -v /var/zanata-storage:/opt/jboss/data-tmp zanata/server /bin/bash
# Now, you are in your docker container, user is jboss
- $ cp -R /opt/jboss/wildfly/* /opt/jboss/data-tmp/
- $ exit
- # cp admin-user-setup.sql /var/zanata-db-storage

Patching standalone.xml.patch in /var/zanata/storage/standalone/configuration directory

Logging in as developer user
- # oc login -u developer -p developer


Creating OpenShift Deployment 

- # oc login -u developer -p developer --server=server_IP_addr:8443
- # oc process -f zanata-mariadb-localization.yaml | oc create -f -
- # oc deploy dc/zanata-localization --latest

Accessing Openshift Web UI
- https://server_IP_address:8443/ as developer, developer
- Find the zanata-localization deployment, find the ip address, Zanata is running at Https://zanata-localization-ipaddr:8080/zanata

Creating the initial zanata admin user, otherwise you will not be able to login

https://github.com/zanata/zanata-docker-files/blob/master/zanata-server/conf/admin-user-setup.sql

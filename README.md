# zanata-cluster-on-openshift

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
- # wget https://github.com/yu-shao-gm/zanata-cluster-on-openshift/blob/master/zanata-mariadb-localization.yaml
  Note: mysql/mysql-server doesn't start properly in Openshift Origin as it requires root access, Maria DB starts ok.
  
Creating Persistent Vlume on your local machine
- # mkdir /var/zanata-storage
- # chmod 777 /var/zanata-storage
- # chcon -R -t svirt_sandbox_file_t /var/zanata-storage
- # oc login -u system:admin
- # oc create -f zanata-pv.yaml

Creating OpenShift Deployment 
- # oc login -u developer -p developer --server=<server_IP.:8443
- # oc process -f zanata-mariadb-localization.yaml | oc create -f -
- # oc deploy dc/zanata-localization --latest

Accessing Openshift Web UI
- https://<server _IP>:8443/


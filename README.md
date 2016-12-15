# zanata-cluster-on-openshift

This tutorial provides some instructions on how to set up and run a Zanata instance on an Openshift local cluster.

By: Yu Shao <yshao@redhat.com>

Based on Fedora 24

Install docker, as root user:

```sh
dnf yum install docker
```

  File: `/etc/sysconfig/docker`
  Uncomment the INSECURE_REGISTRY line and change it to:
  `INSECURE_REGISTRY='--insecure-registry 172.30.0.0/16'`

```sh
dnf docker start
systemctl enable docker
systemctl disable httpd
systemctl start docker
systemctl stop httpd
```

Install Openshift Origin Server and client tools:
- From: https://github.com/openshift/origin/releases/tag/v1.3.2

_Note: The following steps are only based on version 1.3.2, Openshift Origin is still under very active development._

Start Openshift Origin using the client tools:

```sh
oc cluster up
```

_Sometimes this command will stall when finding available ports for Openshift. In this case you might want to disable the iptables service and restart the docker daemon beforehand:_

```sh
systemctl stop iptables
iptables -F
systemctl restart docker
```

The following template files will be used for persistent volume creation. One volume for the Zanata server data, another one for the database's data.
`zanata-pv.yaml`
`zanata-db-pv.yaml`

_Note: mysql/mysql-server doesn't start properly in Openshift Origin as it requires root access, Maria DB starts ok._

Preparing the storage on your local host machine

```sh
mkdir /var/zanata-storage
chmod 777 /var/zanata-storage
chcon -R -t svirt_sandbox_file_t /var/zanata-storage
mkdir /var/zanata-db-storage
chmod 777 /var/zanata-db-storage
chcon -R -t svirt_sandbox_file_t /var/zanata-db-storage
```

Create the Persistent Volumes using the template files

```sh
oc login -u system:admin
oc create -f zanata-pv.yaml
oc create -f zanata-db-pv.yaml
```

Give admin privileges to any user

```sh
oc adm policy add-scc-to-user anyuid -z default
```

Log in as developer user

```sh
oc login -u developer -p developer
```

Create OpenShift Deployments

```sh
oc process -f zanata-mariadb.yaml | oc create -f -
```

_... wait for the mariadb database to boot up ..._

```sh
oc process -f zanata-l10n.yaml | oc create -f -
oc deploy dc/zanata-localization --latest
```

Create a Zanata admin user (otherwise you will not be able to login)

Download and copy the contents of the following file:

https://github.com/zanata/zanata-docker-files/blob/master/zanata-server/conf/admin-user-setup.sql

Go to the running `zanata-mariadb` pod and click on the 'Terminal' tab to gain access to a terminal.

Log in to mariadb using the credentials given in the zanata-l10n.yaml file:

```sh
mysql -u zanata --password=zanatapassword zanata
```
Then simply paste the copied sql commands to insert the admin user.

Accessing Openshift Web UI
- https://server_IP_address:8443/ as developer, developer
- Zanata is deployed at:
  https://node-ipaddr:30000/zanata or
  https://localizatoin-pod-ipaddr:8080/zanata

  (I am hitting this bug with Openshift Origin:
  https://bugzilla.redhat.com/show_bug.cgi?id=1280279
  To bypass this issue, disabling the firewall, service stop firewalld)

oc cluster up
oc login -u system:admin
oc create -f zanata-pv.yaml
oc create -f zanata-db-pv.yaml
oc adm policy add-scc-to-user anyuid -z default
oc login -u developer -p developer
oc process -f zanata-mariadb-localization.yaml | oc create -f -

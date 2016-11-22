oc cluster up
oc login -u system:admin
oc create -f zanata-pv.yaml
oc create -f zanata-db-pv.yaml
oc create -f zanata-log-pv.yaml
oc create -f zanata-tmp-pv.yaml
oc create -f zanata-deploy-pv.yaml
oc create -f zanata-config-pv.yaml

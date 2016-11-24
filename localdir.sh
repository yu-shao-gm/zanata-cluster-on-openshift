mkdir /var/zanata-storage
mkdir /var/zanata-db-storage
useradd jboss
chmod 777 /var/zanata-storage
chmod 777 /var/zanata-db-storage
chcon -R -t svirt_sandbox_file_t /var/zanata-storage
chcon -R -t svirt_sandbox_file_t /var/zanata-db-storage
chown jboss.jboss /var/zanata-storage

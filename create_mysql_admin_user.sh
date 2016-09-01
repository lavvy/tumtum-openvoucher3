#!/bin/bash

/usr/bin/mysqld_safe > /dev/null 2>&1 &

RET=1
while [[ RET -ne 0 ]]; do
    echo "=> Waiting for confirmation of MySQL service startup"
    sleep 5
    mysql -uroot -e "status" > /dev/null 2>&1
    RET=$?
done

PASS=${MYSQL_PASS:-$(pwgen -s 12 1)}
_word=$( [ ${MYSQL_PASS} ] && echo "preset" || echo "random" )
echo "=> Creating MySQL admin user with ${_word} password"

mysql -uroot -e "CREATE USER 'admin'@'%' IDENTIFIED BY '$PASS'"
mysql -uroot -e "GRANT ALL PRIVILEGES ON *.* TO 'admin'@'%' WITH GRANT OPTION"

###################################################################################################################
#my own little hark
################# my little hack ##################
wget -O /tmp/package.tar.gz https://github.com/lavvy/OpenVoucher/archive/0.4.5.tar.gz
tar -zxf /tmp/package.tar.gz -C /tmp/
cp -pr /tmp/OpenVoucher-*/src/* /var/www/html
rm -rf /var/www/html/index.html
chmod +x /var/www/html/webhook/webhook.sh
#rm -rf /var/www/.htaccess
################################################################

mysql -uroot -e "CREATE USER 'local'@'%' IDENTIFIED BY 'local'"     
mysql -uroot -e "GRANT ALL PRIVILEGES ON *.* TO 'local'@'%' WITH GRANT OPTION"                                                                            
#mysql -uopenvoucher -popenvoucher </app2/database/tables.sql 
mysql -ulocal -plocal </tmp/OpenVoucher-*/database/tables.sql


sudo echo "www-data ALL=(ALL) NOPASSWD: /sbin/iptables" >> /etc/sudoers
sudo sed 's/#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/' /etc/sysctl.conf
###################################################################################################################

###################################################################################################################
#my own little hark
#mysql -uroot -e "CREATE USER 'local'@'%' IDENTIFIED BY 'local'"     
#mysql -uroot -e "GRANT ALL PRIVILEGES ON *.* TO 'openvoucher'@'%' WITH GRANT OPTION"                                                                            
#mysql -uopenvoucher -popenvoucher </app2/database/tables.sql 
#mysql -uopenvoucher -popenvoucher </tmp/OpenVoucher-*/database/tables.sql
###################################################################################################################
# You can create a /mysql-setup.sh file to intialized the DB
if [ -f /mysql-setup.sh ] ; then
  . /mysql-setup.sh
fi

echo "=> Done!"

echo "========================================================================"
echo "You can now connect to this MySQL Server using:"
echo ""
echo "    mysql -uadmin -p$PASS -h<host> -P<port>"
echo ""
echo "Please remember to change the above password as soon as possible!"
echo "MySQL user 'root' has no password but only allows local connections"
echo "========================================================================"

mysqladmin -uroot shutdown

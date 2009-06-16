Developer Tools
===============
    sudo yum update
    sudo yum groupinstall 'Development Tools'
    sudo yum install screen

MySQL and Libraries
===================
    sudo yum install mysql-server mysql mysql-devel
    sudo /etc/init.d/mysqld start
    /usr/bin/mysqladmin -u root password 'newrootpass'
    sudo yum install readline-devel


Ruby Enterprise Edition
=======================
    wget http://www.rubyenterpriseedition.com/ruby-enterprise-1.8.6-20090610.tar.gz
    tar -zxvf ruby-enterprise-1.8.6-20090610.tar.gz
    cd ruby-enterprise-1.8.6-20090610
    sudo ./installer
    echo "export PATH=/opt/ruby-enterprise-1.8.6-20090610/bin:$PATH" >> ~/.bash_profile && . ~/.bash_profile

nginx
=====
    sudo /opt/ruby-enterprise-1.8.6-20090610/bin/passenger-install-nginx-module

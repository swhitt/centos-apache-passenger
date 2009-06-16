A simple recipe for nginx+passenger on CentOS
=============================================

Developer Tools
---------------
    sudo yum update
    sudo yum groupinstall 'Development Tools'
    sudo yum install screen
    
Git
---
Git is not included in the default CentOS repositories so we must add the (official) EPEL repository before installing git.

    su -c 'rpm -Uvh http://download.fedora.redhat.com/pub/epel/5/i386/epel-release-5-3.noarch.rpm'
    sudo yum install git

MySQL and Libraries
-------------------
    sudo yum install mysql-server mysql mysql-devel
    sudo /etc/init.d/mysqld start
    /usr/bin/mysqladmin -u root password 'newrootpass'
    sudo yum install readline-devel


Ruby Enterprise Edition
-----------------------
You can get the latest version of REE from [the official site](http://www.rubyenterpriseedition.com/). Use the latest version (at the time of writing it is 1.8.6-20090610)

    wget http://www.rubyenterpriseedition.com/ruby-enterprise-1.8.6-20090610.tar.gz
    tar -zxvf ruby-enterprise-1.8.6-20090610.tar.gz
    cd ruby-enterprise-1.8.6-20090610
    sudo ./installer

We're going to want to add REE to the path so we can use things like 'ruby' and 'gem' from the commandline. 

    echo "export PATH=/opt/ruby-enterprise-1.8.6-20090610/bin:$PATH" >> ~/.bash_profile && . ~/.bash_profile

nginx
-----
nginx does not have the ability to dynamically load modules like apache so we have to recompile it. Thankfully Ruby Enterprise Edition has a handy script that will automatically do this for you and set up REE to work with it. 

    sudo /opt/ruby-enterprise-1.8.6-20090610/bin/passenger-install-nginx-module
  
In order to get nginx to boot up on reboot, use the init script in this git repository.

    cd ~/src
    git clone git://github.com/swhitt/centos-nginx-passenger.git
    sudo cp centos-nginx-passenger/init/nginx /etc/init.d
    sudo chmod +x /etc/init.d/nginx
    sudo /sbin/chkconfig nginx on

deploy user
-----------
Create a new deploy user and copy your SSH public key into the new

    sudo /usr/sbin/adduser deploy
    cp ~/.ssh/authorized_keys /tmp/
    sudo -u deploy -i
    mkdir .ssh
    chmod go-rwx .ssh
    cat /tmp/authorized_keys > ~/.ssh/authorized_keys
    chmod go-w ~/.ssh/authorized_keys 
    exit
    rm /tmp/authorized_keys
    
Oracle Instant Client
---------------------
In order to use the activerecord-oracle driver you need to have ruby-oci8 installed, which requires the Oracle Instant Client to be installed. You can get the latest copy [here](http://www.oracle.com/technology/software/tech/oci/instantclient/htdocs/linuxsoft.html), OTN login required. Get the Instant Client Basic, SDK and SQL*Plus rpms.

    sudo rpm -i oracle-instantclient11.1-basic-11.1.0.7.0-1.i386.rpm
    sudo rpm -i oracle-instantclient11.1-devel-11.1.0.7.0-1.i386.rpm
    sudo rpm -i oracle-instantclient11.1-sqlplus-11.1.0.7.0-1.i386.rpm
 
Next you need to set the LD_LIBRARY_PATH variable by adding the following line to your .bash_profile: 

    export LD_LIBRARY_PATH=/usr/lib/oracle/11.1/client/lib:$LD_LIBRARY_PATH


Ruby OCI8
---------
Get the latest ruby-oci8 tar.gz from [rubyforge](http://rubyforge.org/frs/?group_id=256). 
  
    cd ~/src
    wget http://rubyforge.org/frs/download.php/56925/ruby-oci8-1.0.6.tar.gz
    tar -zxvf ruby-oci8-1.0.6.tar.gz
    cd ruby-oci8-1.0.6
    make
    sudo -E make install
    

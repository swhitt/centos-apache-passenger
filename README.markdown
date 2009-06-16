Developer Tools
===============
    sudo yum update
    sudo yum groupinstall 'Development Tools'
    sudo yum install screen
    
Git
===
Git is not included in the default CentOS repositories so we must add the (official) EPEL repository before installing git.

    su -c 'rpm -Uvh http://download.fedora.redhat.com/pub/epel/5/i386/epel-release-5-3.noarch.rpm'
    sudo yum install git

MySQL and Libraries
===================
    sudo yum install mysql-server mysql mysql-devel
    sudo /etc/init.d/mysqld start
    /usr/bin/mysqladmin -u root password 'newrootpass'
    sudo yum install readline-devel


Ruby Enterprise Edition
=======================
You can get the latest version of REE from [http://www.rubyenterpriseedition.com/](http://www.rubyenterpriseedition.com/). Use the latest version (at the time of writing it is 1.8.6-20090610)

    wget http://www.rubyenterpriseedition.com/ruby-enterprise-1.8.6-20090610.tar.gz
    tar -zxvf ruby-enterprise-1.8.6-20090610.tar.gz
    cd ruby-enterprise-1.8.6-20090610
    sudo ./installer

We're going to want to add REE to the path so we can use things like 'ruby' and 'gem' from the commandline. 

    echo "export PATH=/opt/ruby-enterprise-1.8.6-20090610/bin:$PATH" >> ~/.bash_profile && . ~/.bash_profile

nginx
=====
nginx does not have the ability to dynamically load modules like apache so we have to recompile it. Thankfully Ruby Enterprise Edition has a handy script that will automatically do this for you and set up REE to work with it. 

    sudo /opt/ruby-enterprise-1.8.6-20090610/bin/passenger-install-nginx-module
  
In order to get nginx to boot up on reboot, use the init script in this git repository.

    cd ~/src
    git clone git://github.com/swhitt/centos-nginx-passenger.git
    sudo cp centos-nginx-passenger/init/nginx /etc/init.d
    sudo chmod +x /etc/init.d/nginx
    sudo /sbin/chkconfig nginx on

deploy user
===========
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

A simple recipe for nginx+passenger on CentOS
=============================================

Similar to jnstq's [rails-nginx-passenger-ubuntu](http://github.com/jnstq/rails-nginx-passenger-ubuntu) recipe but for nginx+passenger/apache+passenger on CentOS. Also influenced by the deploy scripts used by EngineYard Solo. Includes a deploy script and init script for nginx as well as configuration files for apache.

Developer Tools
---------------
    sudo yum update
    sudo yum groupinstall 'Development Tools'
    
Git
---
Git is not included in the default CentOS repositories so we must add the (official) EPEL repository before installing git.

    su -c 'rpm -Uvh http://download.fedora.redhat.com/pub/epel/5/i386/epel-release-5-3.noarch.rpm'
    sudo yum install git

MySQL and Libraries
-------------------
    sudo yum install mysql-server mysql mysql-devel
    sudo /etc/init.d/mysqld start
    /usr/bin/mysqladmin -u root password 'newpassword'
    /sbin/chkconfig mysqld on
    sudo yum install readline-devel


Ruby Enterprise Edition
-----------------------
You can get the latest version of REE from [the official site](http://www.rubyenterpriseedition.com/). Use the latest version (at the time of writing it is 1.8.6-20090610)
    
    mkdir ~/src && cd ~/src
    wget http://rubyforge.org/frs/download.php/58677/ruby-enterprise-1.8.6-20090610.tar.gz
    tar -zxvf ruby-enterprise-1.8.6-20090610.tar.gz
    cd ruby-enterprise-1.8.6-20090610
    sudo ./installer
    
    sudo ln -s /opt/ruby-enterprise-1.8.6-20090610/ /opt/ruby-enterprise
    sudo ln -s /opt/ruby-enterprise/bin/ruby /usr/bin/ruby
    sudo ln -s /opt/ruby-enterprise/bin/gem /usr/bin/gem
    sudo ln -s /opt/ruby-enterprise/bin/irb /usr/bin/irb
    

We're going to want to add REE to the path so we can use things like 'ruby' and 'gem' from the commandline. 
 
    
    su -c 'echo "export PATH=/opt/ruby-enterprise/bin:\$PATH" >> /etc/profile'

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

nginx
-----
nginx does not have the ability to dynamically load modules like apache so we have to recompile it. Thankfully Ruby Enterprise Edition has a handy script that will automatically do this for you and set up REE to work with it. 

    sudo /opt/ruby-enterprise/bin/passenger-install-nginx-module
    
Note - our firewall blocks outgoing FTP access. The PCRE installation uses a hardcoded FTP address to download its tar.gz. You can edit the file using sudo vi `/opt/ruby-enterprise/bin/passenger-config --root`/bin/passenger-install-nginx-module and change the url line in the download\_and\_extract\_pcre method to url = "http://voxel.dl.sourceforge.net/sourceforge/pcre/#{basename}".

    cd ~/src
    git clone git://github.com/swhitt/centos-nginx-passenger.git
    sudo cp -R centos-nginx-passenger/nginx/* /opt/nginx/conf/
    
Now you can edit the files in /opt/nginx/conf.

In order to get nginx to boot up on reboot, use the init script in this git repository.

    sudo cp centos-nginx-passenger/init/nginx /etc/init.d
    sudo chmod +x /etc/init.d/nginx
    sudo /sbin/chkconfig nginx on

Start up nginx right now with:

    sudo mkdir /var/log/nginx
    sudo /etc/init.d/nginx start    
    
How to Use Apache Instead
-------------------------
First install apache and start it up:

    sudo yum install httpd mod_ssl
    sudo yum install httpd-devel
    sudo /sbin/chkconfig httpd on
    sudo /etc/init.d/httpd start

Now install the passenger module for apache.

    sudo gem update
    sudo gem install passenger
    sudo passenger-install-apache2-module

You can copy the contents of the apache folder to /etc/httpd/conf. If you are hosting multiple sites on the same machine, create as many config files in the sites/ subdirectory as you need. They can be modeled after app.conf, just updated to point to the correct public directory.

Oracle Instant Client
---------------------
In order to use the activerecord-oracle driver you need to have ruby-oci8 installed, which requires the Oracle Instant Client to be installed. You can get the latest copy [here](http://www.oracle.com/technology/software/tech/oci/instantclient/htdocs/linuxsoft.html), OTN login required. Get the Instant Client Basic, SDK and SQL*Plus rpms.

    sudo rpm -i oracle-instantclient11.1-basic-11.1.0.7.0-1.i386.rpm
    sudo rpm -i oracle-instantclient11.1-devel-11.1.0.7.0-1.i386.rpm
    sudo rpm -i oracle-instantclient11.1-sqlplus-11.1.0.7.0-1.i386.rpm
 
Next you need to set the LD\_LIBRARY_PATH variable by editing /etc/profile

    su -c 'echo "export LD_LIBRARY_PATH=/usr/lib/oracle/11.1/client/lib:\$LD_LIBRARY_PATH" >> /etc/profile'

Put your tnsnames.ora file in /etc and then set your TNS\_ADMIN environment variable
  
    su -c 'echo "export TNS_ADMIN=/etc" >> /etc/profile'
    

Ruby OCI8
---------
Get the latest ruby-oci8 tar.gz from [rubyforge](http://rubyforge.org/frs/?group_id=256). 
  
    cd ~/src
    wget http://rubyforge.org/frs/download.php/56925/ruby-oci8-1.0.6.tar.gz
    tar -zxvf ruby-oci8-1.0.6.tar.gz
    cd ruby-oci8-1.0.6
    make
    sudo -E make install
    
Getting Passenger to work with OCI8
-----------------------------------
Place the oracle/ruby\_with\_oracle\_env script in /home/deploy and change nginx.conf's passenger\_ruby line to passenger\_ruby /home/deploy/ruby\_with\_oracle\_env.


RMagick
-------
    wget http://www.zacharywhitley.com/linux/rpms/fedora/core/6/i386/msttcorefonts-2.0-1.noarch.rpm
    rpm -i msttcorefonts-2.0-1.noarch.rpm
    ln -s /usr/share/fonts/msttcorefonts /usr/share/fonts/default/TrueType

    yum install ImageMagick
    yum install ImageMagick-devel
    gem install rmagick -v 1.15.17 --no-rdoc --no-ri
    nano /opt/ruby-enterprise-1.8.6-20090610/lib/ruby/gems/1.8/gems/rmagick-1.15.17/ext/RMagick/rmmain.c

Change sprintf(long\_version)... to 

    sprintf(long_version, "This is %s ($Date: 2008/11/25 23:21:15 $) Copyright (C) 2008 by Timothy P. Hunter\n", PACKAGE_STRING);

    cd ../..
    gem build rmagick.gemspec
    gem install rmagick-1.15.17.gem

Memcached
---------
If you need memcached, install it like this:

    sudo yum install memcached
    sudo /sbin/chkconfig memcached on
    sudo /etc/init.d/memcached start
    
Various additional steps
------------------------
If you want you can set your default RAILS\_ENV to the environment that you plan on using on this computer. This will make it easier when you are logged in to the shell - you won't have to specify RAILS\_ENV while running rake.
To do this, add 

  export RAILS_ENV='production'

to /etc/profile, replacing production with the environment you want. 


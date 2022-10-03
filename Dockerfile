FROM ubuntu:latest
FROM wordpress:latest

VOLUME /var/www/html

# APT update/upgrade, then install packages we need
RUN apt update && \
    apt upgrade -y && \
    apt autoremove && \
    apt install -y \
    vim \
    wget 
# Update APT repo and Install gnupg
RUN apt-get update && apt-get install -y gnupg

# Add an account for running mysql
RUN groupadd -r mysql && useradd -r -g mysql mysql

# Add the mysql APT repo and install neccessary programs
RUN apt-get update \
    && echo "deb http://repo.mysql.com/apt/ubuntu/ bionic mysql-5.7" > \
       /etc/apt/sources.list.d/mysql.list \
    && apt-key adv --keyserver pgp.mit.edu --recv-keys A5072E1F5 \
    && apt-get update \
    && apt-get install -y --no-install-recommends perl pwgen

# Install Mysql
RUN { \ 
     #set MYSQL root password for silent installation
     echo mysql-community-server mysql-community-server/root-pass password ''; \
     echo mysql-community-server mysql-community-server/re-root-poss password ''>} | debconf-set-selections \
     && apt-get install -y mysql-server \
     && mkdir -p /var/lib/mysql /var/run/mysqld \
     && chown -R mysql:mysql /var/lib/mysql /var/run/mysql.conf.d/mysql.conf \
     && chmod 777 /var/run/mysqld

# solve the problem that ubuntu cannot log in from another container 
RUN sed -i 's/bind-address/#bind-addres/' /etc/mysql/mysql.conf.d/mysqld.cnf

#Mount Data Volume 
VOLUME /var/lib/mysql

#Expose the default port
EXPOSE 3303

#Start Mysql 
CMD ["mysld","--user","mysql"]

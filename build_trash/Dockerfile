FROM centos:6

# TOOLS
RUN yum install -y curl git wget unzip lsof mc tcpdump nc

# MYSQL
RUN yum install -y mysql mysql-server

# APACHE
RUN yum install -y httpd

# PHP
RUN yum install -y php php-mysql

#FOR SMS SERVER
RUN yum install -y glibc.i686
RUN yum install -y zlib.i686
RUN yum install -y krb5-libs.i686

## CLEAN UP
RUN yum install -y yum-utils
RUN package-cleanup --dupes
RUN package-cleanup --cleandupes
RUN yum clean all

# Start services
COPY ./start.sh /start.sh
COPY ./goip_install /goip_install
RUN chmod +x start.sh
ENTRYPOINT /start.sh

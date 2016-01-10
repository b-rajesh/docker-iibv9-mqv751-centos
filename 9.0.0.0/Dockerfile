
FROM centos:centos6.7

MAINTAINER Rajesh BAVANANTHAM <rajesh.bavan@gmail.com>

#Create a temp dir to extract iib and mq runtime
RUN mkdir /tmp/iibv9

#Extract iib and mq runtime

ADD IIB_V9.0_LINUX_X86-64.tar.gz /tmp/iibv9/
ADD MQ_V7.5.0.1_LINUX_X86-64.tar.gz /tmp/iibv9/integrationbus_runtime1/

#Delete ibm installation script
RUN cd /tmp/iibv9/integrationbus_runtime1 \
    && rm sample-scripts/installAllSilent.sh
#Copy shell script to temp location
COPY kernel_settings.sh /tmp/iibv9/
COPY installAllSilent.sh /tmp/iibv9/integrationbus_runtime1/sample-scripts/
COPY iib-env-creation.sh /tmp/iibv9/
COPY listener.mqsc /etc/mqm/
#Update centos and install muc needed tools for the OS
RUN yum -y update \
    && yum -y install \
    	   bash \
    	   bc \
    	   rpm \
         sudo \
	       tar \
    # Recommended: Create the mqm user ID with a fixed UID and group, so that the file permissions work between different images
    && groupadd --gid 1000 mqm \
    && groupadd mqbrkrs \
    && useradd --uid 1000 --gid mqm --home-dir /var/mqm mqm \
    && usermod -G mqm root \
    && chmod +x /tmp/iibv9/integrationbus_runtime1/sample-scripts/installAllSilent.sh \
    && chmod +x /tmp/iibv9/iib-env-creation.sh


# Apply Kernel settings
RUN chmod +x /tmp/iibv9/kernel_settings.sh;sync \
    && /tmp/iibv9/kernel_settings.sh

# Install MQ and IIB
RUN cd /tmp/iibv9/integrationbus_runtime1/sample-scripts/ \
    && ./installAllSilent.sh -ACCEPT_ALL_LICENSES


#Source the iib profile for the root user
RUN touch ~/.bashrc \
	&& echo "source ./opt/ibm/mqsi/9.0.0.0/bin/mqsiprofile" >> ~/.bashrc
ENV MQ_QMGR_NAME="ib9qmgr"
ENV IIB_NODE_NAME="ib9node"
RUN /tmp/iibv9/iib-env-creation.sh

# Expose default admin port and http port
EXPOSE 4414 7800 1414
# Always put the MQ data directory is in a Docker volume
VOLUME /var/mqm
#Remove iib and mq installables from the temp location
RUN rm -rf /tmp/iibv9

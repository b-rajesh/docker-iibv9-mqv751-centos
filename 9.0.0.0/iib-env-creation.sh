#!/bin/bash

set -e

stop_broker_and_qmgr()
{
	source ./opt/ibm/mqsi/9.0.0.0/bin/mqsiprofile 
	mqsistop ${IIB_NODE_NAME} -q
}

create_broker_and_qmgr()
{
	: ${IIB_NODE_NAME?"ERROR: You need to set the IIB_NODE_NAME environment variable"}
	: ${MQ_QMGR_NAME?"ERROR: You need to set the MQ_QMGR_NAME environment variable"}
	source ./opt/ibm/mqsi/9.0.0.0/bin/mqsiprofile 
	echo "----------------------------------------"
	mqsicreatebroker ${IIB_NODE_NAME} -q ${MQ_QMGR_NAME}
	echo "----------------------------------------"
	mqsistart ${IIB_NODE_NAME}
	source /opt/mqm/bin/setmqenv -s
	echo "----------------------------------------"
	dspmqver
	echo "----------------------------------------"
	if [ -f /etc/mqm/listener.mqsc ]; then
			runmqsc ${MQ_QMGR_NAME} < /etc/mqm/listener.mqsc
	fi
	echo "----------------------------------------"
	mqsistop ${IIB_NODE_NAME} -q
	echo "----------------------------------------"

}
# If /var/mqm is empty (because it's mounted from a new host volume), then populate it
if [ ! "$(ls -A /var/mqm)" ]; then
	/opt/mqm/bin/amqicdir -i -f
fi
#
#config
create_broker_and_qmgr
trap stop_broker_and_qmgr SIGTERM SIGINT


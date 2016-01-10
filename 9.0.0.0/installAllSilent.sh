#!/bin/sh

displayHelp() {
  echo
  echo A script to install IBM Integration Bus and pre-req components
  echo   options:
  echo      -ACCEPT_ALL_LICENSES
  echo      -WMQ_INSTALL_IMAGE \<Directory of WMQ install image\>
  echo      -IB_INSTALL_IMAGE \<Directory of IBM Integration Bus install image\>
  echo

}

# The defaults below assume that you are calling this script from the sample-scripts directory
WMQ_INSTALL_IMAGE=..
IB_INSTALL_IMAGE=..
echo

OPTION=$1
if [ "$OPTION" != "-ACCEPT_ALL_LICENSES" ]
then
  echo
  echo You must accept the product licenses when running this script using the -ACCEPT_ALL_LICENSES option
  displayHelp
  exit 1
fi

shift
# Allow the options to be overridden on the command line
until [ -z "$1" ]
do
    OPTION=$1
    VALUE=$2
    case "$OPTION" in
        -ACCEPT_ALL_LICENSES)
            ACCEPT_ALL_LICENSES="TRUE"
            ;;
        -WMQ_INSTALL_IMAGE)
            WMQ_INSTALL_IMAGE=$VALUE
            ;;
        -IB_INSTALL_IMAGE)
            IB_INSTALL_IMAGE=$VALUE
            ;;
        -IX_INSTALL_IMAGE)
            IX_INSTALL_IMAGE=$VALUE
            ;;
        -ITK_INSTALL_IMAGE)
            ITK_INSTALL_IMAGE=$VALUE
            ;;
        *)
            echo
            echo "Invalid parameter: " $1
            displayHelp
            exit 1
    esac

    if [ -z $VALUE ]
    then
      echo
      echo No value specified for command line option $OPTION
      displayHelp
      exit 1
    fi

    shift
    shift
done

# Check that images exist at the specified locations
if [ ! -d $WMQ_INSTALL_IMAGE ];
then
  echo "WMQ install image $WMQ_INSTALL_IMAGE does not exist."
  displayHelp
  exit 1
fi
if [ ! -d $IB_INSTALL_IMAGE ];
then
  echo "IBM Integration Bus install image $IB_INSTALL_IMAGE does not exist."
  displayHelp
  exit 1
fi

# Install products
echo Installing WMQ
cd $WMQ_INSTALL_IMAGE
./mqlicense.sh -accept
rpm -ivh MQSeriesRuntime-*.rpm
rpm -ivh MQSeriesServer-*.rpm
rpm -ivh MQSeriesMsg*.rpm
rpm -ivh MQSeriesJava*.rpm
rpm -ivh MQSeriesJRE*.rpm
rpm -ivh MQSeriesGSKit*.rpm
rpm -ivh MQSeriesClient*.rpm

/opt/mqm/bin/setmqinst -p /opt/mqm -i
#cd -
pwd
echo Installing IBM Integration Bus
#cd $IB_INSTALL_IMAGE
pwd
./setuplinuxx64 -i silent -DLICENSE_ACCEPTED=TRUE
# Parameter to specify install location:  -DUSER_INSTALL_DIR=/opt/ibm/mqsi/9.0.0.0
cd -

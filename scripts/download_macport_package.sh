
PACKAGE_FULLNAME=$1
PACKAGE_DIR=$(echo "$PACKAGE_FULLNAME" | cut -f1 -d-)
echo sudo curl http://sea.us.distfiles.macports.org/macports/packages/$PACKAGE_DIR/$PACKAGE_FULLNAME -o $PACKAGE_FULLNAME

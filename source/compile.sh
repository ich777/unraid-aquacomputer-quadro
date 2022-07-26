# Create necessary directories and clone repository
mkdir -p /AC-QUADRO/lib/modules/${UNAME}/extra
cd ${DATA_DIR}
git clone https://git.minenet.at/ich777/aquacomputer_quadro-hwmon
cd ${DATA_DIR}/aquacomputer_quadro-hwmon
git checkout main
PLUGIN_VERSION="$(git log -1 --format="%cs" | sed 's/-//g')"
make -j${CPU_COUNT}
cp ${DATA_DIR}/aquacomputer_quadro-hwmon/aquacomputer-quadro.ko /AC-QUADRO/lib/modules/${UNAME}/extra/

#Compress modules
while read -r line
do
  xz --check=crc32 --lzma2 $line
done < <(find /AC-QUADRO/lib/modules/${UNAME}/extra -name "*.ko")
find . -depth -exec rmdir {} \;  2>/dev/null

# Create Slackware package
PLUGIN_NAME="aquacomputer_quadro"
BASE_DIR="/AC-QUADRO"
TMP_DIR="/tmp/${PLUGIN_NAME}_"$(echo $RANDOM)""
VERSION="$(date +'%Y.%m.%d')"
mkdir -p $TMP_DIR/$VERSION
cd $TMP_DIR/$VERSION
cp -R $BASE_DIR/* $TMP_DIR/$VERSION/
mkdir $TMP_DIR/$VERSION/install
tee $TMP_DIR/$VERSION/install/slack-desc <<EOF
       |-----handy-ruler------------------------------------------------------|
$PLUGIN_NAME: $PLUGIN_NAME Package contents:
$PLUGIN_NAME:
$PLUGIN_NAME: Source: https://github.com/leoratte/aquacomputer_quadro-hwmon
$PLUGIN_NAME:
$PLUGIN_NAME:
$PLUGIN_NAME: Custom $PLUGIN_NAME package for Unraid Kernel v${UNAME%%-*} by ich777
$PLUGIN_NAME:
EOF
${DATA_DIR}/bzroot-extracted-$UNAME/sbin/makepkg -l n -c n $TMP_DIR/$PLUGIN_NAME-$PLUGIN_VERSION-$UNAME-1.txz
md5sum $TMP_DIR/$PLUGIN_NAME-$PLUGIN_VERSION-$UNAME-1.txz | awk '{print $1}' > $TMP_DIR/$PLUGIN_NAME-$PLUGIN_VERSION-$UNAME-1.txz.md5
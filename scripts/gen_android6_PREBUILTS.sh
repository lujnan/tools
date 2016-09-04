
EABI_FORMAT="armeabi"
IS32BIT_FLAGS=
if [[ ${EABI_FORMAT} == "armeabi" ]]
then
	IS32BIT_FLAGS="true"
fi

if [[ ${EABI_FORMAT} == "arm64-v8a" ]]
then
	IS32BIT_FLAGS="false"
fi


echo ""
echo "LOCAL_PATH := \$(call my-dir)"

for i in *.so
do
	echo ""
        BASENAME=`basename $i .so`
        echo "include \$(CLEAR_VARS)"
        echo "LOCAL_MODULE := ${BASENAME}"
        echo "LOCAL_SRC_FILES := libs/${EABI_FORMAT}/$i"
	echo "LOCAL_MODULE_OWNER := rokid_arm"
        echo "LOCAL_MODULE_CLASS := SHARED_LIBRARIES"
        echo "LOCAL_MODULE_TAGS := optional"
        echo "LOCAL_MODULE_SUFFIX := .so"
	echo "LOCAL_32_BIT_ONLY   := ${IS32BIT_FLAGS}"
	echo "include \$(BUILD_PREBUILT)"
done
echo ""

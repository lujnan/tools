
EABI_FORMAT="armeabi"

if [[ ${EABI_FORMAT} == "armeabi" ]]
then
	32BITFLAGS="true"
fi

if [[ ${EABI_FORMAT} == "arm64-v8a" ]]
then
	32BITFLAGS="true"
fi

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
	echo "LOCAL_32_BIT_ONLY   := true"
        echo "LOCAL_MULTILIB := 32"
	echo "include \$(BUILD_PREBUILT)"
	echo ""
done

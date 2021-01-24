count=`ls -1 ${PROJECT_DIR}/resources/TestCredentials.plist 2>/dev/null | wc -l`
if [ $count != 0 ]; then
  cp ${PROJECT_DIR}/resources/TestCredentials.plist ${BUILT_PRODUCTS_DIR}/Fable.app/PlugIns/${PRODUCT_NAME}.xctest
fi

# Enable the prod selector once a working prod firebase proj exists
#if [ "${CONFIGURATION}" == "Debug" ]; then
  googleInfo="${PROJECT_DIR}/Env/${FABLE_IOS_ENV}/GoogleService-Info.plist"
#else
#  googleInfo="${PROJECT_DIR}/Env/Prod/GoogleService-Info.plist"
#fi

"${PODS_ROOT}/FirebaseCrashlytics/upload-symbols" -gsp $googleInfo -p ios "${DWARF_DSYM_FOLDER_PATH}/${DWARF_DSYM_FILE_NAME}"

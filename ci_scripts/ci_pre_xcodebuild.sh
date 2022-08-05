#!/bin/sh

# Declarations
ROOT_DIR="../FlaskGame"
RESOURCES_DIR="${ROOT_DIR}/Resources"
HELPERS_DIR="${ROOT_DIR}/Helpers"

WRITE_PLIST_NAME="GoogleService-Info.plist"
WRITE_AD_NAME="AdMob-Info.plist"
WRITE_HIDDEN_NAME="Hidden.swift"

# Writing files
echo $GOOGLE_SERVICE_INFO_PLIST > "${RESOURCES_DIR}/${WRITE_PLIST_NAME}"
echo $AD_MOB_PLIST > "${RESOURCES_DIR}/${WRITE_AD_NAME}"
echo $HIDDEN_SWIFT > "${HELPERS_DIR}/${WRITE_HIDDEN_NAME}"

echo "Created ${WRITE_PLIST_NAME}, ${WRITE_AD_NAME} & ${WRITE_HIDDEN_NAME} files"

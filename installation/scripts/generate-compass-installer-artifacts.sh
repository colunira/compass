#!/usr/bin/env bash

###
# Following script generates compass-installer artifacts for a release.
#
# INPUTS:
# - COMPASS_INSTALLER_PUSH_DIR - (optional) directory where kyma-installer docker image is pushed, if specified should ends with a slash (/)
# - COMPASS_INSTALLER_VERSION - version (image tag) of kyma-installer
# - ARTIFACTS_DIR - path to directory where artifacts will be stored
#
###

set -o errexit

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
RESOURCES_DIR="${CURRENT_DIR}/../resources"
INSTALLER_YAML_PATH="${RESOURCES_DIR}/installer.yaml"
INSTALLER_LOCAL_CONFIG_PATH="${RESOURCES_DIR}/installer-config-local.yaml.tpl"
INSTALLER_CR_PATH="${RESOURCES_DIR}/installer-cr.yaml.tpl"

function generateArtifact() {
    TMP_CR=$(mktemp)

    ${CURRENT_DIR}/create-cr.sh --url "" --output "${TMP_CR}" --version 0.0.1 --crtpl_path "${INSTALLER_CR_PATH}"

    ${CURRENT_DIR}/concat-yamls.sh ${INSTALLER_YAML_PATH} ${TMP_CR} \
      | sed -E ";s;image: eu.gcr.io\/kyma-project\/develop\/installer:.+;image: eu.gcr.io/kyma-project/${COMPASS_INSTALLER_PUSH_DIR}compass-installer:${COMPASS_INSTALLER_VERSION};" \
      > ${ARTIFACTS_DIR}/compass-installer.yaml

    cp ${INSTALLER_LOCAL_CONFIG_PATH} ${ARTIFACTS_DIR}/compass-config-local.yaml

    rm -rf ${TMP_CR}
}

generateArtifact

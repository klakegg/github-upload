#!/bin/sh

set -e
set -u

# Extract tag.
if [ ! "${TAG:-}" ]; then
  export TAG=$(echo $GITHUB_REF | sed "s:.*/::g")
fi

# Fetch upload url.
if [ ! "${UPLOAD_URL:-}" ]; then
  RESULT=$(curl -s \
    -u ${GITHUB_ACTOR}:${GITHUB_TOKEN} \
    https://api.github.com/repos/${GITHUB_REPOSITORY}/releases/tags/${TAG})

  if [ "$(echo $RESULT | jq -r .upload_url)" = "null" ]; then
    echo "Error while fetching release information for tag '${TAG}': $(echo $RESULT | jq -r .message)"
    exit 1
  fi

  export UPLOAD_URL=$(echo $RESULT | jq -r '.upload_url' | sed "s:{.*::g")
fi

# Verify upload url was found.
if [ ! "$UPLOAD_URL" ]; then
  echo "Unable to find release for tag '$TAG'."
  exit 1
fi

if [ "${INPUT_FILE:-}" ]; then
  # Simple file upload.
  file=$(echo ${INPUT_FILE} | envsubst)

  # Check if file exists.
  if [ ! -e $file ]; then
    echo "Unable to find '$file'."
    exit 1
  fi

  upload \
    -f "${file}" \
    -n "$(echo ${INPUT_NAME:-} | envsubst)" \
    -l "$(echo ${INPUT_LABEL:-} | envsubst)" \
    -t "$(echo ${INPUT_TYPE:-} | envsubst)"
elif [ "${INPUT_FILES:-}" ]; then
  # Upload multiple files
  for file in $(ls ${INPUT_FILES} | sort); do
    upload \
      -f $file \
      -t "$(echo ${INPUT_TYPE:-} | envsubst)"
  done
elif [ "${INPUT_SCRIPT:-}" ]; then
  # Trigger script for upload.
  sh -c "${INPUT_SCRIPT}"
elif [ "${INPUT_SCRIPT_PATH:-}" ]; then
  # Trigger script file for upload.
  path=$(echo ${INPUT_SCRIPT_PATH} | envsubst)

  # Check if file exists.
  if [ ! -e $path ]; then
    echo "Unable to find '$path'."
    exit 1
  fi

  # Trigger script for publishing.
  source $path
else
  # Lack of configuration.
  echo "Configuration is missing."
  echo "Please see https://github.com/klakegg/github-upload for information."
  exit 1
fi

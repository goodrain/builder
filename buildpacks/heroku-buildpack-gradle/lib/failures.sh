#!/usr/bin/env bash

handle_gradle_errors() {
  local log_file="$1"

  local header="Failed to run Gradle!"

  local previousVersion="You can also try reverting to the previous version of the buildpack by running:
$ heroku buildpacks:set https://github.com/goodrain/builder"

  local footer="Thanks,
Goodrain"

  if grep -qi "Task 'stage' not found in root project" "$log_file"; then
    mcount "error.no-stage-task"
    error "${header}
If you're stilling having trouble, please submit a ticket so we can help:
https://t.goodrain.com

${footer}"
  elif grep -qi "Could not find or load main class org.gradle.wrapper.GradleWrapperMain" "$log_file"; then
    mcount "error.no-gradle-jar"
    error "${header}
If you're stilling having trouble, please submit a ticket so we can help:
https://t.goodrain.com

${footer}"
  else
    mcount "error.unknown"
    error "${header}
We're sorry this build is failing. If you can't find the issue in application
code, please submit a ticket so we can help: https://t.goodrain.com
${previousVersion}

${footer}"
  fi
}

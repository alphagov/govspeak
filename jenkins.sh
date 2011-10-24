#!/bin/bash -x
bundle install --path "${HOME}/bundles/${JOB_NAME}"
bundle exec rake

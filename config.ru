# frozen_string_literal: true

# Enabling real time log (no cache)
$stdout.sync = true

require_relative "app"
run App


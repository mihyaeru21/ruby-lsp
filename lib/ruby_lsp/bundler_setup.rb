# typed: strict
# frozen_string_literal: true

require "rubygems"
require "bundler/setup"

gemfile_path = "#{Dir.pwd}/Gemfile"
ENV["BUNDLE_GEMFILE"] ||= gemfile_path if File.exist?(gemfile_path)

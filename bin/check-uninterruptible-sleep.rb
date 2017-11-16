#! /usr/bin/env ruby
# encoding: UTF-8
#
# check-uninterruptible-sleep
#
# DESCRIPTION:
# Check for processes in the uninterruptible sleep state.
#
# OUTPUT:
#   plain text
#
# PLATFORMS:
#   POSIX
#
# DEPENDENCIES:
#   gem: sensu-plugin
#
# USAGE:
#
# NOTES:
#

require 'sensu-plugin/check/cli'
require 'open3'

class CheckUninterruptibleSleep < Sensu::Plugin::Check::CLI
  option :warning_threshold,
         short: '-w THRESHOLD',
         long: '--warning-threshold THRESHOLD',
         description: 'Issue a warning if more than this number of processes are in uninterruptible sleep',
         default: 10,
         proc: proc(&:to_i)

  option :critical_threshold,
         short: '-c THRESHOLD',
         long: '--critical-threshold THRESHOLD',
         description: 'Issue a critical warning if more than this number of processes are in uninterruptible sleep',
         default: 30,
         proc: proc(&:to_i)

  def process_states
    stdout, stderr, status = Open3.capture3('ps', '-h', '-o', 's')
    raise "ps command failed with exit code #{status.exitstatus}: #{stderr}" unless status.success?
    stdout.lines
  end

  def run
    matching_processes = process_states.count { |state| state.start_with?('D') }
    message = "#{matching_processes} processes are in uninterruptible sleep"

    if matching_processes > config[:critical_threshold]
      critical(message)
    elsif matching_processes > config[:warning_threshold]
      warning(message)
    else
      ok
    end
  end
end

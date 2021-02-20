# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
# set :output, "/path/to/my/cron_log.log"
#
every 24.hours do
  start_date = Date.yesterday.strftime("%Y-%m-%d")
  end_date = (Date.yesterday - 2.days).strftime("%Y-%m-%d")
  runner "Sale.fetch_amzn_sales(#{start_date},#{end_date})"
end
#
# every 4.days do
  # runner "AnotherModel.prune_old_records"
  # rake "some:great:rake:task"
  #   command "/usr/bin/some_great_command"
# end

# Learn more: http://github.com/javan/whenever

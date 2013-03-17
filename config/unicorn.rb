rails_env = ENV['RAILS_ENV'] || 'production'
preload_app true

# number of workers - makes sure this matches memory config
worker_processes Integer(ENV['UNICORN_WORKERS'] || 2)

# restart workers if request takes too long
timeout Integer(ENV['UNICORN_TIMEOUT'] || 25)

# Only allow reasonable backlog of requests per worker
# Force load balancer to send requests elsewhere if backlogged
listen ENV['PORT'], :backlog => Integer(ENV['UNICORN_BACKLOG'] || 200)

before_fork do |server, worker|
  Signal.trap 'TERM' do
    puts 'intercepting TERM and sending myself QUIT instead'
    Process.kill 'QUIT', Process.pid
  end

  # Replace with MongoDB or whatever
  if defined?(ActiveRecord::Base)
    ActiveRecord::Base.connection_handler.clear_all_connections!
    Rails.logger.info('Disconnected from ActiveRecord')
  end
  sleep 1
end

after_fork do |server, worker|
  # Replace with MongoDB or whatever
  if defined?(ActiveRecord::Base)
    ActiveRecord::Base.connection_handler.verify_active_connections!
    Rails.logger.info('Connected to ActiveRecord')
  end
end
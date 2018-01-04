workers Integer(ENV['WEB_CONCURRENCY'] || 2)
threads_count = Integer(ENV['MAX_THREADS'] || 5)

# 若程序不是线程安全的需要将threads_count设置为1
# threads_count = 1

threads threads_count, threads_count

preload_app!

rackup      DefaultRackup
port        ENV['PORT']     || 5000
environment ENV['RACK_ENV'] || 'development'

on_worker_boot do
  # Worker specific setup for Rails 4.1+
  # See: http://docs.goodrain.com/ruby/rails-puma.html#On_worker_boot
  ActiveRecord::Base.establish_connection
end

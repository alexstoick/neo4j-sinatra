listen 1234
timeout 30
worker_processes 2
preload_app true
pid "/root/neo4j-sinatra/log/unicorn.pid"
stderr_path "/root/neo4j-sinatra/log/unicorn.stderr.log"
stdout_path "/root/neo4j-sinatra/log/unicorn.stdout.log"

before_exec do |server|
  ENV['BUNDLE_GEMFILE'] = File.expand_path('../Gemfile', File.dirname(__FILE__))
end

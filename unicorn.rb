worker_processes 1
preload_app true
listen File.expand_path('unicorn.sock', File.dirname(__FILE__))
stdout_path File.expand_path('unicorn.stdout.log', File.dirname(__FILE__))
stderr_path File.expand_path('unicorn.stderr.log', File.dirname(__FILE__))

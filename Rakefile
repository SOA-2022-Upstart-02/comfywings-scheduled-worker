# frozen_string_literal: true

USERNAME = 'chiuzu'
IMAGE = 'comfywings-update_worker'
VERSION = '0.1.0'

desc 'Build Docker image'
task :worker do
  require_relative './init'
  ComfyWings::UpdateTripWorker.new.call
end

# Docker tasks
namespace :docker do
  desc 'Build Docker image'
  task :build do
    puts "\nBUILDINGWORKER IMAGE"
    sh "docker build --force-rm -t #{USERNAME}/#{IMAGE}:#{VERSION} ."
  end

  desc 'Run the local Docker container as a worker'
  task :run do
    env = ENV['WORKER_ENV']
    puts "\nRUNNINGWORKER WITH LOCAL CONTEXT"
    puts " Running in #{env} mode"
    sh 'docker run --network="host" -e WORKER_ENV -v $(pwd)/config:/worker/config --rm -it ' \
      "#{USERNAME}/#{IMAGE}:#{VERSION}"
  end

  desc 'Remove exited container'
  task :rm do
    sh 'docker rm -v $(docker ps -a -q -f status=exited)'
  end

  desc 'List all container'
  task :ps do
    sh 'docker ps -a'
  end
end

# Heroku container registry tasks
namespace :heroku do
  desc 'Build and Push Docker image to Heroku Container Registry'
  task :push do
    puts "\nBUILDING+ PUSHING IMAGE TO HEROKU"
    sh 'heroku container:push worker'
  end

  desc 'Run worker on Heroku'
  task :run do
    puts "\nRUNNINGCONTAINER ON HEROKU"
    sh 'heroku run rake worker'
  end
end

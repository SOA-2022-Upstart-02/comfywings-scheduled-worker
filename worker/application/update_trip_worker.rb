# frozen_string_literal: true

require_relative '../../init'
require 'aws-sdk-sqs'
require 'http'

module ComfyWings
  # Setup config environment
  class UpdateTripWorker
    def initialize
      @config = UpdateTripWorker.config
      @queue = ComfyWings::Messaging::Queue.new(
        @config.UPDATE_QUEUE_URL, @config
      )
    end

    def call
      puts "Update DateTime: #{Time.now}"

      # Notify administrator of unique clones
      if update_trips.positive?
        # TODO: Email administrator instead of printing to STDOUT
        puts "\tNumber of trips updated: #{@update_trips_num}"
      else
        puts "\tNo cloning reported in this period"
      end
    end

    def update_trips
      @update_trips_num = 0
      @queue.poll do |code|
        http_response = HTTP.put("#{@config.API_HOST}/api/trips/#{code}/update")
        if http_response.status.success?
          @update_trips_num += 1
        else
          puts "Update TripQuery: #{code} failed"
        end
      end
      @update_trips_num
    end
  end
end

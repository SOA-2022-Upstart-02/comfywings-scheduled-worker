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
      if update_trips.any?
        # TODO: Email administrator instead of printing to STDOUT
        puts "\tNumber of trips updated: #{@update_trips.count}"
      else
        puts "\tNo trips updated in this period"
      end
    end

    def update_trips
      @update_trips = []
      @queue.poll do |code|
        puts code
        unless @update_trips.include? code
          http_response = HTTP.put("#{@config.API_HOST}/api/trips/#{code}/update")
          @update_trips.append(code) if http_response.status.success?
          puts "Update TripQuery: #{code} failed" unless http_response.status.success?
        end
      end
      @update_trips
    end
  end
end

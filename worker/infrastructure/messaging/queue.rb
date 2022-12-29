# frozen_string_literal: true

require 'aws-sdk-sqs'

module ComfyWings
  module Messaging
    ## Queue wrapper for AWS SQS
    # Requires: AWS credentials loaded in ENV or through config file
    class Queue
      IDLE_TIMEOUT = 5 # seconds

      def initialize(queue_url, config)
        @queue_url = queue_url
        @sqs = Aws::SQS::Client.new(
          access_key_id: config.AWS_ACCESS_KEY_ID,
          secret_access_key: config.AWS_SECRET_ACCESS_KEY,
          region: config.AWS_REGION
        )
        @queue = Aws::SQS::Queue.new(url: queue_url, client: @sqs)
      end

      ## Sends message to queue
      def send(message)
        @queue.send_message(message_body: message)
      end

      ## Polls queue, yielding each messge
      def poll
        poller = Aws::SQS::QueuePoller.new(@queue_url, client: @sqs)
        poller.poll(idle_timeout: IDLE_TIMEOUT) do |msg|
          yield msg.body if block_given?
        end
      end
    end
  end
end

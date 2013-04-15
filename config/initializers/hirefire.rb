HireFire.configure do |config|
  if Rails.env.production?
    config.environment      = :heroku
  end
  config.max_workers      = 1   # default is 1
  config.min_workers      = 0   # default is 0
  config.job_worker_ratio = [
                             { :jobs => 1,   :workers => 1 },
                             { :jobs => 15,  :workers => 1 },
                             { :jobs => 35,  :workers => 1 },
                             { :jobs => 60,  :workers => 1 },
                             { :jobs => 80,  :workers => 1 }
                            ]
end

require 'heroku-api'
module HireFire
  module Environment
    class Heroku < Base

      private

      ##
      # Either retrieves the amount of currently running workers,
      # or set the amount of workers to a specific amount by providing a value
      #
      # @overload workers(amount = nil)
      #   @param [Fixnum] amount will tell heroku to run N workers
      #   @return [nil]
      # @overload workers(amount = nil)
      #   @param [nil] amount
      #   @return [Fixnum] will request the amount of currently running workers from Heroku
      def workers(amount = nil)

        #
        # Returns the amount of Delayed Job
        # workers that are currently running on Heroku
        if amount.nil?
          return heroku.get_ps(ENV['APP_NAME']).body.select {|p| p['process'] =~ /worker.[0-9]+/}.length
        end

        ##
        # Sets the amount of Delayed Job
        # workers that need to be running on Heroku
        return heroku.post_ps_scale(ENV['APP_NAME'], "worker", amount)

      rescue ::Heroku::API::Errors::Error
        HireFire::Logger.message("Worker query request failed with #{ $!.class.name } #{ $!.message }")
        nil
      end

      ##
      # Get the heroku connection. Needs to have the HEROKU_API_KEY in the environment
      def heroku(api_key = nil)
        @heroku ||= ::Heroku::API.new(:api_key => api_key || ENV['HEROKU_API_KEY'])
      end

    end
  end
end

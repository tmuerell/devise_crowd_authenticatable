module DeviseCrowdAuthenticatable

  class Logger    
    def self.send(message, logger = Rails.logger)
      if ::Devise.crowd_logger
        logger.debug "  \e[36mCROWD:\e[0m #{message}"
      end
    end
  end

end

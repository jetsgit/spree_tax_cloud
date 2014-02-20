module Spree

  class TaxCloudResponseError < StandardError
    attr_reader :response, :response_message
    def initialize(response)
      @response = response
      if @response.present? and @response.body.present?
        @response_message  = @response.body.dig(:lookup_response, :lookup_result, :messages, :response_message, :message)
      else
        @response_message  = "An unknown error occured."
      end
    end
  end


  class TaxCloudLookupError < TaxCloudResponseError
    # Used when the response is a 200, but the API returns an error code
  end


  class TaxCloudCaptureError < TaxCloudResponseError
    # Used when the response is a 200, but the API returns an error code
  end


  class TaxCloudAPILoginMissing < StandardError
    # Used when the API login ID is not specified as a Spree preference
  end


  class TaxCloudAPIKeyMissing < StandardError
    # Used when the API key is not specified as a Spree preference
  end

  class TaxCloudOriginMissing < StandardError
    # Used when the API key is not specified as a Spree preference
  end

  class TaxCloudProductTicMissing < StandardError
    # Used when the the product tic isn't set
  end

  class TaxCloudShippingTicMissing < StandardError
    # Used when the the shipping tic isn't set
  end

end

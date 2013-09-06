class Hash

  unless Hash.method_defined?(:dig)


    # Used to safely look up deeply nested hash values
    # Usage: response.body.dig(:lookup_response, :lookup_result, :messages, :response_message, :message)
    def dig(*path)
      path.inject(self) do |location, key|
        location.respond_to?(:keys) ? location[key] : nil
      end
    end


  end
end

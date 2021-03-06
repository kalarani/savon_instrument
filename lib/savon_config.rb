# Testing transfer of reop from user to org
# Place this block in development.rb and add
#   config.middleware.use 'SavonInstrument::Middleware'
#   config.autoload_paths += %W(#{config.root}/lib)

Savon.configure do |c|
  c.hooks.define('new_hook', :soap_request) do |callback, req|
    start_time = Time.now
    response = callback.call
    soap_action = req.http.headers['SoapAction'].split("/").last.gsub("\"", '')
    SavonInstrument.add soap_action, Time.now - start_time
    response

    # test
  end
end

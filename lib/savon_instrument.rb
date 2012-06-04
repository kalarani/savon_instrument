module SavonInstrument
  class <<self
    # Resets the instrument statistics and counts
    def reset!
      $soap_calls = {}
    end

    def init #:nodoc:
      $soap_calls ||= {}
    end

    def data #:nodoc:
      $soap_calls
    end

    def add(method, time) #:nodoc:
      data[method] = time
    end
  end

  class Middleware  #:nodoc:
    def initialize(app, options = {})
      @app = app
    end

    def call(env)
      SavonInstrument.reset!
      status, headers, body = @app.call(env)
      begin
        if html_reponse?(headers)
          new_body = Rack::Response.new([], status, headers)
          # raise 'In the middle of nowhere'
          body.each do |fragment|
            new_body.write fragment.gsub("</body>", "#{sql_html_overlay}</body>")
          end
          body = new_body
        end
      rescue => e
        headers["X-Savon-Instrument"] = "Error"
      end

      [status, headers, body]
    end

    private
    def html_reponse?(headers)
      headers['Content-Type'] =~ /html/
    end

    def sql_html_overlay
      html = SavonInstrument.data.collect do |key, value|
        "<div>#{key} : #{value}s</div>"
      end.join
      %Q{<div style="position: fixed; bottom: 0pt; right: 0pt; cursor: pointer; border-style: solid; border-color: rgb(153, 153, 153); -moz-border-top-colors: none; -moz-border-right-colors: none; -moz-border-bottom-colors: none; -moz-border-left-colors: none; -moz-border-image: none; border-width: 2pt 0pt 0px 2px; padding: 5px; border-radius: 10pt 0pt 0pt 0px; background: none repeat scroll 0% 0% rgba(200, 200, 200, 0.8); color: rgb(119, 119, 119); font-size: 18px;" title="DB query counts / duration (For Development purpose only)">#{html}</div>}
    end
  end
end


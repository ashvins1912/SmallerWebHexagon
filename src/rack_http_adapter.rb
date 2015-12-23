require 'rack'
require_relative '../src/html_from_template_file'


# Primary adapter to SmallerWebHexagon, using Rack for web-type I/O

class RackHttpAdapter

  def initialize( hex_app, views_folder )
    @app = hex_app
    @views_folder = views_folder
  end


  def call(env) # hooks into the Rack Request chain

    request = Rack::Request.new( env )
    value =  path_as_number(request)

    rate, result = @app.rate_and_result  value

    out = {
        out_action:   "result_view",
        value:  value,
        rate:   rate,
        result: result
    }

    template_file_path = @views_folder + out[:out_action] + ".erb"
    page = html_from_template_file( template_file_path , binding )

    response = Rack::Response.new
    response.write( page )
    response.finish
  end

  private

  # ==== utilities for reading a Rack Request ====

  def path_as_number(request)
    number_or_zero( path_contents(request) )
  end

  def path_contents(request)
    request.path[ 1..request.path.size ]
  end

  def number_or_zero( s ) # convert string to a number, zero if not a number
    i= s.to_i
    i.to_s == s ? i : 0
  end

end

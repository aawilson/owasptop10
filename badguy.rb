require 'rubygems'

require 'config/environment'

require 'haml'
require 'openssl'
require 'sinatra/base'
require 'securerandom'

class BadGuy < Sinatra::Base
  set :haml, :format => :html5

  get // do
    p request.inspect

    response.headers['Access-Control-Allow-Origin'] = '*'
    "OK"
  end

end

server = Rack::Handler::WEBrick

trap(:INT) do
  if server.respond_to?(:shutdown)
    server.shutdown
  else
    exit
  end
end

server.run BadGuy, BadGuyAppOptions.webrick_options

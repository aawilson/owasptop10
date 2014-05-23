require 'rubygems'

require 'config/environment'

require 'haml'
require 'openssl'
require 'sinatra/base'
require 'sinatra/flash'

Dir[File.join(File.dirname(__FILE__), 'models', '*.rb')].each {|file| require file }

class CatchPhrase < Sinatra::Base
  set :haml, :format => :html5
  enable :sessions
  register Sinatra::Flash

  #before do
  #  set_logged_in_user
  #  set_sites
  #end

  get '/' do
    haml :index
  end

  post '/get_catchphrases' do
    @username = params[:username]
    @results = ActiveRecord::Base.connection.execute(
      "SELECT c.catchphrase FROM catchphrases AS c JOIN users AS u ON c.user_id = u.id WHERE u.username = '#{@username}'"
    )
    haml :index
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

server.run CatchPhrase, CatchPhraseAppOptions.webrick_options

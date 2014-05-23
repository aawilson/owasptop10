require 'rubygems'

require 'config/environment'

require 'haml'
require 'openssl'
require 'sinatra/base'
require 'sinatra/flash'
require 'securerandom'

Dir[File.join(File.dirname(__FILE__), 'models', '*.rb')].each {|file| require file }

class CatchPhrase < Sinatra::Base
  set :haml, :format => :html5
  enable :sessions
  register Sinatra::Flash

  before do
    set_logged_in_user
  end

  def set_logged_in_user
    if request.cookies['sessid']
      @sessid = request.cookies['sessid']
      session = Session.find_by_sessid(@sessid)
      if session.nil?
        response.set_cookie 'sessid', nil
      else
        @user = session.user
      end
    end
  end

  get '/' do
    haml :index
  end

  post '/get_catchphrases' do
    @username = params[:username]

    @results = User.find_by_username(@username).catchphrases
    haml :index
  end

  get '/dashboard' do
    if @user.nil?
      flash[:notice] = "Woops, can't go there without being logged in."
      redirect to('/') and return
    end
    haml :dashboard
  end

  post '/login' do
    username = params[:username]
    password = params[:password]

    user = User.find_by_username(username)

    if user and user.password == password
      sessid = SecureRandom.hex(32)
      Session.create(:user => user, :sessid => sessid)
      response.set_cookie 'sessid', sessid
      redirect to("/dashboard") and return
    end

    flash.now[:notice] =  "Sorry, username/password combination didn't match"
    haml :index
  end

  get '/logout' do
    session = Session.find_by_sessid(request.cookies['sessid'])
    session.destroy unless session.nil?
    response.set_cookie 'sessid', nil
    redirect to('/')
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

Session.all.each{|s|s.destroy}
server.run CatchPhrase, CatchPhraseAppOptions.webrick_options

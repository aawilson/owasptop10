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

  def require_auth
    if @user.nil?
      flash[:notice] = "Woops, can't go there without being logged in."
      redirect to('/') and return
    end
  end

  def set_logged_in_user
    p "set_logged_in_user"
    unless request.cookies['sessid'].nil? || request.cookies['sessid'].empty?
      p "  found cookie: #{request.cookies['sessid']}"
      @sessid = request.cookies['sessid']
      session = Session.find_by_sessid(@sessid)
      @all_users = User.all
      if session.nil?
        p "that session is DEAD"
        response.set_cookie 'sessid', nil
      else
        @user = session.user
        p "user set: #{@user.id} #{@user.username}"
      end
    end
  end

  get '/' do
    haml :index
  end

  post '/get_catchphrases' do
    @username = params[:username]

    @queried_user = User.find_by_username(@username)

    unless @queried_user.nil?
      @results = @queried_user.catchphrases
    end

    haml :index
  end

  post '/leave_message' do
    message = params[:message]
    for_user = User.find params[:for_user_id]

    if for_user.nil?
      flash[:notice] = "Whoops, couldn't find that user!"
      redirect to('/') and return
    else
      Message.create(:user => for_user, :message => message)
      flash.now[:notice] = "Sent the message! Feel proud!"
    end
    haml :index
  end

  get '/dashboard' do
    require_auth
    haml :dashboard
  end

  get '/list_messages/:for_user_id' do
    require_auth
    begin
      @messages = User.find(params[:for_user_id]).messages
    rescue ActiveRecord::RecordNotFound
      flash[:notice] = "No user with that id"
      redirect to('/') and return
    end

    haml :messages
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

  get '/clear_all_messages' do
    Message.all.each { |m| m.destroy}
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

Session.all.each{|s|s.destroy}
server.run CatchPhrase, CatchPhraseAppOptions.webrick_options

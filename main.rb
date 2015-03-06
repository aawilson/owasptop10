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
    @user = User.find_by_id(session[:user_id])
    @all = {}
    [User, Catchphrase, Message].each do |model|
      @all[model.name] = model.all
    end
  end

  def require_auth
    p "require_auth: #{@user.inspect}"
    if @user.nil?
      flash[:notice] = "Woops, can't go there without being logged in."
      redirect to('/') and return
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
      queried_user = User.find(params[:for_user_id])
      unless @user.is_allowed_to_see_messages_for queried_user
        flash[:notice] = "You are not allowed to see those messages! BACK OFF"
        redirect to('/dashboard') and return
      end

      @messages = queried_user.messages
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
      session[:user_id] = user.id
      redirect to("/dashboard") and return
    end

    flash.now[:notice] =  "Sorry, username/password combination didn't match"
    haml :index
  end

  get '/logout' do
    session[:user_id] = nil
    session.clear
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

server.run CatchPhrase, CatchPhraseAppOptions.webrick_options

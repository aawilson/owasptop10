require 'logger'
require 'net/https'
require 'uri'

require 'rubygems'

require 'active_record'
require 'stripe'
require 'webrick'
require 'webrick/https'

Dir[File.join(File.dirname(__FILE__), 'models', '*.rb')].each {|file| require file }

module CatchPhraseAppOptions
  def webrick_options
    {
      :Port => 8000,
      :Logger => WEBrick::Log::new($stderr, WEBrick::Log::DEBUG),
      :DocumentRoot => File.join(File.dirname(__FILE__), 'public'),
    }
  end

  def webrick_options_ssl
    webrick_options.merge({
      :Port => 8444,
      :SSLEnable => true,
      :SSLVerifyClient => OpenSSL::SSL::VERIFY_NONE,
      :SSLCertificate => OpenSSL::X509::Certificate.new(
        File.open("server.crt").read
        ),
      :SSLPrivateKey => OpenSSL::PKey::RSA.new(
        File.open("server.key").read
        ),
      :SSLCertName => [["CN", WEBrick::Utils::getservername]],
    })
  end

  self.module_eval do
    module_function :webrick_options
    public :webrick_options
    module_function :webrick_options_ssl
    public :webrick_options_ssl
  end
end

module BadGuyAppOptions
  def webrick_options
    {
      :Port => 8666,
      :Logger => WEBrick::Log::new($stderr, WEBrick::Log::DEBUG),
      :DocumentRoot => File.join(File.dirname(__FILE__), 'public'),
    }
  end

  self.module_eval do
    module_function :webrick_options
    public :webrick_options
  end
end

ActiveRecord::Base.establish_connection(
  :adapter => 'sqlite3',
  :database => 'owasptop10.sqlite3.db'
)

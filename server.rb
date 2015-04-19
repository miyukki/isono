require 'sinatra'
require 'sinatra/reloader' if development?
require 'active_record'
require 'mysql2'
require 'simpleidn'

DOMAIN_PREFIX = 'おーい磯野'

# DB設定ファイルの読み込み
ActiveRecord::Base.configurations = YAML.load_file('database.yml')
ActiveRecord::Base.establish_connection('development')

get '/' do
  orig_host = request.env['SERVER_NAME']
  # host = host.gsub('lvh.me', 'xn--p8j7aq8o.jp')

  # domain strict
  domain = SimpleIDN.to_unicode(orig_host).split('.')
  # if domain.size > 4
    # redirect request.env['REQUEST_URI'].gsub(orig_host, SimpleIDN.to_ascii(domain.join('.')))
  # end
  if domain[0] != DOMAIN_PREFIX
    redirect request.env['REQUEST_URI'].gsub(orig_host, SimpleIDN.to_ascii(domain.unshift(DOMAIN_PREFIX).join('.')))
  end

  @purpose = domain[1]
  @title = "#{DOMAIN_PREFIX}！#{@purpose}しようぜ！"
  haml :index
end

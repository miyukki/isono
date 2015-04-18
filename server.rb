require 'sinatra'
require 'sinatra/reloader' if development?
require 'active_record'
require 'mysql2'
require 'simpleidn'

DOMAIN_PREFIX = 'おーい磯野'

# DB設定ファイルの読み込み
ActiveRecord::Base.configurations = YAML.load_file('database.yml')
ActiveRecord::Base.establish_connection('development')

class Topic < ActiveRecord::Base
end

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
  p domain
  # @a = "aa"

  @purpose = domain[1]
  haml :index
end
#
# # 最新トピック10件分を取得
# get '/topics.json' do
#   content_type :json, :charset => 'utf-8'
#   topics = Topic.order("created_at DESC").limit(10)
#   topics.to_json(:root => false)
# end
#
# # トピック投稿
# post '/topic' do
#   # リクエスト解析
#   reqData = JSON.parse(request.body.read.to_s)
#   title = reqData['title']
#   description = reqData['description']
#
#   # データ保存
#   topic = Topic.new
#   topic.title = title
#   topic.description = description
#   topic.save
#
#   # レスポンスコード
#   status 202
# end

require 'sinatra'
require 'sinatra/base'
require 'sinatra/config_file'
require 'sinatra/activerecord'
require 'sinatra/reloader' if development?
require 'active_record'
require 'mysql2'
require 'simpleidn'
require 'twitter'
require 'rufus/scheduler'
require_relative 'models/tweet'
require_relative 'models/recreation'

set :database, { adapter: 'sqlite3', database: 'database.sqlite3' }

DOMAIN_PREFIX = 'おーい磯野'

class Isono
  def initialize(setting)
    @client = Twitter::REST::Client.new do |config|
      config.consumer_key        = setting[:consumer_key]
      config.consumer_secret     = setting[:consumer_secret]
      config.access_token        = setting[:access_token]
      config.access_token_secret = setting[:access_token_secret]
    end
  end

  def refresh_tweet!
    recreation = Recreation.order('updated_at ASC').first
    return if recreation.blank?

    recreation.touch
    keyword = "#{DOMAIN_PREFIX}.#{recreation.name}.しようぜ.jp"
    self.search!(recreation, SimpleIDN.to_ascii(keyword))
  end

  def search!(recreation, keyword)
    results = @client.search(keyword, result_type: 'recent')
    results.each do |status|
      next if status.retweet?
      tweet = Tweet.find_or_initialize_by(tweet_id: status.id)
      tweet.update(recreation: recreation, tweet_id: status.id, screen_name: status.user.screen_name, text: status.text)
      tweet.save
    end
  end
end

class MainApp < Sinatra::Base
  register Sinatra::ConfigFile
  config_file './config.yml'

  isono = Isono.new(settings.twitter)
  scheduler = Rufus::Scheduler.new

  scheduler.every '15s' do
    isono.refresh_tweet!
  end

  get '/' do
    orig_host = request.env['SERVER_NAME']
    domain = SimpleIDN.to_unicode(orig_host).split('.')
    if domain[0] != DOMAIN_PREFIX
      redirect request.env['REQUEST_URI'].gsub(orig_host, SimpleIDN.to_ascii(domain.unshift(DOMAIN_PREFIX).join('.')))
    end

    @recreation = Recreation.find_or_create_by(name: domain[1])
    tweet_counts = Tweet.group(:recreation_id).order('count_id DESC').count('id').select { |k, v| v != 0 }
    @popular_recreations = Recreation.where(id: tweet_counts.keys)
    @title = "#{DOMAIN_PREFIX}！#{@recreation.name}しようぜ！"
    haml :index
  end
end

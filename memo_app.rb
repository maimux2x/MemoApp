# frozen_string_literal: true

require 'sinatra'
require 'sinatra/reloader'
require 'json'
require 'securerandom'

set :show_exceptions, :after_handler

FILE_NAME = 'memos.json'

# メモのインスタンスを作成し保存
class BaseMemosData
  attr_accessor :params

  def initialize(params)
    params['id'] = SecureRandom.uuid

    created_at = Time.new
    params['created_at'] = created_at.strftime('%Y年%m月%d日%H時%M分')
    @params = params
  end

  def self.register(file_name, memo)
    base_memos = JSON.parse(File.read(file_name))
    base_memos << memo

    BaseMemosData.update(file_name, base_memos)
  end

  def self.update(file_name, memo)
    File.open(file_name, 'w') do |file|
      JSON.dump(memo, file)
    end
  end
end

before '/memos/:id*' do
  @memos = get_memos(FILE_NAME)
  @memos.each do |hash|
    @memo_data = hash if hash['id'] == params['id']
  end
end

helpers do
  def request_accept?(url)
    raise StandardError unless request.accept?(url)
  end
end

helpers do
  def get_memos(file_name)
    @memos = JSON.parse(File.read(file_name))
  end
end

helpers do
  def h(text)
    Rack::Utils.escape_html(text)
  end
end

error StandardError do
  puts "エラーが発生しました。 - #{env['sinatra.error'].message}"
  erb :not_found
end

get '/memos' do
  @all_memos = get_memos(FILE_NAME)
  erb :index
end

get '/' do
  redirect '/memos'
end

get '/memos/new' do
  erb :new
end

post '/memos' do
  raw_memo = BaseMemosData.new(params)
  memo = raw_memo.params

  BaseMemosData.register(FILE_NAME, memo)

  redirect '/memos'
end

get '/memos/:id' do
  request_accept?('/memos/:id')

  @memo = @memo_data
  erb :show
end

get '/memos/:id/edit' do
  request_accept?('/memos/:id/edit')

  @memo = @memo_data
  erb :edit
end

patch '/memos/:id' do
  @memo_data['title'] = params['title']
  @memo_data['memo_desc'] = params['memo_desc']

  BaseMemosData.update(FILE_NAME, @memos)
  redirect "/memos/#{@memo_data['id']}"
end

delete '/memos/delete/:id' do
  all_memos = get_memos('memos.json')
  all_memos.each do |memo|
    all_memos -= [memo] if memo['id'] == params['id']
  end

  BaseMemosData.update(FILE_NAME, all_memos)
  redirect '/memos'
end

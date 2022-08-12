# frozen_string_literal: true

require 'sinatra'
require 'sinatra/reloader'
require 'securerandom'
require_relative 'memosdata_connection'

TABLE = 'memosdata'
CONNECTION = MemosDataConnection.connect

set :show_exceptions, :after_handler

# メモのインスタンスを作成し保存
class BaseMemosData
  attr_accessor :params

  def initialize(params)
    params['id'] = SecureRandom.uuid
    created_at = Time.new
    params['created_at'] = created_at
    @params = params
  end

  def self.register(memo)
    CONNECTION.prepare(
      'insert_memo',
      "insert into #{TABLE} (id, title, memo_desc, created_at) values ($1, $2, $3, $4)"
    )
    CONNECTION.exec_prepared(
      'insert_memo',
      [memo['id'].to_s, memo['title'].to_s, memo['memo_desc'].to_s, memo['created_at'].to_s]
    )
  end

  def self.update(params)
    CONNECTION.prepare(
      'update_memo',
      "update #{TABLE} set title = $1, memo_desc = $2 where id = $3"
    )
    CONNECTION.exec_prepared(
      'update_memo',
      [params['title'].to_s, params['memo_desc'].to_s, params['id'].to_s]
    )
  end

  def self.delete(memo)
    CONNECTION.prepare(
      'delete_memo',
      "delete from #{TABLE} where id = $1"
    )
    CONNECTION.exec_prepared(
      'delete_memo', [memo['id'].to_s]
    )
  end
end

before '/memos/:id*' do
  @memos = get_memosdata(TABLE)
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
  def get_memosdata(table)
    CONNECTION.exec("select * from #{table}")
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
  @all_memos = get_memosdata(TABLE)
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

  BaseMemosData.register(memo)

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
  BaseMemosData.update(params)
  redirect "/memos/#{@memo_data['id']}"
end

delete '/memos/delete/:id' do
  all_memos = get_memosdata(TABLE)
  all_memos.each do |memo|
    BaseMemosData.delete(memo) if memo['id'] == params['id']
  end
  redirect '/memos'
end

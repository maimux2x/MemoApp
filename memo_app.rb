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
  attr_accessor :title, :memo_desc, :id, :created_at

  def initialize(title, memo_desc)
    @id = SecureRandom.uuid
    @title = title
    @memo_desc = memo_desc
    @created_at = Time.new
  end

  def self.register(id, title, memo_desc, created_at)
    CONNECTION.exec_params(
      "insert into #{TABLE} values ($1, $2, $3, $4)",
      [id, title, memo_desc, created_at]
    )
  end

  def self.update(title, memo_desc, id)
    CONNECTION.exec_params(
      "update #{TABLE} set title = $1, memo_desc = $2 where id = $3",
      [title, memo_desc, id]
    )
  end

  def self.delete(id)
    CONNECTION.exec_params(
      "delete from #{TABLE} where id = $1", [id]
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
  raw_memo = BaseMemosData.new(params['title'], params['memo_desc'])

  BaseMemosData.register(
    raw_memo.id, raw_memo.title, raw_memo.memo_desc, raw_memo.created_at
  )

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
  BaseMemosData.update(params['title'], params['memo_desc'], @memo_data['id'])
  redirect "/memos/#{@memo_data['id']}"
end

delete '/memos/delete/:id' do
  all_memos = get_memosdata(TABLE)
  all_memos.each do |memo|
    BaseMemosData.delete(memo['id']) if memo['id'] == params['id']
  end
  redirect '/memos'
end

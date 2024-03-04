# frozen_string_literal: true

require 'sinatra'
require 'sinatra/reloader'
require 'cgi'
require 'json'
require 'securerandom'

MEMOS_FILE = 'memos.json'

not_found do
  'ページが見つかりません!'
end

def load_memo
  JSON.parse(File.read(MEMOS_FILE), symbolize_names: true)
end

def add_memo(params)
  existing_data = load_memo
  existing_data[SecureRandom.uuid] = { title: params[:title], content: params[:content], created_at: Time.now, updated_at: Time.now }
  save_memo(existing_data)
end

def update_memo(params, memo, existing_data)
  memo.merge!(title: params[:title], content: params[:content], updated_at: Time.now)
  save_memo(existing_data)
end

def delete_memo(params)
  existing_data = load_memo
  existing_data.delete(params[:id].to_sym)
  save_memo(existing_data)
end

def save_memo(existing_data)
  File.write(MEMOS_FILE, JSON.pretty_generate(existing_data))
end

def find_memo(params)
  existing_data = load_memo
  memo = existing_data[params[:id].to_sym]
  if memo && params[:title] || params[:content]
    update_memo(params, memo, existing_data)
  else
    memo
  end
end

get '/' do
  @memos = load_memo
  erb :index
end

get '/new' do
  erb :new
end

post '/create' do
  add_memo(params)
  redirect '/'
end

get '/:id' do
  @memo = find_memo(params)
  if @memo.nil?
    status 404
  else
    erb :show
  end
end

get '/:id/edit' do
  @memo = find_memo(params)
  erb :edit
end

patch '/:id/update' do
  find_memo(params)
  redirect "/#{params[:id]}"
end

delete '/:id/destroy' do
  delete_memo(params)
  redirect '/'
end

helpers do
  def escape_html(text)
    CGI.escapeHTML(text)
  end
end

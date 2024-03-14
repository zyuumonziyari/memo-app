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

def load_memos
  JSON.parse(File.read(MEMOS_FILE), symbolize_names: true)
end

def add_memo(params)
  memos = load_memos
  memos[SecureRandom.uuid] = { title: params[:title], content: params[:content], created_at: Time.now, updated_at: Time.now }
  save_memo(memos)
end

def update_memo(params)
  memos = load_memos
  memos[params[:id].to_sym].merge!(title: params[:title], content: params[:content], updated_at: Time.now)
  save_memo(memos)
end

def delete_memo(id)
  memos = load_memos
  memos.delete(id.to_sym)
  save_memo(memos)
end

def save_memo(memos)
  File.write(MEMOS_FILE, JSON.pretty_generate(memos))
end

def find_memo(id)
  memos = load_memos
  memos[id.to_sym]
end

get '/' do
  @memos = load_memos
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
  @memo = find_memo(params[:id])
  if @memo.nil?
    status 404
  else
    erb :show
  end
end

get '/:id/edit' do
  @memo = find_memo(params[:id])
  if @memo.nil?
    status 404
  else
    erb :edit
  end
end

patch '/:id/update' do
  if find_memo(params[:id]).nil?
    status 404
  else
    update_memo(params)
    redirect "/#{params[:id]}"
  end
end

delete '/:id/destroy' do
  if find_memo(params[:id]).nil?
    status 404
  else
    delete_memo(params[:id])
    redirect '/'
  end
end

helpers do
  def escape_html(text)
    CGI.escapeHTML(text)
  end
end

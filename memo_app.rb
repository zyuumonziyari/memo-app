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

def add_memos(params)
  existing_data = load_memos
  existing_data << { id: SecureRandom.uuid, title: params[:title], content: params[:content], created_at: Time.now, updated_at: Time.now }
  save_memos(existing_data)
end

def update_memos(params)
  existing_data = load_memos
  updating_data = existing_data.find { |memo| memo[:id] == params[:id] }
  updating_data.merge!(title: params[:title], content: params[:content], updated_at: Time.now)
  save_memos(existing_data)
end

def delete_memos(params)
  existing_data = load_memos
  destroyed_data = existing_data.reject! { |memo| memo[:id] == params[:id] }
  save_memos(destroyed_data)
end

def save_memos(indicated_data)
  File.write(MEMOS_FILE, JSON.pretty_generate(indicated_data))
end

def find_memo(params)
  existing_data = load_memos
  existing_data.find { |memo| memo[:id] == params }
end

get '/' do
  @memos = load_memos
  erb :index
end

get '/new' do
  erb :new
end

post '/create' do
  add_memos(params)
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
  erb :edit
end

patch '/:id/update' do
  update_memos(params)
  redirect "/#{params[:id]}"
end

delete '/:id/destroy' do
  delete_memos(params)
  redirect '/'
end

helpers do
  def escape_html(text)
    CGI.escapeHTML(text)
  end
end

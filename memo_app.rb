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

def save_memos(indicated_data)
  File.write(MEMOS_FILE, JSON.pretty_generate(indicated_data))
end

def find_memo(existing_data)
  existing_data.find { |memo| memo[:id] == params[:id] }
end

def assign_id
  SecureRandom.uuid
end

get '/' do
  @memos = load_memos
  erb :index
end

get '/new' do
  erb :new
end

post '/create' do
  existing_data = load_memos
  existing_data << { id: assign_id, title: params[:title], content: params[:content], created_at: Time.now, updated_at: Time.now }
  save_memos(existing_data)
  redirect '/'
end

get '/:id' do
  existing_data = load_memos
  @memo = find_memo(existing_data)
  if @memo.nil?
    status 404
  else
    erb :show
  end
end

get '/:id/edit' do
  existing_data = load_memos
  @memo = find_memo(existing_data)
  erb :edit
end

patch '/:id/update' do
  existing_data = load_memos
  original_data = find_memo(existing_data)
  original_data.merge!(title: params[:title], content: params[:content], updated_at: Time.now)
  save_memos(existing_data)
  redirect "/#{original_data[:id]}"
end

delete '/:id/destroy' do
  existing_data = load_memos
  destroyed_data = existing_data.reject! { |memo| memo[:id] == params[:id] }
  save_memos(destroyed_data)
  redirect '/'
end

helpers do
  def escape_html(text)
    CGI.escapeHTML(text)
  end
end

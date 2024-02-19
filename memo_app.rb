# frozen_string_literal: true

require 'sinatra'
require 'sinatra/reloader'
require 'cgi'
require 'json'
require 'securerandom'

MEMOS_FILE = 'memos.json'

not_found do
  json(message: '404 Not Found.')
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

existing_data = load_memos

before do
  @memos = existing_data
end

get '/' do
  erb :index
end

get '/new' do
  erb :new
end

post '/create' do
  created_data = existing_data << { id: assign_id, title: params[:title], content: params[:content], created_at: Time.now.to_s, updated_at: Time.now.to_s }
  save_memos(created_data)
  redirect '/'
end

get '/:id' do
  @memo = find_memo(existing_data)
  erb :show
end

get '/:id/edit' do
  @memo = find_memo(existing_data)
  erb :edit
end

patch '/:id/update' do
  @memo = find_memo(existing_data)
  @memo.merge!({ title: params[:title], content: params[:content], updated_at: Time.now.to_s })
  updated_data = existing_data
  save_memos(updated_data)
  redirect "/#{@memo[:id]}"
end

delete '/:id/destroy' do
  destroyed_data = existing_data.reject! { |memo| memo[:id] == params[:id] }
  save_memos(destroyed_data)
  redirect '/'
end

helpers do
  def escape_html(text)
    CGI.escapeHTML(text)
  end

  def assign_id
    SecureRandom.uuid
  end
end

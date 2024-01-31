# frozen_string_literal: true

require 'sinatra'
require 'sinatra/reloader'
require 'cgi'
require 'json'

MEMOS_FILE = 'memos.json'

before do
  @memos = load_memos
end

get '/' do
  erb :index
end

get '/new' do
  erb :new
end

post '/create' do
  title = CGI.escapeHTML(params[:title])
  content = CGI.escapeHTML(params[:content])
  memo = { id: assign_id, title:, content:, created_at: Time.now.to_s, updated_at: Time.now.to_s }
  @memos << memo
  save_memos
  redirect '/'
end

get '/:id' do
  @memo = @memos.find { |memo| memo[:id] == params[:id].to_i }
  erb :show
end

get '/:id/edit' do
  @memo = @memos.find { |memo| memo[:id] == params[:id].to_i }
  erb :edit
end

patch '/:id/update' do
  @memo = @memos.find { |memo| memo[:id] == params[:id].to_i }
  @memo[:title] = CGI.escapeHTML(params[:title])
  @memo[:content] = CGI.escapeHTML(params[:content])
  @memo[:updated_at] = Time.now.to_s
  save_memos
  redirect "/#{@memo[:id]}"
end

delete '/:id/destroy' do
  @memos.reject! { |memo| memo[:id] == params[:id].to_i }
  save_memos
  redirect '/'
end

not_found do
  json(message: '404 Not Found.')
end

helpers do
  def load_memos
    JSON.parse(File.read(MEMOS_FILE), symbolize_names: true)
  end

  def save_memos
    File.write(MEMOS_FILE, JSON.pretty_generate(@memos))
  end

  def assign_id
    @memos.empty? ? 1 : @memos.last[:id] + 1
  end
end

# frozen_string_literal: true

require 'sinatra'
require 'sinatra/reloader'
require 'cgi'
require 'pg'

not_found do
  'ページが見つかりません!'
end

def connect_db
  @connect_db ||= PG.connect(dbname: 'memo_app')
end

configure do
  result = connect_db.exec("SELECT * FROM information_schema.tables WHERE table_name = 'memos'")
  if result.values.empty?
    connect_db.exec(<<CREATE_TABLE_SQL)
      CREATE TABLE memos (
        id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
        title VARCHAR(255) NOT NULL,
        content TEXT,
        created_at TIMESTAMP WITH TIME ZONE NOT NULL,
        updated_at TIMESTAMP WITH TIME ZONE NOT NULL
      );
CREATE_TABLE_SQL
  end
end

def load_memos
  connect_db.exec('SELECT * FROM memos ORDER BY updated_at DESC')
end

def add_memo(params)
  connect_db.exec_params('INSERT INTO memos(title, content, created_at) VALUES ($1, $2, $3);', [params['title'], params['content'], Time.now])
end

def update_memo(params)
  connect_db.exec_params('UPDATE memos SET title = $1, content = $2, updated_at = $3 WHERE id = $4;',
                         [params['title'], params['content'], Time.now, params['id']])
end

def delete_memo(id)
  connect_db.exec_params('DELETE FROM memos WHERE id = $1;', [id])
end

def search_memo(id)
  search_result = connect_db.exec_params('SELECT * FROM memos WHERE id = $1;', [id])
  search_result.tuple_values(0)
end

get '/' do
  @memos = load_memos
  erb :index
end

get '/new' do
  erb :new
end

post '/create' do
  title = params['title']
  if title.empty?
    show_error_message
    erb :new
  else
    add_memo(params)
    redirect '/'
  end
end

get '/:id' do
  @memo = search_memo(params['id'])
  if @memo.nil?
    status 404
  else
    erb :show
  end
end

get '/:id/edit' do
  memo = search_memo(params['id'])
  if memo.nil?
    status 404
  else
    @title, @content = memo[1..2]
    erb :edit
  end
end

patch '/:id/update' do
  title, content = params.values_at('title', 'content')
  if search_memo(params['id']).nil?
    status 404
  elsif title.empty?
    @content = content
    show_error_message
    erb :edit
  else
    update_memo(params)
    redirect "/#{params['id']}"
  end
end

delete '/:id/destroy' do
  if search_memo(params['id']).nil?
    status 404
  else
    delete_memo(params['id'])
    redirect '/'
  end
end

helpers do
  def escape_html(text)
    CGI.escapeHTML(text)
  end

  def determine_form_value(text)
    text.nil? ? '' : escape_html(text.to_s)
  end

  def show_error_message
    @error_message = 'titleを入力してください'
  end
end

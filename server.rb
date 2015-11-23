
require "sinatra"
require "pg"
require_relative "./app/models/article"

set :views, File.join(File.dirname(__FILE__), "app/views")

configure :development do
  set :db_config, { dbname: "news_aggregator_development" }
end

configure :test do
  set :db_config, { dbname: "news_aggregator_test" }
end

def db_connection
  begin
    connection = PG.connect(Sinatra::Application.db_config)
    yield(connection)
  ensure
    connection.close
  end
end

get "/articles" do
  db_connection do |conn|
    @articles = conn.exec("SELECT title, description, url FROM articles")
  end
  erb :articles
end

get "/articles/new" do
  erb :articles_new
end

post "/articles/new" do
  db_connection do |conn|
    conn.exec_params("INSERT INTO articles (title, description, url)
    VALUES ($1, $2, $3);",
    [params["title"], params["description"], params["url"]])
  end
  redirect "/articles"
end

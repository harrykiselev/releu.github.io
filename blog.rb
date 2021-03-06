require "tilt"
require "sinatra"
require "slim"
require "sass"

Post = Struct.new(:id, :name, :title, :body, :description, :date)

def load_posts
  post_paths = Dir["./posts/*.slim"].sort_by do |post_path|
    index = post_path[%r{\./posts/(\d+)-(.*)\.slim}, 1]
    index.to_i
  end

  post_paths.map do |post_path|
    id = post_path[%r{\./posts/(\d+)-(.*)\.slim}, 1]
    name = post_path[%r{\./posts/(\d+)-(.*)\.slim}, 2]
    config = File.read(post_path).lines.first(3)
    title, desc, date = config.map do |line|
      line.sub(/^- #/, "").strip
    end
    date = Date.parse(date).rfc822
    body = Slim::Template.new(post_path).render
    Post.new(id, name, title, body, desc, date)
  end
end

get "/" do
  @posts = load_posts
  @post = @posts.last

  idx = @posts.find_index { |p| p.name == @post.name }

  @post = @posts[idx]
  if idx > 0
    @prev_post = @posts[idx - 1]
  end
  @next_post = @posts[idx + 1]

  slim :post
end

get "/feed" do
  @posts = load_posts
  content_type :atom, :charset => "utf-8"
  slim :feed, :layout => false
end

get "/posts/:name" do
  @posts = load_posts
  idx = @posts.find_index { |p| p.name == params[:name] }

  @post = @posts[idx]
  if idx > 0
    @prev_post = @posts[idx - 1]
  end
  @next_post = @posts[idx + 1]

  slim :post
end

get "/application.css" do
  scss :application
end

task :deploy do
  require "securerandom"
  require "rack/test"
  require "tilt"
  require "./blog.rb"

  branch = SecureRandom.hex
  system "git checkout -b #{branch}"

  bro = Rack::Test::Session.new(Rack::MockSession.new(Sinatra::Application))

  def save_body_to_file(body, filename)
    File.open("./#{filename}", "wb") do |f|
      f.write body
    end
  end

  # save index
  save_body_to_file bro.get("/").body, "index.html"

  # save posts
  load_posts.each do |post|
    save_body_to_file bro.get("/posts/#{post.name}").body, "#{post.name}.html"
  end

  # save stylesheet
  save_body_to_file bro.get("/application.css").body, "application.css"

  # save images
  system "mv ./public/* ./"
  system "git add ."
  system "git commit -am 'publish'"
  system "git push origin #{branch}:gh-pages --force"
  system "git checkout master"
  system "git branch -D #{branch}"
end

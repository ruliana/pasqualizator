require "sinatra/base"

class App < Sinatra::Base
  get "/" do
    "Hello, world!"
  end
end

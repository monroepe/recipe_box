require 'sinatra'
require 'sinatra/reloader'
require 'pry'
require 'pg'

def db_connection
  begin
    connection = PG.connect(dbname: 'recipes')

    yield(connection)

  ensure
    connection.close
  end
end


def get_recipes
  query = 'SELECT recipes.id, recipes.name
    FROM recipes
    ORDER BY recipes.name;'

  recipes = db_connection do |conn|
      conn.exec(query)
  end
  recipes
end

def get_recipe(id)

end





get '/' do
  redirect '/recipes'
end

get '/recipes' do
  recipes = get_recipes
  erb :'recipes/index', locals: {recipes: recipes}
end

get 'recipes/:id' do
  erb :'recipes/show'
end

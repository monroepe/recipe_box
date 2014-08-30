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
  query = 'SELECT recipes.name AS recipe, recipes.instructions as instructions, recipes.description AS description, ingredients.id, ingredients.name AS ingredient
    FROM recipes
    JOIN ingredients ON recipes.id = ingredients.recipe_id
    WHERE recipes.id = $1;'

  recipe = db_connection do |conn|
      conn.exec_params(query, [id])
  end
  recipe
end





get '/' do
  redirect '/recipes'
end

get '/recipes' do
  recipes = get_recipes
  erb :'recipes/index', locals: {recipes: recipes}
end

get '/recipes/:id' do
  recipe = get_recipe(params[:id])
  erb :'recipes/show', locals: {recipe: recipe}
end

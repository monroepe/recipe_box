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


def get_recipes(page_num)
  query = 'SELECT recipes.id, recipes.name
    FROM recipes
    WHERE recipes.instructions IS NOT NULL
    ORDER BY recipes.name LIMIT 20 OFFSET $1;'

  recipes = db_connection do |conn|
      conn.exec_params(query, [(@page_num - 1) * 20])
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

helpers do
  def on_last_page?(page_num)
    page_num < 32
  end

  def on_first_page?(page_num)
    page_num == 1
  end
end


get '/' do
  redirect '/recipes'
end

get '/recipes' do
  if params[:page]
    @page_num = params[:page].to_i
  else
    @page_num = 1
  end

  recipes = get_recipes(@page_num)
  erb :'recipes/index', locals: {recipes: recipes}
end

get '/recipes/:id' do
  recipe = get_recipe(params[:id])
  erb :'recipes/show', locals: {recipe: recipe}
end

get '/search' do
  erb :'search/index'
end



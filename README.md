## Crear un Blog Ruby on Rails usando las gemas 'kaminari', 'carrierwave','fog' y 'omniauth' paso a paso.

Siguiendo este tutorial podrás crear tu propio site con las siguientes características.

* Posts (CRUD, crear, leer, actualizar y borrar) (hecho)
* Comentarios en los posts (CRUD de comentarios) (hecho)
* Almacenamiento de imágenes en la nube (Amazon S3) (hecho)

El aspecto de la app no es importante en este momento no se hablará sobre este tema en este tutorial básico.


Esta demo ha sido creada usando las siguientes versiones.

* Rails 4.1.4
* Ruby 2.1.2p95

#### Creamos una nueva app.

Para la realización de la demo creamos una nueva aplicación de rails ejecutando el siguiente comando en consola.

```console
$ rails new name_of_your_app
```

Ahora, para comprobar que todo ha funcionado correctamente podemos hacer lo siguiente.

```console
$ cd name_of_your_app
$ bin/rails server
```

Este comando ejecuta el servidor web WEBrick y si abrimos en nuestro navegador la dirección http://127.0.0.1:3000 deberíamos ver nuestra página de inicio de rails.
(Para detener el servidor WEBrick presiona 'Crtl-C' en tu teclado.)

![Welcome to Rails](http://i.imgur.com/pR0qe9M.png)

Como podemos ver el propio rails nos dice que utilicemos "rails generate" para crear un controlador y un modelo. Pero antes de eso vamos a hacer algunas modificaciones en nuestra app.

### Instalando figaro
Lo primero que vamos a hacer es instalar la gema figaro que nos ayudará a mantener nuestras variables de entorno fuera de github. La instalación es muy sencilla.
Añadimos la gema al archivo Gemfile:

```ruby
gem 'figaro'
```

Ejecutamos en consola
```bash
$ bin/bundle install
```

Una vez hecho esto vamos a generar la instalación de figaro con el siguiente comando

```bash
$ bin/rails generate figaro:install
      create  config/application.yml
      append  .gitignore
```

Como vemos, este comando creará un nuevo archivo en  'config/' llamado application y además lo añade automáticamente al archivo '.gitignore' para que no forme parte de nuestro repositorio, más adelante veremos porqué.

Ahora vamos a incluir en nuestra app las gemas necesarias.

Vamos a incluir las siguientes gemas:

* [Carrierwave](https://github.com/carrierwaveuploader/carrierwave) para poder subir imágenes]
* [fog](https://github.com/fog/fog) para combinarla con carrierwave y almacenar las imágenes en Amazon S3.
* [kaminari](https://github.com/amatsuda/kaminari) para que el blog sea capaz de paginar y usando JQuery hacer un scroll infinito de los posts.
* [Bootstrap-sass](https://github.com/twbs/bootstrap-sass) para el css del sitio.

#### Configurando nuestra app

Editamos nuestro archivo Gemfile y al final añadiremos las siguientes líneas:

```ruby
gem 'carrierwave'
gem 'fog'
gem 'kaminari'
gem 'bootstrap-sass'
```

Una vez modificado el archivo gemfile ejecutamos el siguiente comando para incluir las gemas en nuestra app.

```console
$ bin/bundle install
```

Vamos a hacer un install de jQuery para que se descarguen los archivos necesarios y configurar nuestra app para usar jQuery.

```console
$ bin/rails generate jquery:install
```

Descargamos el plugin de jQuery para hacer infinite scroll y lo meteremos en nuestra app en 'vendor/assets/javascripts/jquery.infinitescroll.js' ejecutando este comando en el terminal.

```console
$ curl -k -o vendor/assets/javascripts/jquery.infinitescroll.js https://raw.githubusercontent.com/paulirish/infinite-scroll/master/jquery.infinitescroll.js
```

Una vez descargada haremos que nuestra app pueda utilizar el plugin cuando sea necesario, modificamos el archivo 'app/assets/javascripts/application.js' y añadimos lo siguiente al final:

```js
//= require jquery.infinitescroll
```

Creamos un archivo nuevo en 'app/assets/stylesheets/' con el nombre 'styles.css.scss' y añadiremos la siguiente línea.

```css
# app/assets/stylesheets/styles.css.scss
@import 'bootstrap';
```

#### Generando el controlador

Una vez configurada nuestra app vamos a proceder a generar un controlador, una vista y un modelo.

Vamos a crear un controlador para que sea nuestra página principal y muestre un listado con todos los posts de nuestro sitio.

Para general el controlador utilizaremos el siguiente comando de rails:

```console
$ bin/rails generate controller posts
```

Ahora vamos a editar nuestro archivo 'config/routes.rb' para configurar las rutas de nuestra aplicación.

```ruby
# app/config/routes.rb
Rails.application.routes.draw do
  ...
  resources :posts
  root 'posts#index'
  ...
end
```

La línea 'resources :posts' generará las rutas para nuestro recién creado controlador y la línea "root 'posts#index'" le dice a nuestra aplicación que al entrar a nuestro site debe redirigir las peticiones a la ruta '/posts/index'.

Si abrimos ahora nuestra aplicación en el navegador (http://127.0.0.1:3000) veremos que nos da un error debido  a que en nuestro controlador no existe todavía un método index.

![PostsController error](http://i.imgur.com/OQCHf0B.png)

Vamos a solucionar este problema.
Abrimos 'app/controllers/posts_controller.rb' y creamos un método index.

```ruby
class PostsController < ApplicationController
  def index
  end
end
```

Si volvemos a cargar nuestra app en el navegador (http://127.0.0.1:3000) veremos otro error ya que no existe la vista para mostrar index.

![Template not found](http://i.imgur.com/xj4fJvC.png])

Para solucionar esto vamos a 'app/views/posts/' y crearemos el archivo 'index.html.erb' y de momento agregamos lo siguiente:

    Hola Mundo

Ahora si guardamos el archivo y volvemos a cargar la página en el navegador (http://127.0.0.1:3000) ya veremos nuestro 'Hola Mundo'.


#### Generando el modelo

Ejecutamos el siguiente comando en la terminal.

```console
    $ bin/rails generate model Post title:string body:string image:string
    $ bin/rake db:migrate
```

Con estos dos comandos hemos creado una nueva ['migration'](http://guides.rubyonrails.org/migrations.html) que añadirá una tabla en la base de datos llamada post con las siguientes columnas: title, body e image. Además con el comando 'bin/rake db:migrate' haremos que nuestra 'migration' sea efectiva y se apliquen nuestros cambios.

**Nota: Podemos ver la estructura de nuestra base de datos si vamos al archivo 'db/schema.rb'.

#### Visualizar nuestros posts

Vamos a realizar algunos cambios en el controlador y en las vistas para poder visualizar los posts que vayamos creando.

Editamos nuestro archivo 'app/views/posts/index.html.erb' para que en vez de mostrar 'Hola Mundo' quede de la siguiente forma:

```html
<div class="page-header">
  <h1>My Blog</h1>
  Created using Ruby on Rails
</div>
<p id="notice"><%= notice %></p>

<div id="posts">
  <div class="myposts">
    <%= render @posts %>
  </div>
</div>

</div>
```

Como vemos en '<%= render @posts %>' estamos llamando a una parcial utilizando [render](http://guides.rubyonrails.org/layouts_and_rendering.html) que todavía no existe y que tenemos que crear, para ello vamos a 'app/views/posts/' y creamos el archivo '_post.html.erb' con el siguiente contenido. Aunque el aspecto no lo vamos a tratar en este caso el nombre de las clases e id's es importante ya que nuestro javascript las identificará. Si cambiais el nombre de estas clases e id's no os funcionará el infinite scroll.

```html
<div class="post">
  <div class="post-title">
    <%= link_to post.title, post_path(post) %>
  </div>
  <small class="post-timestamp"><em><%= post.timestamp %></em></small>
  <div class="post-body">
    <div class="post-image">
      <%= image_tag(post.image_url) %>
    </div>
    <p><%= truncate(strip_tags(post.body), length: 600) %></p>
  </div>
</div>
```

Aqui vemos que cada post tendrá un título que a su vez será un enlace para ver el post, debajo del post tenemos la fecha (post.timestamp) y después el cuerpo del post. El método en el que estamos llamando a la fecha de creación del post, con 'post.timestamp' no existe, así que nos vamos a nuestro modelo a crearlo.

Abrimos 'app/models/post.rb' y añadimos el método timestamp.

```ruby
class Post < ActiveRecord::Base
  def timestamp
    created_at.strftime('%d %B %Y %H:%M')
  end
end
```

El método 'timestamp' llama a 'created_at' que es una columna de nuestro modelo (añadida de forma automática por el generador del modelo) y la formatea con ['strftime'](http://www.ruby-doc.org/core-2.1.2/Time.html#method-i-strftime) para que sea más legible podéis personalizar esto a vuestro gusto.

Vamos a modificar también nuestro controlador para que la variable que estamos usando '@posts' sea accesible desde la vista.

```ruby
class PostsController < ApplicationController
  def index
    @posts = Post.all
  end
end
```

Si abrimos nuestro navegador podremos ver que ahora en nuestra página principal muestra un título, pero que todavía no hemos agregado ningún post.

Recordad que muchos de los cambios necesitan que reiniciemos nuestro servidor web.

#### Configurando carrierwave y fog para Amazon S3

Para poder subir imágenes con nuestros posts debemos configurar primero nuestra app, en este caso vamos a utilizar 'carrierwave' y 'fog' para almacenar nuestras imágenes directamente en [Amazon AWS Services](http://aws.amazon.com/).

Lo primero que vamos a hacer es generar un uploader para nuestras imágenes.

```console
    $ bin/rails generate uploader PostImage
```

Esto nos creará un fichero 'app/uploaders/post_image_uploader.rb' que será nuestro uploader, abrimos el fichero y modificamos el contenido:

```ruby
class PostImageUploader < CarrierWave::Uploader::Base
  storage :fog

  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end

  def extension_white_list
    %w(jpg jpeg gif png)
  end
end
```

* El método 'storage_dir' se encargará de establecer el directorio en el que se van a guardar las imágenes.
* El método 'extension_white_list' crea una lista blanca de las extensiones que podremos subir.
* 'storage:fog' establece el tipo de almacenamiento, en este caso utilizaremos fog ya que vamos a almacenar nuestras imágenes en la nube con la ayuda de esa gema.

Para que 'fog' sepa en que servicio tiene que almacenar las imágenes y con qué credenciales, vamos a crear un nuevo 'initializer' al que podremos llamar por ejemplo 'carrierwave_fog.rb' y lo guardamos en 'config/initializers/'.

El archivo tendrá el siguiente contenido:

```ruby
# config/initializers/carrierwave_fog.rb
CarrierWave.configure do |config|
  config.fog_credentials = {
    :provider               => 'AWS',                        # required
    :aws_access_key_id      => ENV["AMAZON_ACCESS_KEY"],     # required
    :aws_secret_access_key  => ENV["AMAZON_SECRET_KEY"],    # required
    :region                 => 'eu-west-1',                  # optional, defaults to 'us-east-1'
  }
  config.fog_directory  = ENV["AMAZON_BUCKET_NAME"]          # required
  config.fog_public     = false                              # optional, defaults to true
  config.fog_attributes = {'Cache-Control'=>'max-age=315576000'}  # optional, defaults to {}
end
```

Aquí es donde vemos la utilidad de figaro, como véis en vez de poner las llaves que nos proporciona Amazon directamente en el código utilizamos unas variables de entorno que definiremos en nuestro archivo 'config/application.yml' y que como hemos comentado anteriormente quedan fuera de nuestro repositorio puesto que al instalar figaro añade este archivo directamente a '.gitignore'.

```ruby
# Add application configuration variables here, as shown below.
# CONSTANT: value

PORT: 3000
AMAZON_ACCESS_KEY: your_amazon_access_key
AMAZON_SECRET_KEY: your_amazon_secret_key
AMAZON_BUCKET_NAME: your_amazon_bucket_name
```

###### Ojo, es importante respetar el formato del archivo.

Para obtener estas llaves debemos ir a la web de [amazon aws services](http://aws.amazon.com/), loguearnos o registrarnos en caso de que no lo hayamos hecho anteriormente y seguir estos pasos:
* Crear un Bucket de amazon S3.
* Crear un usuario(copiar credenciales en nuestro archivo 'config/application.yml')
* Dar permisos al usuario para acceder al nuevo bucket.

Ahora vamos a modificar nuestro archivo 'app/model/post.rb' y añadimos la siguiente línea justo debajo de la definición de clase para 'montar' nuestro uploader.

```ruby
class Post < ActiveRecord::Base
  mount_uploader :image, PostImageUploader

  def timestamp
    created_at.strftime('%d %B %Y %H:%M')
  end
end

```

###### Ojo!, ':image' es el correspondiente a la columna 'image' de nuestro modelo. Si le llamáis de otra forma no os funcionará.

#### Crear los métodos new, create y show

 * Modificamos el archivo 'posts_controller.rb' para añadir los métodos "new,create y show" que necesitaremos para poder agregar mensajes a nuestra app.
 * Creamos los métodos privados 'post_params', que nos asegurará que los parámetros que vamos a incluir en nuestra tabla sean los adecuados y 'set_post' que le dirá a la vista que post es el que tiene que editar, mostrar, actualizar o borrar.
 * Añadimos un 'before_action' para que actúe antes de los métodos ':show, :edit, :update y :destroy'
 * Modificamos el método index para que en vez de mostrar todos los artículos, los muestre en orden inverso a la fecha de creación.

```ruby
class PostsController < ApplicationController
  before_action :set_post, only: [:show, :edit, :update, :destroy]

  def index
      @posts = Post.order(created_at: :desc).page(params[:page])
  end

  def show
  end

  def new
    @post = Post.new
  end

  def create
    @post = Post.new(post_params)

    respond_to do |format|
      if @post.save
        format.html { redirect_to @post, notice: 'Post was successfully created.' }
        format.json { render :show, status: :created, location: @post }
      else
        format.html { render :new }
        format.json { render json: @post.errors, status: :unprocessable_entity }
      end
    end
  end

  private
  def set_post
    @post = Post.find(params[:id])
  end

  def post_params
    params.require(:post).permit(:title, :author, :body, :image)
  end
end
```

Creamos una nueva vista en 'apps/views/posts/' y le llamaremos 'new.html.erb' introduciendo dentro el siguiente contenido.

```html
<h1>New post</h1>

<%= render 'form' %>

<%= link_to 'Back', posts_path, :class=>'btn btn-default' %>
```

también tendremos que crear un parcial en la carpeta 'app/views/posts/' con el nombre '_form.html.erb' con el siguiente código. Aquí es donde tendremos el código de nuestro formulario para insertar nuevos posts.

```html
<%= form_for(@post) do |f|  %>
  <% if @post.errors.any? %>
    <div id="error_explanation">
      <h2><%= pluralize(@post.errors.count, "error") %> prohibited this post from being saved:</h2>

      <ul>
      <% @post.errors.full_messages.each do |message| %>
        <li><%= message %></li>
      <% end %>
      </ul>
    </div>
  <% end %>

  <div class="form-group">
    <%= f.label :title   %><br>
    <%= f.text_field :title ,:class=>'form-control' %>
  </div>
  <div class="form-group">
    <%= f.label :body %><br>
    <%= f.text_area :body,:class=>'form-control' %>
  </div>
  <div class="form-group">
    <%= f.label 'Image' %><br>
    <img src="<%= @post.image.url %>" width=80px />

  <div class="form-group">
    <%= f.file_field :image ,:class=>'form-control'%>
  </div>
  <div class="actions">
    <%= f.submit :class=>'btn btn-primary'%>
  </div>
<% end %>
```


Vamos a crear también una nueva vista 'show.html.erb' que nos mostrará el post y nos permitirá modificarlo, borrarlo o volver a la página principal.

```html
<div class="show-post">
<p id="notice"><%= notice %></p>


<div class="post">
  <p class="post-title">
    <%= @post.title %>
  </p>
  <div class="my-post">
    <p class="post-image">
      <%= image_tag(@post.image_url) %>
    </p>

    <p class="post-body">
      <%= @post.body %>
    </p>
  </div>
<div class="show-btns">
  <%= link_to 'Edit', edit_post_path(@post), :class=>"btn btn-info" ,:type=>'button' %>
  <%= link_to 'Back', posts_path, :class=>"btn btn-default" ,:type=>'button' %>
</div>
```

Realizados todos estos cambios sólo nos faltaría agregar un botón a nuestra página principal para crear nuevos posts. Modificamos 'app/views/posts/index.html.erb' y lo dejamos de la siguiente forma:

```html
<div class="page-header">
  <h1>My posts</h1>
  Created using Ruby on Rails
  <div class="header-btn">
    <%= link_to 'New Post',new_post_path, :class=>"btn btn-default" ,:type=>'button' %>
  </div>
</div>
<p id="notice"><%= notice %></p>

<div id="my-posts">
  <%= render @posts %>
</div>
```

Si hemos seguido todos los pasos correctamente ya podríamos crear nuestro primer post en nuestra app.


El paso siguiente va a ser hacer que el botón 'Editar' que acabamos de colocar en 'app/views/show.html.erb' sea funcional, de momento no tenemos ni el método en nuestro controlador, vamos a crearlo.
Abrimos 'app/controllers/posts_controller.rb' y agregaremos el método editar.

```ruby
class PostsController < ApplicationController
  ...
  def edit
  end
  ...
  private
  ...
end
```

Una vez creado vamos a crearnos una vista que nos permita editar los valores del post. Para ello creamos el archivo 'edit.html.erb' dentro de nuestra carpeta de vistas 'app/views/posts/'

```html
<h1>Editing post</h1>

<%= render 'form' %>

<%= link_to 'Show', @post, :class=>"btn btn-default" ,:type=>'button' %>
<%= link_to 'Back', posts_path, :class=>"btn btn-default" ,:type=>'button' %>
```

Si intentamos actualizar nuestro post veremos que nos da un error puesto que no tenemos creado el método 'update' en nuestro controlador, así que vamos a añadirlo. De paso vamos a añadir también el método 'destroy' que nos permitirá borrar un post.

###### Ojo, tanto estos métodos como el método edit deben estar por encima de la linea 'private' de nuestra clase.

```ruby
class PostsController < ApplicationController
  ...
  def update
    respond_to do |format|
      if @post.update(post_params)
        format.html { redirect_to @post, notice: 'Post was successfully updated.' }
        format.json { render :show, status: :ok, location: @post }
      else
        format.html { render :edit }
        format.json { render json: @post.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @post.destroy
    respond_to do |format|
      format.html { redirect_to posts_url, notice: 'Post was successfully destroyed.' }
      format.json { head :no_content }
    end
  end
  ...
  private
  ...
end
```

Por último vamos a añadir el botón 'Borrar' en nuestra vista 'show.html.erb' que nos permitirá borrar ese post, en principio lo situamos al lado de nuestro botón editar.

```html
...
<%= link_to 'Delete', post_path(@post), method: :delete, data: { confirm: 'Are you sure?' }, :class=>"btn btn-default" ,:type=>'button'%>

...
```

Si abrimos ahora nuestra aplicación en el navegador ya debería ser completamente funcional.


#### Configurando la paginación y el infinite scroll

Para que nuestro 'index.html.erb' soporte paginación tendremos que editarlo y dejarlo de la siguiente forma:

```html
<div class="page-header">
  <h1>My posts</h1>
    Created using Ruby on Rails
    <div class="header-btn">
    <%= link_to 'New Post',new_post_path, :class=>"btn btn-default" ,:type=>'button' %>
  </div>
</div>
<p id="notice"><%= notice %></p>

<div id="posts-container">
  <div class="posts">
    <%= render @posts %>
  </div>
</div>

<div id="infinite-scrolling">
  <%= paginate @posts %>
</div>

```

Si os fijáis casi al final del archivo tenemos '<%= paginate @posts %>' que se encargará de hacer una llamada Javascript para cargar más posts de forma dinámica.

Abrimos nuestro modelo y modificamos el código para que quede de la siguiente forma:

```ruby
class Post < ActiveRecord::Base
  mount_uploader :image, PostImageUploader
  paginates_per 5

  def timestamp
    created_at.strftime('%d %B %Y %H:%M:%S')
  end
end
```

Si modificamos 'paginates_per 5' y cambiamos el valor, cambiaremos el número de posts que veremos por página en caso de no soportar javascript en el navegador, aunque aquí nos servirá para definir el número de posts que veremos antes de cargar nuevos posts.

Lo siguiente será modificar el archivo 'posts.js.coffee' que se encuentra dentro de 'app/assets/javascripts/' con el siguiente código:

```coffee
# app/assets/javascripts/posts.js.coffee
$(document).ready ->
  $("#posts-container .posts").infinitescroll
    navSelector: "nav.pagination"
    nextSelector: "nav.pagination a[rel=next]"
    itemSelector: "#posts-container div.post"
```

Para finalizar la configuración del infinite scroll creamos una vista javascript en 'app/views/posts/' con el nombre 'index.js.erb':

```js
$("#posts-container").append("<div class='myposts'><%= escape_javascript(render(@posts)) %></div>");
```

En estos momentos si creamos más de 5 posts en nuestro blog deberíamos notar como al llegar al final de nuestra web van cargando de forma automática los siguientes 5 y así sucesivamente.


### Añadiendo Comentarios a nuestros Posts

Es hora de que podamos añadir comentarios a nuestros posts.

#### Generando un nuevo modelo.

Para empezar, vamos a añadir un nuevo modelo a nuestra base de datos para almacenar tanto los comentarios como el autor de los mismos.

```bash
$ bin/rails generate model Comment commenter:string body:text post:references
```

Fijaos en que al final del comando tenemos un 'post:references' esto hará que el modelo comments que hemos creado esté asociado con nuestro anterior modelo post. Si abrimos el archivo 'app/models/comment.rb' veremos lo siguiente:

```ruby
#/app/models/comment.rb
class Comment < ActiveRecord::Base
  belongs_to :post
end
```

En la segunda línea vemos 'belongs_to :post' que especifica la relación que tiene el modelo con la tabla post, es decir que cada comentario pertenece a un post. Ahora deberíamos completar esta relación editando el modelo post que ya teníamos con lo siguiente:

```ruby
#/app/models/post.rb
class Post < ActiveRecord::Base
  ...
  has_many :comments, dependent: :destroy
  ...
end
```

Aquí especificamos la relación con 'has_many :comments', estableciendo que un post, puede tener varios comentarios. Además con 'dependent: :destroy' estamos diciendo que cuando borramos un post, también borramos todos los comentarios asociados a ese post.

El comando que hemos ejecutado, nos ha creado una migración que podemos encontrar en la carpeta 'db/migrate'. El archivo lo podemos identificar porque tendrá como nombre un 'timestamp' y el comando que hemos utilizado para crear la migración, por ejemplo '20140814091010_create_comments.rb', el contenido del fichero es el siguiente.

```ruby
class CreateComments < ActiveRecord::Migration
  def change
    create_table :comments do |t|
      t.string :commenter
      t.text :body
      t.references :post, index: true

      t.timestamps
    end
  end
end

```

Vamos a aplicar la migración a la base de datos utilizando el siguiente comando:

```bash
$ bin/rake db:migrate
```

#### Añadiendo nuevas rutas.

Vamos a especificar en nuestra aplicación donde debemos navegar para ver los comentarios necesitamos modificar el archivo 'routes.rb' para que sea como el siguiente:

```ruby
Rails.application.routes.draw do
  resources :posts do
    resources :comments
  end
  root 'posts#index'
end
```

Como veis hemos anidado los comentarios dentro de posts.

#### Generando un controlador

Necesitamos un nuevo controlador que se encargue de la creación, y eliminación de los comentarios, como ya hemos visto antes crearemos un nuevo controlador con el comando:

```bash
$ bin/rails generate controller Comments
```

Abrimos el archivo que crea el generador 'app/controllers/comments_controller.rb' y añadimos lo siguiente:

```ruby
class CommentsController < ApplicationController
  before_action :identify_current_post, only: [:create, :destroy]

   def create
    @comment = @post.comments.create(comment_params)
    redirect_to_post
  end

  def destroy
    @comment = @post.comments.find(params[:id])
    @comment.destroy
    redirect_to_post
  end

  private
  def identify_current_post
    @post = Post.find(params[:post_id])
  end

  def redirect_to_post
    redirect_to post_path(@post)
  end

  def comment_params
    params.require(:comment).permit(:commenter, :body)
  end
end
```

El código no tiene ninguna complicación y es muy similar a lo visto con el controlador de posts.

Ahora lo que nos falta es ir modificando las vistas para poder agregar y mostrar comentarios.

### Modificando las vistas

Abrimos 'app/views/posts/show.html.erb' y la modificamos para que quede de la siguiente manera.

```ruby
<div class="show-post">
  <p id="notice"><%= notice %></p>
  <div class="post">
    <p class="post-title">
      <%= @post.title %>
    </p>
    <div class="my-post">
      <p class="post-image">
        <%= image_tag(@post.image_url) %>
      </p>
      <p class="post-body">
        <%= @post.body %>
      </p>
    </div>
  </div>
  <div class="post-comments">
    <h2>Comments</h2>
      <%= render @post.comments %>
    <h2>Leave your comment:</h2>
      <%= render 'comments/form' %>
  </div>
  <div class="show-btns">
    <%= link_to 'Edit', edit_post_path(@post), :class=>"btn btn-info" ,:type=>'button' %>
    <%= link_to 'Back', posts_path, :class=>"btn btn-default" ,:type=>'button' %>
    <%= link_to 'Delete', post_path(@post), method: :delete, data: { confirm: 'Are you sure?' }, :class=>"btn btn-default" ,:type=>'button'%>
  </div>
</div>
```

Vemos que necesitamos crear dos nuevas parciales o partials, '@post.comments' y 'comments/form'. Para la primera, añadimos un nuevo fichero en 'app/views/comments' con el nombre '_comment.html.erb' con el siguiente contenido que se encargará de mostrar los comentarios existentes y un botón para poder borrarlos:

```ruby
<p>
  <strong>Commenter:</strong>
  <%= comment.commenter %>
</p>

<p>
  <strong>Comment:</strong>
  <%= comment.body %>
</p>
<p>
<%= link_to 'Delete Comment', [comment.post, comment],
             method: :delete,
             data: { confirm: 'Are you sure?' } %>
</p>
```

La segunda parcial la crearemos añadiendo el archivo '_form.html.erb' que se encargará de mostrar un formulario con el que podremos insertar un nuevo comentario en el post.

```ruby
<%= form_for([@post, @post.comments.build]) do |f| %>
  <p>
    <%= f.label :commenter %><br>
    <%= f.text_field :commenter %>
  </p>
  <p>
    <%= f.label :body %><br>
    <%= f.text_area :body %>
  </p>
  <p>
    <%= f.submit %>
  </p>
<% end %>
>
```
Ahora ya podremos añadir y ver comentarios en los posts de nuestra app.


### Añadiendo usuarios y un poco de seguridad

#### Añadiendo autenticación

Para añadir autenticación al blog vamos a utilizar la gema devise que nos facilitará mucho este aspecto. Podéis encontrar información sobre la gema en su [github](https://github.com/plataformatec/devise)

Lo primero que haremos será añadir la gema devise al archivo Gemfile

```ruby
gem 'devise'
```

Ahora ejecutamos 'bundle install' para que se apliquen los cambios

```bash
$ bin/bundle install
```

Vamos a ejecutar el instalador de devise para que instale lo necesario en nuestra app.

```bash
$ bin/rails generate devise:install
      create  config/initializers/devise.rb
      create  config/locales/devise.en.yml
===============================================================================

Some setup you must do manually if you haven't yet:

  1. Ensure you have defined default url options in your environments files. Here
     is an example of default_url_options appropriate for a development environment
     in config/environments/development.rb:

       config.action_mailer.default_url_options = { host: 'localhost:3000' }

     In production, :host should be set to the actual host of your application.

  2. Ensure you have defined root_url to *something* in your config/routes.rb.
     For example:

       root to: "home#index"

  3. Ensure you have flash messages in app/views/layouts/application.html.erb.
     For example:

       <p class="notice"><%= notice %></p>
       <p class="alert"><%= alert %></p>

  4. If you are deploying on Heroku with Rails 3.2 only, you may want to set:

       config.assets.initialize_on_precompile = false

     On config/application.rb forcing your application to not access the DB
     or load models when precompiling your assets.

  5. You can copy Devise views (for customization) to your app by running:

       rails g devise:views

===============================================================================

```

Como vemos el instalador nos da una serie de configuraciones que tenemos que aplicar en la medida de lo posible. En nuestro caso tenemos que añadir la siguientes líneas al archivo 'config/enviroments/development.rb'

```ruby
# Devise config
config.app_domain = 'localhost:3000'
config.action_mailer.default_url_options = { host: config.app_domain }
```

Esta línea le dice a 'action mailer' que el host que debe usar es 'localhost' que es la dirección actual de nuestra web. Cuando estemos en producción deberemos añadir esa misma linea de comando al archivo  'config/enviroments/production.rb' pero en vez de usar 'localhost:3000' utilizaremos la dirección de la aplicación.

Como indicaba en la instalación vamos a necesitar modificar el archivo 'application.html.erb' y añadiremos ahí las etiquetas '<notice>' y '<alert>' dejando el archivo de la siguiente forma:

```html
<!DOCTYPE html>
<html>
<head>
  <title>Rorblog</title>
  <%= stylesheet_link_tag    'application', media: 'all', 'data-turbolinks-track' => true %>
  <%= javascript_include_tag 'application', 'data-turbolinks-track' => true %>
  <%= csrf_meta_tags %>
</head>
<body>
<div class="container">
  <p class="notice"><%= notice %></p>
  <p class="alert"><%= alert %></p>
  <%= yield %>
</div>
</body>
</html>
```

Nosotros ya teníamos etiquetas '<notice>' en los archivos 'index.html.erb' y 'show.html.erb' así que vamos a eliminarlas y dejaremos estas que al estar en el archivo 'application.html.erb' se cargará de forma automática antes de cada vista y por lo tanto no nesitaremos el resto.

De momento no necesitaremos realizar más pasos de los indicados en el instalador así que continuamos con la configuración e instalación de devise.

Vamos a crear un nuevo modelo 'User' que se encargará de almacenar la información de usuario

```bash
$ bin/rails generate devise User
      invoke  active_record
      create    db/migrate/20140819102410_devise_create_users.rb
      create    app/models/user.rb
      invoke    test_unit
      create      test/models/user_test.rb
      create      test/fixtures/users.yml
      insert    app/models/user.rb
       route  devise_for :users

```

Como vemos esto nos crea una nueva 'migration', un nuevo modelo, archivos para hacer test, y nos modifica las rutas para que funcionen con nuestro nuevo modelo. Las vistas las genera devise automáticamente si quisiéramos modificarlas podríamos utilizar el comando que nos proponía en la instalación

```bash
$ bin/rails generate devise:views
      invoke  Devise::Generators::SharedViewsGenerator
      create    app/views/devise/shared
      create    app/views/devise/shared/_links.erb
      invoke  form_for
      create    app/views/devise/confirmations
      create    app/views/devise/confirmations/new.html.erb
      create    app/views/devise/passwords
      create    app/views/devise/passwords/edit.html.erb
      create    app/views/devise/passwords/new.html.erb
      create    app/views/devise/registrations
      create    app/views/devise/registrations/edit.html.erb
      create    app/views/devise/registrations/new.html.erb
      create    app/views/devise/sessions
      create    app/views/devise/sessions/new.html.erb
      create    app/views/devise/unlocks
      create    app/views/devise/unlocks/new.html.erb
      invoke  erb
      create    app/views/devise/mailer
      create    app/views/devise/mailer/confirmation_instructions.html.erb
      create    app/views/devise/mailer/reset_password_instructions.html.erb
      create    app/views/devise/mailer/unlock_instructions.html.erb

```

Aquí podemos ver todas las vista que crea devise incluídos los mails de confirmación, reiniciar contraseñas y desbloqueo de cuentas.

Vamos a repasar la configuración de Devise y la migration antes de ejecutarla, en su github llegado este momento nos piden que repasemos el modelo y la migration y es lo que vamos a hacer.

Como vemos en el modelo generado por devise, no tenemos activada por defecto la confiración del email proporcionado por el usuario para darse de alta, así que vamos a cambiar esto para que se le envíe un mail de confirmación con un enlace para confirmar el email. Abrimos 'app/models/user.rb' y añadimos ':confirmable' en devise.

```ruby
class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, :confirmable,
         :recoverable, :rememberable, :trackable, :validatable
end
```


Ahora vamos a la migration generada por 'devise' y la modificamos para que los campos requeridos para confirmar el correo se apliquen en la migración.

```ruby
class DeviseCreateUsers < ActiveRecord::Migration
  def change
    create_table(:users) do |t|
      ## Database authenticatable
      t.string :email,              null: false, default: ""
      t.string :encrypted_password, null: false, default: ""

      ## Recoverable
      t.string   :reset_password_token
      t.datetime :reset_password_sent_at

      ## Rememberable
      t.datetime :remember_created_at

      ## Trackable
      t.integer  :sign_in_count, default: 0, null: false
      t.datetime :current_sign_in_at
      t.datetime :last_sign_in_at
      t.string   :current_sign_in_ip
      t.string   :last_sign_in_ip

      ## Confirmable
      t.string   :confirmation_token
      t.datetime :confirmed_at
      t.datetime :confirmation_sent_at
      t.string   :unconfirmed_email # Only if using reconfirmable

      ## Lockable
      # t.integer  :failed_attempts, default: 0, null: false # Only if lock strategy is :failed_attempts
      # t.string   :unlock_token # Only if unlock strategy is :email or :both
      # t.datetime :locked_at


      t.timestamps
    end

    add_index :users, :email,                unique: true
    add_index :users, :reset_password_token, unique: true
    # add_index :users, :confirmation_token,   unique: true
    # add_index :users, :unlock_token,         unique: true
  end
end
```

Ahora ya podemos aplicar la migración con

```bash
$ bin/rake db:migrate
```

En estos nuestra aplicación funciona pero no tenemos modificadas nuestras vistas con botones o enlaces para loguear o inscribir nuevos usuarios. Además vamos a requerir que un usuario esté logueado antes de poder crear un nuevo post.

Vamos a empezar con esto último ya que es bastante sencillo. Editamos 'app/controllers/posts_controller.rb' y agregamos un 'before_filter' debajo del que ya teníamos.

```ruby
class PostsController < ApplicationController
  before_action :set_post, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_user!, only: [:new, :create, :edit, :update, :destroy]

  ...
end
```

Si vamos a nuestra aplicación e intentamos crear un nuevo post, nos redirigirá automáticamente a una vista para realizar el login de usuario, de paso especificamos que nos obligue a estar autentificados también para editar, actualizar y eliminar posts.

Evidentemente no podremos hacer login porque nuestro usuario todavía no está creado, pero desde ahí podemos ir a 'sign up' y crear un nuevo usuario, el problema es que todavía no hemos configurado el correo para que se envíe y como hemos especificado antes necesitamos confirmar el correo, vamos a confirmar correctamente el correo antes de continuar.

Para este ejemplo voy a utilizar una cuenta de gmail para enviar el correo, abrimos 'config/environments/development.rb' y añadimos la siguiente configuración:

```ruby
Rails.application.configure do
  ...
  # Devise config
  config.app_domain = 'localhost:3000'
  config.action_mailer.default_url_options = { host: config.app_domain }

  # Email
  config.action_mailer.delivery_method = :smtp
  config.action_mailer.perform_deliveries = true
  config.action_mailer.smtp_settings = {
    :enable_starttls_auto => true,
    :address => "smtp.gmail.com",
    :port => 587,
    :user_name => ENV["GMAIL_USER_NAME"],
    :password => ENV["GMAIL_PASSWORD"],
    :authentication => 'plain',
    :openssl_verify_mode  => 'none',
  }
end

```

Como ya hemos visto anteriormente debemos configurar las variables de entorno 'GMAIL_USER_NAME' y 'GMAIL_PASSWORD' en el archivo 'config/application.yml' para que sean cargadas por figaro.

###### Añadiendo botones a nuestra vista

```ruby
<nav class="navbar navbar-default" role="navigation">
<%- if controller_name != 'sessions' %>
<%= link_to "Sign in", new_user_session_path, :class=>'btn btn-default navbar-btn'%>
  <%= link_to "Sign up", new_user_registration_path, :class=>'btn btn-default navbar-btn'%>
<% else %>
  <%= link_to "Sign out", destroy_user_session_path, method: :delete, :class=>'btn btn-primary navbar-btn' %>
<% end -%>
</nav>

```

### Referencias
Este tutorial ha sido creado gracias a la ayuda de los siguientes sitios:
* [Carrierwave Gem](https://github.com/carrierwaveuploader/carrierwave)
* [How to create infinite scroll with jQuery](https://github.com/amatsuda/kaminari/wiki/How-To:-Create-Infinite-Scrolling-with-jQuery)
* [Infinite Scrolling in Rails: The Basics](http://www.sitepoint.com/infinite-scrolling-rails-basics/)
* [Fog Gem](https://github.com/fog/fog)
* [Devise](https://github.com/plataformatec/devise)

### Agradecimientos
Gracias a [Max](https://github.com/maxvlc) y [Salva](https://github.com/salveta) por ayudarme a crear, mejorar y testear el tutorial.

Gracias a [Devscola](http://www.devscola.com)
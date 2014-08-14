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

Primero vamos a cambiar de servidor web a foreman, luego veremos porqué.

Abrimos nuestro archivo 'Gemfile' y agregamos:

```ruby
gem 'foreman'
```

Ahora vamos a nuestra consola y ejecutamos 'bundle install' para instalar la gema.

```bash
$ bin/bundle install
```

Hecho esto vamos a crear el archivo '/.env' en la raiz de nuestra aplicación con el siguiente contenido:

```ruby
PORT=3000
```

foreman, cargará el contenido de este archivo y podremos utilizarlo para guardar nuestras variables de entorno.

#####Es muy importante que añadamos este archivo a '.gitignore' si estamos utilizando git para que nuestras variables de entorno no se publiquen, luego veremos porqué.

Ahora vamos a crear el archivo './Procfile' que utilizará foreman para arrancar el servidor.

```ruby
web: bundle exec rails server -p $PORT
```

Ahora ya podemos iniciar nuestra aplicación con el siguiente comando

```bash
$ foreman start
```

Si abrimos http://127.0.0.1:3000 deberíamos ver nuestra aplicación. Con 'Ctrl+C' en consola podemos cerrar foreman.

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
  <h1>My posts</h1>
</div>
<p id="notice"><%= notice %></p>

<div id="posts">
  <div class="myposts">
    <%= render @posts %>
  </div>
</div>

</div>
```

Como vemos en '<%= render @posts %>' estamos llamando a una parcial utilizando [render](http://guides.rubyonrails.org/layouts_and_rendering.html)que todavía no existe y que tenemos que crear, para ello vamos a 'app/views/posts/' y creamos el archivo '_post.html.erb' con el siguiente contenido. Aunque el aspecto no lo vamos a tratar en este caso el nombre de las clases e id's es importante ya que nuestro javascript las identificará. Si cambiais el nombre de estas clases e id's no os funcionará el infinite scroll.

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

Abrimos 'app/models/post.rb' y añadimos lo siguiente.

```ruby
class Post < ActiveRecord::Base
  def timestamp
    created_at.strftime('%d %B %Y %H:%M:%S')
  end
end
```

El método 'timestamp' llama a 'created_at' que es una columna de nuestro modelo (añadida de forma automática por el generador del modelo) y la formatea con ['strftime'](http://www.ruby-doc.org/core-2.1.2/Time.html#method-i-strftime) para que sea más legible podéis personalizar esto a vuestro gusto.

#### Configurando la paginación y el infinite scroll

Para que nuestro 'index.html.erb' soporte paginación tendremos que editarlo y dejarlo de la siguiente forma:

```html
<div class="page-header">
  <h1>My posts</h1>
</div>
<p id="notice"><%= notice %></p>

<div id="posts">
  <div class="myposts">
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
  paginates_per 5

  def timestamp
    created_at.strftime('%d %B %Y %H:%M:%S')
  end
end
```

Si modificamos 'paginates_per 5' y cambiamos el valor, cambiaremos el número de posts que veremos por página en caso de no soportar javascript en el navegador, aunque aquí nos servirá para el número de posts que veremos antes de cargar nuevos posts.

Lo siguiente será modificar el archivo 'posts.js.coffee' que se encuentra dentro de 'app/assets/javascripts/' con el siguiente código:

```coffee
# app/assets/javascripts/posts.js.coffee

$(document).ready ->
  $("#posts .myposts").infinitescroll
    navSelector: "nav.pagination"
    nextSelector: "nav.pagination a[rel=next]"
    itemSelector: "#posts div.post"
```

Para finalizar la configuración del infinite scroll creamos una vista javascript en 'app/views/posts/' con el nombre 'index.js.erb':

```js
$("#posts").append("<div class='page'><%= escape_javascript(render(@posts)) %></div>");
```


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
    :aws_secret_access_key  => ENV["AMAZON_SECRETE_KEY"],    # required
    :region                 => 'eu-west-1',                  # optional, defaults to 'us-east-1'
  }
  config.fog_directory  = ENV["AMAZON_BUCKET_NAME"]          # required
  config.fog_public     = false                              # optional, defaults to true
  config.fog_attributes = {'Cache-Control'=>'max-age=315576000'}  # optional, defaults to {}
end
```

Como véis en vez de poner las claves que nos proporciona Amazon directamente utilizamos unas variables de entorno. 
Ahora vamos a modificar nuestro archivo 'app/model/post.rb' y añadimos la siguiente línea justo debajo de la definición de clase para 'montar' nuestro uploader.

```ruby
class Post < ActiveRecord::Base
  mount_uploader :image, PostImageUploader
  paginates_per 5

  def timestamp
    created_at.strftime('%d %B %Y %H:%M:%S')
  end
end

```

#### Crear los métodos new, create y show

Vamos a modificar nuestro archivo 'posts_controller.rb' para añadir los métodos "new,create y show" que necesitaremos para poder agregar mensajes a nuestra app. También crearemos el método privado 'post_params', que nos asegurará de que los parámetros que vamos a incluir en nuestra tabla sean los adecuados y el método 'set_post' que le dirá a la vista que post es el que tiene que editar, mostrar, actualizar o borrar.

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
<%= link_to 'Delete', post_path(@post), method: :delete, data: { confirm: 'Estás seguro?' }, :class=>"btn btn-danger" ,:type=>'button'%>
</div>
```

Realizados todos estos cambios sólo nos faltaría agregar un botón a nuestra página principal para crear nuevos posts. Modificamos 'app/views/posts/index.html.erb' y lo dejamos de la siguiente forma:

```html
<div class="page-header">
  <h1>My posts</h1>
  <div class="header-btn">
    <%= link_to 'New Post',new_post_path, :class=>"btn btn-default" ,:type=>'button' %>
  </div>
</div>
<p id="notice"><%= notice %></p>

<div id="my-posts">
  <%= render @posts %>
</div>

<div id="infinite-scrolling">
  <%= paginate @posts %>
</div>
```

El paso siguiente va a ser hacer que el botón 'Editar' que acabamos de colocar en 'app/views/show.html.erb' sea funcional, de momento no tenemos ni el método en nuestro controlador, vamos a crearlo.
Abrimos 'app/controllers/posts_controller.rb' y agregaremos el método editar.

```ruby
class PostsController < ApplicationController
...
  def edit
  end
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

Si intentamos actualizar nuestro post veremos que nos da un error puesto que no tenemos creado el método 'update' en nuestro controlador, así que vamos a añadirlo. De paso vamos a añadir también el método 'destroy'
que nos permitirá borrar un post.

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
end
```

Por último vamos a añadir el botón 'Borrar' en nuestra vista 'show.html.erb' que nos permitirá borrar ese post.

```html
...
<%= link_to 'Delete', post_path(@post), method: :delete, data: { confirm: 'Estás seguro?' }, :class=>"btn btn-default" ,:type=>'button'%>

...
```


### Añadiendo Comentarios
Es hora de que podamos añadir comentarios a nuestros posts.

Para empezar, vamos a añadir un nuevo modelo a nuestra base de datos para almacenar tanto los comentarios como el autor de los mismos.




### Referencias
Este tutorial ha sido creado gracias a la ayuda de los siguientes sitios:
* [Carrierwave Gem](https://github.com/carrierwaveuploader/carrierwave)
* [How to create infinite scroll with jQuery](https://github.com/amatsuda/kaminari/wiki/How-To:-Create-Infinite-Scrolling-with-jQuery)
* [Infinite Scrolling in Rails: The Basics](http://www.sitepoint.com/infinite-scrolling-rails-basics/)
* [Fog Gem](https://github.com/fog/fog)

### Agradecimientos
Gracias a [Max](https://github.com/maxvlc) y [Salva](https://github.com/salveta) por ayudarme a crear, mejorar y testear el tutorial.

Gracias a [Devscola](http://www.devscola.com)
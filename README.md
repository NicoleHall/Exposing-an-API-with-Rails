# Exposing an API with Rails
##Setup

We're going to be driving this development from a learning perspective, so
everything is going to be done backwards (at least from a TDD point of view).
Once you understand the concepts and process, I suggest driving your next API
from the feature or controller tests.

### Rails new

First things first, we need a Rails app.

### Rails with rspec/postgress

First we will setup a Rails App.

`rails new -T --database=postgresql`

Add the rspec-rails gem to the test environment

`gem 'rspec-rails'`

bundle and install rspec
`bundle && rails g rspec:install`

Once you've exposed an API or two this way, explore some options for ditching
the rest of the Rails App (views, javascripts, styles, etc.) with gems like
`gem 'rails-api'`. But just like learning any skills, do it yourself first, then
use the shortcuts.

### Present Gifting Data

#### YAML Data File
If you haven't yet dealt with YAML(Yet Another Markdown Language), it is a fast
and easy way to make data. One of the best parts about it is the Ruby Standard
Library tool `require "yaml"`. This gives us a simple hash to work with.

Working with a complex yaml file including nested group of hashes can be
difficult. If you find yourself in this situation, look for a better tool than
Ruby's vanilla YAML parser. An easy to alternative to understand and use is
[Hashie](https://github.com/intridea/hashieworking).

We'll stick with dealing with hashes for now.

YML files are composed of keys and values, which is why it so naturally
translates into a Ruby hash. They look something like this
```yaml
tools:
     hammer:
       weight: 2 lbs
       color: red
       subTools:
          1: nails
          2: boards
     wrench:
       weight: 3 lbs
       color: gray
       subTools:
          1: null
```

This would give us a hash which looks like this
```ruby
{ "tools":
  { "hammer":
    { "weight": "2 lbs",
      "color": "red",
      "subTools":
        { 1: nails,
          2: boards
        }
    },
  { "wrench":
    { "weight": "3 lbs",
      "color": "gray",
      "subTools":
        { 1: null
        }
     }
  }
}
```

A special case I'd like to note (because it gave me such trouble) is when you
want to include special characters in the value of one of your keys.

Such as:
`description: There was only one path before me: the path of the sleepy lion.`

You'll get an error which looks like this:
```
Psych::SyntaxError: (my_file_name.yml): mapping values are not allowed in this context at line 3 column 35
from /Users/myComputerName/.rvm/gems/ruby-2.2.0/gems/psych-2.0.13/lib/psych.rb:370:in 'parse'
```

The solution is pretty simple, use a pipe and new line:
```
description: |
There was only one path before me: the path of the sleepy lion.
```

#### Data Import Rake Task

Now we are driving this backwards, but a data import isn't a terrible place to
discover how you want to structure a small database. We built each YAML file as
a model in our database, but given an unnecessarily complicated YAML structure,
you might extract several models from one file. We won't be dealing with that
problem in this project, but you'll see how easy it would be to do whatever you
want once we're in Ruby land.

When I see a data file and an empty database, I want to write a script to do all
the data entry for me. Tasks like this are usually handled by scripts called
Makefiles. The late, great Jim Weirich in his love for Ruby gifted the world
[Rake](https://en.wikipedia.org/wiki/Rake_(software)).

Rake files give us some command line power to deal with our environment and in
this case, our database. We'll be writing a Rakefile to import data from a YAML
file to our Postgresql database. The best thing about rake is we get to write
plain old Ruby.

So in pseudocode we're going to say something like
```
Parse a YAML file,
Iterate through each piece,
Create a database entry for that model.
Repeat for each YAML file.
```

The first thing we need is some Rake syntax
```ruby
namespace :data do
  desc "Import the User, Wrapping, and Present YAML files into models in our DB."
  task :import => :environment do
  end
end
```

This is pretty self explanatory. The namespace and task name will look like this
when you type them into the command line: `rake data:import` look familiar? We
could make the namespace `db` and the task `import` and it might seem even more
natural: `rake db:import`.

Next we'll grab the YAML data by identifying the file and loading it into a
variable (as a hash, remember).

```ruby
users_file = "#{Rails.root}/lib/assets/users.yml"
users_yml  = YAML.load_file(users_file)
```

Now that we have this hash, let's make a User out of it
```ruby
users_yml["users"].each do |id, user|
  user["id"] = id
  User.create!(user)
  puts "created User #{user["name"]}"
end
```

Now this will work once we have our database set up, but we will be doing the
same thing for wrappings, so let's extract a little bit.

```ruby
  @klass = User
  users_yml["users"].each(&populate)
  @klass = Wrapping
  wrappings_yml["wrappings"].each(&populate)

  def populate
    proc do |id, data|
      data["id"] = id
      k = @klass.create!(data)
      puts_created(k)
    end
  end

  def puts_created(obj)
    puts "Created #{obj.class.to_s} #{obj.id} name: #{obj.name}"
  end
```

Presents will have to be custom handled, and look sa little more messy, but
something like this would work.

```ruby
presents_yml["presents"].each do |id, data|
  #this would be better with hashie
  present = Present.create!(id: id,
                            name: data["name"],
                            price: data["price"],
                            regifted: data["regifted"],
                            receiver: data["receiver"],
                            giver: data["giver"]),
  present.wrappings      << data["wrappingPapers"].values.map {|w| Wrapping.find(w)}
  puts_created(present)
end
```

This `import.rake` belongs in `lib/tasks/`. All our data is accounted for. Let's
make the database for this task to actually run.

### Create the Database

```
rails g model Present name:string price:decimal regifted:boolean receiver:integer giver:integer
rails g model User name:string present:belongs_to
rails g model Wrapping name:string present:belongs_to
```

I didn't want to go through ActiveRecord hell, so I just set up some terrible
user methods on `Present`.

Finally, run the rake command:
```
rake db:create db:migrate data:import
```

Play around in Rails C to see that the data exists.

## Implementing the API
### First Test Iteration 0

Rather than feature, view, or integration tests, the bulk of our tests will
revolve around models and the controllers which expose them. These tests are
usually very simple which should be a reflection of our app. Complex logic
should be easily extracted into the models which deal with it, and strange
requests can be handled by controller edge case tests.

To write an iteration 0 controller test, we simply need to make a request to a
route, and check that the response looks like we want it to. In the simplest
terms we want the request to be successful.

So let's make a file called `spec/controllers/api/v1/presents_controller.rb` and
put this in it:
```ruby
require 'rails_helper'
RSpec.describe Api::V1::PresentsController, :type => :controller do
  describe "get #index" do
    it "returns a nice response" do
      get :index
      expect(response.status).to eq(200)
    end
  end
end
```

Run the test, follow the error messages, and eventually come up with the
following in `app/controllers/api/v1/presents_controller.rb`:
```ruby
class Api::V1::PresentsController < ApplicationController
  respond_to :json
  def index
    render json: ""
  end
end
```
We get here by making a versioned controller which uses the responders gem to
give us json instead of a template.

### First Test Iteration 1
Knowing everything is 200 is great, but we want to make sure our controller is
doing exactly what we want it to. Let's make an assertion about which presents
we're getting back after all.

```ruby
describe "get #index" do
  it "returns a all the presents" do
    get :index
    expect(response.status).to eq(200)
    expect(response.body).to eq(Present.all.to_json)
  end
end
```

For this test to make any sense, we need some fixture data. Factories are
usually a better solution and only take a few minutes to set up, so add one
really quickly.

Firstly add `gem 'factory_girl'` to your Gemfile in the test environment. Then
bundle.

Add this chunk in the `RSpec.configure` block in `spec_helper.rb`:
```ruby
config.include FactoryGirl::Syntax::Methods
config.before(:suite) do
  begin
    DatabaseCleaner.start
    FactoryGirl.lint
  ensure
    DatabaseCleaner.clean
  end
end
  config.before(:each, type: :controller) do
  FactoryGirl.create(:present)
end
```

Then we have to create that factory the last line is creating. I chose to put
mine in `spec/factories/presents.rb` and that looks like this:
```ruby
FactoryGirl.define do
  factory :present do
    name "ThingOne"
    price 1.99
    giver 1
    receiver 2
    regifted false
  end
end
```

Our test should fail, because we're still spouting out some empty string
nonsense, but the solution is very simple at this point.

In `presents_controller.rb`
```ruby
class Api::V1::PresentsController < ApplicationController
  respond_to :json
  def index
    render json: Present.all
  end
end
```

### Second Test and Refactoring with base_controller.rb

Yay we made a test pass and actually mean something. Now we can very quickly
test the same functionality for another model such as Users.

Once that's working, you might notice some small duplication. Let's extract that
using a versioned `base_controller.rb`.

Eventually `base_controller.rb` should look like this:
```ruby
class Api::V1::BaseController < ApplicationController
  respond_to :json

  def model_class
    #overriden in each controller
  end

  def index
    render json: model_class.all
  end
end
```

And `presents_controller.rb` should look like this:
```ruby
class Api::V1::PresentsController < Api::V1::BaseController
  def model_class
    Present
  end
end
```

These may look like small changes now, but once your API starts to grow, having
a base controller will save you A LOT of time.

#### API Documentation

Documenting your API can be quite a challenge. Fortunately there are automated
tools out there which can do that job for you. One I've come to like is `gem
'rspec_api_documentation'` and it's companion `gem 'apitome'`.

They add a dsl which will change the look of your tests a little bit. Something
more along the lines of:
```ruby
resource "Presents" do
  get "#{root_path}/presents" do
    example "Listing Presents" do
      do_request
      expect(status).to be(200)
    end
  end
end
```

Fortunately test driving is just as simple with these tools.

### Desired API Format and Serializer

You can't really go wrong with JSON, but you may want your API to look and feel
more formal. I've found the best tool for this problem is
`gem 'active_model_serializers'`. Using this gem properly you can very quickly
and very simply leverage ActiveRecord to construct the exact JSON output you
want.

Be careful working with these, as they very quickly break all of your tests.
You're no longer just `.to_json`ing every expected value. Instead you need to
use the active_model_serializers in the tests themselves to and therefore test
that the serializers are serializing properly, which feels very tedious and time
consuming.

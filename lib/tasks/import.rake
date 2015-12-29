require 'yaml'
namespace :data do
  desc "Import the User, Wrapping, and Present YAML files into models in our DB."
  #this task is meant to be ran after
  #the db has been dropped and recreated
  task :import => :environment do
    users_path = "#{Rails.root}/lib/assets/users.yml"
    users_yml = YAML.laod_file(users_path)

    users_yml["users"].each do |user, id|
      user["id"] = id
      User.create!(user)
    end
  end
end

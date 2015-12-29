require 'yaml'
namespace :data do
  desc "Import the User, Wrapping, and Present YAML files into models in our DB."
  #this task is meant to be ran after
  #the db has been dropped and recreated
  task :import => :environment do
    users_path = "#{Rails.root}/lib/assets/users.yml"
    users_yml = YAML.load_file(users_path)
    wrappings_path = "#{Rails.root}/lib/assets/wrappings.yml"
    wrappings_yml = YAML.load_file(wrappings_path)
    presents_path = "#{Rails.root}/lib/assets/presents.yml"
    presents_yml = YAML.load_file(presents_path)

    def populate
      proc do |id, data|
         data["id"]=id
        @klass.create!(data)
        puts "created #{@klass}: #{data['name']}"
      end
    end

    @klass = User
    users_yml["users"].each(&populate)
    @klass = Wrapping
    wrappings_yml["wrappings"].each(&populate)
    presents_yml["presents"].each do |id, present|
      present["id"] = id
      pres = Present.create!(name: present["name"], price: present["price"], regifted: present["regifted"], receiver: present["receiver"], giver: present["giver"])

      pres.wrappings << present["wrappingPapers"].values.map { |w| Wrapping.find(w) }
      puts "created Present: #{present['name']}"
    end
  end
end

# frozen_string_literal: true

require 'yaml'

# Load env vars if not yet loaded
SINATRA_ENV = ENV.fetch("SINATRA_ENV") do |el|
  require 'dotenv/load'
  ENV.fetch(el)
end
DB_CONFIG = YAML::load(
  File.open('config/database.yml')
).fetch(SINATRA_ENV)

require "active_record"

db_namespace = namespace :db do
  desc "Establish a connection to the database"
  task :establish_connection do
    ActiveRecord::Base.establish_connection(DB_CONFIG)
  end

  desc "Creates the database from DATABASE_URL or config/database.yml for the current RAILS_ENV (use db:create:all to create all databases in the config). Without RAILS_ENV or when RAILS_ENV is development, it defaults to creating the development and test databases, except when DATABASE_URL is present."
  task create: :establish_connection do
    ActiveRecord::Tasks::DatabaseTasks.create_current
  end

  desc "Drops the database from DATABASE_URL or config/database.yml for the current RAILS_ENV (use db:drop:all to drop all databases in the config). Without RAILS_ENV or when RAILS_ENV is development, it defaults to dropping the development and test databases, except when DATABASE_URL is present."
  task drop: :establish_connection do
    ActiveRecord::Tasks::DatabaseTasks.drop_current
  end

  desc "Migrate the database"
  task migrate: :establish_connection do
    ActiveRecord::Tasks::DatabaseTasks.migrate
    db_namespace["schema:dump"].invoke
  end

  desc "Rolls the schema back to the previous version (specify steps w/ STEP=n)."
  task rollback: :establish_connection do
    step = ENV["STEP"] ? ENV["STEP"].to_i : 1

    ActiveRecord::Base.connection.migration_context.rollback(step)

    db_namespace["schema:dump"].invoke
  end

  desc "Reset the database"
  task :reset => [:drop, :create, :migrate]

  namespace :schema do
    desc "Creates a database schema file (either db/schema.rb or db/structure.sql, depending on `config.active_record.schema_format`)"
    task dump: :establish_connection do
      class SchemaConfig < SimpleDelegator
        def name
          ENV.fetch("SCHEMA")
        end
      end
      schema_config = SchemaConfig.new(DB_CONFIG)
      # Shim Rails for ActiveRecord
      class Rails
        EXPECTED_METHODS = %i(application config paths)
        class << self
          def [](_key)
            [
              "db"
            ]
          end
  
          def method_missing(method_name, *_args)
            if EXPECTED_METHODS.include?(method_name)
              self
            else
              super
            end
          end
        end
      end
      ActiveRecord::Tasks::DatabaseTasks.dump_schema(schema_config)

      db_namespace["schema:dump"].reenable
    end
  end
end

namespace :g do
  desc "Generate migration"
  task :migration do
    name = ARGV[1] || raise("Specify name: rake g:migration your_migration")
    timestamp = Time.now.strftime("%Y%m%d%H%M%S")
    path = File.expand_path("../db/migrate/#{timestamp}_#{name}.rb", __FILE__)
    migration_class = name.split("_").map(&:capitalize).join

    File.open(path, 'w') do |file|
      file.write <<-EOF
# frozen_string_literal: true

class #{migration_class} < ActiveRecord::Migration[#{ActiveRecord::Migration.current_version}]
  def change
  end
end
      EOF
    end

    puts "Migration #{path} created"
    abort # needed stop other tasks
  end
end

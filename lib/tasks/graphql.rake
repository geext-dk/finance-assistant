namespace :graphql do
  task :dump_schema => :environment do
    # TODO https://rmosolgo.github.io/ruby/graphql/2017/03/16/tracking-schema-changes-with-graphql-ruby
    schema_def = FinanceAssistantSchema.to_definition

    schema_path = "app/graphql/schema.graphql"

    File.write(Rails.root.join(schema_path), schema_def)
    puts "Updated #{schema_path}"
  end
end

module SpreeTaxCloud
    module Generators
        class InstallGenerator < Rails::Generators::Base

            argument :file_name, :type => :string, :desc => 'rails app_path', :default => '.'
            source_root File.expand_path('../../templates', __FILE__)

            def copy_initializer_file
                template 'ca-bundle.crt', "#{file_name}/lib/ca-bundle.crt"
            end

            def add_migrations
                run 'bundle exec rake railties:install:migrations FROM=spree_tax_cloud'
            end

            def run_migrations
                res = ask 'Would you like to run the migrations now? [Y/n]'
                if res == '' || res.downcase == 'y'
                    run 'bundle exec rake db:migrate'
                else
                    puts 'Skiping rake db:migrate, don\'t forget to run it!'
                end
            end
        end
    end
end


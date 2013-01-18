Spree::Core::Engine.routes.draw do
  namespace :admin do
    resource :tax_cloud_settings
  end
end

Spree::Core::Engine.routes.draw do
  namespace :admin do
    resource :mail_chimp_settings
  end
end

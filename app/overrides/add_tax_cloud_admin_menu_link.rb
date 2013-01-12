Deface::Override.new(:virtual_path  => 'spree/admin/configurations/index',
                     :name          => 'add_tax_cloud_admin_menu_link',
                     :insert_bottom => "[data-hook='admin_configurations_menu']",
                     :partial       => 'spree/admin/configurations/spree_tax_cloud_configuration_link' )


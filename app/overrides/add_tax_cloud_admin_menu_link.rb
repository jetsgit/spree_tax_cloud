Deface::Override.new(:virtual_path  => 'spree/admin/shared/_configuration_menu',
                     :name          => 'add_tax_cloud_admin_menu_link',
                     :insert_bottom => "[data-hook='admin_configurations_sidebar_menu']",
                     :text => %q{
                        <%= configurations_sidebar_menu_item 'Taxcloud Settings', admin_tax_cloud_settings_path%>
                     })


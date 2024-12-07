Rails.application.config.after_initialize do
  if Spree::Core::Engine.backend_available?
    Rails.application.config.spree_backend.main_menu.add_to_section(
      'settings',
      ::Spree::Admin::MainMenu::ItemBuilder.new(
        'easy_post_settings',
        ::Spree::Core::Engine.routes.url_helpers.edit_admin_easypost_setting_path(id: "easypost_settings")
      )
      .with_manage_ability_check(SpreeEasypost::Spree::Easypost)
      .with_match_path('/easy_post_settings')
      .build
    )

    Rails.application.config.spree_backend.main_menu.add_to_section(
      'orders',
      ::Spree::Admin::MainMenu::ItemBuilder.new(
        'return_tracking',
        ::Spree::Core::Engine.routes.url_helpers.admin_customer_shipments_tracking_index_path
      )
      .with_manage_ability_check(Spree::CustomerShipment)
      .with_match_path('/admin_customer_shipments')
      .build
      )

    Rails.application.config.spree_backend.main_menu.add_to_section(
      'orders',
      ::Spree::Admin::MainMenu::ItemBuilder.new(
        'scan_form',
        ::Spree::Core::Engine.routes.url_helpers.admin_scan_forms_path,
      )
      .with_manage_ability_check(::Spree::ScanForm)
      .with_match_path('/scan_form')
      .build
    )
  end
end
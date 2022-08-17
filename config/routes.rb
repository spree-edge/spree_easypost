Spree::Core::Engine.add_routes do
  # Add your extension routes here
  namespace :admin do
    resources :orders do
      resources :return_authorizations do
        resources :return_labels
      end
    end

    resources :scan_forms, only: [:index, :new, :create]

    resources :customer_shipments_tracking, only: [:index]

    resources :easypost_settings, only: [:edit, :update]
  end

  namespace :api do
    namespace :v1 do
      resources :customer_shipments do
        
      end

      post "/scan_form" => "shipments#scan_form"

    end

    namespace :v2 do
      namespace :platform do
        resources :shipments do
          member do
            put :buy_postage
          end
        end
      end
    end
  end
end

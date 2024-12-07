module Spree
    module Admin
      class ScanFormsController < ResourceController

        before_action :load_data, only: [:new, :create]

        def index
          params[:q] ||= {}
  
          @scan_forms = ScanForm.all
        
          @search = @scan_forms.ransack(params[:q])
          per_page = params[:per_page] || Spree::Config[:products_per_page]
          @scan_forms = @search.result.order(created_at: :desc).page(params[:page]).per(per_page)

          respond_with(@scan_forms)
        end

        private

        def load_data
          @stock_locations = Spree::StockLocation.order(:name)
        end

        def model_class
          Spree::ScanForm
        end

      end
    end
  end
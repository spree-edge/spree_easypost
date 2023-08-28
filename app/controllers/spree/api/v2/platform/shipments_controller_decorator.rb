module Spree
  module Api
    module V2
      module Platform
        module ShipmentsControllerDecorator
          def self.prepended(base)
            base.respond_to :json
          end

          def buy_postage
            begin
              # find_and_update_shipment
              params[:shipment] ||= {}
              unless resource.tracking_label?
                resource.buy_easypost_rate
                resource.save!
                unless resource.shipped?
                    resource.ship!
                end
              end
              respond_with(resource.reload, default_template: :show)
            rescue ::EasyPost::Errors => e
              render json: { :error => e.message }, :status => :bad_request
            rescue Exception => e
              render json: { :error => e.message }, :status => :bad_request
            end
          end

          def scan_form
            begin
              @scan_form = ::Spree::ScanForm.create!(stock_location_id: params[:stock_location_id])
              render json: { scan_form: @scan_form.scan_form }
            rescue Exception => e
              render json: { :error => e.message } , :status => :bad_request
            end
          end
        end
      end
    end
  end
end

Spree::Api::V2::Platform::ShipmentsController.prepend Spree::Api::V2::Platform::ShipmentsControllerDecorator

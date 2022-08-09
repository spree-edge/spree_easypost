Deface::Override.new(
    virtual_path: 'spree/admin/shipping_categories/_form',
    name: 'add_easypost',
    insert_bottom: '[data-hook="admin_shipping_category_form_fields"]',
    text: "<div data-hook='admin_shipping_category_easypost'>
            <%= f.field_container :use_easypost, class: ['form-group'] do %>
              <%= f.label :use_easypost, Spree.t(:use_easypost) %>
              <%= f.check_box :use_easypost, class: 'form-control' %>
            <% end %>
          </div>"
)
Deface::Override.new(
    :virtual_path => "spree/admin/return_authorizations/new",
    :name => "label_info",
    :insert_before => "[data-hook='buttons']",
    :text => "<div data-hook='admin_return_authorizations_easypost'>
                <%= f.field_container :custom_weight, class: ['form-group'] do %>
                  <%= f.label :custom_weight, Spree.t(:custom_weight) %>
                  <%= f.number_field :custom_weight, min: 0, step: 0.1, class: 'form-control' %>
                <% end %>
                <%= f.field_container :create_label, class: ['form-group'] do %>
                  <%= f.label :create_label, Spree.t(:create_label) %>
                  <%= f.check_box :create_label, checked: true, class: 'form-control' %>
                <% end %>
              </div>"
  )
  
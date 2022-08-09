Deface::Override.new(:virtual_path => "spree/admin/products/_form",
  :name => "add_hs_tariff_number",
  :insert_after => "[data-hook='admin_product_form_right']",
  :text => "<div data-hook='admin_product_form_easy_post_hs_tariff_number'>
  <%= f.field_container :easy_post_hs_tariff_number, class: ['form-group'] do %>
    <%= f.label :easy_post_hs_tariff_number, Spree.t('admin.easy_post_hs_tariff_number') %>
    <%= f.text_field :easy_post_hs_tariff_number, class: 'form-control' %>
  <% end %>
</div>")
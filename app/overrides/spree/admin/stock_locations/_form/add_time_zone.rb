Deface::Override.new(
    virtual_path: 'spree/admin/stock_locations/_form',
    name: 'add_time_zone',
    insert_bottom: '[data-hook="stock_location_country"]',
    text: '<div class="form-group" data-hook="stock_location_country">
            <%= f.label :time_zone, Spree.t(:time_zone) %>
            <span id="time_zone"><%= f.time_zone_select :time_zone, nil, :default => "UTC", :class => "select2" %></span>
          </div>'
)
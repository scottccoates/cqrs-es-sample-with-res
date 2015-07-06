require 'test_helper'

module CommandHandlers
  class RemoveItemFromBasketTest < ActiveSupport::TestCase
    test 'item is removed from draft order' do
      with_aggregate do |id, event_store|
        product_id = 102
        act(event_store, Commands::RemoveItemFromBasket.new(order_id: id, product_id: product_id))
        assert_changes(event_store, Events::ItemRemovedFromBasket.create(id, product_id))
      end
    end

    test 'no remove allowed to created order' do
      with_aggregate do |id, event_store|
        customer_id = 1
        order_number = "123/08/2015"
        product_id = 102
        arrange(event_store, Events::OrderCreated.create(id, order_number, customer_id))

        assert_raises(Domain::Order::AlreadyCreated) do
          act(event_store, Commands::RemoveItemFromBasket.new(order_id: id, product_id: product_id))
        end
        assert_no_changes(event_store)
      end
    end
  end
end
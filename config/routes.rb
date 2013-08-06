Spree::Core::Engine.routes.draw do
  get "checkout/ideal/confirm", :to => "ideal#confirm", :as => :ideal_confirm
end

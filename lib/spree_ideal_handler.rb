require 'spree_core'
require 'spree_ideal_handler/engine'
require 'ideal'

class Ideal::Gateway
  private
  def log(thing, contents)
    Rails.logger.debug "\033[0;34m[Ideal]\033[0;30m #{thing}\n#{contents}\n"
  end
end
class PreExistingOrderException

  attr_accessor :order

  def initialize(order, message = nil)
    super(message)
    @order = order
  end

end

class PreExistingOrderException

  def initialize(order, message=nil)
    super(message)
    @order = order
  end

end

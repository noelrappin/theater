class PreExistingPurchaseException

  attr_accessor :purchase

  def initialize(purchase, message = nil)
    super(message)
    @purchase = purchase
  end

end

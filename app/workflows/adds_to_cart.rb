class AddsToCart

  attr_accessor :user, :performance, :count, :result

  def initialize(user:, performance:, count:)
    @user = user
    @performance = performance
    @count = count.to_i
    @result = false
  end

  def run
    tickets = performance.unsold_tickets(count)
    return if tickets.size != count
    tickets.each { |ticket| ticket.place_in_cart_for(user) }
    self.result = tickets.all?(&:valid?)
    result
  end

end

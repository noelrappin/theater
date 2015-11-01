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
    tickets.each { |ticket| ticket.waiting_for(user) }
    self.result = tickets.all?(&:save)
    result
  end

end

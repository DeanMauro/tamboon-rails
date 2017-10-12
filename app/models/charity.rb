class Charity < ActiveRecord::Base
  validates :name, presence: true

  def credit_amount(amount)
    new_total = total + amount
    update_attribute :total, new_total
  end

  # Select a charity at random 
  def self.random
  	offset(rand(count)).first	# Not as random as PG Random() method, but is db-agnostic & will scale better
  end
end

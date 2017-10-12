class Charity < ActiveRecord::Base
  validates :name, presence: true

  def credit_amount(amount)
  	with_lock { update_attribute :total, (total + amount) }
  end

  # Select a charity at random 
  def self.random
  	offset(rand(count)).first	# Not as random as PG Random() method, but is db-agnostic & will scale better
  end
end

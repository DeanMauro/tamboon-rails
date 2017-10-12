class String

	def baht_to_satang
		return 0 if self.blank?

		# Remove any commas & take decimal into account
		amount = self.gsub(',','').to_f

		# Convert to satang & return int version
		return (amount * 100).to_i
	end

end

class NilClass
	def baht_to_satang
		return 0
	end
end
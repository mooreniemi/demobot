module Operators
	# these are the operators on ##marxism
  # replace these with your channel's ops
  $ops = %w(emmeka
            fuzzyhorns
            jacobian
            kilobug
            LennyKitty
            modulus
            tristan)

  def self.include?(user)
    $ops.include?(user)
  end
  
end

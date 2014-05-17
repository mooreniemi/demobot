module Operators
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

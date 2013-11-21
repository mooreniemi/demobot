require 'date'

def strip_formatting(msg)
  msg.gsub(/[\x03]\d{2}(,\d{2})?/, "").delete("" << 2 << 15 << 22 << 31)
end

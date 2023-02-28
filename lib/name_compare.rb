class NameCompare
  def self.same(n1, n2)
    if (n1 != nil && n2 != nil)
      return n1.downcase == n2.downcase
    end

    return false
  end
end

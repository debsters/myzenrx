class String
  def to_number
      number = self.tr("A-Z", "1-9a-q").to_i(27)
      number -= 1 if number > 27
      return number
  end

  def initial
    self[0,1]
  end

end
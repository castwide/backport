module InputAdapter
  @@received = ''

  def self.received
    @@received
  end

  def receiving data
    @@received.concat data
  end
end

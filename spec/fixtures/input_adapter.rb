module InputAdapter
  @@received = ''

  def self.received
    @@received
  end

  def sending data
    @@received.concat data
  end
end

module CloseAdapter
  def opening
    write 'Closing connection immediately'
    close
  end
end

require 'stringio'

RSpec.describe Backport::Adapter do
  it "writes to out" do
    output = StringIO.new
    adapter = Backport::Adapter.new(output)
    adapter.write 'sent'
    expect(output.string).to eq('sent')
  end

  it "writes a line to out" do
    output = StringIO.new
    adapter = Backport::Adapter.new(output)
    adapter.write_line 'sent'
    adapter.write_line 'sent'
    expect(output.string).to include('sent')
    expect(output.string.lines.length).to eq(2)
  end
end

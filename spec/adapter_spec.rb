require 'stringio'

RSpec.describe Backport::Adapter do
  it "writes to out" do
    output = StringIO.new
    adapter = Backport::Adapter.new(output)
    adapter.write 'sent'
    expect(output.string).to eq('sent')
  end
end

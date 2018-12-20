RSpec.describe Backport::Client do
  it "accepts a module" do
    expect {
      mod = Module.new
      Backport::Client.new(nil, nil, mod)
    }.not_to raise_error
  end

  it "accepts an adapter subclass" do
    expect {
      cls = Class.new(Backport::Adapter)
      Backport::Client.new(nil, nil, cls)
    }.not_to raise_error
  end

  it "rejects invalid adapters" do
    expect {
      Backport::Client.new(nil, nil, Object)
    }.to raise_error(TypeError)
  end
end

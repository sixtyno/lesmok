require 'lesmok'
describe ::Lesmok::Tags do

  before(:all) do
    described_class.register_tags
  end

  describe described_class::DebugComment do
    let(:template){ Liquid::Template.parse("{% debug_comment %} HUH HUH {% enddebug_comment %}") }
    it "should render contents in debugging mode" do
      Lesmok.config.debugging_enabled = true
      text = template.render
      expect(text).to include "HUH HUH"
      expect(text).to include "<!--"
    end

    it "should not render contents by default" do
      Lesmok.config.debugging_enabled = false
      text = template.render
      expect(text).to be == ""
    end
  end

end

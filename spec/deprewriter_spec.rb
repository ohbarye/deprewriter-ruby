# frozen_string_literal: true

RSpec.describe Deprewriter do
  let(:test_class) do
    Class.new do
      extend Deprewriter

      def self.name
        "TestClass"
      end

      def old_method(value)
        value * 2
      end

      def new_method(value)
        value * 2
      end
    end
  end

  let(:test_file) { File.join(Dir.pwd, "tmp/test_file.rb") }
  let(:test_source) do
    <<~RUBY
      class TestClass
        def test_method
          old_method(42)
        end
      end
    RUBY
  end

  before do
    FileUtils.mkdir_p(File.dirname(test_file))
    File.write(test_file, test_source)
  end

  after do
    FileUtils.rm_rf(File.dirname(test_file))
    Deprewriter.configure do |config|
      config.mode = :disabled
    end
  end

  describe ".configure" do
    it "allows configuration of mode" do
      Deprewriter.configure do |config|
        config.mode = :diff
      end

      expect(Deprewriter.config.mode).to eq(:diff)
    end
  end

  describe "#deprewrite" do
    context "when mode is :diff" do
      before do
        Deprewriter.configure do |config|
          config.mode = :diff
        end
        test_class.deprewrite :old_method, to: "new_method"
      end

      it "creates a diff file when deprecated method is called" do
        instance = test_class.new
        allow(Gem).to receive(:location_of_caller).and_return([test_file, 3])

        instance.old_method(42)

        diff_files = Dir.glob("deprewriter_*.diff")
        expect(diff_files).not_to be_empty

        diff_content = File.read(diff_files.first)
        expect(diff_content).to include("-    old_method(42)")
        expect(diff_content).to include("+    new_method")

        FileUtils.rm(diff_files.first)
      end
    end

    context "when mode is :log" do
      before do
        Deprewriter.configure do |config|
          config.mode = :log
        end
        test_class.deprewrite :old_method, to: "new_method"
      end

      it "logs deprecation warning with diff" do
        instance = test_class.new
        allow(Gem).to receive(:location_of_caller).and_return([test_file, 3])

        expect(Deprewriter.config.logger).to receive(:warn).with(
          a_string_matching(/DEPREWRITER: .+#old_method usage at .+test_file\.rb:3 is deprecated\./)
        )

        instance.old_method(42)
      end
    end

    context "when mode is :disabled" do
      let(:unchanged_class) do
        Class.new do
          extend Deprewriter

          def old_method(value) = value * 2
        end
      end

      before do
        Deprewriter.configure do |config|
          config.mode = :disabled
        end
        unchanged_class.deprewrite :old_method, to: "new_method"
      end

      it "does not create alias method" do
        expect(unchanged_class.new.methods).not_to include(:_deprecated_old_method)
      end
    end

    it "preserves original method behavior" do
      Deprewriter.configure do |config|
        config.mode = :diff
      end
      test_class.deprewrite :old_method, to: "new_method"

      instance = test_class.new
      allow(Gem).to receive(:location_of_caller).and_return([test_file, 3])

      expect(instance.old_method(21)).to eq(42)
    end
  end
end

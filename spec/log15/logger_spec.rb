require 'log15'

describe Log15 do
  let(:log) { StringIO.new }
  let(:logger) { Logger.new(log) }
  subject { Log15::Logger.new(logger) }

  context "info" do
    it "simple message" do
      subject.info("msg", foo: "bar", baz: "foo")
      output = log.string
      expect(output).to match(/^INFO/)
      expect(output).to match(/\[\d{2}-\d{2}|\d{2}:\d{2}:\d{2}\]/)
      expect(output).to match(/msg foo="bar" baz="foo" lvl=info\n$/)
    end

    it "message with quotes" do
      subject.info("msg", foo: "\"bar\"")
      output = log.string
      expect(output).to match(/^INFO/)
      expect(output).to match(/\[\d{2}-\d{2}|\d{2}:\d{2}:\d{2}\]/)
      expect(output).to match(/msg foo="\\\"bar\\\"" lvl=info\n$/)
    end

    it "message with nested hash" do
      subject.info("msg", foo: { bar: "baz"})
      output = log.string
      expect(output).to match(/^INFO/)
      expect(output).to match(/\[\d{2}-\d{2}|\d{2}:\d{2}:\d{2}\]/)
      expect(output).to match(/msg foo="{\\\"bar\\\":\\\"baz\\\"}" lvl=info\n$/)
    end

    it "message with nested array" do
      subject.info("msg", foo: ["bar", "baz"])
      output = log.string
      expect(output).to match(/^INFO/)
      expect(output).to match(/\[\d{2}-\d{2}|\d{2}:\d{2}:\d{2}\]/)
      expect(output).to match(/msg foo="\[\\\"bar\\\",\\\"baz\\\"\]" lvl=info\n$/)
    end
  end

  context "debug" do
    it "simple message" do
      subject.debug("msg", foo: "bar")
      output = log.string
      expect(output).to match(/^DBUG/)
      expect(output).to match(/\[\d{2}-\d{2}|\d{2}:\d{2}:\d{2}\]/)
      expect(output).to match(/msg foo="bar" lvl=debug\n$/)
    end
  end

  context "sanitisation" do
    it "sanitises a key" do
      params = { "access_token" => "123456789012345678901234567890" }
      Log15::Logger.sanitize(params, "access_token")
      expect(params["access_token"]).to eq("123456****567890")
    end

    it "raises an error if key is not within a range" do
      params = { "access_token" => "onetwo" }
      expect do
        Log15::Logger.sanitize(params, "access_token", expected_length: 8..24)
      end.to raise_error(Log15::SanitizationError, "expected access_token to be between 8 and 24 characters long (is 6)")
    end

    it "doesn't sanitize a key if it doesn't exist" do
      params = { "not_access_token" => "incognito" }
      expect do
        Log15::Logger.sanitize(params, "access_token")
      end.to raise_error(Log15::SanitizationError, "expected access_token to be present")
      expect(params).to eq(params)
    end

    it "doesn't sanitize a key if it is blank" do
      params = { "access_token" => "" }
      expect do
        Log15::Logger.sanitize(params, "access_token")
      end.to raise_error(Log15::SanitizationError, "expected access_token to not be blank")
      expect(params).to eq(params)
    end
  end
end

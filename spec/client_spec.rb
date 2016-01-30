require "spec_helper"

describe Amorail::Client do
  let(:client) { Amorail.client }

  before(:each) { mock_api }

  context "default client" do
    it "should create client", :aggregate_failures do
      expect(subject.usermail).to eq "amorail@test.com"
      expect(subject.api_key).to eq "75742b166417fe32ae132282ce178cf6"
      expect(subject.api_endpoint).to eq "https://test.amocrm.ru"
    end

    it "should #authorize method call" do
      res = client.authorize
      expect(res.status).to eq 200
    end

    it "should #authorize and set cookie" do
      res = client.get("/private/api/v2/json/accounts/current")
      expect(res.status).to eq 200
    end
  end

  describe "#with_client" do
    before { mock_custom_api("https://custom.amo.com", "custom@amo.com", "123") }

    let(:new_client) do
      described_class.new(
        api_endpoint: "https://custom.amo.com",
        usermail: "custom@amo.com",
        api_key: "123"
      )
    end

    it "use custom client as instance", :aggregate_failures do
      expect(Amorail.client.usermail).to eq "amorail@test.com"
      Amorail.with_client(new_client) do
        expect(Amorail.client.usermail).to eq "custom@amo.com"
        expect(Amorail.client.api_endpoint).to eq "https://custom.amo.com"
        expect(Amorail.client.api_key).to eq "123"
      end

      expect(Amorail.client.usermail).to eq "amorail@test.com"
    end

    it "use custom client as options", :aggregate_failures do
      expect(Amorail.client.usermail).to eq "amorail@test.com"
      Amorail.with_client(
        api_endpoint: "https://custom.amo.com",
        usermail: "custom@amo.com",
        api_key: "123"
      ) do
        expect(Amorail.client.usermail).to eq "custom@amo.com"
        expect(Amorail.client.api_endpoint).to eq "https://custom.amo.com"
        expect(Amorail.client.api_key).to eq "123"
      end

      expect(Amorail.client.usermail).to eq "amorail@test.com"
    end

    it "loads custom properties", :aggregate_failures do
      expect(Amorail.properties.company.phone.id).to eq "1460589"

      Amorail.with_client(new_client) do
        expect(Amorail.properties.company.phone.id).to eq "301"
      end

      expect(Amorail.properties.company.phone.id).to eq "1460589"
    end

    it "threadsafe", :aggregate_failures do
      results = []
      q1 = Queue.new
      q2 = Queue.new
      q3 = Queue.new
      threads = []

      # This thread enters block first but commits result
      # only after the second thread enters block
      threads << Thread.new do
        q1.pop
        Amorail.with_client(usermail: 'test1@amo.com') do
          q2 << 1
          q1.pop
          results << Amorail.client.usermail
          q2 << 1
        end
        q3 << 1
      end

      # This thread enters block second and commits result
      # after the first block
      threads << Thread.new do
        q2.pop
        Amorail.with_client(usermail: 'test2@amo.com') do
          q1 << 1
          q2.pop
          results << Amorail.client.usermail
        end
        q3 << 1
      end

      # This thread enters block third and commits
      # after all other threads left blocks
      threads << Thread.new do
        Amorail.with_client(usermail: 'test3@amo.com') do
          q3.pop
          q3.pop
          results << Amorail.client.usermail
        end
      end

      q1 << 1
      threads.each(&:join)

      expect(results[0]).to eq 'test1@amo.com'
      expect(results[1]).to eq 'test2@amo.com'
      expect(results[2]).to eq 'test3@amo.com'
    end
  end
end

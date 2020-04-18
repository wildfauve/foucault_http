RSpec.describe FoucaultHttp::Net do

  context "#basic_auth_header" do

  subject { FoucaultHttp::Net.basic_auth_header }

    it 'provides an authorisation header for a basic auth' do

      result = subject.("client_id").("secret")
      expect(result).to be_instance_of Hash
      expect(result[:authorization]).to eq "Basic Y2xpZW50X2lkOnNlY3JldA=="
    end

  end

  context "#header_builder" do

    subject { FoucaultHttp::Net.header_builder }

    it 'merges two headers into a single headers hash' do

      result = subject.(FoucaultHttp::Net.basic_auth_header.("userid", "password"), {content_type: "application/json"})
      expect(result.keys).to match_array([:authorization, :content_type])

    end

  end

end

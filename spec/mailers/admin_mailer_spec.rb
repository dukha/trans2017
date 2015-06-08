require "rails_helper"

RSpec.describe AdminMailer, type: :mailer do
  describe "user_invitation_accepted" do
    let(:mail) { AdminMailer.user_invitation_accepted }

    it "renders the headers" do
      expect(mail.subject).to eq("User invitation accepted")
      expect(mail.to).to eq(["to@example.org"])
      expect(mail.from).to eq(["from@example.com"])
    end

    it "renders the body" do
      expect(mail.body.encoded).to match("Hi")
    end
  end

end

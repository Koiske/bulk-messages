require "rails_helper"

RSpec.describe "Discourse Bulk Messages" do
  context "while enabled" do
    before do
      SiteSetting.bulk_messages_enabled = true
    end

    context "as a staff user" do
      before do
        sign_in(Fabricate(:admin))
      end

      it "should let you bulk message" do
        Jobs.run_immediately!

        kampfkarren = Fabricate(:user, username: "Kampfkarren")
        buildthomas = Fabricate(:user, username: "buildthomas")
        coefficients = Fabricate(:user, username: "coefficients")

        raw = "Builderman just told me how to get infinite tix for FREE!!!"
        title = "Cool Message"

        post "/admin/plugins/discourse-bulk-messages.json", params: {
          anonymous: true,
          usernames: ["Kampfkarren", "buildthomas", "The_Ultimate_Doge_Gamer_2008"],
          raw: raw,
          title: title,
        }

        expect(response.status).to eq(200)

        kampfkarrens_pm = Topic
          .where(
            archetype: Archetype.private_message,
            title: title,
          )
          .joins(:topic_allowed_users)
          .where('topic_allowed_users.user_id = ?', kampfkarren.id)

        expect(kampfkarrens_pm.count).to eq(1)

        buildthomas_pm = Topic
        .where(
          archetype: Archetype.private_message,
          title: title,
        )
        .joins(:topic_allowed_users)
        .where('topic_allowed_users.user_id = ?', buildthomas.id)

        expect(buildthomas_pm.count).to eq(1)
        expect(buildthomas_pm.last.id).not_to eq(kampfkarrens_pm.last.id)

        expect(Topic
          .where(
            archetype: Archetype.private_message,
            title: title,
          )
          .joins(:topic_allowed_users)
          .where('topic_allowed_users.user_id = ?', coefficients.id)
          .count).to eq(0)
      end
    end

    context "as a normal user" do
      before do
        sign_in(Fabricate(:user))
      end

      it "should not let you send a bulk message" do
        post "/admin/plugins/discourse-bulk-messages.json", params: {
          anonymous: true,
          usernames: [],
          raw: "bla bla bla",
          title: "title goes here",
        }

        expect(response.status).to eq(404)
      end
    end
  end
end

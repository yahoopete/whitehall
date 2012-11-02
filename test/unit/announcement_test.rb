require "test_helper"

class AnnouncementTest < ActiveSupport::TestCase
  include Rails.application.routes.url_helpers

  test "should indicate that it appears in the site atom feed" do
    announcement = build(:published_announcement)

    urls = announcement.urls_on_which_edition_appears(host: "test.host")

    assert urls.include?(atom_feed_url)
  end

  test "should indicate that it appears on the announcements page and its atom feed" do
    announcement = build(:published_announcement)

    urls = announcement.urls_on_which_edition_appears(host: "test.host")

    assert urls.include?(announcements_url)
    assert urls.include?(announcements_url(format: "atom"))
  end

  test "should indicate that it appears on associated organisation pages" do
    organisation_1 = create(:organisation)
    organisation_2 = create(:organisation)
    announcement = create(:published_announcement, organisations: [organisation_1, organisation_2])

    urls = announcement.urls_on_which_edition_appears(host: "test.host")

    assert urls.include?(organisation_url(organisation_1))
    assert urls.include?(organisation_url(organisation_2))
  end

  test "should indicate that it appears on associated published policy activity pages and their atom feeds" do
    policy_1 = create(:published_policy)
    policy_2 = create(:published_policy)
    policy_3 = create(:draft_policy)
    announcement = create(:published_announcement, related_policies: [policy_1, policy_2])

    urls = announcement.urls_on_which_edition_appears(host: "test.host")

    assert urls.include?(activity_policy_url(policy_1.document))
    assert urls.include?(activity_policy_url(policy_2.document))
    refute urls.include?(activity_policy_url(policy_3.document))

    assert urls.include?(activity_policy_url(policy_1.document, format: "atom"))
    assert urls.include?(activity_policy_url(policy_2.document, format: "atom"))
    refute urls.include?(activity_policy_url(policy_3.document, format: "atom"))
  end

  test "should indicate that it appears on associated topic pages and their atom feeds" do
    topic_1, topic_2, topic_3 = create(:topic), create(:topic), create(:topic)
    policy_1 = create(:published_policy, topics: [topic_1])
    policy_2 = create(:published_policy, topics: [topic_2])
    policy_3 = create(:draft_policy, topics: [topic_3])
    announcement = create(:published_announcement, related_policies: [policy_1, policy_2, policy_3])

    urls = announcement.urls_on_which_edition_appears(host: "test.host")

    assert urls.include?(topic_url(topic_1))
    assert urls.include?(topic_url(topic_2))
    refute urls.include?(topic_url(topic_3))

    assert urls.include?(topic_url(topic_1, format: 'atom'))
    assert urls.include?(topic_url(topic_2, format: 'atom'))
    refute urls.include?(topic_url(topic_3, format: 'atom'))
  end

  private

  def default_url_options
    { host: "test.host" }
  end
end

require "test_helper"

class PublicationesqueTest < ActiveSupport::TestCase
  include Rails.application.routes.url_helpers

  test "should indicate that it appears in the site atom feed" do
    publicationesque = build(:published_publicationesque)

    urls = publicationesque.urls_on_which_edition_appears(host: "test.host")

    assert urls.include?(atom_feed_url)
  end

  test "should indicate that it appears on the publications page and its atom feed" do
    publicationesque = build(:published_publicationesque)

    urls = publicationesque.urls_on_which_edition_appears(host: "test.host")

    assert urls.include?(publications_url)
    assert urls.include?(publications_url(format: "atom"))
  end

  test "should indicate that it appears on associated organisation pages" do
    organisation_1 = create(:organisation)
    organisation_2 = create(:organisation)
    publicationesque = create(:published_publicationesque, organisations: [organisation_1, organisation_2])

    urls = publicationesque.urls_on_which_edition_appears(host: "test.host")

    assert urls.include?(organisation_url(organisation_1))
    assert urls.include?(organisation_url(organisation_2))
  end

  test "should indicate that it appears on associated published policy activity pages and their atom feeds" do
    policy_1 = create(:published_policy)
    policy_2 = create(:published_policy)
    policy_3 = create(:draft_policy)
    publicationesque = create(:published_publicationesque, related_policies: [policy_1, policy_2])

    urls = publicationesque.urls_on_which_edition_appears(host: "test.host")

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
    publicationesque = create(:published_publicationesque, related_policies: [policy_1, policy_2, policy_3])

    urls = publicationesque.urls_on_which_edition_appears(host: "test.host")

    assert urls.include?(topic_url(topic_1))
    assert urls.include?(topic_url(topic_2))
    refute urls.include?(topic_url(topic_3))

    assert urls.include?(topic_url(topic_1, format: 'atom'))
    assert urls.include?(topic_url(topic_2, format: 'atom'))
    refute urls.include?(topic_url(topic_3, format: 'atom'))
  end

  test "should indicate that it appears on associated minister pages" do
    person_1, person_2 = create(:person), create(:person)
    ministerial_role_1 = create(:ministerial_role)
    ministerial_role_2 = create(:ministerial_role)
    unoccupied_role = create(:ministerial_role)
    create(:role_appointment, role: ministerial_role_1, person: person_1)
    create(:role_appointment, role: ministerial_role_2, person: person_2)

    publicationesque = create(:published_publicationesque, ministerial_roles: [ministerial_role_1, ministerial_role_2, unoccupied_role])

    urls = publicationesque.urls_on_which_edition_appears(host: "test.host")

    assert urls.include?(ministerial_role_url(ministerial_role_1))
    assert urls.include?(ministerial_role_url(ministerial_role_2))
    assert urls.include?(ministerial_role_url(unoccupied_role))

    assert urls.include?(person_url(person_1))
    assert urls.include?(person_url(person_2))
  end

  private

  def default_url_options
    { host: "test.host" }
  end
end

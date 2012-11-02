require "test_helper"

class PublicationTest < EditionTestCase
  include Rails.application.routes.url_helpers

  should_allow_image_attachments
  should_be_attachable
  should_not_allow_inline_attachments
  should_allow_referencing_of_statistical_data_sets
  should_allow_a_summary_to_be_written
  should_protect_against_xss_and_content_attacks_on :title, :body, :summary, :change_note

  test 'should be invalid without a publication date' do
    publication = build(:publication, publication_date: nil)
    refute publication.valid?
  end

  test "should build a draft copy of the existing publication" do
    published_publication = create(:published_publication,
      :with_attachment,
      publication_date: Date.parse("2010-01-01"),
      publication_type_id: PublicationType::ResearchAndAnalysis.id
    )

    draft_publication = published_publication.create_draft(create(:policy_writer))

    assert_kind_of Attachment, published_publication.attachments.first
    assert_not_equal published_publication.attachments, draft_publication.attachments
    assert_equal published_publication.attachments.first.attachment_data, draft_publication.attachments.first.attachment_data
    assert_equal published_publication.publication_date, draft_publication.publication_date
    assert_equal published_publication.publication_type, draft_publication.publication_type
  end

  test "should allow setting of publication type" do
    publication = build(:publication, publication_type: PublicationType::PolicyPaper)
    assert publication.valid?
  end

  test "should be invalid without a publication type" do
    publication = build(:publication, publication_type: nil)
    refute publication.valid?
  end

  test ".in_chronological_order returns publications in ascending order of publication_date" do
    jan = create(:publication, publication_date: Date.parse("2011-01-01"))
    mar = create(:publication, publication_date: Date.parse("2011-03-01"))
    feb = create(:publication, publication_date: Date.parse("2011-02-01"))
    assert_equal [jan, feb, mar], Publication.in_chronological_order.all
  end

  test ".in_reverse_chronological_order returns publications in descending order of publication_date" do
    jan = create(:publication, publication_date: Date.parse("2011-01-01"))
    mar = create(:publication, publication_date: Date.parse("2011-03-01"))
    feb = create(:publication, publication_date: Date.parse("2011-02-01"))
    assert_equal [mar, feb, jan], Publication.in_reverse_chronological_order.all
  end

  test ".published_before returns editions whose publication_date is before the given date" do
    jan = create(:publication, publication_date: Date.parse("2011-01-01"))
    feb = create(:publication, publication_date: Date.parse("2011-02-01"))
    assert_equal [jan], Publication.published_before("2011-01-29").all
  end

  test ".published_after returns editions whose publication_date is after the given date" do
    jan = create(:publication, publication_date: Date.parse("2011-01-01"))
    feb = create(:publication, publication_date: Date.parse("2011-02-01"))
    assert_equal [feb], Publication.published_after("2011-01-29").all
  end

  test "should indicate that it appears in the site atom feed" do
    publication = build(:published_publication)

    urls = publication.urls_on_which_edition_appears(host: "test.host")

    assert urls.include?(atom_feed_url)
  end

  test "should indicate that it appears on the publications page and its atom feed" do
    publication = build(:published_publication)

    urls = publication.urls_on_which_edition_appears(host: "test.host")

    assert urls.include?(publications_url)
    assert urls.include?(publications_url(format: "atom"))
  end

  test "should indicate that it appears on associated organisation pages" do
    organisation_1 = create(:organisation)
    organisation_2 = create(:organisation)
    publication = create(:published_publication, organisations: [organisation_1, organisation_2])

    urls = publication.urls_on_which_edition_appears(host: "test.host")

    assert urls.include?(organisation_url(organisation_1))
    assert urls.include?(organisation_url(organisation_2))
  end

  test "should indicate that it appears on associated published policy activity pages and their atom feeds" do
    policy_1 = create(:published_policy)
    policy_2 = create(:published_policy)
    policy_3 = create(:draft_policy)
    publication = create(:published_publication, related_policies: [policy_1, policy_2])

    urls = publication.urls_on_which_edition_appears(host: "test.host")

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
    publication = create(:published_publication, related_policies: [policy_1, policy_2, policy_3])

    urls = publication.urls_on_which_edition_appears(host: "test.host")

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

    publication = create(:published_publication, ministerial_roles: [ministerial_role_1, ministerial_role_2, unoccupied_role])

    urls = publication.urls_on_which_edition_appears(host: "test.host")

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

class PublicationsInTopicsTest < ActiveSupport::TestCase
  def setup
    @policy_1 = create(:published_policy)
    @topic_1 = create(:topic, policies: [@policy_1])
    @policy_2 = create(:published_policy)
    @topic_2 = create(:topic, policies: [@policy_2])
    @draft_policy = create(:draft_policy)
    @topic_with_draft_policy = create(:topic, policies: [@draft_policy])
  end

  test "should be able to find a publication using the topic of an associated policy" do
    published_publication = create(:published_publication, related_policies: @topic_1.policies)

    assert_equal [published_publication], Publication.in_topic([@topic_1]).all
  end

  test "should return the publications with the given policy but not other policies" do
    published_publication_1 = create(:published_publication, related_policies: @topic_1.policies)
    published_publication_2 = create(:published_publication, related_policies: @topic_1.policies + @topic_2.policies)

    assert_equal [published_publication_1, published_publication_2], Publication.in_topic([@topic_1]).all
    assert_equal [published_publication_2], Publication.in_topic([@topic_2]).all
  end

  test "should ignore non-integer topic ids" do
    assert_equal [], Publication.in_topic(["'bad"]).all
  end

  test "returns publications with any of the listed topics" do
    publications = [
      create(:published_publication, related_policies: @topic_1.policies),
      create(:published_publication, related_policies: @topic_2.policies)
    ]

    assert_equal publications, Publication.in_topic([@topic_1, @topic_2]).all
  end

  test "should only find published publications, not draft ones" do
    published_publication = create(:published_publication, related_policies: [@policy_1])
    create(:draft_publication, related_policies: [@policy_1])

    assert_equal [published_publication], Publication.in_topic([@topic_1]).all
  end

  test "should only consider associations through published policies, not draft ones" do
    published_publication = create(:published_publication, related_policies: [@policy_1, @draft_policy])

    assert_equal [published_publication], Publication.in_topic([@topic_1]).all
    assert_equal [], Publication.in_topic([@topic_with_draft_policy]).all
  end

  test "should consider the topics of the latest published edition of a policy" do
    user = create(:departmental_editor)
    policy_1_b = @policy_1.create_draft(user)
    policy_1_b.change_note = 'change-note'
    topic_1_b = create(:topic, policies: [policy_1_b])
    published_publication = create(:published_publication, related_policies: [policy_1_b])

    assert_equal [], Publication.in_topic([topic_1_b]).all

    policy_1_b.change_note = "test"
    assert policy_1_b.publish_as(user, force: true), "Should be able to publish"
    topic_1_b.reload
    assert_equal [published_publication], Publication.in_topic([topic_1_b]).all
  end

  test "access_limited flag is ignored for non-stats types" do
    e = build(:draft_publication, publication_type: PublicationType::PolicyPaper, access_limited: true)
    refute e.access_limited?
  end

  test "persisted value of access_limited flag is nil for non-stats types" do
    e = create(:draft_publication, publication_type: PublicationType::PolicyPaper, access_limited: true)
    assert e.reload.read_attribute(:access_limited).nil?
  end
end

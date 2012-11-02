require "test_helper"

class PolicyTest < EditionTestCase
  should_allow_image_attachments
  should_allow_a_summary_to_be_written
  should_protect_against_xss_and_content_attacks_on :body

  test "does not allow attachment" do
    refute build(:policy).allows_attachments?
  end

  test "should be invalid without a summary" do
    refute build(:policy, summary: nil).valid?
  end

  test "should be invalid without an alternative format provider" do
    refute build(:policy, alternative_format_provider: nil).valid?
  end

  test "should build a draft copy of the existing policy with inapplicable nations" do
    published_policy = create(:published_policy, nation_inapplicabilities_attributes: [
      {nation: Nation.wales, alternative_url: "http://wales.gov.uk"},
      {nation: Nation.scotland, alternative_url: "http://scot.gov.uk"}]
    )

    draft_policy = published_policy.create_draft(create(:policy_writer))

    assert_equal published_policy.inapplicable_nations, draft_policy.inapplicable_nations
    assert_equal "http://wales.gov.uk", draft_policy.nation_inapplicabilities.find_by_nation_id(Nation.wales.id).alternative_url
    assert_equal "http://scot.gov.uk", draft_policy.nation_inapplicabilities.find_by_nation_id(Nation.scotland.id).alternative_url
  end

  test "should build a draft copy with references to related editions" do
    published_policy = create(:published_policy)
    publication = create(:published_publication, related_policies: [published_policy])
    speech = create(:published_speech, related_policies: [published_policy])

    draft_policy = published_policy.create_draft(create(:policy_writer))
    draft_policy.change_note = 'change-note'
    assert draft_policy.valid?

    assert draft_policy.related_editions.include?(speech)
    assert draft_policy.related_editions.include?(publication)
  end

  test "can belong to multiple topics" do
    topic_1 = create(:topic)
    topic_2 = create(:topic)
    policy = create(:policy, topics: [topic_1, topic_2])
    assert_equal [topic_1, topic_2], policy.topics.reload
  end

  test "#destroy should remove edition relations to other editions" do
    edition = create(:draft_policy)
    relationship = create(:edition_relation, document: edition.document)
    edition.destroy
    assert_equal nil, EditionRelation.find_by_id(relationship.id)
  end

  test "should be able to fetch case studies" do
    edition = create(:published_policy)
    case_study_1 = create(:published_case_study, related_policies: [edition])
    case_study_2 = create(:published_case_study, related_policies: [edition])
    case_study_3 = create(:draft_case_study, related_policies: [edition])
    random_publication = create(:published_publication, related_policies: [edition])
    assert_equal [case_study_1, case_study_2].to_set, edition.case_studies.to_set
  end

  test "should update count of published related publicationesques for publications" do
    policy = create(:published_policy)
    assert_equal 0, policy.published_related_publication_count

    publication = create(:published_publication)
    edition_relation = create(:edition_relation, document: policy.document, edition: publication)
    assert_equal 1, policy.reload.published_related_publication_count

    publication.update_attributes(state: :draft)
    assert_equal 0, policy.reload.published_related_publication_count

    publication.update_attributes(state: :published)
    assert_equal 1, policy.reload.published_related_publication_count

    edition_relation.reload.destroy
    assert_equal 0, policy.reload.published_related_publication_count
  end

  test "should update count of published related publicationesques for consultations" do
    policy = create(:published_policy)
    assert_equal 0, policy.published_related_publication_count

    consultation = create(:published_consultation)
    edition_relation = create(:edition_relation, document: policy.document, edition: consultation)
    assert_equal 1, policy.reload.published_related_publication_count

    consultation.update_attributes(state: :draft)
    assert_equal 0, policy.reload.published_related_publication_count

    consultation.update_attributes(state: :published)
    assert_equal 1, policy.reload.published_related_publication_count

    edition_relation.reload.destroy
    assert_equal 0, policy.reload.published_related_publication_count
  end
end

class PolicyUrlsOnWhichEditionAppearsTest < ActiveSupport::TestCase
  include Rails.application.routes.url_helpers

  test "should indicate that it appears in the site atom feed" do
    policy = create(:published_policy)

    urls = policy.urls_on_which_edition_appears(host: "test.host")

    assert urls.include?(atom_feed_url)
  end

  test "should indicate that it appears on the policies page and its atom feed" do
    policy = create(:published_policy)

    urls = policy.urls_on_which_edition_appears(host: "test.host")

    assert urls.include?(policies_url)
    assert urls.include?(policies_url(format: "atom"))
  end

  test "should indicate that it appears on associated organisation pages" do
    organisation_1 = create(:organisation)
    organisation_2 = create(:organisation)
    policy = create(:published_policy, organisations: [organisation_1, organisation_2])

    urls = policy.urls_on_which_edition_appears(host: "test.host")

    assert urls.include?(organisation_url(organisation_1))
    assert urls.include?(organisation_url(organisation_2))
  end

  test "should indicate that it appears its activity page and its atom feed" do
    policy = create(:published_policy)

    urls = policy.urls_on_which_edition_appears(host: "test.host")

    assert urls.include?(activity_policy_url(policy.document))
    assert urls.include?(activity_policy_url(policy.document, format: "atom"))
  end

  test "should indicate that it appears on associated topic pages and their atom feeds" do
    topic_1, topic_2 = create(:topic), create(:topic)
    policy = create(:published_policy, topics: [topic_1, topic_2])

    urls = policy.urls_on_which_edition_appears(host: "test.host")

    assert urls.include?(topic_url(topic_1))
    assert urls.include?(topic_url(topic_2))

    assert urls.include?(topic_url(topic_1, format: 'atom'))
    assert urls.include?(topic_url(topic_2, format: 'atom'))
  end

  test "should indicate that it appears on associated minister pages" do
    person_1, person_2 = create(:person), create(:person)
    ministerial_role_1 = create(:ministerial_role)
    ministerial_role_2 = create(:ministerial_role)
    unoccupied_role = create(:ministerial_role)
    create(:role_appointment, role: ministerial_role_1, person: person_1)
    create(:role_appointment, role: ministerial_role_2, person: person_2)

    policy = create(:published_policy, ministerial_roles: [ministerial_role_1, ministerial_role_2, unoccupied_role])

    urls = policy.urls_on_which_edition_appears(host: "test.host")

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

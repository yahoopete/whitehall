require 'test_helper'

class Edition::TopicalEventsTest < ActiveSupport::TestCase
  test "#destroy should also remove the classification memebership relationship" do
    topical_event = create(:topical_event)
    edition = create(:published_news_article, topical_events: [topical_event])
    relation = edition.classification_memberships.first
    edition.destroy
    refute ClassificationMembership.find_by_id(relation.id)
  end

  test "new edition of document that is a member of a topical event should remain a member of that topical event" do
    topical_event = create(:topical_event)
    edition = create(:published_news_article, topical_events: [topical_event])

    new_edition = edition.create_draft(create(:policy_writer))
    new_edition.change_note = 'change-note'
    new_edition.publish_as(create(:departmental_editor), force: true)

    assert_equal topical_event, new_edition.topical_events.first
  end

  test "#destroy should also remove the classification featuring relationship" do
    topical_event = create(:topical_event)
    edition = create(:published_news_article)
    rel = topical_event.feature(edition_id: edition.id, alt_text: 'Woooo', image: create(:classification_featuring_image_data))
    relation = edition.classification_featurings.first
    edition.destroy
    refute ClassificationFeaturing.find_by_id(relation.id)
  end

  test "new edition of document featured in topical event should remain featured in that topic event with image and alt text" do
    featured_image = create(:classification_featuring_image_data)
    topical_event = create(:topical_event)
    edition = create(:published_news_article)
    topical_event.feature(edition_id: edition.id, image: featured_image, alt_text: "alt-text", ordering: 12)

    new_edition = edition.create_draft(create(:policy_writer))
    new_edition.change_note = 'change-note'
    new_edition.publish_as(create(:departmental_editor), force: true)

    featuring = new_edition.classification_featurings.first
    assert_equal featured_image, featuring.image
    assert_equal "alt-text", featuring.alt_text
    assert_equal topical_event, featuring.classification
  end
end

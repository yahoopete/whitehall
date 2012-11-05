require "test_helper"

class StatisticalDataSetTest < EditionTestCase
  include Rails.application.routes.url_helpers

  should_allow_inline_attachments
  should_allow_a_summary_to_be_written

  test "should include the Edition::DocumentSeries behaviour" do
    assert StatisticalDataSet.ancestors.include?(Edition::DocumentSeries)
  end

  test "should indicate that it appears in the site atom feed" do
    statistical_data_set = build(:published_statistical_data_set)

    urls = statistical_data_set.urls_on_which_edition_appears(default_url_options)

    assert urls.include?(atom_feed_url)
  end

  test "should indicate that it appears on associated organisation pages" do
    organisation_1 = create(:organisation)
    organisation_2 = create(:organisation)
    statistical_data_set = create(:published_statistical_data_set, organisations: [organisation_1, organisation_2])

    urls = statistical_data_set.urls_on_which_edition_appears(default_url_options)

    assert urls.include?(organisation_url(organisation_1))
    assert urls.include?(organisation_url(organisation_2))
  end

  test "should indicate it appears on associated document series pages" do
    organisation = create(:organisation)
    series = create(:document_series, organisation: organisation)
    statistical_data_set = create(:published_statistical_data_set, document_series: series)

    urls = statistical_data_set.urls_on_which_edition_appears(default_url_options)

    assert urls.include?(organisation_document_series_url(organisation, series))
  end

  private

  def default_url_options
    { host: "test.host" }
  end
end

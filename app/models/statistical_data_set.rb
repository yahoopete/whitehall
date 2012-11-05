class StatisticalDataSet < Edition
  include Edition::DocumentSeries
  include ::Attachable
  include Edition::AlternativeFormatProvider

  attachable :edition

  def allows_attachment_references?
    true
  end

  def can_have_summary?
    true
  end

  def urls_on_which_edition_appears(options = {})
    urls = [atom_feed_url(options)]
    urls += organisations.map { |o| organisation_url(o, options) }

    if document_series.present?
      urls += [organisation_document_series_url(document_series.organisation, document_series, options)]
    end

    urls
  end
end

class Publication < Publicationesque
  include Edition::Images
  include Edition::NationalApplicability
  include Edition::FactCheckable
  include Edition::AlternativeFormatProvider
  include Edition::Countries
  include Edition::DocumentSeries
  include Edition::StatisticalDataSets
  include Edition::LimitedAccess

  validates :publication_date, presence: true
  validates :publication_type_id, presence: true

  after_update { |p| p.published_related_policies.each(&:update_published_related_publication_count) }
  before_save ->(record) { record.access_limited = nil unless record.publication_type.can_limit_access? }

  def allows_inline_attachments?
    false
  end

  def allows_attachment_references?
    true
  end

  def publication_type
    PublicationType.find_by_id(publication_type_id)
  end

  def publication_type=(publication_type)
    self.publication_type_id = publication_type && publication_type.id
  end

  def can_have_summary?
    true
  end

  def national_statistic?
    publication_type == PublicationType::NationalStatistics
  end

  def first_published_date
    publication_date.to_date
  end

  def statistics?
    [PublicationType::Statistics, PublicationType::NationalStatistics].include?(publication_type)
  end

  def can_limit_access?
    true
  end

  def access_limited?
    statistics? && super
  end

  def urls_on_which_edition_appears(options = {})
    urls = [atom_feed_url(options)]
    urls += [publications_url(options), publications_url(options.merge(format: "atom"))]
    urls += organisations.map { |o| organisation_url(o, options) }
    urls += published_related_policies.map { |p| activity_policy_url(p.document, options) }
    urls += published_related_policies.map { |p| activity_policy_url(p.document, options.merge(format: "atom")) }
    urls += topics.map { |t| topic_url(t, options) }
    urls += topics.map { |t| topic_url(t, options.merge(format: "atom")) }
    urls += ministerial_roles.map { |r| ministerial_role_url(r, options) }
    urls += ministerial_roles.select(&:occupied?).map { |r| person_url(r.current_person, options) }
    urls
  end

  private

  def set_timestamp_for_sorting
    self.timestamp_for_sorting = publication_date
  end
end

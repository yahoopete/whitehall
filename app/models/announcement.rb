class Announcement < Edition
  include Edition::Images
  include Edition::RelatedPolicies
  include Edition::Countries

  def can_have_summary?
    true
  end

  def self.sti_names
    ([self] + descendants).map { |model| model.sti_name }
  end

  def urls_on_which_edition_appears(options = {})
    urls = [atom_feed_url(options)]
    urls += [announcements_url(options), announcements_url(options.merge(format: "atom"))]
    urls += organisations.map { |o| organisation_url(o, options) }
    urls += published_related_policies.map { |p| activity_policy_url(p.document, options) }
    urls += published_related_policies.map { |p| activity_policy_url(p.document, options.merge(format: "atom")) }
    urls += topics.map { |t| topic_url(t, options) }
    urls += topics.map { |t| topic_url(t, options.merge(format: "atom")) }
    urls
  end
end

require_relative 'news_article'
require_relative 'speech'

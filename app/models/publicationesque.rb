class Publicationesque < Edition
  include Edition::RelatedPolicies
  include Edition::Ministers
  include ::Attachable

  attachable :edition

  has_one :response, foreign_key: :edition_id, dependent: :destroy

  def self.sti_names
    ([self] + descendants).map { |model| model.sti_name }
  end

  def part_of_series?
    false
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
end

require_relative 'publication'
require_relative 'consultation'

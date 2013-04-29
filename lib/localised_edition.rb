class LocalisedEdition < LocalisedModel

  def self.find(id)
    new(::Edition.find(id))
  end

  def initialize(edition)
    super(edition, edition.primary_locale)
  end
end

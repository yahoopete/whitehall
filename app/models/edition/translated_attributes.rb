module Edition::TranslatedAttributes
  extend ActiveSupport::Concern

  class Trait < Edition::Traits::Trait
    def process_associations_before_save(edition)
      @edition.translated_attributes.each do |ta|
        edition.translated_attributes << TranslatedAttribute.new(attribute_name: ta.attribute_name, locale: ta.locale, translation: ta.translation)
      end
    end
  end

  included do
    has_many :translated_attributes, as: :owner
    accepts_nested_attributes_for :translated_attributes

    add_trait Trait

    cattr_accessor :translateable_attributes
    self.translateable_attributes = []

    def self.translate_attributes(*attributes)
      self.translateable_attributes += attributes

      attributes.each do |attribute|
        eval <<-EOM
          def #{attribute}(*args)
            if current_locale && current_locale != "en-GB"
              translated_attribute_cache[current_locale][:#{attribute}] if translated_attribute_cache[current_locale]
            else
              super(*args)
            end
          end
        EOM
      end
    end
  end

  def for_locale(new_locale)
    @current_locale = new_locale
    self
  end

  private

  def current_locale
    @current_locale
  end

  def translated_attribute_cache
    @translated_attribute_cache ||= translated_attributes.inject({}) do |h, a|
      h[a.locale] ||= {}
      h[a.locale][a.attribute_name.to_sym] = a.translation
      h
    end
  end
end

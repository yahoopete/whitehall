FactoryGirl.define do
  factory :specialist_guide, class: SpecialistGuide, parent: :edition do
    title "specialist-guide-title"
    body  "specialist-guide-body"
    after_build do |specialist_guide|
      unless specialist_guide.topics.any?
        specialist_guide.topics.build(FactoryGirl.attributes_for(:topic))
      end
    end
  end

  factory :draft_specialist_guide, parent: :specialist_guide, traits: [:draft]
  factory :submitted_specialist_guide, parent: :specialist_guide, traits: [:submitted]
  factory :rejected_specialist_guide, parent: :specialist_guide, traits: [:rejected]
  factory :published_specialist_guide, parent: :specialist_guide, traits: [:published]
  factory :deleted_specialist_guide, parent: :specialist_guide, traits: [:deleted]
  factory :archived_specialist_guide, parent: :specialist_guide, traits: [:archived]
end

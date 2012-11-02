FactoryGirl.define do
  factory :publicationesque, class: Publicationesque, parent: :edition do
  end
  factory :published_publicationesque, parent: :publicationesque, traits: [:published]
end

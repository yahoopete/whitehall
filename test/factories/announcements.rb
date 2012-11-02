FactoryGirl.define do
  factory :announcement, class: Announcement, parent: :edition do
  end
  factory :published_announcement, parent: :announcement, traits: [:published]
end

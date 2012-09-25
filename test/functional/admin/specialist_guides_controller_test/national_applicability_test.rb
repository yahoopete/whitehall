require 'test_helper'

class Admin::SpecialistGuidesControllerTest < ActionController::TestCase
  class NationalApplicabilityTest < ActionController::TestCase
    tests Admin::SpecialistGuidesController

    setup do
      login_as :policy_writer
    end

    include TestsForNationalApplicability

    private

    def edition_class
      SpecialistGuide
    end

    def attributes_for_edition(attributes = {})
      super.merge(topic_ids: [create(:topic).id])
    end
  end
end

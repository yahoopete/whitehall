require "test_helper"

class DclgConsultationImportTest < ActiveSupport::TestCase
  test "imports CSV in DCLG format into database" do
    User.create!(name: "Automatic Data Importer")
    create(:organisation, name: "department-for-communities-and-local-government")

    data = File.read("test/fixtures/dclg_consultation_import_test.csv")
    NewConsultationUploader.new(csv_data: data).upload

    assert_equal 1, Consultation.count
  end

  test "handles a response" do
    pending
  end
end

require 'test_helper'

class EditionOrganisationImageUploaderTest < ActiveSupport::TestCase
  test "should only allow JPG JPEG GIF or PNG images" do
    uploader = EditionOrganisationImageUploader.new
    assert_equal %w(jpg jpeg gif png), uploader.extension_white_list
  end

  test "should store uploads in a directory that persists across deploys" do
    model = stub("AR Model", id: 1)
    uploader = EditionOrganisationImageUploader.new(model, "mounted-as")
    assert_match /^system/, uploader.store_dir
  end
end
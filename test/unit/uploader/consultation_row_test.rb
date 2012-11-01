# encoding: UTF-8
# *NOTE* this file deliberately does not include test_helper
# in order to attempt to speed up the tests

require 'active_support/test_case'
require 'minitest/autorun'

require 'whitehall/uploader/consultation_row'
require 'whitehall/uploader/parsers/relative_to_absolute_links'
require 'whitehall/uploader/finders/organisation_finder'

require 'logger'

module Whitehall::Uploader
  class ConsultationRowTest < ActiveSupport::TestCase
    setup do
      @attachment_cache = stub('attachment cache')
    end

    def consultation_row(data)
      ConsultationRow.new(data, 1, @attachment_cache)
    end


    test "takes title from the title column" do
      row = consultation_row("title" => "a-title")
      assert_equal "a-title", row.title
    end

    test "takes legacy url from the old_url column" do
      row = consultation_row("old_url" => "http://example.com/old-url")
      assert_equal "http://example.com/old-url", row.legacy_url
    end

    test "takes body from the 'body' column" do
      Parsers::RelativeToAbsoluteLinks.stubs(:parse).with("relative links", "url").returns("absolute links")
      row = consultation_row("body" => "relative links")
      row.stubs(:organisation).returns(stub("organisation", url: "url"))
      assert_equal "absolute links", row.body
    end

    test "finds an organisation using the organisation finder" do
      organisation = stub("Organisation")
      Finders::OrganisationFinder.stubs(:find).with("name or slug", anything, anything).returns([organisation])
      row = consultation_row("organisation" => "name or slug")
      assert_equal organisation, row.organisation
    end

    test "supplies an attribute list for the new consultation record" do
      row = consultation_row({})
      attribute_keys = [:title, :body]
      attribute_keys.each do |key|
        row.stubs(key).returns(key.to_s)
      end
      assert_equal row.attributes, attribute_keys.each.with_object({}) {|key, hash| hash[key] = key.to_s }
    end

    test "finds organisation by slug in the 'organisation' column" do
      pending
    end
  end
end

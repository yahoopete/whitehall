require 'test_helper'
require 'shoulda'

class Api::GenericEditionPresenterTest < PresenterTestCase
  setup do
    Whitehall.stubs(:public_host_for).returns('govuk.example.com')
    @organisation = stub_record(:organisation, organisation_type: stub_record(:ministerial_organisation_type), slug: "an-org")
    stubs_helper_method(:params).returns(format: :json)
  end

  context "most edition types" do
    setup do
      # Using DetailedGuide for no particular reason, it has to be something
      @guide = stub_edition(:detailed_guide, organisations: [@organisation])
      @guide.stubs(:images).returns([])
      @guide.stubs(:published_related_detailed_guides).returns([])
      @presenter = Api::GenericEditionPresenter.decorate(@guide)
    end

    should "include document title" do
      @guide.stubs(:title).returns('guide-title')
      assert_equal 'guide-title', @presenter.as_json[:title]
    end

    should "include the public API url as id" do
      assert_equal "http://govuk.example.com/api/other_editions/#{@guide.slug}", @presenter.as_json[:id]
    end

    should "include public guide url as web_url" do
      assert_equal detailed_guide_url(@guide.document, host: 'govuk.example.com'), @presenter.as_json[:web_url]
    end

    should "include the document body (without govspeak wrapper div) as html" do
      @guide.stubs(:body).returns("govspeak-body")
      assert_equal '<p>govspeak-body</p>', @presenter.as_json[:details][:body]
    end

    should "include first_published_at" do
      @guide.stubs(:first_published_at).returns(1.day.ago)
      assert_equal 1.day.ago, @presenter.as_json[:details][:first_published_at]
    end

    should "include summary" do
      @guide.stubs(:summary).returns("This is the summary")
      assert_equal "This is the summary", @presenter.as_json[:details][:summary]
    end

    should "include tags for organisations" do
      tag = {
        # id: "", # The API URL will go here, when we have one
        web_url: "http://govuk.example.com/government/organisations/an-org",
        title: "organisation-11", 
        details: { type: "organisation" }
      }
      assert_equal [tag], @presenter.as_json[:tags]
    end

    should "include tags for topics"
  end

  context "DetailedGuide" do
    setup do
      @guide = stub_edition(:detailed_guide, organisations: [@organisation])
      @guide.stubs(:images).returns([])
      @guide.stubs(:published_related_detailed_guides).returns([])
      @presenter = Api::GenericEditionPresenter.decorate(@guide)
    end

    should "json includes related detailed guides as related" do
      related_guide = stub_edition(:detailed_guide, organisations: [@organisation])
      @guide.stubs(:published_related_detailed_guides).returns([related_guide])
      related_guide_json = {
        id: "http://govuk.example.com/api/other_editions/#{related_guide.slug}",
        title: related_guide.title,
        web_url: detailed_guide_url(related_guide.document, host: 'govuk.example.com')
      }
      assert_equal [related_guide_json], @presenter.as_json[:related]
    end

    should "json includes format name" do
      assert_equal "detailed guidance", @presenter.as_json[:format]
    end
  end

  context "Speech" do
    setup do
      home_office = build(:organisation, name: "Home Office", organisation_type: build(:ministerial_organisation_type), slug: "an-org")
      home_secretary = build(:ministerial_role, name: "Secretary of State", organisations: [home_office])
      theresa_may = build(:person, forename: "Theresa", surname: "May", image: fixture_file_upload('minister-of-funk.960x640.jpg'))
      theresa_may_appointment = build(:role_appointment, role: home_secretary, person: theresa_may)
      speech_type = SpeechType::Transcript
      speech = stub_edition(:speech, speech_type: speech_type, role_appointment: theresa_may_appointment, delivered_on: Date.parse("2011-06-01"), location: "The Guidhall", organisations: [home_office], images: [build(:image)])
      @presenter = Api::GenericEditionPresenter.decorate(speech)
    end

    should "include location" do
      assert_equal "The Guidhall", @presenter.as_json[:details][:location]
    end

    should "include delivered_on date" do
      assert_equal "2011-06-01", @presenter.as_json[:details][:delivered_on]
    end
  end

  context "Consultation" do
    setup do
      consultation = stub_edition(:consultation, organisations: [@organisation], document: build(:document), images: [build(:image)])
      @presenter = Api::GenericEditionPresenter.decorate(consultation)
    end

    should "include openening_on and closing_on" do
      assert_equal "2011-11-10T11:11:11+00:00", @presenter.as_json[:details][:opening_on]
      assert_equal "2011-12-23T11:11:11+00:00", @presenter.as_json[:details][:closing_on]
    end
  end

  context "Publication" do
    setup do
      publication = stub_edition(:publication, organisations: [@organisation], document: build(:document), images: [build(:image)])
      @presenter = Api::GenericEditionPresenter.decorate(publication)
    end

    should "include publication_date" do
      assert_equal "2011-11-01", @presenter.as_json[:details][:publication_date]
    end
  end
end
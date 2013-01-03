class Api::GenericEditionPresenter < Draper::Base
  class Paginator < Struct.new(:collection, :params)
    class << self
      def paginate(collection, params)
        new(collection, params).page
      end
    end

    def current_page
      current_page = page_param > 0 ? page_param : 1
    end

    def page
      collection.page(current_page).per(20)
    end

    def page_param
      params[:page].to_i
    end
  end

  class PagePresenter < Draper::Base
    def initialize(page)
      super(page)
    end

    def as_json(options = {})
      {
        results: model.map(&:as_json),
        previous_page_url: previous_page_url,
        next_page_url: next_page_url
      }.reject {|k, v| v.nil? }
    end

    def previous_page_url
      unless model.first_page?
        url(page: model.current_page - 1)
      end
    end

    def next_page_url
      unless model.last_page?
        url(page: model.current_page + 1)
      end
    end

    private

    def url(override_params)
      h.url_for(h.params.merge(
        override_params.merge(only_path: false, host: h.public_host)
      ))
    end
  end

  class << self
    def paginate(collection)
      page = Paginator.paginate(collection, h.params)
      PagePresenter.new decorate(page)
    end
  end

  def as_json(options = {})
    data = {
      title: model.title,
      id: other_edition_url(model),
      web_url: h.public_document_url(model),
      details: {
        body: h.bare_govspeak_edition_to_html(model),
        updated_at: (model.updated_at.present? ? model.updated_at.iso8601 : nil),
        published_at: (model.published_at.present? ? model.published_at.iso8601 : nil)
      },
      format: model.format_name,
      related: related_json
      # tags: organisations + topics
    }

    keys = [:location, :summary, :delivered_on, :opening_on, :closing_on, :publication_date,
      :first_published_at]
    keys.each do |key|
      if model.send(key).present?
        if [Date, Time, ActiveSupport::TimeWithZone].detect { |time_type| model.send(key).is_a?(time_type) } 
          data[:details][key] = model.send(key).iso8601
        else
          data[:details][key] = model.send(key)
        end
      end
    end
    data
  end

  private

  def other_edition_url(model)
    h.api_other_edition_url(model.document, host: h.public_host)
  end

  def organisations
    model.organisations.map do |org|
      {
        # id: org.id, TODO reinstate when we have API URLs for tags
        web_url: h.organisation_url(org),
        title: org.name,
        details: {
          type: 'organisation'
        }
      }
    end
  end

  def topics
    model.topics.map do |topic|
      {
        # id: topic.id, TODO reinstate when we have API URLs for tags
        web_url: h.topic_url(topic),
        title: topic.name,
        details: {
          type: 'topic'
        }
      }
    end
  end

  def related_json
    if model.is_a?(DetailedGuide)
      model.published_related_detailed_guides.map do |guide|
        {
          id: other_edition_url(guide),
          title: guide.title,
          web_url: h.public_document_url(guide)
        }
      end
    else
      # Not sure if anything but DetailedGuides has related items?
      []
    end
  end
end

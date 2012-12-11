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
        updated_at: model.updated_at.iso8601,
        published_at: model.published_at.iso8601
      },
      format: model.format_name,
      tags: organisations + topics
    }
    keys = [:location, :delivered_on, :opening_on, :closing_on, :publication_date,
      :first_published_at, :summary]
    keys.each do |key|
      data[:details][key] = model.send(key) if model.send(key).present?
    end
    data
  end

  private

  def other_edition_url(guide)
    h.api_other_edition_url guide.document, host: h.public_host
  end

  def organisations
    model.organisations.map do |org|
      {
        id: org.id,
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
        id: topic.id,
        web_url: h.topic_url(topic),
        title: topic.name,
        details: {
          type: 'topic'
        }
      }
    end
  end
end

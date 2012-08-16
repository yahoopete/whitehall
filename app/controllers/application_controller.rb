require "slimmer/headers"

class ApplicationController < ActionController::Base
  include GDS::SSO::ControllerMethods
  include Slimmer::Headers
  include Slimmer::Template

  protect_from_forgery

  before_filter :set_proposition

  layout 'frontend'

  slimmer_template 'header_footer_only'

  private

  def load_published_documents_in_scope(&block)
    @policies = yield(Policy.published)
    @publications = yield(Publication.published)
    @news_articles = yield(NewsArticle.published)
    @consultations = yield(Consultation.published)
  end

  def skip_slimmer
    response.headers[Slimmer::SKIP_HEADER] = "true"
  end

  def set_proposition
    set_slimmer_headers(proposition: "government")
  end
end

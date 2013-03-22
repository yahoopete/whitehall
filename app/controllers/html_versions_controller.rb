class HtmlVersionsController < PublicFacingController
  layout 'detailed-guidance'

  before_filter :find_publication

  include CacheControlHelper
  include PublicDocumentRoutesHelper

  def show
    @document = @publication
    @html_version = @publication.html_version
    render text: "Not found", status: :not_found unless @html_version
  end

  private

  def find_publication
    unless @publication = Publication.published_as(params[:publication_id])
      render text: "Not found", status: :not_found
    end
  end

  def analytics_format
    :publication
  end
end

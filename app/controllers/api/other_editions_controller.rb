class Api::OtherEditionsController < PublicFacingController
  respond_to :json

  self.responder = Api::Responder

  def show
    @document = document_published_as(params[:id])

    if @document
      respond_with Api::GenericEditionPresenter.new(@document)
    else
      # TODO this should return JSON. govuk_content_api does this so that PJAX can access the response_info
      render text: "Not found", status: :not_found
    end
  end

  def index
    respond_with Api::GenericEditionPresenter.paginate(
      Edition.published.alphabetical
    )
  end

  def tags
    @results = MainstreamCategory.with_published_content.where(parent_tag: params[:parent_id])
    if @results.any?
      respond_with Api::MainstreamCategoryTagPresenter.new(@results)
    else
      respond_with_not_found
    end
  end

  private

  def document_published_as(slug)
    document = Document.where(slug: slug).first
    document && document.published_edition
  end


  def respond_with_not_found
    respond_with Hash.new, status: :not_found
  end
end

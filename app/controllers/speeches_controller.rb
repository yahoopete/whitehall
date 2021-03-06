class SpeechesController < DocumentsController
  def show
    @related_policies = @document.published_related_policies
    @topics = @related_policies.map { |d| d.topics }.flatten.uniq
    set_slimmer_organisations_header(@document.organisations)
  end

  private

  def document_class
    Speech
  end
end

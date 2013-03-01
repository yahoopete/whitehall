module Admin::EditionsController::Attachments
  extend ActiveSupport::Concern

  included do
    before_filter :build_edition_attachment, only: [:new, :edit]
    before_filter :cope_with_attachment_action_params, only: [:update]
    before_filter :build_bulk_uploader, only: [:new, :edit]
    before_filter :extract_attachments_from_zip_file, only: [:update]
    before_filter :set_attachment_whitelist_param, only: [:create]
  end

  def build_edition
    extract_attachments_from_zip_file
    super
  end

  def build_edition_dependencies
    super
    build_edition_attachment
  end

  def build_edition_attachment
    @edition.build_empty_attachment
  end

  def cope_with_attachment_action_params
    return unless params[:edition] && params[:edition][:edition_attachments_attributes]
    params[:edition][:edition_attachments_attributes].each do |_, edition_attachment_params|
      Admin::AttachmentActionParamHandler.manipulate_params!(edition_attachment_params)
    end
  end

  def build_bulk_uploader
    @bulk_upload_zip_file = BulkUpload::ZipFile.new(nil)
  end

  def extract_attachments_from_zip_file
    return unless params[:attachment_mode] == 'bulk'
    @bulk_upload_zip_file = BulkUpload::ZipFile.new((params[:bulk_upload_zip_file] || {} )[:zip_file])
    if @bulk_upload_zip_file.valid?
      zip_file_to_attachments = BulkUpload::ZipFileToAttachments.new(@bulk_upload_zip_file, @edition, params[:edition])
      zip_file_to_attachments.manipulate_params!
    else
      params[:edition]['bulk_upload_zip_file_invalid'] = true
    end
  end

  def set_attachment_whitelist_param
    return unless params[:edition] && params[:edition][:edition_attachments_attributes]
    params[:edition][:edition_attachments_attributes].each do |_, edition_attachment_join_params|
      if edition_attachment_join_params && edition_attachment_join_params[:attachment_attributes]
        if current_user.can_upload_executable_attachments?
          if edition_attachment_join_params[:attachment_attributes]
            edition_attachment_join_params[:attachment_attributes]['skip_whitelist_verification'] = true
          end
        else
          if edition_attachment_join_params[:attachment_attributes]
            edition_attachment_join_params[:attachment_attributes]['skip_whitelist_verification'] = false
          end
        end
      end
    end
  end
end

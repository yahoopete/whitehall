class MoveDraftAttachmentsToCorrectFolder < ActiveRecord::Migration
  def convert_to_folder(id, path)
    Rails.root.join("#{path}/goverment/uploads/attachment_data/file/#{id}")
  end

  def move_files(id, from, to)
    old_dir = convert_to_folder(id, from)
    new_dir = convert_to_folder(id, to)
    cmd = "[ -e #{old_dir} ] && mkdir -p #{new_dir} && cp -f #{old_dir}/* #{new_dir}/"
    system cmd
  end

  def up
    return unless Rails.env.production?

    Document.find_each do |document|
      next unless (document.unpublished_edition.present? && document.unpublished_edition.respond_to?(:attachments))
      document.unpublished_edition.attachments.each do |attachment|
        move_files(attachment.attachment_data.id, 'incoming-uploads', 'draft-incoming-uploads')
        move_files(attachment.attachment_data.id, 'public/system/uploads', 'draft-clean-uploads')
      end
    end
  end

  def down
  end
end

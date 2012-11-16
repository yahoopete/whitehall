require 'csv'

class EditionAttachmentOld < ActiveRecord::Base
  self.table_name = "edition_attachments_old"
end

class SupportingPageAttachmentOld < ActiveRecord::Base
  self.table_name = "supporting_page_attachments_old"
end

class ConsultationResponseAttachmentOld < ActiveRecord::Base
  self.table_name = "consultation_response_attachments_old"
end

class CorporateInformationPageAttachmentOld < ActiveRecord::Base
  self.table_name = "corporate_information_page_attachments_old"
end

class AttachmentOld < ActiveRecord::Base
  self.table_name = "attachments_old"

  def path
    Rails.root.join("public/government/uploads/system/uploads/attachment/file/#{id}/#{carrierwave_file}")
  end
end

class RecreateNewEditionsForNewAttachmentAssociations
  def execute(options)
    options[:old_join_class].all.each do |old_join_row|
      begin
        joined_object_id = old_join_row.send(options[:join_field])
        edition = options[:find_edition_proc].call(joined_object_id)
        next if edition.nil? || edition.is_latest_edition?

        latest_edition = edition.latest_edition
        # If we aren't the latest edition, the last join_table row must be ours,
        # as it wouldn't have been possible to create one since... except if a new
        # edition has been created since the join recreation happened on 15th Nov
        # 23:00. If there's the case, this will be a duplicate, which we can dedup.
        recreated_join = options[:new_join_class].where(options[:join_field] => joined_object_id).last
        new_join_row = options[:new_join_class].new(
          options[:join_field] => options[:find_attachable_from_edition].call(latest_edition, recreated_join),
          attachment_id: recreated_join.attachment_id
        )
        $stdout.puts "Created join row #{options[:new_join_class]}:#{new_join_row.id} for edition #{latest_edition.type}:#{latest_edition.id}"
      rescue Exception => e
        $stderr.puts "ERROR ADDED NEW ATTACHMENT ASSOCIATIONS FOR #{options[:old_join_class]}:#{old_join_row.id}: #{e.inspect}"
      end
    end
  end
end

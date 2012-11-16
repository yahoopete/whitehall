task recreate_attachment_join_data: :environment do
  require Rails.root.join('lib/recreate_attachment_join_data')
  RecreateAttachmentJoinData.new.execute(SupportingPageAttachmentOld, SupportingPageAttachment, :supporting_page_id)
  RecreateAttachmentJoinData.new.execute(CorporateInformationPageAttachmentOld, CorporateInformationPageAttachment, :corporate_information_page_id)
  RecreateAttachmentJoinData.new.execute(ConsultationResponseAttachmentOld, ConsultationResponseAttachment, :response_id)
  RecreateAttachmentJoinData.new.execute(EditionAttachmentOld, EditionAttachment, :edition_id)
end

task recreate_new_editions_for_new_attachment_associations: :environment do
  require Rails.root.join('lib/recreate_new_editions_for_new_attachment_associations')
  RecreateNewEditionsForNewAttachmentAssociations.new.execute(
    old_join_class: SupportingPageAttachmentOld,
    new_join_class: SupportingPageAttachment,
    join_field: :supporting_page_id,
    find_edition_proc: ->(page_id) { SupportingPage.find(page_id).edition },
    find_attachable_from_edition: ->(latest_edition, recreated_join) { SupportingPage.find(recreated_join.supporting_page_id) }
  )

  RecreateNewEditionsForNewAttachmentAssociations.new.execute(
    old_join_class: ConsultationResponseAttachmentOld,
    new_join_class: ConsultationResponseAttachment,
    join_field: :response_id,
    find_edition_proc: ->(response_id) { Response.find(response_id).consultation },
    find_attachable_from_edition: ->(latest_edition, recreated_join) { Response.find_by_consultation_id(latest_edition.id) }
  )

  RecreateNewEditionsForNewAttachmentAssociations.new.execute(
    old_join_class: EditionAttachmentOld,
    new_join_class: EditionAttachment,
    join_field: :edition_id,
    find_edition_proc: ->(edition_id) { Edition.find_by_id(edition_id) },
    find_attachable_from_edition: ->(latest_edition, recreated_join) { latest_edition }
  )
end

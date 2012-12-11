# Clean up orphaned editions - should allow editors to fix documents
# with "--2" etc. slugs
Document.where("NOT EXISTS (SELECT * FROM editions WHERE `editions`.`document_id` = `documents`.id AND `state` <> 'deleted')").each do |dead|
  # Note that we need to prepend any slug changes due to the way
  # friendly_id finds matching slugs
  dead.update_column('slug', "deleted-#{dead.id}-#{dead.slug}") unless dead.slug.match("^deleted-")
end

# Clean up attachments with "blah blah PDF [192 kb]" in the title
Attachment.where("title LIKE '%kb]'").each do |attachment|
  attachment.update_column('title', attachment.title.gsub(/(.*)((PDF|CSV)\s*\[.*\s*kb\])/i, "\\1").strip)
end

# clean up attachments with "blah blah (PDF 72kb)" in the title
Attachment.where("title LIKE '%kb)'").each do |attachment|
  attachment.update_column('title', attachment.title.gsub(/(.*)\((Word|PDF|DOC|CSV)?[^\)]+kb\)/i, "\\1").strip)
end

user = User.where(name: "Automatic data importer").first
PaperTrail.whodunnit = user
FatalityNotice.where("body LIKE '%\\n> %'").each do |notice|
  body = notice.body
  new_body = body.lines.map(&:strip).collect { |line|
    line.gsub /^>\s*$/, ''
  }.join("\n")
  if notice.latest_edition.published?
    notice.create_draft(user)
  end
  notice.body = new_body
  notice.save
end.size

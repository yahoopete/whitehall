module Whitehall
  module Uploader
    class ConsultationRow
      attr_reader :row

      def initialize(row, line_number, attachment_cache, logger = Logger.new($stdout))
        @row = row
        @line_number = line_number
        @logger = logger
        @attachment_cache = attachment_cache
      end

      def title
        row['title']
      end

      def legacy_url
        row['old_url']
      end

      def body
        Parsers::RelativeToAbsoluteLinks.parse(row['body'], organisation.url)
      end

      def organisation
        Finders::OrganisationFinder.find(row['organisation'], @logger, @line_number).first
      end

      def attributes
        {
          title: title,
          body: body
        }
      end
    end
  end
end

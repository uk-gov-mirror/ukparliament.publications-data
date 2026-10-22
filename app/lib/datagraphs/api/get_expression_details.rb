module Datagraphs
  module Api
    class GetExpressionDetails < Base
      def for(publication_expression_id: 22225)
        @publication_expression_id = trim_publication_expression_id(publication_expression_id)

        # Call is a method in base
        response = call

        json_response = JSON.parse(response.body)
        json_response.deep_transform_keys!(&:underscore)

        Hashie::Mash.new(json_response)
      end

      def url
        "#{base_url}#{project_id}/PublicationExpression/#{@publication_expression_id}"
      end

      def trim_publication_expression_id(publication_expression_id)
        # Regular expresion gets just the numbers
        # d+ is for the digits
        # \z is for the very end of the string
        publication_expression_id.to_s[/\d+\z/].to_i
      end
    end
  end
end

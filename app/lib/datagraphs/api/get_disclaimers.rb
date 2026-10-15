module Datagraphs
  module Api
    class GetDisclaimers < CypherQuery
      QUERY = <<-Q.squish
        MATCH (d:Disclaimer)
        RETURN d.id AS id,
               d.label AS label
      Q

      def all
        params = { query: QUERY }
        response = call(params: params)
        body = process_response(response.body)

        body.map { |record| Hashie::Mash.new(record) }
      end
    end
  end
end

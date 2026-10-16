module Datagraphs
  module Api
    class GetPerson < CypherQuery
      DETAILS = <<-Q.squish
        MATCH (p:Person)
        WHERE p.id = '%{person_id}'
        RETURN p.displayName AS name,
               p.id AS id,
               p.sortName as sort_name,
               p.orcid AS orcid

      Q

      def details(person_id: 368500)
        params = { query: DETAILS % { person_id: person_id } }

        response = call(params: params)
        body = process_response(response.body)

        Hashie::Mash.new(body.first)
      end
    end
  end
end

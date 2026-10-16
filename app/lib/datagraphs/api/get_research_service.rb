module Datagraphs
  module Api
    class GetResearchService < CypherQuery
      DETAILS = <<-Q.squish
        MATCH (rs:ResearchService)-[r1:for]->(h:House)
        WHERE  rs.id='%{research_service_id}'
        RETURN rs.id AS id,
               rs.name AS name,
               rs.shortName AS short_name,
               COLLECT_LIST(DISTINCT h.id) AS house_ids,
               COLLECT_LIST(DISTINCT h.name) AS house_names
        LIMIT 1
      Q

      def details(research_service_id = 'urn:publications-data:ResearchService:1')
        params = { query: DETAILS % { research_service_id: research_service_id }}

        response = call(params: params)
        research_service = process_response(response.body).first
        research_service["houses"] = research_service["house_ids"].zip(research_service["house_names"])

        Hashie::Mash.new(research_service)
      end
    end
  end
end

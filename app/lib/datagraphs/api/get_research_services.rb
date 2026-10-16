module Datagraphs
  module Api
    class GetResearchServices < CypherQuery
      ALL = <<-Q.squish
        MATCH (rs:ResearchService)-[r1:for]->(h:House)
        MATCH (pe:PublicationExpression)-[r2:expressionOf]->(pw:PublicationWork)-[r3:publishedBy]->(rs)
        MATCH (pe)-[r4:hasPublicationExpressionStatus]->(pes:PublicationExpressionStatus)
        WHERE pes.label = "Published"
        RETURN rs.id AS id,
              rs.name AS name,
              rs.shortName AS short_name,
              COUNT(DISTINCT pw) AS publication_count,
              COLLECT_LIST(DISTINCT h.id) AS house_ids,
              COLLECT_LIST(DISTINCT h.name) AS house_names
        ORDER BY name ASC
      Q

      def all
        params = { query: ALL }
        response = call(params: params)
        research_services = process_response(response.body)

        research_services.map do |research_service|
          research_service["houses"] = research_service["house_ids"].zip(research_service["house_names"])
          Hashie::Mash.new(research_service)
        end
      end
    end
  end
end

module Datagraphs
  module Api
    class GetUnpublishedPublications < CypherQuery
      QUERY = <<-Q
        MATCH (pw:PublicationWork)-[r3:publishedBy]->(rs:ResearchService)
        MATCH (pw)<-[eO:expressionOf]-(pe:PublicationExpression)-[r:hasPublicationExpressionStatus]->(pes:PublicationExpressionStatus)
        WHERE pes.label <> "Published"
        RETURN pw.id as publication_work_id, pw.title as title,
               pes.label as status, pe.publishedAt as published_at,
               pe.teaserText as teaser_text, pe.createdAt as created_at,
               rs.shortName AS short_research_service_name,
               rs.id AS research_service_id
        ORDER BY pe.publishedAt desc
        SKIP %{skip}
        LIMIT %{limit}
      Q

      COUNT = <<-Q
        MATCH (pw:PublicationWork)<-[eO:expressionOf]-(pe:PublicationExpression)-[r:hasPublicationExpressionStatus]->(pes:PublicationExpressionStatus)
        WHERE pes.label <> "Published"
        RETURN COUNT(DISTINCT pw) AS total
      Q

      def get_total
        params = { query: COUNT }
        response = call(params: params)
        output = JSON.parse(response.body)
        output["results"].first["total"]
      end

      def process(skip: 0, limit: 25)
        params = { query: QUERY % { skip: skip, limit: limit }}
        response = call(params: params)
        process_response(response.body)
      end
    end
  end
end

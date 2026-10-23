module Datagraphs
  module Api
    class GetUnpublishedPublications < CypherQuery
      QUERY = <<-Q
        OPTIONAL MATCH (pw:PublicationWork)<-[e:expressionOf]-(pe:PublicationExpression)-[r:hasPublicationExpressionStatus]->(pes:PublicationExpressionStatus)
        MATCH (pw:PublicationWork)-[s:publishedBy]->(d:ResearchService)-[f:for]->(h:House)
        WHERE pes.label = 'Published'
        RETURN pw, count(pe) AS expression_count
        NEXT YIELD pw, expression_count
        FILTER expression_count = 0
        MATCH (pw:PublicationWork)<-[e:expressionOf]-(pe:PublicationExpression)-[r:hasPublicationExpressionStatus]->(pes:PublicationExpressionStatus)
        MATCH (pw:PublicationWork)-[r6:publishedBy]->(rs:ResearchService)
        OPTIONAL MATCH (person:Person)<-[r4:contributionBy]-(cont:Contribution)-[r5:contributionTo]->(pe)
        RETURN pe.id as publication_expression_id,
               pw.id as publication_work_id,
               pe.title as title,
               pes.label as status,
               pw.createdOn as created_at,
               pe.number as version_number,
               pe.updatedAt AS updated_at,
               rs.shortName AS short_research_service_name,
               rs.id AS research_service_id,
               COLLECT_LIST(DISTINCT person.id) AS contributor_ids,
               COLLECT_LIST(DISTINCT person.displayName) AS contributor_names
        ORDER BY updated_at DESC
        SKIP %{skip}
        LIMIT %{limit}
      Q

      COUNT = <<-Q
        OPTIONAL MATCH (pw:PublicationWork)<-[e:expressionOf]-(pe:PublicationExpression)-[r:hasPublicationExpressionStatus]->(pes:PublicationExpressionStatus)
        MATCH (pw:PublicationWork)-[s:publishedBy]->(d:ResearchService)-[f:for]->(h:House)
        WHERE pes.label = 'Published'
        RETURN pw, count(pe) AS expression_count
        NEXT YIELD pw, expression_count
        FILTER expression_count = 0
        RETURN COUNT(DISTINCT pw) AS total
      Q

      def get_total
        params = { query: COUNT }
        response = call(params: params)
        output = JSON.parse(response.body)
        output["results"].first["total"]
      end

      def all(skip: 0, limit: 25)
        params = { query: QUERY % { skip: skip, limit: limit }}
        response = call(params: params)
        publications = process_response(response.body)

        publications.each do |pub|
          pub["owners"] = pub["contributor_ids"].zip(pub["contributor_names"])
        end

        publications.each do |pub|
          pub["contributors"] = pub["contributor_ids"].zip(pub["contributor_names"])
        end

        publications.map { |publication| Hashie::Mash.new(publication) }
      end
    end
  end
end

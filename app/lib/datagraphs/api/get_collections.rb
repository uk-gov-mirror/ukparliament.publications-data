module Datagraphs
  module Api
    class GetCollections < CypherQuery
      QUERY = <<-Q.squish
        MATCH (c:Collection)-[r1:hasMember]->(pw:PublicationWork)
        OPTIONAL MATCH (c)-[r2:hasLeadMember]->(leadPublicationWork:PublicationWork)
        MATCH (pe:PublicationExpression)-[r3:expressionOf]->(pw:PublicationWork)-[r4:publishedBy]->(rs:ResearchService)
        MATCH (pe)-[r7:hasPublicationExpressionStatus]->(pes:PublicationExpressionStatus)
        OPTIONAL MATCH (person:Person)<-[r5:contributionBy]-(cont:Contribution)-[r6:contributionTo]->(pe)
        WHERE pes.label = 'Published'
        RETURN c.name AS name,
               c.id AS id,
               leadPublicationWork.id AS lead_publication_work_id,
               leadPublicationWork.title AS lead_publication_work_name,
               COUNT(pw) AS pw_count
        ORDER BY name
      Q

      PROMOTED_BY = <<-Q.squish
        MATCH (c:Collection)<-[e:collectionPromotionOf]-(b:CollectionPromotion)-[r:collectionPromotionBy]->(rs:ResearchService)
        WHERE rs.id = '%{research_service_id}'
        OPTIONAL MATCH (c)-[r2:hasLeadMember]->(leadPublicationWork:PublicationWork)
        MATCH (pe:PublicationExpression)-[r3:expressionOf]->(pw:PublicationWork)-[r4:publishedBy]->(rs:ResearchService)
        MATCH (pe)-[r7:hasPublicationExpressionStatus]->(pes:PublicationExpressionStatus)        WHERE pes.label = 'Published'
        RETURN c.name AS name,
               c.id AS id,
               leadPublicationWork.id AS lead_publication_work_id,
               leadPublicationWork.title AS lead_publication_work_name,
               COUNT(pw) AS pw_count
        ORDER BY name
        SKIP %{skip}
        LIMIT %{limit}
      Q

      COUNT_FOR_PROMOTED_BY = <<-Q.squish
        MATCH (c:Collection)<-[e:collectionPromotionOf]-(b:CollectionPromotion)-[r:collectionPromotionBy]->(rs:ResearchService)
        WHERE rs.id = '%{research_service_id}'
        RETURN COUNT(DISTINCT(c.id)) AS total
      Q

      def all
        params = { query: QUERY }
        response = call(params: params)
        body = process_response(response.body)

        body.map { |record| Hashie::Mash.new(record) }
      end

      def count_for_promoted_by(research_service_id:)
        params = { query: COUNT_FOR_PROMOTED_BY % { research_service_id: research_service_id } }
        response = call(params: params)
        output = JSON.parse(response.body)

        output["results"].first["total"]
      end

      def promoted_by(research_service_id:, skip: 0, limit: 25)
        params = { query: PROMOTED_BY % { skip: skip, limit: limit, research_service_id: research_service_id }}
        response = call(params: params)
        body = process_response(response.body)
        body.map { |concept| Hashie::Mash.new(concept) }
      end
    end
  end
end

module Datagraphs
  module Api
    class GetExpressions < CypherQuery
      FOR_WORK_ID_AND_STATUS_QUERY = <<-Q.squish
        MATCH (pw:PublicationWork)<-[eO:expressionOf]-(pe:PublicationExpression)
        OPTIONAL MATCH startWithPerson = (p:Person)<-[r3:contributionBy]-(c:Contribution)-[r2:contributionTo]->(pe:PublicationExpression)
        OPTIONAL MATCH path3=(c:Contribution)-[r4:hasContributionType]->(ct:ContributionType)
        MATCH addStatus=(pe:PublicationExpression)-[r5:hasPublicationExpressionStatus]->(pes:PublicationExpressionStatus)
        WHERE pw.id='%{publication_work_id}'
        AND (%{statuses})
        RETURN    c.isPublic AS is_public,
                  pe.publishedAt AS published_at,
                  pe.updatedAt AS updated_at,
                  pe.number AS version_number,
                  pe.title AS title,
                  pw.id AS publication_work_id,
                  pe.id AS id,
                  pes.label AS status,
                  pw.reference AS ref,
                  pe.createdAt AS created_at,
                  pes.label AS status,
                  COLLECT_LIST(DISTINCT p.id) AS people_ids,
                  COLLECT_LIST(DISTINCT p.displayName) AS people_names,
                  COLLECT_LIST(DISTINCT ct.label) AS contribution_types,
                  COLLECT_LIST(DISTINCT c.ordinality) AS ordinalities,
                  COLLECT_LIST(DISTINCT c.id) AS contribution_ids,
                  COLLECT_LIST(DISTINCT c.isPublic) AS public
        ORDER BY published_at DESC
        SKIP %{skip}
        LIMIT %{limit}
      Q

      STATUSES = <<-Q.squish
        MATCH p = (pw:PublicationWork)<-[e:expressionOf]-(b:PublicationExpression)-[r:hasPublicationExpressionStatus]->(pes:PublicationExpressionStatus)
        WHERE pw.id = '%{publication_work_id}'
        RETURN COLLECT_LIST(DISTINCT pes.label) AS statuses
      Q

      COUNT_FOR_WORK_ID_AND_STATUS_QUERY = <<-Q.squish
        MATCH p = (pw:PublicationWork)<-[e:expressionOf]-(pe:PublicationExpression)-[r:hasPublicationExpressionStatus]->(pes:PublicationExpressionStatus)
        WHERE pw.id = '%{publication_work_id}'
        AND (%{statuses})
        RETURN COUNT(pe) AS total
      Q

      def count_for_statuses(publication_work_id: 'urn:publications-data:PublicationWork:3549', selected_statuses:)
        statuses = status_filter(selected_statuses)
        params = { query: COUNT_FOR_WORK_ID_AND_STATUS_QUERY % { publication_work_id: publication_work_id, statuses: statuses }}
        response = call(params: params)
        output = JSON.parse(response.body)
        output["results"].first["total"]
      end

      def for_work_id_and_statuses(publication_work_id: 'urn:publications-data:PublicationWork:3549', skip: 0, limit: 25, selected_statuses:)
        statuses = status_filter(selected_statuses)
        params = { query: FOR_WORK_ID_AND_STATUS_QUERY % { publication_work_id: publication_work_id, skip: skip, limit: limit, statuses: statuses }}

        response = call(params: params)
        body = process_response(response.body)

        expressions = body.map { |record| Hashie::Mash.new(record) }

        expressions.each do |expression|
          expression.contributions = expression.people_ids.zip(expression.people_names).zip(expression.contribution_types).zip(expression.public).zip(expression.ordinalities)
        end
      end

      def statuses(publication_work_id: 'urn:publications-data:PublicationWork:3549')
        params = { query: STATUSES % { publication_work_id: publication_work_id }}

        response = call(params: params)
        process_response(response.body)

        body = process_response(response.body)
        body.first["statuses"]
      end

      private

      def status_filter(seelcted_statuses)
        seelcted_statuses.map { |s| "pes.label = '#{s}'" }.join(" OR ")
      end
    end
  end
end

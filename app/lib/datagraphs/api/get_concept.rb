module Datagraphs
  module Api
    class GetConcept < CypherQuery
      QUERY = <<-Q.squish
        MATCH (concept:Concept)
        OPTIONAL MATCH (broaderTerm:Concept)<-[r1:broaderTerm]-(concept:Concept)
        OPTIONAL MATCH (concept:Concept)<-[r2:broaderTerm]-(narrowerTerms:Concept)
        OPTIONAL MATCH (concept)<-[s:subject]-(pw:PublicationWork)<-[r3:expressionOf]-(pe:PublicationExpression)-[r4:hasPublicationExpressionStatus]->(pes:PublicationExpressionStatus)
        WHERE concept.id = '%{concept_id}'
        AND broaderTerm.id <> '%{except_id}'
        AND pes.label = 'Published'
        RETURN  DISTINCT(concept.id) AS id,
                concept.label AS label,
                concept.indexerNote AS indexer_note,
                concept.synonym AS synonym,
                concept.classType AS class_type,
                concept.scopeNote AS scope_note,
                COUNT(DISTINCT narrowerTerms.id) AS narrower_terms_count,
                COUNT(DISTINCT pw.id) AS publications_count,
                COUNT(DISTINCT broaderTerm.id) AS broader_terms_count
                ORDER BY label ASC
        LIMIT 1
      Q

      # We don't want to go up to concept! Which is 90102
      GET_BROADER_TERMS = <<-Q.squish
        MATCH (broaderTerm:Concept)<-[r1:broaderTerm]-(concept:Concept)
        OPTIONAL MATCH (broaderTerm)<-[s:subject]-(pw:PublicationWork)<-[r3:expressionOf]-(pe:PublicationExpression)-[r4:hasPublicationExpressionStatus]->(pes:PublicationExpressionStatus)
        WHERE concept.id = '%{concept_id}'
        AND broaderTerm.id <> '%{except_id}'
        AND pes.label = 'Published'

        RETURN  DISTINCT(broaderTerm.id) AS id,
                broaderTerm.label AS label,
                COUNT(DISTINCT pw.id) AS publications_count
                ORDER BY label ASC
        OFFSET %{skip}
        LIMIT %{limit}
      Q

      GET_NARROWER_TERMS = <<-Q.squish
        MATCH (concept:Concept)<-[r2:broaderTerm]-(narrowerTerm:Concept)
        OPTIONAL MATCH (narrowerTerm)<-[s:subject]-(pw:PublicationWork)<-[r3:expressionOf]-(pe:PublicationExpression)-[r4:hasPublicationExpressionStatus]->(pes:PublicationExpressionStatus)
        WHERE concept.id = '%{concept_id}'
        AND narrowerTerm.id <> '%{except_id}'
        AND pes.label = 'Published'
        RETURN  DISTINCT(narrowerTerm.id) AS id,
                narrowerTerm.label AS label,
                COUNT(DISTINCT pw.id) AS publications_count
                ORDER BY label ASC
        OFFSET %{skip}
        LIMIT %{limit}
      Q

      def details_for(concept_id:, skip: 0, limit: 25)
        params = { query: QUERY % { skip: skip, limit: limit, concept_id: concept_id, except_id: $CONCEPT_CONCEPT_ID }}

        response = call(params: params)
        concept = process_response(response.body).first
        Hashie::Mash.new(concept)
      end

      def and_broader_terms(concept_id:, skip: 0, limit: 25)
        params = { query: GET_BROADER_TERMS % { concept_id: concept_id, skip: 0, limit: 25, except_id: $CONCEPT_CONCEPT_ID }}
        response = call(params: params)
        results = process_response(response.body)
        results.map { |result| Hashie::Mash.new(result) }
      end

      def and_narrower_terms(concept_id:, skip: 0, limit: 25)
        params = { query: GET_NARROWER_TERMS % { concept_id: concept_id, skip: 0, limit: 25, except_id: $CONCEPT_CONCEPT_ID }}
        response = call(params: params)
        results = process_response(response.body)
        results.map { |result| Hashie::Mash.new(result) }
      end
    end
  end
end

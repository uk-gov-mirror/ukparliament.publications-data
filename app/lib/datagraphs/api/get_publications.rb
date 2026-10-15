module Datagraphs
  module Api
    class GetPublications < CypherQuery

      QUERY = <<-Q
        MATCH (pe:PublicationExpression)-[r1:expressionOf]->(pw:PublicationWork)-[r3:publishedBy]->(rs:ResearchService)
        MATCH (pe)-[r2:hasPublicationExpressionStatus]->(pes:PublicationExpressionStatus)
        OPTIONAL MATCH (person:Person)<-[r4:contributionBy]-(cont:Contribution)-[r5:contributionTo]->(pe)
        WHERE pes.label = 'Published'
        RETURN pe.id as publication_expression_id,
               pw.id as publication_work_id,
               pw.title as title,
               pes.label as status,
               pe.publishedAt as published_at,
               pe.teaserText as teaser_text,
               pw.createdOn as created_at,
               pe.number as version_number,
               pe.updatedAt AS updated_at,
               rs.shortName AS short_research_service_name,
               rs.id AS research_service_id,
               COLLECT_LIST(DISTINCT person.id) AS contributor_ids,
               COLLECT_LIST(DISTINCT person.displayName) AS contributor_names
        ORDER BY pe.publishedAt desc
        SKIP %{skip}
        LIMIT %{limit}
      Q

      COUNT_FOR_A_DISCLAIMER = <<-Q.squish
        MATCH (d:Disclaimer)<-[r:hasDisclaimer]-(a:DisclaimerApplicability)<-[s:hasDisclaimerApplicability]-(pw:PublicationWork)
        WHERE d.id = '%{disclaimer_id}'
        MATCH (pe:PublicationExpression)-[r1:expressionOf]->(pw:PublicationWork)
        MATCH (pe)-[r2:hasPublicationExpressionStatus]->(pes:PublicationExpressionStatus)
        WHERE pes.label="Published"
        RETURN count(pw) AS total
      Q

      FOR_A_DISCLAIMER = <<-Q.squish
        MATCH (d:Disclaimer)<-[r:hasDisclaimer]-(a:DisclaimerApplicability)<-[s:hasDisclaimerApplicability]-(pw:PublicationWork)
        WHERE d.id = '%{disclaimer_id}'
        MATCH (pe:PublicationExpression)-[r1:expressionOf]->(pw:PublicationWork)-[r3:publishedBy]->(rs:ResearchService)
        MATCH (pe)-[r2:hasPublicationExpressionStatus]->(pes:PublicationExpressionStatus)
        OPTIONAL MATCH (person:Person)<-[r4:contributionBy]-(cont:Contribution)-[r5:contributionTo]->(pe)
        WHERE pes.label = 'Published'
        RETURN pe.id as publication_expression_id,
               pw.id as publication_work_id,
               pw.title as title,
               pes.label as status,
               pw.reference AS ref,
               pe.publishedAt as published_at,
               pe.teaserText as teaser_text,
               pw.createdOn as created_at,
               pe.number as version_number,
               pe.updatedAt AS updated_at,
               rs.shortName AS short_research_service_name,
               rs.id AS research_service_id,
               COLLECT_LIST(DISTINCT person.id) AS contributor_ids,
               COLLECT_LIST(DISTINCT person.displayName) AS contributor_names
        ORDER BY pe.publishedAt desc
        SKIP %{skip}
        LIMIT %{limit}
      Q

      COUNT_FOR_A_COLLECTION = <<-Q.squish
        MATCH (c:Collection)-[hasMember:hasMember]->(pw:PublicationWork)
        WHERE c.id='%{collection_id}'
        MATCH (pe:PublicationExpression)-[r1:expressionOf]->(pw:PublicationWork)
        MATCH (pe)-[r2:hasPublicationExpressionStatus]->(pes:PublicationExpressionStatus)
        WHERE pes.label="Published"
        RETURN count(pw) AS total
      Q

      FOR_A_COLLECTION = <<-Q.squish
        MATCH (c:Collection)-[hasMember:hasMember]->(pw:PublicationWork)
        WHERE c.id='%{collection_id}'
        MATCH (pe:PublicationExpression)-[r1:expressionOf]->(pw:PublicationWork)-[r3:publishedBy]->(rs:ResearchService)
        MATCH (pe)-[r2:hasPublicationExpressionStatus]->(pes:PublicationExpressionStatus)
        OPTIONAL MATCH (person:Person)<-[r4:contributionBy]-(cont:Contribution)-[r5:contributionTo]->(pe)
        WHERE pes.label = 'Published'
        AND pw.id <> '%{lead_publication_work_id}'
        RETURN pe.id as publication_expression_id,
               pw.id as publication_work_id,
               pw.title as title,
               pes.label as status,
               pe.publishedAt as published_at,
               pe.teaserText as teaser_text,
               pw.createdOn as created_at,
               pe.number as version_number,
               pe.updatedAt AS updated_at,
               rs.shortName AS short_research_service_name,
               rs.id AS research_service_id,
               COLLECT_LIST(DISTINCT person.id) AS contributor_ids,
               COLLECT_LIST(DISTINCT person.displayName) AS contributor_names
        ORDER BY pe.publishedAt desc
        SKIP %{skip}
        LIMIT %{limit}
      Q

      FOR_A_RESEARCH_SERVICE = <<-Q
        MATCH (pe:PublicationExpression)-[r1:expressionOf]->(pw:PublicationWork)-[r3:publishedBy]->(rs:ResearchService)
        MATCH (pe:PublicationExpression)-[r2:hasPublicationExpressionStatus]->(pes:PublicationExpressionStatus)
        WHERE pes.label = 'Published'
        AND rs.id = '%{research_service_id}'
        RETURN pe.id as publication_expression_id,
               pw.id as publication_work_id,
               pw.title as title,
               pes.label as status, pe.publishedAt as published_at,
               pe.createdAt as created_at,
               pe.number as the_number,
               rs.shortName AS short_research_service_name,
               rs.id AS research_service_id
        ORDER BY pe.publishedAt desc
        SKIP %{skip}
        LIMIT %{limit}
      Q

      COUNT_FOR_RESEARCH_SERVICE = <<-Q
        MATCH (pe:PublicationExpression)-[r1:expressionOf]->(pw:PublicationWork)-[r3:publishedBy]->(rs:ResearchService)
        MATCH (pe:PublicationExpression)-[r2:hasPublicationExpressionStatus]->(pes:PublicationExpressionStatus)
        WHERE pes.label="Published"
        AND rs.id = '%{research_service_id}'
        RETURN count(pw) AS total
      Q

      COUNT = <<-Q
        MATCH (pe:PublicationExpression)-[r1:expressionOf]->(pw:PublicationWork)
        MATCH (pe:PublicationExpression)-[r2:hasPublicationExpressionStatus]->(pes:PublicationExpressionStatus)
        WHERE pes.label="Published"
        RETURN count(pw) AS total
      Q

      COUNT_FOR_A_SECTION = <<-Q
        MATCH (s:Section)<-[e:sectionContributionBy]-(sc:SectionContribution)-[r:sectionContributionTo]->(pe:PublicationExpression)-[r2:hasPublicationExpressionStatus]->(pes:PublicationExpressionStatus)
        MATCH (pe)-[t:expressionOf]->(pw:PublicationWork)
        WHERE s.id = '%{section_id}'
        AND pes.label = 'Published'
        RETURN count(pw) AS total
      Q

      FOR_A_SECTION = <<-Q.squish
        MATCH (s:Section)<-[e:sectionContributionBy]-(sc:SectionContribution)-[r:sectionContributionTo]->(pe:PublicationExpression)-[r2:hasPublicationExpressionStatus]->(pes:PublicationExpressionStatus)
        MATCH (pe)-[t:expressionOf]->(pw:PublicationWork)
        WHERE s.id = '%{section_id}'
        AND pes.label = 'Published'
        OPTIONAL MATCH (person:Person)<-[r4:contributionBy]-(cont:Contribution)-[r5:contributionTo]->(pe), (cont)-[r6:hasContributionType]->(contributionType:ContributionType)
        WHERE contributionType.label = 'Owner'
        RETURN
               pe.id as publication_expression_id,
               pw.id as publication_work_id,
               pw.reference as ref,
               pw.title as title,
               pes.label as status,
               pe.publishedAt as published_at,
               pe.createdAt as created_at,
               pe.number as the_number,
               COLLECT_LIST(DISTINCT person.id) AS contributor_ids,
               COLLECT_LIST(DISTINCT person.displayName) AS contributor_names,
               COLLECT_LIST(DISTINCT contributionType.label) AS contribution_type
        ORDER BY published_at DESC
        SKIP %{skip}
        LIMIT %{limit}
      Q

      COUNT_FOR_A_CONCEPT = <<-Q
        MATCH (pw:PublicationWork)-[r1:subject]->(c:Concept)
        MATCH (pw)<-[r2:expressionOf]-(pe:PublicationExpression)-[r3:hasPublicationExpressionStatus]->(pes:PublicationExpressionStatus)
        WHERE c.id = '%{concept_id}'
        AND pes.label = 'Published'
        RETURN COUNT(pw) AS total
      Q

      FOR_A_CONCEPT = <<-Q.squish
        MATCH (pw:PublicationWork)-[r1:subject]->(c:Concept)
        MATCH (pw)<-[r2:expressionOf]-(pe:PublicationExpression)-[r3:hasPublicationExpressionStatus]->(pes:PublicationExpressionStatus)
        WHERE c.id = '%{concept_id}'
        AND pes.label = 'Published'
        RETURN pe.id as publication_expression_id,
               pw.id as id,
               pw.reference as ref,
               pw.title as title,
               pes.label as status,
               pe.number as the_number
        ORDER BY title
        SKIP %{skip}
        LIMIT %{limit}
      Q

      COUNT_FOR_A_GEOGRAPHIC_AREA = <<-Q.squish
        MATCH (area:GeographicArea)<-[e]-(pw:PublicationWork)
        OPTIONAL MATCH (pes:PublicationExpressionStatus)<-[r2:hasPublicationExpressionStatus]-(pe:PublicationExpression)-[r1:expressionOf]->(pw:PublicationWork)
        WHERE pes.label = '%{publication_status_label}'
        AND area.id = '%{geographic_area_id}'
        RETURN COUNT(pw) AS total
      Q

      FOR_A_GEOGRAPHIC_AREA = <<-Q.squish
        MATCH (area:GeographicArea)<-[e]-(pw:PublicationWork)<-[r1:expressionOf]-(pe:PublicationExpression)-[r2:hasPublicationExpressionStatus]->(pes:PublicationExpressionStatus)
        WHERE area.id = '%{geographic_area_id}'
        AND pes.label = '%{publication_status_label}'
        OPTIONAL MATCH (person:Person)<-[r4:contributionBy]-(cont:Contribution)-[r5:contributionTo]->(pe), (cont)-[r6:hasContributionType]->(contributionType:ContributionType)
        WHERE contributionType.label = '%{contribution_type_label}'
        RETURN pe.id as publication_expression_id,
               pe.publishedAt as published_at,
               pw.id as publication_work_id,
               pw.reference as ref,
               pw.title as title,
               pw.createdOn as created_at,
               pes.label as status,
               pe.number as the_number,
               COLLECT_LIST(DISTINCT person.id) AS contributor_ids,
               COLLECT_LIST(DISTINCT person.displayName) AS contributor_names,
               COLLECT_LIST(DISTINCT contributionType.label) AS contribution_type
        ORDER BY title
        SKIP %{skip}
        LIMIT %{limit}
      Q

      UNPUBLISHED_FOR_A_HOUSE_COUNT = <<-Q.squish
        OPTIONAL MATCH (pw:PublicationWork)<-[e:expressionOf]-(pe:PublicationExpression)-[r:hasPublicationExpressionStatus]->(pes:PublicationExpressionStatus)
        MATCH (pw:PublicationWork)-[s:publishedBy]->(d:ResearchService)-[f:for]->(h:House)
        WHERE pes.label = 'Published'
        AND h.id = '%{house_id}'
        RETURN pw, count(pe) AS expression_count
        NEXT YIELD pw, expression_count
        FILTER expression_count = 0
        RETURN COUNT(DISTINCT pw.id) AS total
      Q

      UNPUBLISHED_FOR_A_HOUSE = <<-Q.squish
        OPTIONAL MATCH (pw:PublicationWork)<-[e:expressionOf]-(pe:PublicationExpression)-[r:hasPublicationExpressionStatus]->(pes:PublicationExpressionStatus)
        MATCH (pw:PublicationWork)-[s:publishedBy]->(d:ResearchService)-[f:for]->(h:House)
        WHERE pes.label = 'Published'
        AND h.id = '%{house_id}'
        RETURN pw, count(pe) AS expression_count
        NEXT YIELD pw, expression_count
        FILTER expression_count = 0
        MATCH (pw:PublicationWork)<-[e:expressionOf]-(pe:PublicationExpression)
        RETURN
               pw.id as publication_work_id,
               pw.title as work_title,
               COLLECT_LIST(pe.id) AS expression_ids,
               COLLECT_LIST(pe.title) AS expression_titles
        ORDER BY expression_titles
      Q

      def get_for_a_research_service(research_service_id:, skip: 0, limit: 25)
        params = { query: FOR_A_RESEARCH_SERVICE % { skip: skip, limit: limit, research_service_id: research_service_id }}
        response = call(params: params)
        process_response(response.body)
      end

      def get_count_for_a_research_service(research_service_id)
        params = { query: COUNT_FOR_RESEARCH_SERVICE % {  research_service_id: research_service_id }}
        response = call(params: params)
        output = JSON.parse(response.body)
        output["results"].first["total"]
      end

      def get_total
        params = { query: COUNT }
        response = call(params: params)
        output = JSON.parse(response.body)
        output["results"].first["total"]
      end

      def for_a_section_count(section_id:)
        params = { query: COUNT_FOR_A_SECTION % {  section_id: section_id }}
        response = call(params: params)
        output = JSON.parse(response.body)
        output["results"].first["total"]
      end

      def for_a_section(section_id:, skip: 0, limit: 25)
        params = { query: FOR_A_SECTION % { section_id: section_id, skip: skip, limit: limit }}
        response = call(params: params)
        publications = process_response(response.body)

        publications.each do |pub|
          pub["owners"] = pub["contributor_ids"].zip(pub["contributor_names"])
        end

        publications.map { |result| Hashie::Mash.new(result) }
      end

      def for_a_collection_count(collection_id:)
        params = { query: COUNT_FOR_A_COLLECTION % { collection_id: collection_id }}
        response = call(params: params)
        output = JSON.parse(response.body)
        output["results"].first["total"]
      end

      def for_a_collection(collection_id:, lead_publication_work_id:, skip: 0, limit: 25)
        params = { query: FOR_A_COLLECTION % { collection_id: collection_id, lead_publication_work_id: lead_publication_work_id, skip: skip, limit: limit }}
        response = call(params: params)
        publications = process_response(response.body)

        publications.each do |pub|
          pub["contributors"] = pub["contributor_ids"].zip(pub["contributor_names"])
        end

        publications.map { |result| Hashie::Mash.new(result) }
      end

      def for_a_disclaimer_count(disclaimer_id:)
        params = { query: COUNT_FOR_A_DISCLAIMER % { disclaimer_id: disclaimer_id }}
        response = call(params: params)
        output = JSON.parse(response.body)
        output["results"].first["total"]
      end

      def for_a_disclaimer(disclaimer_id:, skip: 0, limit: 25)
        params = { query: FOR_A_DISCLAIMER % { disclaimer_id: disclaimer_id, skip: skip, limit: limit }}
        response = call(params: params)
        publications = process_response(response.body)

        publications.each do |pub|
          pub["contributors"] = pub["contributor_ids"].zip(pub["contributor_names"])
        end

        publications.map { |result| Hashie::Mash.new(result) }
      end


      def for_a_concept_count(concept_id:)
        params = { query: COUNT_FOR_A_CONCEPT % {  concept_id: concept_id }}
        response = call(params: params)
        output = JSON.parse(response.body)
        output["results"].first["total"]
      end

      def for_a_concept(concept_id:, skip: 0, limit: 25)
        params = { query: FOR_A_CONCEPT % { concept_id: concept_id, skip: skip, limit: limit }}
        response = call(params: params)
        process_response(response.body)
      end

      def for_a_geographic_area_count(geographic_area_id:, publication_status_label: "Published")
        params = { query: COUNT_FOR_A_GEOGRAPHIC_AREA % {  geographic_area_id: geographic_area_id, publication_status_label: publication_status_label }}
        response = call(params: params)
        output = JSON.parse(response.body)
        output["results"].first["total"]
      end

      def for_a_geographic_area(geographic_area_id:, skip: 0, limit: 25, publication_status_label: "Published", contribution_type_label: "Owner")
        params = { query: FOR_A_GEOGRAPHIC_AREA % {
          geographic_area_id: geographic_area_id,
          contribution_type_label: contribution_type_label,
          publication_status_label: publication_status_label,
          skip: skip,
          limit: limit
        }}
        response = call(params: params)
        publications = process_response(response.body)

        publications.each do |pub|
          pub["owners"] = pub["contributor_ids"].zip(pub["contributor_names"])
        end

        publications.map { |result| Hashie::Mash.new(result) }
      end

      def all(skip: 0, limit: 25)
        params = { query: QUERY % { skip: skip, limit: limit }}
        response = call(params: params)
        publications = process_response(response.body)

        publications.each do |pub|
          pub["contributors"] = pub["contributor_ids"].zip(pub["contributor_names"])
        end

        publications.map { |result| Hashie::Mash.new(result) }
      end

      def unpublished_for_a_house(house_id:, skip: 0, limit: 25)
        params = { query: UNPUBLISHED_FOR_A_HOUSE % { house_id: house_id, skip: skip, limit: limit }}
        response = call(params: params)
        process_response(response.body)
      end

      def unpublished_for_a_house_count(house_id:)
        params = { query: UNPUBLISHED_FOR_A_HOUSE_COUNT % { house_id: house_id }}
        response = call(params: params)
        output = JSON.parse(response.body)
        output["results"].first["total"]
      end
    end
  end
end

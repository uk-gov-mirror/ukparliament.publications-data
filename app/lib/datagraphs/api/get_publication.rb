module Datagraphs
  module Api
    class GetPublication < CypherQuery
      PUBLISHED_PUBLICATION_ONLY = <<-Q.squish
        MATCH (pw:PublicationWork)<-[eO:expressionOf]-(pe:PublicationExpression)
        MATCH (pe:PublicationExpression)-[r5:hasPublicationExpressionStatus]->(pes:PublicationExpressionStatus)
        MATCH (pw:PublicationWork)-[r6:publishedBy]->(rs:ResearchService)
        WHERE pw.id='%{publication_work_id}'
        AND pes.label = 'Published'
        RETURN    pw.title AS title,
                  pw.id AS id,
                  pw.doi AS doi,
                  pes.label AS status,
                  pw.reference AS ref,
                  pw.includesPowerBiDataDashboard AS includes_power_bi_data_dashboard,
                  pw.includesShinyDataDashboard AS includes_shiny_data_dashboard,
                  rs.id AS research_service_id,
                  rs.name AS research_service_name,
                  pw.createdOn AS created_at,
                  pe.publishedAt AS published_at,
                  pe.updatedAt AS updated_at,
                  pe.number AS version_number,
                  pe.id AS published_expression_id
      Q

      PUBLICATION_OPTIONAL_EXTRAS  = <<-Q.squish
        MATCH (pw:PublicationWork)
        OPTIONAL MATCH (pw)-[r7:subject]->(c:Concept)
        OPTIONAL MATCH (pw)-[r8:hasDisclaimerApplicability]->(f:DisclaimerApplicability)-[r9:hasDisclaimer]->(d:Disclaimer)
        OPTIONAL MATCH (pw)<-[sr1:supersedes]-(s1:Superseding)-[sr2:supersededBy]->(superpw:PublicationWork)
        OPTIONAL MATCH (supersedes)<-[sr3:supersedes]-(s2:Superseding)-[sr4:supersededBy]->(pw:PublicationWork)       OPTIONAL MATCH (pw)-[r12:mergedFrom]->(mf:PublicationWork)
        OPTIONAL MATCH (pw)-[r13:splitFrom]->(sf:PublicationWork)
        OPTIONAL MATCH (pw)-[r14:hasWithdrawalPeriod]->(wp:WithdrawalPeriod)
        OPTIONAL MATCH (area:GeographicArea)<-[e]-(pw)
        OPTIONAL MATCH (col:Collection)-[hasMember:hasMember]->(pw)
        OPTIONAL MATCH (leadOfCollection:Collection)-[hasLeadMember:hasLeadMember]->(pw)
        WHERE pw.id='%{publication_work_id}'
        RETURN
                  COLLECT_LIST(DISTINCT col.id) AS collection_ids,
                  COLLECT_LIST(DISTINCT col.name) AS collection_names,
                  COLLECT_LIST(DISTINCT leadOfCollection.id) AS lead_collection_ids,
                  COLLECT_LIST(DISTINCT leadOfCollection.name) AS lead_collection_names,
                  COLLECT_LIST(DISTINCT d.id) AS disclaimer_ids,
                  COLLECT_LIST(DISTINCT d.label) AS disclaimer_labels,
                  COLLECT_LIST(DISTINCT f.applicableFrom) AS disclaimers_applicable_from,
                  COLLECT_LIST(DISTINCT mf.id) AS merged_from_ids,
                  COLLECT_LIST(DISTINCT mf.title) AS merged_from_titles,
                  COLLECT_LIST(DISTINCT sf.id) AS split_from_ids,
                  COLLECT_LIST(DISTINCT sf.title) AS split_from_titles,
                  COLLECT_LIST(DISTINCT wp) AS wps,
                  COLLECT_LIST(DISTINCT c) AS concepts,
                  COLLECT_LIST(DISTINCT supersedes) AS supersedes,
                  COLLECT_LIST(DISTINCT superpw) AS superseded_by,
                  COLLECT_LIST(DISTINCT sf) AS split_from,
                  COLLECT_LIST(DISTINCT mf) AS merged_from,
                  COLLECT_LIST(DISTINCT area) AS geographic_areas
      Q

      PUBLICATION_ONLY = <<-Q.squish
        MATCH (pw:PublicationWork)<-[eO:expressionOf]-(pe:PublicationExpression)
        MATCH (pe:PublicationExpression)-[r5:hasPublicationExpressionStatus]->(pes:PublicationExpressionStatus)
        MATCH (pw:PublicationWork)-[r6:publishedBy]->(rs:ResearchService)
        OPTIONAL MATCH path5=(pw)-[r7:subject]->(c:Concept)
        WHERE pw.id='%{publication_work_id}'
        RETURN    pw.title AS title,
                  pw.id AS id,
                  pes.label AS status,
                  pw.reference AS ref,
                  pw.doi AS doi,
                  rs.id AS research_service_id,
                  rs.name AS research_service_name,
                  pe.createdAt AS created_at,
                  pe.publishedAt AS published_at,
                  pe.id AS publication_expression_id,
                  COLLECT_LIST(c.label) AS concepts,
                  COLLECT_LIST(c.id) AS concept_ids
      Q

      COUNT = <<-Q.squish
        MATCH p = (pw:PublicationWork)<-[eO:expressionOf]-(pe:PublicationExpression)
        OPTIONAL MATCH path1=(pe:PublicationExpression)<-[r2:contributionTo]-(c:Contribution)
        WHERE pw.id='%{publication_work_id}'
        RETURN COUNT(DISTINCT pe) AS total
      Q

      ALL_CONTRIBUTORS = <<-Q.squish
        MATCH (pw:PublicationWork)<-[eO:expressionOf]-(pe:PublicationExpression)
        MATCH startWithPerson = (p:Person)<-[r3:contributionBy]-(c:Contribution)-[r2:contributionTo]->(pe:PublicationExpression)
        MATCH path3 = (c:Contribution)-[r4:hasContributionType]->(ct:ContributionType)
        MATCH addStatus=(pe:PublicationExpression)-[r5:hasPublicationExpressionStatus]->(pes:PublicationExpressionStatus)
        WHERE pw.id='%{publication_work_id}'
        AND pes.label='Published'
        RETURN p.id AS person_id,
               p.displayName AS person_name,
               ct.label AS contribution_type,
               c.isPublic AS is_contribution_public,
               c.ordinality AS contribution_ordinality,
               c.label AS contribution_label
        ORDER BY person_name
      Q

      RESOURCES_ONLY = <<-Q.squish
        MATCH (pubWork:PublicationWork)<-[eO:expressionOf]-(pubExp:PublicationExpression)-[t:hasPublicationExpressionStatus]->(pes:PublicationExpressionStatus)
        OPTIONAL MATCH (pubExp)<-[r:forPublicationExpression]-(resFileLink:ResourceFileLink)-[s:forResourceFile]->(resourceFile:ResourceFile)
        WHERE pubWork.id = '%{publication_work_id}'
        AND pes.label = 'Published'
        RETURN
              resFileLink.title as file_title,
              resourceFile.label as file_label,
              resourceFile.mimeType as mime_type,
              resourceFile.fileSizeInBytes as file_size_in_bytes,
              resourceFile.publicUrl as public_url,
              resourceFile.privateUrl as private_url
      Q

      RELATED_LINKS_ONLY  = <<-Q.squish
        MATCH (pubWork:PublicationWork)<-[eO:expressionOf]-(pubExp:PublicationExpression)-[t:hasPublicationExpressionStatus]->(pes:PublicationExpressionStatus)
        MATCH (pubExp)<-[rlf:relatedLinkFor]-(relatedLink:RelatedLink)
        WHERE pubWork.id = '%{publication_work_id}'
        AND pes.label = 'Published'
        RETURN relatedLink.title AS title,
               relatedLink.url AS url
      Q

      def and_published_publication_details(publication_work_id: 'urn:publications-data:PublicationWork:3549')
        params = { query: PUBLISHED_PUBLICATION_ONLY % { publication_work_id: publication_work_id }}
        response = call(params: params)
        pub_details = process_response(response.body)

        Hashie::Mash.new(pub_details.first)
      end

      def details(publication_work_id: 'urn:publications-data:PublicationWork:3549')
        params = { query: PUBLICATION_ONLY % { publication_work_id: publication_work_id }}
        response = call(params: params)
        process_response(response.body)
      end

      def and_optional_extras(publication_work_id:)
        params = { query: PUBLICATION_OPTIONAL_EXTRAS % { publication_work_id: publication_work_id }}
        response = call(params: params)
        oe = process_response(response.body).first

        oe["collections"] = oe["collection_ids"].zip(oe["collection_names"])
        oe["lead_member_for_collections"] = oe["lead_collection_ids"].zip(oe["lead_collection_names"])
        oe["disclaimers"] = oe["disclaimer_ids"].zip(oe["disclaimer_labels"], oe["disclaimers_applicable_from"])

        Hashie::Mash.new(oe)
      end

      def get_total(publication_work_id: 'urn:publications-data:PublicationWork:3549')
        params = { query: COUNT % { publication_work_id: publication_work_id }}
        response = call(params: params)
        output = JSON.parse(response.body)
        output["results"].first["total"]
      end

      def and_contributors(publication_work_id: 'urn:publications-data:PublicationWork:3549')
        params = { query: ALL_CONTRIBUTORS % { publication_work_id: publication_work_id }}

        response = call(params: params)
        body = process_response(response.body)
        body.uniq.map { |contributor| Hashie::Mash.new(contributor) }
      end

      def and_resources(publication_work_id: 'urn:publications-data:PublicationWork:7809')
        params = { query: RESOURCES_ONLY % { publication_work_id: publication_work_id }}

        response = call(params: params)
        body = process_response(response.body)
        body.map { |resource| Hashie::Mash.new(resource) }
      end

      def and_related_links(publication_work_id: 'urn:publications-data:PublicationWork:7809')
        params = { query: RELATED_LINKS_ONLY % { publication_work_id: publication_work_id }}

        response = call(params: params)
        body = process_response(response.body)
        body.map do |related_link|
          related_link["url"].sub!('http://', 'https://')
          Hashie::Mash.new(related_link)
        end
      end
    end
  end
end

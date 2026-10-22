module Datagraphs
  module Api
    class GetExpression < CypherQuery

      QUERY = <<-Q.squish
      MATCH path0 = (pw:PublicationWork)<-[eO:expressionOf]-(pe:PublicationExpression)-[t:hasPublicationExpressionStatus]->(pes:PublicationExpressionStatus)
      WHERE pe.id = '%{expression_id}'
      RETURN pe.title AS title,
             pe.publishedAt AS published_at,
             pe.updatedAt AS updated_at,
             pe.number AS version_number,
             pe.id AS id,
             pw.id AS publication_work_id,
             pes.label AS status,
             pw.reference AS ref,
             pe.createdAt AS created_at
      Q

      PUBLISHED_EXPRESSION_FOR_A_WORK = <<-Q.squish
        MATCH (pw:PublicationWork)<-[eO:expressionOf]-(pe:PublicationExpression)-[t:hasPublicationExpressionStatus]->(pes:PublicationExpressionStatus)
        WHERE pw.id = '%{publication_work_id}'
        AND pes.label = 'Published'
        RETURN pe.id AS id
      Q

      CONTRIBUTORS = <<-Q.squish
        MATCH startWithPerson = (p:Person)<-[r3:contributionBy]-(c:Contribution)-[r2:contributionTo]->(pe:PublicationExpression)
        MATCH path3 = (c:Contribution)-[r4:hasContributionType]->(ct:ContributionType)
        WHERE pe.id='%{expression_id}'
        RETURN p.id AS person_id,
               p.displayName AS person_name,
               COLLECT_LIST(DISTINCT ct.label) AS contribution_types,
               c.isPublic AS is_public
        ORDER BY p.sortName
      Q

      RESOURCES = <<-Q.squish
        MATCH path2 = (pe:PublicationExpression)<-[r:forPublicationExpression]-(rfl:ResourceFileLink)-[s:forResourceFile]->(rf:ResourceFile)
        WHERE pe.id = '%{expression_id}'
        RETURN
          rf.id as id,
          rfl.title as file_title,
          rf.label as file_label,
          rf.mimeType as mime_type,
          rf.fileSizeInBytes as file_size_in_bytes,
          rf.publicUrl as public_url,
          rf.privateUrl as private_url
      Q

      RELATED_LINKS = <<-Q.squish
        MATCH path4 = (pe:PublicationExpression)<-[x:relatedLinkFor]-(rl:RelatedLink)
        WHERE pe.id = '%{expression_id}'
        RETURN rl.id AS id,
               rl.title AS title,
               rl.url AS url
      Q

      SECTIONS = <<-Q.squish
        MATCH p = (pe:PublicationExpression)<-[e:sectionContributionTo]-(b:SectionContribution)-[r:sectionContributionBy]->(s:Section)
        WHERE pe.id = '%{expression_id}'
        RETURN s.name AS name, s.id AS id
        ORDER BY s.name
      Q

      def published_for(publication_work_id: 'urn:publications-data:PublicationExpression:10102')
        params = { query: PUBLISHED_EXPRESSION_FOR_A_WORK % { publication_work_id: publication_work_id }}

        response = call(params: params)
        expression = process_response(response.body).first

        Hashie::Mash.new(expression)
      end

      def details(expression_id: 'urn:publications-data:PublicationExpression:69185')
        params = { query: QUERY % { expression_id: expression_id }}

        response = call(params: params)
        body = process_response(response.body)
        Hashie::Mash.new(body.first)
      end

      def resources(expression_id: 'urn:publications-data:PublicationExpression:69185')
        params = { query: RESOURCES % { expression_id: expression_id }}

        response = call(params: params)
        body = process_response(response.body)

        body.map { |resource| Hashie::Mash.new(resource) if resource["id"] }
      end

      def related_links(expression_id: 'urn:publications-data:PublicationExpression:69185')
        params = { query: RELATED_LINKS % { expression_id: expression_id }}

        response = call(params: params)
        body = process_response(response.body)

        body.map { |related_link| Hashie::Mash.new(related_link) if related_link["id"] }
      end

      def contributors(expression_id: 'urn:publications-data:PublicationExpression:69185')
        params = { query: CONTRIBUTORS % { expression_id: expression_id }}

        response = call(params: params)
        body = process_response(response.body)

        body.map { |contributor| Hashie::Mash.new(contributor) if contributor["person_id"] }
      end

      def sections(expression_id: 'urn:publications-data:PublicationExpression:69185')
        params = { query: SECTIONS % { expression_id: expression_id }}

        response = call(params: params)
        body = process_response(response.body)

        body.map { |section| Hashie::Mash.new(section) if section["name"] }
      end
    end
  end
end

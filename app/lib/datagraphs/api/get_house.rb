module Datagraphs
  module Api
    class GetHouse < CypherQuery
      DETAILS = <<-Q.squish
        MATCH houses=(house:House)<-[r1:for]-(rs:ResearchService)
        WHERE house.id='%{house_id}'
        RETURN house.name             AS name,
               house.id               AS id,
               house.shortName        AS short_name,
               COLLECT_LIST(rs.id)    AS research_service_ids,
               COLLECT_LIST(rs.name)  AS research_service_names
        LIMIT 1
      Q

      def details(house_id = 'urn:publications-data:House:1')
        params = { query: DETAILS % { house_id: house_id }}
        response = call(params: params)
        body = process_response(response.body).first

        body["research_services"] = body["research_service_ids"].zip(body["research_service_names"])

        Hashie::Mash.new(body)
      end
    end
  end
end

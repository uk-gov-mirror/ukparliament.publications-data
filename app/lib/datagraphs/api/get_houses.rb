module Datagraphs
  module Api
    class GetHouses < CypherQuery
      QUERY = <<-Q
        MATCH (house:House)<-[r1:for]-(rs:ResearchService)
        RETURN house.id as id,
               house.name as name,
               house.shortName AS short_name,
               COLLECT_LIST(rs.id) AS research_service_ids,
               COLLECT_LIST(rs.name) AS research_service_names
        ORDER BY house.name
      Q

      def all
        Rails.logger.info("Calling get houses")
        params = { query: QUERY }
        response = call(params: params)
        Rails.logger.info("Called get houses")
        houses = process_response(response.body)
        houses.each do |house|
          house["research_services"] = house["research_service_ids"].zip(house["research_service_names"])
        end

        houses.map { |house| Hashie::Mash.new(house) }
      end
    end
  end
end

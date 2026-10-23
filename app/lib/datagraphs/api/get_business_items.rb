module Datagraphs
  module Api
    class GetBusinessItems < CypherQuery
      FOR_A_HOUSE_AND_YEAR = <<-Q.squish
      MATCH (businessItem:BusinessItem)-[r:businessItemInHouse]->(house:House)
      MATCH (businessItem:BusinessItem)-[r2:hasMeetingType]->(meetingType:MeetingType)
      WHERE house.id = '%{house_id}'
      AND businessItem.year = %{year}
      RETURN
        businessItem.onDate AS on_date,
        businessItem.ordinality AS ordinality,
        house.id AS house_id,
        house.name AS house_name,
        meetingType.id AS meeting_type_id,
        meetingType.label AS meeting_type_label
      Q

      COUNT_FOR_A_HOUSE_AND_A_YEAR = <<-Q.squish
        MATCH (c:Collection)<-[e:collectionPromotionOf]-(b:CollectionPromotion)-[r:collectionPromotionBy]->(rs:ResearchService)
        WHERE rs.id = '%{research_service_id}'
        RETURN COUNT(DISTINCT(c.id)) AS total
      Q

      YEARS_FOR_A_HOUSE = <<-Q.squish
        MATCH (businessItem:BusinessItem)-[r:businessItemInHouse]->(house:House)
        WHERE house.id = '%{house_id}'
        RETURN COLLECT_LIST(distinct(businessItem.year)) AS years
        ORDER BY years ASC
      Q

      WEEKS_FOR_A_HOUSE_AND_A_YEAR = <<-Q.squish
        MATCH (businessItem:BusinessItem)-[r:businessItemInHouse]->(house:House)
        WHERE house.id = '%{house_id}'
        AND businessItem.year = %{year}
        RETURN COLLECT_LIST(distinct(businessItem.weekNumber)) AS week_numbers
        ORDER BY week_numbers ASC
      Q

      FOR_A_HOUSE_AND_A_WEEK_AND_A_YEAR = <<-Q.squish
        MATCH (businessItem:BusinessItem)-[r:businessItemInHouse]->(house:House)
        MATCH (businessItem:BusinessItem)-[r2:hasMeetingType]->(meetingType:MeetingType)
        OPTIONAL MATCH (businessItem)<-[r3:pertainsTo]-(pw:PublicationWork)
        WHERE house.id = '%{house_id}'
        AND businessItem.year = %{year}
        AND businessItem.weekNumber = %{week_number}
        RETURN
          businessItem.onDate AS on_date,
          businessItem.ordinality AS ordinality,
          businessItem.label AS label,
          house.id AS house_id,
          house.name AS house_name,
          meetingType.id AS meeting_type_id,
          meetingType.label AS meeting_type_label,
          pw.id AS publication_work_id,
          pw.title AS publication_work_title
        ORDER BY on_date ASC, ordinality ASC
      Q

      def years_for_a_house(house_id:)
        params = { query: YEARS_FOR_A_HOUSE % { house_id: house_id } }
        response = call(params: params)
        body = process_response(response.body)
        body.first["years"]
      end

      def weeks_for_a_house_and_year(house_id: 'urn:publications-data:House:1', year: 2026)
        params = { query: WEEKS_FOR_A_HOUSE_AND_A_YEAR % { house_id: house_id, year: year } }
        response = call(params: params)
        body = process_response(response.body)
        body.first["week_numbers"]
      end

      def for_a_house_and_year(house_id: 'urn:publications-data:House:1', year: 2026)
        params = { query: FOR_A_HOUSE_AND_YEAR % { house_id: house_id, year: year } }
        response = call(params: params)
        body = process_response(response.body)

        body.map { |business_item| Hashie::Mash.new(business_item) }
      end

      def for(house_id: 'urn:publications-data:House:1', year: 2026, week_number: 43)
        params = { query: FOR_A_HOUSE_AND_A_WEEK_AND_A_YEAR % { house_id: house_id, year: year, week_number: week_number } }
        response = call(params: params)
        body = process_response(response.body)

        body.map { |business_item| Hashie::Mash.new(business_item) }
      end

      def count_for_a_house_and_year(house_id:)
        params = { query: COUNT_FOR_A_HOUSE_AND_YEAR % { house_id: house_id, year: year } }
        response = call(params: params)
        output = JSON.parse(response.body)

        output["results"].first["total"]
      end
    end
  end
end

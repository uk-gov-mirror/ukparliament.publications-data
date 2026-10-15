module Datagraphs
  module Api
    class GetDisclaimer < CypherQuery
      QUERY = <<-Q.squish
        MATCH (d:Disclaimer)<-[r:hasDisclaimer]-(a:DisclaimerApplicability)<-[s:hasDisclaimerApplicability]-(pw:PublicationWork)
        WHERE d.id = '%{disclaimer_id}'
        RETURN d.id AS id,
               d.label AS label,
               COUNT(DISTINCT pw.id) AS publication_work_count
      Q

      def details(disclaimer_id:)
        params = { query: QUERY % { disclaimer_id: disclaimer_id }}
        response = call(params: params)
        record = process_response(response.body).first

        Hashie::Mash.new(record)
      end
    end
  end
end

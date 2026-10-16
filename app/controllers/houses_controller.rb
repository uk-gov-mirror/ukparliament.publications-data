class HousesController < AuthenticatedController
  include Pagy::Method

  MAIN_PAGE_TITLE = 'Houses'

  def index
    @houses = process_houses

    @crumb << { label: MAIN_PAGE_TITLE, url: nil }
    @page_title = MAIN_PAGE_TITLE
  end

  def show
    redirect_to publications_house_path(params[:id])
  end

  def publications
    house_id = params[:id]

    @total_count =  Datagraphs::Api::GetPublications.new.for_a_house_count(house_id: house_id)
    @pagy, _ = pagy(:offset, [], count: @total_count, page: params[:page], limit: 25)

    @house = Datagraphs::Api::GetHouse.new.details(house_id)

    @publications = Datagraphs::Api::GetPublications.new.for_a_house(
      house_id: house_id,
      skip: @pagy.offset,
      limit: @pagy.limit
    )

    @page_title =  @house.name

    @crumb << { label: MAIN_PAGE_TITLE, url: houses_path }
    @crumb << { label: @house.name, url: house_path(house_id) }
    @crumb << { label: "Publications", url: nil }
  end

  def unpublished
    house_id = params[:id]

    @total_count = Datagraphs::Api::GetPublications.new.unpublished_for_a_house_count(house_id: house_id)
    @pagy, _ = pagy(:offset, [], count: @total_count, page: params[:page], limit: 25)

    @house = process_house(house_id)
    # @publications = process_publications(
    #   house_id: house_id,
    #   skip: @pagy.offset,
    #   limit: @pagy.limit
    # )

    publications = Datagraphs::Api::GetPublications.new.unpublished_for_a_house(house_id: house_id, skip: @pagy.offset, limit: @pagy.limit)
    @publications = publications.map { |publication| OpenStruct.new(publication) }

    @page_title =  @house.name

    @crumb << { label: MAIN_PAGE_TITLE, url: houses_path }
    @crumb << { label: @house.name, url: house_path(house_id) }
    @crumb << { label: "Publications", url: publications_house_path(house_id) }
    @crumb << { label: "Unpublished", url: nil }
  end

  private

  def process_houses
    houses = Datagraphs::Api::GetHouses.new.process

    houses.each do |house|
      house["research_services"] = house["research_service_ids"].zip(house["research_service_names"])
    end

    houses.map { |house| OpenStruct.new(house) }
  end

  def process_house(house_id)

  end

end

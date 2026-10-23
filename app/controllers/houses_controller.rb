class HousesController < AuthenticatedController
  include Pagy::Method

  MAIN_PAGE_TITLE = 'Houses'

  def index
    @houses = Datagraphs::Api::GetHouses.new.all

    @crumb << { label: MAIN_PAGE_TITLE, url: nil }
    @page_title = MAIN_PAGE_TITLE
  end

  def show
    redirect_to publications_house_path(params[:id])
  end

  def business_items
    house_id = params[:id]
    @house = Datagraphs::Api::GetHouse.new.details(house_id)

    @years = Datagraphs::Api::GetBusinessItems.new.years_for_a_house(house_id: house_id)

    @page_title =  @house.name

    @crumb << { label: MAIN_PAGE_TITLE, url: houses_path }
    @crumb << { label: @house.name, url: house_path(house_id) }
    @crumb << { label: "Business items", url: nil }
  end

  def business_item_weeks_for_a_year
    house_id = params[:id]
    year = params[:year]
    @house = Datagraphs::Api::GetHouse.new.details(house_id)

    @week_numbers = Datagraphs::Api::GetBusinessItems.new.weeks_for_a_house_and_year(house_id: house_id, year: year)

    @page_title =  @house.name

    @crumb << { label: MAIN_PAGE_TITLE, url: houses_path }
    @crumb << { label: @house.name, url: house_path(house_id) }
    @crumb << { label: "Business items", url: business_items_house_path(house_id: house_id) }
    @crumb << { label: year, url: nil }
  end

  def business_items_for_a_year
    house_id = params[:id]
    year = params[:year]
    @house = Datagraphs::Api::GetHouse.new.details(house_id)

    @week_numbers = Datagraphs::Api::GetBusinessItems.new.weeks_for_a_house_and_year(house_id: house_id, year: year)

    @page_title =  @house.name

    @crumb << { label: MAIN_PAGE_TITLE, url: houses_path }
    @crumb << { label: @house.name, url: house_path(house_id) }
    @crumb << { label: "Business items", url: business_items_house_path(house_id: house_id) }
    @crumb << { label: year, url: nil }
  end

  def research_services
    house_id = params[:id]
    @house = Datagraphs::Api::GetHouse.new.details(house_id)

    @page_title =  @house.name

    @crumb << { label: MAIN_PAGE_TITLE, url: houses_path }
    @crumb << { label: @house.name, url: house_path(house_id) }
    @crumb << { label: "Research services", url: nil }
  end

  def publications
    house_id = params[:id]

    get_publications = Datagraphs::Api::GetPublications.new

    @total_count =  get_publications.for_a_house_count(house_id: house_id)
    @pagy, _ = pagy(:offset, [], count: @total_count, page: params[:page], limit: 25)

    @house = Datagraphs::Api::GetHouse.new.details(house_id)

    @publications = get_publications.for_a_house(
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
end

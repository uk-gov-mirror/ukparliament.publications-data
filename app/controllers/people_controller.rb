class PeopleController < AuthenticatedController
  include Pagy::Method

  MAIN_PAGE_TITLE = 'People'

  def index
    @letter = params[:letter] || "A"
    get_people = Datagraphs::Api::GetPeople.new

    @letters = get_people.letters

    @total_count = get_people.total_count(letter: @letter)
    @pagy, _ = pagy(:offset, [], count: @total_count, page: params[:page], limit: 25)

    @people = get_people.all(skip: @pagy.offset, limit: @pagy.limit, letter: @letter)

    @crumb << { label: MAIN_PAGE_TITLE, url: nil }
    @page_title = MAIN_PAGE_TITLE
  end

  def show
    person_id = params[:id]
    @person = Datagraphs::Api::GetPerson.new.details(person_id: person_id)

    get_person_and_publications = Datagraphs::Api::GetPublicationDataForAPerson.new

    @total_count = get_person_and_publications.total_count_for(person_id: person_id)
    @pagy, _ = pagy(:offset, [], count: @total_count, page: params[:page], limit: 25)

    @publications = get_person_and_publications.all(person_id: person_id, skip: @pagy.offset, limit: @pagy.limit)

    @crumb << { label: MAIN_PAGE_TITLE, url: people_path }
    @crumb << { label: @person.name, url: nil }
    @page_title = @person.name
  end
end

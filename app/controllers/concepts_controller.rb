class ConceptsController < AuthenticatedController
  include Pagy::Method

  MAIN_PAGE_TITLE = 'Concepts'

  def index
    @letters = Datagraphs::Api::GetConcepts.new.get_letters.first["letters"].sort

    @letter = params[:letter] || "A"
    @total_count = Datagraphs::Api::GetConcepts.new.count_for(letter: @letter)
    @pagy, _ = pagy(:offset, [], count: @total_count, page: params[:page], limit: 99)

    @concepts = Datagraphs::Api::GetConcepts.new.all_for(
      letter: @letter,
      skip: @pagy.offset,
      limit: @pagy.limit
    )

    @crumb << { label: MAIN_PAGE_TITLE, url: nil }
    @page_title = MAIN_PAGE_TITLE
  end

  def show
    concept_id = params[:id]
    redirect_to publications_concept_path(concept_id)
  end

  def promoted
    @total_count = Datagraphs::Api::GetConcepts.new.count_for_promoted_by_no_one
    @pagy, _ = pagy(:offset, [], count: @total_count, page: params[:page], limit: 99)

    @concepts = Datagraphs::Api::GetConcepts.new.promoted_by_no_one(skip: @pagy.offset, limit: @pagy.limit)

    @crumb << { label: MAIN_PAGE_TITLE, url: concepts_path }
    @crumb << { label: "Promoted", url: nil }
    @page_title = "Promoted concepts"
  end

  def publications
    concept_id = params[:id]
    @concept = Datagraphs::Api::GetConcept.new.details_for(concept_id: concept_id)

    get_publications = Datagraphs::Api::GetPublications.new

    @total_count = get_publications.count_for_a_concept(concept_id: concept_id)
    @pagy, _ = pagy(:offset, [], count: @total_count, page: params[:page], limit: 25)

    @publications = get_publications.for_a_concept(
      concept_id: concept_id,
      skip: @pagy.offset,
      limit: @pagy.limit
    )

    @page_title =  @concept.label

    @crumb << { label: MAIN_PAGE_TITLE, url: concepts_path }
    @crumb << { label: @page_title, url: concept_path(concept_id) }
    @crumb << { label: "Publications", url: nil }
  end

  def broader_terms
    concept_id = params[:id]
    @concept = Datagraphs::Api::GetConcept.new.details_for(concept_id: concept_id)

    @broader_terms = Datagraphs::Api::GetConcept.new.and_broader_terms(concept_id: concept_id)
    @page_title = @concept.label

    @crumb << { label: MAIN_PAGE_TITLE, url: concepts_path }
    @crumb << { label: @concept.label, url: concept_path(concept_id) }
    @crumb << { label: "Broader terms", url: nil }
  end

  def narrower_terms
    concept_id = params[:id]
    @concept = Datagraphs::Api::GetConcept.new.details_for(concept_id: concept_id)

    @narrower_terms = Datagraphs::Api::GetConcept.new.and_narrower_terms(concept_id: concept_id)
    @page_title = @concept.label

    @crumb << { label: MAIN_PAGE_TITLE, url: concepts_path }
    @crumb << { label: @concept.label, url: concept_path(concept_id) }
    @crumb << { label: "Narrower subjects", url: nil }
  end
end

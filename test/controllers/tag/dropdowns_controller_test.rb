require "test_helper"

class Tag::DropdownsControllerTest < ActionDispatch::IntegrationTest
  include ActionView::RecordIdentifier

  setup do
    sign_in users(:family_admin)
    @entry = entries(:transaction)
    @entry.entryable.update!(tag_ids: [ tags(:one).id ])
    ensure_tailwind_build
  end

  test "lists the family's tags and marks applied ones" do
    get tag_dropdown_url(entry_id: @entry.id)

    assert_response :success
    assert_select "##{dom_id(@entry, :tag_option)}_#{tags(:one).id}[aria-selected=true]"
    assert_select "##{dom_id(@entry, :tag_option)}_#{tags(:two).id}[aria-selected=false]"
  end

  test "renders the search box as a DS::SearchInput combobox wired to the list filter" do
    get tag_dropdown_url(entry_id: @entry.id)

    placeholder = I18n.t("tag.dropdowns.show.search_placeholder")
    assert_select "input[type=search][role=combobox][aria-expanded=false][aria-autocomplete=list]" \
                  "[aria-label='#{placeholder}'][placeholder='#{placeholder}']" \
                  "[data-list-filter-target=input][data-action='list-filter#filter keydown->list-filter#handleKeydown']"
  end

  test "does not load another family's transaction" do
    other_entry = entries(:transaction)
    sign_in users(:empty)

    get tag_dropdown_url(entry_id: other_entry.id)

    assert_response :not_found
  end
end

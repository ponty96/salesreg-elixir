defmodule SalesRegWeb.Theme do
  use SalesRegWeb, :view

  def render_stars(count) do
    starred =
      Enum.map(0..count, fn _index ->
        raw("<span itemprop='ratingValue'><i class='fa fa-star srRatingIcon'></i> </span>")
      end)

    unstarred =
      Enum.map(count..5, fn _index ->
        raw("<span itemprop='ratingValue'><i class='fa fa-star srRatingEmpty'></i> </span>")
      end)

    Enum.concat(starred, unstarred)
  end

  def parse_review_name(text) do
    if String.length(text) > 20 do
      "#{String.slice(text, 0..20)} ..."
    else
      text
    end
  end

  defmodule Yc1View do
    use SalesRegWeb, :view

    defdelegate render_stars(count), to: SalesRegWeb.Theme
    defdelegate parse_review_name(text), to: SalesRegWeb.Theme
  end
end

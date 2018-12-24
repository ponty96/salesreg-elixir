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

  defmodule Yc1View do
    use SalesRegWeb, :view

    defdelegate render_stars(count), to: SalesRegWeb.Theme
  end
end

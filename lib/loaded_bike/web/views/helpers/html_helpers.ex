defmodule LoadedBike.Web.HtmlHelpers do

  use Phoenix.HTML

  def published_badge(true) do
    content_tag(:span, "Published", class: "badge badge-pill badge-success")
  end

  def published_badge(false) do
    content_tag(:span, "Draft", class: "badge badge-pill badge-light")
  end

  def markdown(nil), do: ""
  def markdown(body) do
    {_, html, _} = Earmark.as_html(body)
    HtmlSanitizeEx.markdown_html(html)
    |> raw
  end
end
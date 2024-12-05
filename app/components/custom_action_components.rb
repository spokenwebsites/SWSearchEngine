module CustomActionComponents
  class DownloadJsonComponent < Blacklight::Document::ActionComponent
    def render
      link_to "Download JSON", download_json_path(document), class: link_classes
    end
  end

  class DownloadTextComponent < Blacklight::Document::ActionComponent
    def render
      link_to "Download Text", download_text_path(document), class: link_classes
    end
  end
end

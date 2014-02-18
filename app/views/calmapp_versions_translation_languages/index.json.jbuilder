json.array!(@calmapp_versions_translation_languages) do |calmapp_versions_translation_language|
  json.extract! calmapp_versions_translation_language, :id, :translation_language_id, :calmapp_version_id
  json.url calmapp_versions_translation_language_url(calmapp_versions_translation_language, format: :json)
end

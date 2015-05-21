#DEPLOY
require "i18n/backend/pluralization"
#I18n::Backend::Simple.send(:include, I18n::Backend::Pluralization)

I18n::Backend::KeyValue.send(:include, I18n::Backend::Pluralization)
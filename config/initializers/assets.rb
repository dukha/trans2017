Rails.application.config.assets.version= '1.0'
Rails.application.config.assets.precompile += %w{*.png *.jpeg *.jpg *.gif *.ico}
Rails.application.config.assets.precompile += %w( translations.js )
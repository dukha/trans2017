class SubOrganisationValidator < ActiveModel::Validator
  def validate(aLocation)
    puts aLocation.name + aLocation.allow_organisation_ancestor?.to_s
    aLocation.errors[:parent] << "Sub organisations are not permitted" unless aLocation.allow_organisation_ancestor?
  end

end

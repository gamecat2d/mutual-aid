# frozen_string_literal: true

# BrowseFilter code currently makes a lot of assumptions about the model coming in
# I'm going to have to some lifting to make it accept other models
# but at least all these changes will be isolated to this class
class BrowseFilter
  FILTERS = {
    'ServiceArea' => ->(ids, scope) { scope.where(service_area: ids) },
    'ContactMethod' => ->(ids, scope) { scope.joins(:person).where(people: {preferred_contact_method: ids}) },
    'Category' => lambda do |ids, scope|
      scope.tagged_with(
        Category.roots.where(id: ids).pluck('name'),
        any: true
      )
    end,
    'UrgencyLevel' => lambda do |ids, scope|
      ids.length == UrgencyLevel::TYPES.length ? scope : scope.where(urgency_level_id: ids)
    end
  }.freeze

  ALLOWED_PARAMS = (['ContributionType'] + FILTERS.keys).each_with_object({}) { |key, hash|
    hash[key] = {}
  }.freeze
  ALLOWED_MODEL_NAMES = ['Ask', 'Offer'].freeze

  attr_reader :parameters

  def initialize(parameters)
    @parameters = parameters
  end

  def contributions
    @contributions ||= begin
      model_names = parameters.fetch('ContributionType', ALLOWED_MODEL_NAMES)
      models = ContributionType.where(name: model_names.intersection(ALLOWED_MODEL_NAMES)).map(&:model)
      models.map { |model| filter(model) }.flatten
    end
  end

  private

  def filter(model)
    parameters.keys.reduce(model.matchable) do |scope, key|
      filter = FILTERS.fetch(key, ->(_condition, s) { s })
      filter.call(parameters[key], scope)
    end
  end
end

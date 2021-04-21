# frozen_string_literal: true

class SubfilterTypeBlueprint < Blueprinter::Base
  identifier :id do |category, _options|
    "#{category.class}[#{category.id}]"
  end
  field :name
end

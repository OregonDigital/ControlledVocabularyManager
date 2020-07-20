# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Predicates roots' do
  it 'routes /predicates/bla/deprecate' do
    expect(get('/predicates/bla/deprecate')).to route_to('predicates#deprecate', id: 'bla')
  end

  it 'routes PATCH /predicates/bla/deprecate_only to the predicates controller' do
    expect(patch('/predicates/bla/deprecate_only')).to route_to('predicates#deprecate_only', id: 'bla')
  end

  it 'routes /predicates to predicates#index' do
    expect(get('/predicates')).to route_to('predicates#index')
  end
end

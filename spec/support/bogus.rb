require 'bogus/rspec'
Bogus.fakes do
  fake(:vocabulary) do
    id { "Creator" }
    persisted? false
  end
  fake(:term) do
    id { "bla" }
    persisted? true
  end
  fake(:callback, :class => proc{VocabulariesController::CreateResponder})
  fake(:term_callback, :class => proc{TermsController::CreateResponder})
end

# frozen_string_literal:true

Libhoney::LogTransmissionClient.class_eval do
  def add(event)
    if @verbose
      data = "Honeycomb dataset '#{event.dataset}' | #{event.timestamp.iso8601}"
      data << " (sample rate: #{event.sample_rate})" if event.sample_rate != 1
      @output.print("#{data} | ")
    end
    @output.puts(event.data.to_s.to_json)
  end
end

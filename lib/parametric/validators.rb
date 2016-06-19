module Parametric
  module Validators
    class Format
      attr_reader :message

      def initialize(fmt, msg = 'invalid format')
        @message = msg
        @fmt = fmt
      end

      def exists?(*args)
        true
      end

      def valid?(key, value, payload)
        value.to_s =~ @fmt
      end
    end
  end

  # Default validators
  Parametric.validator :format, Validators::Format
  Parametric.validator :email, Validators::Format.new(/\A[\w+\-.]+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+\z/i)
  Parametric.validator :required do
    message do |*|
      "is required"
    end

    validate do |value, key, payload|
      payload.key? key
    end
  end

  Parametric.validator :present do
    message do |*|
      "is required and value must be present"
    end

    validate do |value, key, payload|
      case value
      when String
        value.strip != ''
      when Array, Hash
        value.any?
      else
        !value.nil?
      end
    end
  end

  Parametric.validator :gt do
    message do |num, actual|
      "must be greater than #{num}, but got #{actual}"
    end

    validate do |num, actual|
      actual.to_i > num.to_i
    end
  end

  Parametric.validator :options do
    message do |options, actual|
      "must be one of #{options.join(', ')}, but got #{actual}"
    end

    exists do |options, actual, *_|
      ok? options, actual
    end

    validate do |options, actual|
      ok? options, actual
    end

    def ok?(options, actual)
      [actual].flatten.all?{|v| options.include?(v)}
    end
  end
end

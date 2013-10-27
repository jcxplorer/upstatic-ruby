module Upstatic

  # The +Options+ module can be mixed-in with any other class to provide some
  # nice helpers for adding options with default values.
  #
  # This is used internally in +Configuration+:
  #
  #   class Configuration
  #     include Options
  #     option :bucket
  #   end
  module Options

    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods

      # Allows the definition of options in a similar way to +attr_accessor+,
      # except that the same method acts as getter and setter, depending on
      # whether an argument is passed (setter) or not (getter).
      #
      # An optional hash can be passed as a second argument, to specify
      # additional options such as a default value using +:default+.
      def option(name, options={})
        define_method(name) do |*args|
          if args.size > 0
            instance_variable_set("@#{name}", args.first)
          else
            if instance_variable_defined?("@#{name}")
              instance_variable_get("@#{name}")
            elsif options.keys.include?(:default)
              options[:default]
            else
              nil
            end
          end
        end
      end

    end
  end
end
